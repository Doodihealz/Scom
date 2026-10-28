# Windows PowerShell 5.1. Existing settings and unrelated mods are preserved.
Set-StrictMode -Version 2.0
Add-Type -AssemblyName System.IO.Compression
if (-not ('ScomInstaller.NativeDirectory' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace ScomInstaller {
    public static class NativeDirectory {
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool CreateDirectory(string path, IntPtr securityAttributes);
    }
}
'@
}

function ConvertTo-ScomRelativePath {
    param([Parameter(Mandatory = $true)][string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path) -or [IO.Path]::IsPathRooted($Path)) {
        throw "Invalid relative path: '$Path'."
    }
    $parts = $Path.Replace('/', '\').Split('\')
    foreach ($part in $parts) {
        if ($part.Length -eq 0 -or $part.Length -gt 255 -or $part -in '.', '..' -or
            $part -match '[\x00-\x1f<>:"|?*]' -or $part -match '[ .]$' -or
            $part -match '^(?i:CON|PRN|AUX|NUL|COM[1-9\u00b9\u00b2\u00b3]|LPT[1-9\u00b9\u00b2\u00b3])(?:\.|$)') {
            throw "Unsafe Windows path: '$Path'."
        }
    }
    return ($parts -join '\')
}

function Get-ScomAttributes {
    param([string]$Path)
    try { return [IO.File]::GetAttributes($Path) }
    catch [IO.FileNotFoundException] { return $null }
    catch [IO.DirectoryNotFoundException] { return $null }
}

function Assert-ScomNoReparsePoint {
    param([Parameter(Mandatory = $true)][string]$Path)
    $full = [IO.Path]::GetFullPath($Path)
    $root = [IO.Path]::GetPathRoot($full)
    if ($root.StartsWith('\\')) { throw 'Network locations are not supported.' }
    $current = $root
    foreach ($part in $full.Substring($root.Length).Split('\', [StringSplitOptions]::RemoveEmptyEntries)) {
        $current = [IO.Path]::Combine($current, $part)
        $attributes = Get-ScomAttributes $current
        if ($null -ne $attributes -and ($attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Reparse points are not allowed: $current"
        }
    }
}

function Join-ScomSafePath {
    param([string]$Root, [string]$RelativePath)
    $relative = ConvertTo-ScomRelativePath $RelativePath
    $base = [IO.Path]::GetFullPath($Root).TrimEnd('\')
    $full = [IO.Path]::GetFullPath([IO.Path]::Combine($base, $relative))
    if (-not $full.StartsWith($base + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escapes its root: $RelativePath"
    }
    Assert-ScomNoReparsePoint $full
    return $full
}

function Get-ScomStreamHash {
    param([IO.Stream]$Stream)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($sha.ComputeHash($Stream)).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Get-ScomFileHash {
    param([string]$Path)
    Assert-ScomNoReparsePoint $Path
    $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
    try { return Get-ScomStreamHash $stream }
    finally { $stream.Dispose() }
}

function Get-ScomTreeFiles {
    param([string]$Root, [switch]$ExcludeRuntimeData)
    $pending = New-Object 'Collections.Generic.Stack[string]'
    $pending.Push($Root)
    while ($pending.Count -gt 0) {
        $directory = $pending.Pop()
        Assert-ScomNoReparsePoint $directory
        foreach ($path in [IO.Directory]::EnumerateFileSystemEntries($directory)) {
            $name = [IO.Path]::GetFileName($path)
            if ($ExcludeRuntimeData -and ($name -match '^(?i:logs?|caches?|temp|tmp)$' -or $name -match '(?i)\.(log|tmp)$')) { continue }
            $attributes = Get-ScomAttributes $path
            if ($attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Reparse point in source: $path" }
            if ($attributes -band [IO.FileAttributes]::Directory) { $pending.Push($path) }
            else { $path }
        }
    }
}

function Read-ScomPackage {
    param([Parameter(Mandatory = $true)][string]$PackageRoot)
    $root = [IO.Path]::GetFullPath($PackageRoot).TrimEnd('\')
    Assert-ScomNoReparsePoint $root
    $manifestPath = Join-ScomSafePath $root 'manifest.json'
    if ((New-Object IO.FileInfo $manifestPath).Length -gt 16777216) { throw 'Manifest is too large.' }
    $manifest = [IO.File]::ReadAllText($manifestPath) | ConvertFrom-Json
    if ($manifest.schemaVersion -ne 1 -or $manifest.basegameTrebuchetSHA -notmatch '^[0-9a-fA-F]{64}$') {
        throw 'Unsupported manifest or invalid base-game SHA256.'
    }
    $payloadRoot = Join-ScomSafePath $root 'payload'
    if (-not [IO.Directory]::Exists($payloadRoot)) { throw 'Package payload folder is missing.' }
    $files = New-Object 'Collections.Generic.List[object]'
    $filePaths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $allPaths = New-Object 'Collections.Generic.Dictionary[string,string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in @($manifest.files)) {
        $relative = ConvertTo-ScomRelativePath $entry.path
        if (-not $filePaths.Add($relative)) { throw "Duplicate package path: $relative" }
        if ($entry.sha256 -notmatch '^[0-9a-fA-F]{64}$' -or $entry.bytes -is [string] -or
            [decimal]$entry.bytes -lt 0 -or [decimal]$entry.bytes -ne [math]::Truncate([decimal]$entry.bytes)) {
            throw "Invalid file metadata: $relative"
        }
        $prefix = ''
        foreach ($part in $relative.Split('\')) {
            $prefix = if ($prefix) { $prefix + '\' + $part } else { $part }
            if ($allPaths.ContainsKey($prefix) -and $allPaths[$prefix] -cne $prefix) { throw "Case collision in manifest: $prefix" }
            $allPaths[$prefix] = $prefix
        }
        $source = Join-ScomSafePath $payloadRoot $relative
        $info = New-Object IO.FileInfo $source
        if (-not $info.Exists -or $info.Length -ne [long]$entry.bytes -or (Get-ScomFileHash $source) -ne $entry.sha256) {
            throw "Package file failed SHA256/length validation: $relative"
        }
        $replaceFrom = @()
        if ($entry.PSObject.Properties['replaceFromSha256']) {
            if (($entry.replaceFromSha256 -isnot [string] -and $entry.replaceFromSha256 -isnot [array]) -or
                ($relative -notmatch '^SanctuaryMods\\SCOM\\(?:lua|units)\\.+\.lua$' -and
                 $relative -notmatch '^LJ\\lua\\AI\\mods\\AI-Scom\\.+\.(?:lua|txt)$' -and
                 $relative -cne 'SanctuaryMods\SCOM\packs\scom.sanpack' -and
                 $relative -cne 'SanctuaryMods\SCOM\lua\source-manifest.tsv')) {
                throw "Invalid source upgrade preimage: $relative"
            }
            $preimages = @($entry.replaceFromSha256)
            if ($preimages.Count -eq 0 -or $preimages.Count -gt 16) { throw "Invalid source upgrade preimage: $relative" }
            foreach ($preimage in $preimages) {
                if ($preimage -isnot [string] -or $preimage -notmatch '^[0-9a-fA-F]{64}$' -or $replaceFrom -contains $preimage) {
                    throw "Invalid source upgrade preimage: $relative"
                }
                $replaceFrom += $preimage.ToLowerInvariant()
            }
        }
        $files.Add([pscustomobject]@{ Path = $relative; Bytes = [long]$entry.bytes; SHA256 = $entry.sha256.ToLowerInvariant(); Source = $source; ReplaceFromSHA256 = $replaceFrom })
    }
    if ($files.Count -eq 0) { throw 'Package contains no files.' }
    foreach ($relative in $filePaths) {
        $parent = [IO.Path]::GetDirectoryName($relative)
        while ($parent) {
            if ($filePaths.Contains($parent)) { throw "File/directory collision: $parent" }
            $parent = [IO.Path]::GetDirectoryName($parent)
        }
    }
    $obsoleteFiles = New-Object 'Collections.Generic.List[object]'
    $obsoletePaths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    if ($manifest.PSObject.Properties['obsoleteFiles']) {
        if ($manifest.obsoleteFiles -isnot [array]) { throw 'Invalid obsolete file list.' }
        foreach ($entry in $manifest.obsoleteFiles) {
            $relative = ConvertTo-ScomRelativePath $entry.path
            if ($relative -notmatch '^LJ\\lua\\AI\\mods\\AI-Scom\\.+\.(?:lua|txt)$' -or
                -not $obsoletePaths.Add($relative) -or $filePaths.Contains($relative) -or $allPaths.ContainsKey($relative)) {
                throw "Invalid or duplicate obsolete file path: $relative"
            }
            if ($entry.sha256 -isnot [string] -or $entry.sha256 -notmatch '^[0-9a-fA-F]{64}$' -or
                ($entry.bytes -isnot [int] -and $entry.bytes -isnot [long]) -or $entry.bytes -lt 0) {
                throw "Invalid obsolete file metadata: $relative"
            }
            $prefix = ''
            foreach ($part in $relative.Split('\')) {
                $prefix = if ($prefix) { $prefix + '\' + $part } else { $part }
                if ($allPaths.ContainsKey($prefix) -and $allPaths[$prefix] -cne $prefix) { throw "Case collision in manifest: $prefix" }
                $allPaths[$prefix] = $prefix
            }
            $obsoleteFiles.Add([pscustomobject]@{ Path = $relative; Bytes = [long]$entry.bytes; SHA256 = $entry.sha256.ToLowerInvariant() })
        }
        foreach ($relative in $obsoletePaths) {
            $parent = [IO.Path]::GetDirectoryName($relative)
            while ($parent) {
                if ($filePaths.Contains($parent) -or $obsoletePaths.Contains($parent)) { throw "File/directory collision: $parent" }
                $parent = [IO.Path]::GetDirectoryName($parent)
            }
        }
    }
    $actualPaths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($source in @(Get-ScomTreeFiles $payloadRoot)) {
        $relative = $source.Substring($payloadRoot.Length + 1)
        if (-not $actualPaths.Add($relative)) { throw "Case collision in payload: $relative" }
        if (-not $filePaths.Contains($relative)) { throw "Unlisted payload file: $relative" }
    }
    return [pscustomobject]@{ Root = $root; PayloadRoot = $payloadRoot; Manifest = $manifest; Files = $files.ToArray(); ObsoleteFiles = $obsoleteFiles.ToArray() }
}

function Assert-ScomEngine {
    param([object]$Package, [string]$EngineRoot)
    $root = [IO.Path]::GetFullPath($EngineRoot).TrimEnd('\')
    Assert-ScomNoReparsePoint $root
    $exe = Join-ScomSafePath $root 'Sanctuary.exe'
    if (-not [IO.File]::Exists($exe)) { throw 'Select the engine folder containing Sanctuary.exe.' }
    $nativeRelative = if ($Package.Manifest.PSObject.Properties['basegameTrebuchetPath']) { $Package.Manifest.basegameTrebuchetPath } else { 'Sanctuary_Data\Managed\Trebuchet.dll' }
    $native = Join-ScomSafePath $root $nativeRelative
    if (-not [IO.File]::Exists($native) -or (Get-ScomFileHash $native) -ne $Package.Manifest.basegameTrebuchetSHA) {
        throw "This game build is unsupported: native Trebuchet SHA256 does not match."
    }
    return $root
}

function Get-ScomExistingBepInExVersion {
    param([object]$Package, [string]$EngineRoot)
    foreach ($marker in @('BepInEx\core\BepInEx.Core.dll', 'BepInEx\core\BepInEx.Unity.Mono.dll', 'BepInEx\core\BepInEx.Unity.IL2CPP.dll')) {
        if (Get-ScomAttributes (Join-ScomSafePath $EngineRoot $marker)) { throw 'Existing BepInEx 6 is incompatible with this BepInEx 5 package. Nothing installed.' }
    }
    $corePath = Join-ScomSafePath $EngineRoot 'BepInEx\core\BepInEx.dll'
    if (-not [IO.File]::Exists($corePath)) { return $null }
    $installed = [Reflection.AssemblyName]::GetAssemblyName($corePath)
    $bundledCore = @($Package.Files | Where-Object { $_.Path -eq 'BepInEx\core\BepInEx.dll' })
    if ($bundledCore.Count -ne 1) { throw 'Package BepInEx core is missing.' }
    $bundled = [Reflection.AssemblyName]::GetAssemblyName($bundledCore[0].Source)
    if ($installed.Name -ne 'BepInEx' -or $installed.Version.Major -ne 5 -or $installed.Version.Minor -ne 4 -or $installed.Version -gt $bundled.Version) {
        throw "Existing BepInEx $($installed.Version) cannot be upgraded safely by this BepInEx $($bundled.Version) package. Nothing installed."
    }
    $preloaderPath = Join-ScomSafePath $EngineRoot 'BepInEx\core\BepInEx.Preloader.dll'
    if ([IO.File]::Exists($preloaderPath)) {
        $preloader = [Reflection.AssemblyName]::GetAssemblyName($preloaderPath)
        if ($preloader.Name -ne 'BepInEx.Preloader' -or $preloader.Version -ne $installed.Version) { throw 'Existing BepInEx core and preloader versions differ. Nothing installed.' }
    }
    foreach ($file in $Package.Files | Where-Object { $_.Path -match '^BepInEx\\core\\[^\\]+\.dll$' }) {
        $existingPath = Join-ScomSafePath $EngineRoot $file.Path
        if (-not [IO.File]::Exists($existingPath)) { continue }
        $existingAssembly = [Reflection.AssemblyName]::GetAssemblyName($existingPath)
        $bundledAssembly = [Reflection.AssemblyName]::GetAssemblyName($file.Source)
        if ($existingAssembly.Name -ne $bundledAssembly.Name -or $existingAssembly.Version -gt $bundledAssembly.Version) {
            throw "Existing runtime dependency cannot be downgraded or replaced safely: $($file.Path). Nothing installed."
        }
    }
    $doorstopPath = Join-ScomSafePath $EngineRoot 'doorstop_config.ini'
    if (-not [IO.File]::Exists((Join-ScomSafePath $EngineRoot 'winhttp.dll')) -or -not [IO.File]::Exists($doorstopPath)) {
        throw 'Existing BepInEx bootstrap is incomplete: winhttp.dll and doorstop_config.ini are required. Nothing installed.'
    }
    $doorstopSettings = @{}
    $supportedSection = $false
    $sectionCount = 0
    foreach ($line in [IO.File]::ReadAllLines($doorstopPath)) {
        if ($line -match '^\s*\[([^\]]+)\]\s*$') {
            $supportedSection = $Matches[1] -in @('General', 'UnityDoorstop')
            if ($supportedSection) { $sectionCount++ }
            continue
        }
        if ($supportedSection -and $line -match '^\s*([^=;#]+?)\s*=\s*(.*?)\s*$') {
            $key = $Matches[1].Replace('_', '').ToLowerInvariant()
            $value = $Matches[2]
            if ($key -notin @('enabled', 'targetassembly')) { continue }
            if ($doorstopSettings.ContainsKey($key)) { throw 'Existing Doorstop has duplicate bootstrap settings. Nothing installed.' }
            $doorstopSettings[$key] = $value
        }
    }
    if ($sectionCount -ne 1 -or $doorstopSettings['enabled'] -ne 'true' -or
        $doorstopSettings['targetassembly'] -notmatch '^BepInEx[\\/]core[\\/]BepInEx\.Preloader\.dll$') {
        throw 'Existing Doorstop must be enabled and target BepInEx\core\BepInEx.Preloader.dll. Nothing installed.'
    }
    return $installed.Version
}

function Test-ScomReplaceableFile {
    param([string]$Path)
    return ($Path -match '^BepInEx\\core\\[^\\]+\.(dll|xml)$' -or $Path -in @(
        'BepInEx\plugins\ModLoader.dll', 'BepInEx\plugins\SupComStyleUI\SupComStyleUI.dll', 'BepInEx\patchers\SanctuaryPatcherHost.dll',
        'SanctuaryMods\SCOM\Scom-patcher.dll', 'SanctuaryMods\SCOM\lua\source-manifest.tsv'))
}

function Get-ScomInstallPlan {
    param([Parameter(Mandatory = $true)][object]$Package, [Parameter(Mandatory = $true)][string]$EngineRoot)
    $root = Assert-ScomEngine $Package $EngineRoot
    $create = New-Object 'Collections.Generic.List[object]'
    $skip = New-Object 'Collections.Generic.List[object]'
    $preserve = New-Object 'Collections.Generic.List[object]'
    $replace = New-Object 'Collections.Generic.List[object]'
    $remove = New-Object 'Collections.Generic.List[object]'
    $conflicts = New-Object 'Collections.Generic.List[string]'
    $bepInExVersion = Get-ScomExistingBepInExVersion $Package $root
    $expectedPaths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($file in $Package.Files) {
        $null = $expectedPaths.Add($file.Path)
        $destination = Join-ScomSafePath $root $file.Path
        $record = [pscustomobject]@{ Path = $file.Path; Destination = $destination; Source = $file.Source; Bytes = $file.Bytes; SHA256 = $file.SHA256 }
        $parent = [IO.Path]::GetDirectoryName($destination)
        while ($parent.Length -gt $root.Length) {
            $attributes = Get-ScomAttributes $parent
            if ($null -ne $attributes -and -not ($attributes -band [IO.FileAttributes]::Directory)) {
                $conflicts.Add("File blocks required directory: $parent")
                break
            }
            $parent = [IO.Path]::GetDirectoryName($parent)
        }
        $attributes = Get-ScomAttributes $destination
        $reuseBootstrap = $null -ne $bepInExVersion -and $file.Path -in @('.doorstop_version', 'doorstop_config.ini', 'winhttp.dll')
        # The version marker is optional; never label an existing proxy with the bundled Doorstop version.
        if ($reuseBootstrap -and $null -eq $attributes) { continue }
        if ($null -eq $attributes) { $create.Add($record); continue }
        if ($attributes -band [IO.FileAttributes]::Directory) {
            $conflicts.Add("Existing content differs: $($file.Path)")
            continue
        }
        if ($reuseBootstrap -or $file.Path -match '^BepInEx\\config\\') { $preserve.Add($record); continue }
        $existingBytes = (New-Object IO.FileInfo $destination).Length
        $existingHash = Get-ScomFileHash $destination
        if ($existingBytes -eq $file.Bytes -and $existingHash -eq $file.SHA256) { $skip.Add($record); continue }
        $pinnedSourceUpdate = $file.PSObject.Properties['ReplaceFromSHA256'] -and ($file.ReplaceFromSHA256 -contains $existingHash)
        if ($pinnedSourceUpdate -or ((Test-ScomReplaceableFile $file.Path) -and ($file.Path -notmatch '^BepInEx\\core\\' -or $null -ne $bepInExVersion))) {
            $record | Add-Member NoteProperty OriginalSHA256 $existingHash
            $record | Add-Member NoteProperty OriginalBytes $existingBytes
            $replace.Add($record)
        }
        else { $conflicts.Add("Existing content differs: $($file.Path)") }
    }
    foreach ($file in $Package.ObsoleteFiles) {
        $null = $expectedPaths.Add($file.Path)
        $destination = Join-ScomSafePath $root $file.Path
        $attributes = Get-ScomAttributes $destination
        if ($null -eq $attributes) { continue }
        if (($attributes -band [IO.FileAttributes]::Directory) -or
            (New-Object IO.FileInfo $destination).Length -ne $file.Bytes -or (Get-ScomFileHash $destination) -ne $file.SHA256) {
            $conflicts.Add("Obsolete file differs: $($file.Path)")
            continue
        }
        $remove.Add([pscustomobject]@{ Path = $file.Path; Destination = $destination; Bytes = $file.Bytes; SHA256 = $file.SHA256 })
    }
    if ($Package.Manifest.PSObject.Properties['ownedRoots']) {
        $allowedRoots = @('SanctuaryMods\SCOM', 'LJ\lua\AI\mods\AI-Scom', 'BepInEx\plugins\SupComStyleUI', 'BepInEx\plugins\SCOMTreeDecay', 'BepInEx\plugins\SCOMLandMotion')
        foreach ($ownedRoot in @($Package.Manifest.ownedRoots)) {
            $relativeRoot = ConvertTo-ScomRelativePath $ownedRoot
            if ($relativeRoot -notin $allowedRoots) { throw "Unsupported owned mod root: $relativeRoot" }
            $directory = Join-ScomSafePath $root $relativeRoot
            $attributes = Get-ScomAttributes $directory
            if ($null -eq $attributes) { continue }
            if (-not ($attributes -band [IO.FileAttributes]::Directory)) {
                $conflicts.Add("File blocks owned mod directory: $relativeRoot")
                continue
            }
            foreach ($existingFile in @(Get-ScomTreeFiles $directory)) {
                $relative = $existingFile.Substring($root.Length + 1)
                if (-not $expectedPaths.Contains($relative)) { $conflicts.Add("Unlisted file in owned mod directory: $relative") }
            }
        }
    }
    return [pscustomobject]@{ EngineRoot = $root; Create = $create.ToArray(); Replace = $replace.ToArray(); Remove = $remove.ToArray(); Skip = $skip.ToArray(); Preserve = $preserve.ToArray(); BepInExVersion = $bepInExVersion; Conflicts = $conflicts.ToArray() }
}

function Copy-ScomStream {
    param([IO.Stream]$Source, [IO.Stream]$Destination)
    $Source.CopyTo($Destination, 1048576)
}

function New-ScomDirectories {
    param([string]$EngineRoot, [string]$Directory, [Collections.Generic.List[string]]$CreatedDirectories)
    $missing = New-Object 'Collections.Generic.Stack[string]'
    $current = $Directory
    while ($current.Length -gt $EngineRoot.Length) {
        Assert-ScomNoReparsePoint $current
        $attributes = Get-ScomAttributes $current
        if ($null -ne $attributes) {
            if (-not ($attributes -band [IO.FileAttributes]::Directory)) { throw "Directory blocked by file: $current" }
            break
        }
        $missing.Push($current)
        $current = [IO.Path]::GetDirectoryName($current)
    }
    while ($missing.Count -gt 0) {
        $current = $missing.Pop()
        Assert-ScomNoReparsePoint $current
        if ([ScomInstaller.NativeDirectory]::CreateDirectory($current, [IntPtr]::Zero)) { $CreatedDirectories.Add($current) }
        else {
            $errorCode = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if ($errorCode -ne 183) { throw (New-Object ComponentModel.Win32Exception $errorCode) }
            Assert-ScomNoReparsePoint $current
            if (-not [IO.Directory]::Exists($current)) { throw "Directory creation conflict: $current" }
        }
    }
}

function Invoke-ScomInstall {
    param([Parameter(Mandatory = $true)][object]$Package, [Parameter(Mandatory = $true)][string]$EngineRoot)
    # Revalidate immediately before the first destination write, even after a UI preview.
    $verified = Read-ScomPackage $Package.Root
    $plan = Get-ScomInstallPlan $verified $EngineRoot
    if ($plan.Conflicts.Count -gt 0) { throw ('Nothing installed. Conflicts:' + [Environment]::NewLine + ($plan.Conflicts -join [Environment]::NewLine)) }
    $createdFiles = New-Object 'Collections.Generic.List[object]'
    $createdDirectories = New-Object 'Collections.Generic.List[string]'
    $replacedFiles = New-Object 'Collections.Generic.List[object]'
    $removedFiles = New-Object 'Collections.Generic.List[object]'
    $stagedFiles = New-Object 'Collections.Generic.List[string]'
    try {
        foreach ($file in $plan.Remove) {
            $backup = $file.Destination + '.scom-removed-' + [guid]::NewGuid().ToString('N')
            Assert-ScomNoReparsePoint $backup
            Assert-ScomNoReparsePoint $file.Destination
            if ((New-Object IO.FileInfo $file.Destination).Length -ne $file.Bytes -or (Get-ScomFileHash $file.Destination) -ne $file.SHA256) {
                throw "Obsolete file changed before removal: $($file.Path)"
            }
            [IO.File]::Move($file.Destination, $backup)
            $removedFiles.Add([pscustomobject]@{ Path = $file.Destination; Backup = $backup; Bytes = $file.Bytes; SHA256 = $file.SHA256 })
            if ((New-Object IO.FileInfo $backup).Length -ne $file.Bytes -or (Get-ScomFileHash $backup) -ne $file.SHA256) {
                throw "Removed file failed verification: $($file.Path)"
            }
        }
        foreach ($file in $plan.Replace) {
            $stage = $file.Destination + '.scom-stage-' + [guid]::NewGuid().ToString('N')
            $backup = $file.Destination + '.scom-original-' + [guid]::NewGuid().ToString('N')
            $stagedFiles.Add($stage)
            $source = [IO.File]::Open($file.Source, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
            $target = $null
            try {
                $target = [IO.File]::Open($stage, [IO.FileMode]::CreateNew, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
                Copy-ScomStream $source $target
                $target.Flush()
                $target.Position = 0
                if ($target.Length -ne $file.Bytes -or (Get-ScomStreamHash $target) -ne $file.SHA256) { throw "Staged file failed verification: $($file.Path)" }
            }
            finally {
                if ($null -ne $target) { $target.Dispose() }
                $source.Dispose()
            }
            Assert-ScomNoReparsePoint $file.Destination
            if ((New-Object IO.FileInfo $file.Destination).Length -ne $file.OriginalBytes -or (Get-ScomFileHash $file.Destination) -ne $file.OriginalSHA256) {
                throw "Existing file changed before update: $($file.Path)"
            }
            $updated = [pscustomobject]@{ Path = $file.Destination; Backup = $backup; SHA256 = $file.SHA256; OriginalSHA256 = $null }
            $replacedFiles.Add($updated)
            [IO.File]::Replace($stage, $file.Destination, $backup)
            $updated.OriginalSHA256 = Get-ScomFileHash $backup
            if ($updated.OriginalSHA256 -ne $file.OriginalSHA256 -or (Get-ScomFileHash $file.Destination) -ne $file.SHA256) {
                throw "Updated file failed verification: $($file.Path)"
            }
        }
        foreach ($file in $plan.Create) {
            New-ScomDirectories $plan.EngineRoot ([IO.Path]::GetDirectoryName($file.Destination)) $createdDirectories
            Assert-ScomNoReparsePoint $file.Destination
            $source = [IO.File]::Open($file.Source, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
            $destination = $null
            $created = $null
            try {
                $destination = [IO.File]::Open($file.Destination, [IO.FileMode]::CreateNew, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
                $created = [pscustomobject]@{ Path = $file.Destination; SHA256 = $null }
                $createdFiles.Add($created)
                try { Copy-ScomStream $source $destination }
                finally {
                    $destination.Flush()
                    $destination.Position = 0
                    $created.SHA256 = Get-ScomStreamHash $destination
                }
                if ($destination.Length -ne $file.Bytes -or $created.SHA256 -ne $file.SHA256) { throw "Copied file failed verification: $($file.Path)" }
            }
            finally {
                if ($null -ne $destination) { $destination.Dispose() }
                $source.Dispose()
            }
        }
    }
    catch {
        $failure = $_.Exception.Message
        $retained = New-Object 'Collections.Generic.List[string]'
        for ($i = $replacedFiles.Count - 1; $i -ge 0; $i--) {
            $updated = $replacedFiles[$i]
            try {
                if (-not [IO.File]::Exists($updated.Backup)) { continue }
                Assert-ScomNoReparsePoint $updated.Path
                if ($updated.OriginalSHA256 -and (Get-ScomFileHash $updated.Path) -eq $updated.SHA256 -and (Get-ScomFileHash $updated.Backup) -eq $updated.OriginalSHA256) {
                    $discard = $updated.Path + '.scom-stage-' + [guid]::NewGuid().ToString('N')
                    $stagedFiles.Add($discard)
                    [IO.File]::Replace($updated.Backup, $updated.Path, $discard)
                    if ((Get-ScomFileHash $updated.Path) -ne $updated.OriginalSHA256) { throw 'Restored original failed verification.' }
                }
                else { $retained.Add($updated.Backup) }
            }
            catch { $retained.Add($updated.Backup) }
        }
        for ($i = $createdFiles.Count - 1; $i -ge 0; $i--) {
            $created = $createdFiles[$i]
            try {
                Assert-ScomNoReparsePoint $created.Path
                if ($created.SHA256 -and (Get-ScomFileHash $created.Path) -eq $created.SHA256) { [IO.File]::Delete($created.Path) }
                else { $retained.Add($created.Path) }
            }
            catch { $retained.Add($created.Path) }
        }
        for ($i = $removedFiles.Count - 1; $i -ge 0; $i--) {
            $removed = $removedFiles[$i]
            try {
                Assert-ScomNoReparsePoint $removed.Path
                Assert-ScomNoReparsePoint $removed.Backup
                if ($null -eq (Get-ScomAttributes $removed.Path) -and
                    (New-Object IO.FileInfo $removed.Backup).Length -eq $removed.Bytes -and (Get-ScomFileHash $removed.Backup) -eq $removed.SHA256) {
                    [IO.File]::Move($removed.Backup, $removed.Path)
                    if ((Get-ScomFileHash $removed.Path) -ne $removed.SHA256) { throw 'Restored obsolete file failed verification.' }
                }
                else { $retained.Add($removed.Backup) }
            }
            catch { $retained.Add($removed.Backup) }
        }
        for ($i = $createdDirectories.Count - 1; $i -ge 0; $i--) {
            $directory = $createdDirectories[$i]
            try {
                Assert-ScomNoReparsePoint $directory
                if (@([IO.Directory]::EnumerateFileSystemEntries($directory)).Count -eq 0) { [IO.Directory]::Delete($directory, $false) }
            }
            catch { $retained.Add($directory) }
        }
        if ($retained.Count) { $failure += "`r`nRollback preserved changed or inaccessible paths: " + ($retained -join ', ') }
        throw $failure
    }
    finally {
        foreach ($stage in $stagedFiles) {
            try { Assert-ScomNoReparsePoint $stage; [IO.File]::Delete($stage) }
            catch { Write-Warning "Temporary update file could not be removed: $stage" }
        }
    }
    # Commit only after all additions, updates and removals have verified. Optional user backups remain separate.
    foreach ($updated in $replacedFiles) {
        try {
            if ((Get-ScomFileHash $updated.Path) -ne $updated.SHA256) { throw 'Updated destination changed.' }
            if ((Get-ScomFileHash $updated.Backup) -ne $updated.OriginalSHA256) { throw 'Original snapshot changed.' }
            [IO.File]::Delete($updated.Backup)
        }
        catch { Write-Warning "Installation succeeded; original snapshot retained: $($updated.Backup)" }
    }
    foreach ($removed in $removedFiles) {
        try {
            Assert-ScomNoReparsePoint $removed.Path
            Assert-ScomNoReparsePoint $removed.Backup
            if ($null -ne (Get-ScomAttributes $removed.Path)) { throw 'Removed destination reappeared.' }
            if ((New-Object IO.FileInfo $removed.Backup).Length -ne $removed.Bytes -or (Get-ScomFileHash $removed.Backup) -ne $removed.SHA256) { throw 'Removed snapshot changed.' }
            [IO.File]::Delete($removed.Backup)
        }
        catch { Write-Warning "Installation succeeded; removed file snapshot retained: $($removed.Backup)" }
    }
    return [pscustomobject]@{ Installed = $createdFiles.Count; Updated = $replacedFiles.Count; Removed = $removedFiles.Count; Skipped = $plan.Skip.Count; Preserved = $plan.Preserve.Count; EngineRoot = $plan.EngineRoot }
}

function Get-ScomBackupFiles {
    param([object]$Package, [string]$EngineRoot, [string]$UserModsRoot)
    $root = Assert-ScomEngine $Package $EngineRoot
    $seen = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $backupRoots = if ($Package.Manifest.PSObject.Properties['backupRoots']) { @($Package.Manifest.backupRoots) } else { @() }
    foreach ($relativeRoot in $backupRoots) {
        $relative = ConvertTo-ScomRelativePath $relativeRoot
        if ($relative -notmatch '^(?i:SanctuaryMods|Mods|BepInEx\\(?:core|plugins|patchers|config)|LJ\\lua\\AI\\Mods)(?:\\|$)') {
            throw "Backup root is outside the supported mod folders: $relative"
        }
        $directory = Join-ScomSafePath $root $relative
        if (-not [IO.Directory]::Exists($directory)) { continue }
        foreach ($path in @(Get-ScomTreeFiles $directory -ExcludeRuntimeData)) {
            $name = $path.Substring($root.Length + 1).Replace('\', '/')
            if ($seen.Add($name)) {
                [pscustomobject]@{ Path = $path; Name = $name; Bytes = (New-Object IO.FileInfo $path).Length; SHA256 = Get-ScomFileHash $path }
            }
        }
    }
    $backupFiles = if ($Package.Manifest.PSObject.Properties['backupFiles']) { @($Package.Manifest.backupFiles) } else { @() }
    foreach ($relativeFile in $backupFiles) {
        $relative = ConvertTo-ScomRelativePath $relativeFile
        if ($relative -notin @('winhttp.dll', 'doorstop_config.ini', '.doorstop_version')) {
            throw "Backup file is outside the supported mod bootstrap files: $relative"
        }
        $path = Join-ScomSafePath $root $relative
        $attributes = Get-ScomAttributes $path
        if ($null -eq $attributes) { continue }
        if ($attributes -band [IO.FileAttributes]::Directory) { throw "Backup file is a directory: $relative" }
        if ($seen.Add($relative)) {
            [pscustomobject]@{ Path = $path; Name = $relative; Bytes = (New-Object IO.FileInfo $path).Length; SHA256 = Get-ScomFileHash $path }
        }
    }
    if ($UserModsRoot) {
        $userRoot = [IO.Path]::GetFullPath($UserModsRoot).TrimEnd('\')
        Assert-ScomNoReparsePoint $userRoot
        if ([IO.Directory]::Exists($userRoot)) {
            foreach ($path in @(Get-ScomTreeFiles $userRoot -ExcludeRuntimeData)) {
                $name = 'UserMods/' + $path.Substring($userRoot.Length + 1).Replace('\', '/')
                [pscustomobject]@{ Path = $path; Name = $name; Bytes = (New-Object IO.FileInfo $path).Length; SHA256 = Get-ScomFileHash $path }
            }
        }
    }
}

function Assert-ScomBackupMatches {
    param([string]$BackupPath, [object[]]$Files)
    Assert-ScomNoReparsePoint $BackupPath
    $expected = @{}
    foreach ($file in $Files) { $expected[$file.Name] = $file }
    $stream = [IO.File]::Open($BackupPath, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
    $archive = $null
    try {
        $archive = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Read, $true)
        if ($archive.Entries.Count -ne $Files.Count) { throw 'Canonical backup has different contents.' }
        $seen = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
        foreach ($entry in $archive.Entries) {
            $null = ConvertTo-ScomRelativePath $entry.FullName
            if (-not $seen.Add($entry.FullName) -or -not $expected.ContainsKey($entry.FullName)) { throw 'Canonical backup contains unexpected entries.' }
            $file = $expected[$entry.FullName]
            $entryStream = $entry.Open()
            try {
                if ($entry.Length -ne $file.Bytes -or (Get-ScomStreamHash $entryStream) -ne $file.SHA256) { throw "Canonical backup differs: $($entry.FullName)" }
            }
            finally { $entryStream.Dispose() }
        }
    }
    finally {
        if ($null -ne $archive) { $archive.Dispose() }
        $stream.Dispose()
    }
}

function New-ScomBackup {
    param([Parameter(Mandatory = $true)][object]$Package, [Parameter(Mandatory = $true)][string]$EngineRoot,
        [Parameter(Mandatory = $true)][string]$BackupPath, [string]$UserModsRoot)
    $root = Assert-ScomEngine $Package $EngineRoot
    $path = [IO.Path]::GetFullPath($BackupPath)
    Assert-ScomNoReparsePoint $path
    if ($path.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Select a backup location outside the game engine folder.' }
    if (-not [IO.Directory]::Exists([IO.Path]::GetDirectoryName($path))) { throw 'Backup destination folder does not exist.' }
    if ($UserModsRoot -and $path.StartsWith([IO.Path]::GetFullPath($UserModsRoot).TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Select a backup location outside the user Mods folder.'
    }
    $files = @(Get-ScomBackupFiles $Package $root $UserModsRoot)
    if (Get-ScomAttributes $path) {
        Assert-ScomBackupMatches $path $files
        return [pscustomobject]@{ Path = $path; Files = $files.Count; Reused = $true }
    }
    $stream = [IO.File]::Open($path, [IO.FileMode]::CreateNew, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $archive = $null
    $snapshotHash = $null
    try {
        try {
            $archive = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Create, $true)
            foreach ($file in $files) {
                Assert-ScomNoReparsePoint $file.Path
                $source = [IO.File]::Open($file.Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
                $target = $null
                try {
                    if ($source.Length -ne $file.Bytes -or (Get-ScomStreamHash $source) -ne $file.SHA256) { throw "Backup source changed: $($file.Name)" }
                    $source.Position = 0
                    $entry = $archive.CreateEntry($file.Name, [IO.Compression.CompressionLevel]::Optimal)
                    $target = $entry.Open()
                    Copy-ScomStream $source $target
                }
                finally {
                    if ($null -ne $target) { $target.Dispose() }
                    $source.Dispose()
                }
            }
        }
        finally {
            if ($null -ne $archive) { $archive.Dispose() }
            $stream.Flush()
            $stream.Position = 0
            $snapshotHash = Get-ScomStreamHash $stream
            $stream.Dispose()
        }
        Assert-ScomBackupMatches $path $files
        return [pscustomobject]@{ Path = $path; Files = $files.Count; Reused = $false }
    }
    catch {
        $stream.Dispose()
        $failure = $_.Exception.Message
        try {
            if ($snapshotHash -and (Get-ScomFileHash $path) -eq $snapshotHash) { [IO.File]::Delete($path) }
            else { $failure += "`r`nIncomplete backup preserved because its content could not be verified: $path" }
        }
        catch { $failure += "`r`nIncomplete backup could not be safely removed: $path" }
        throw $failure
    }
}
