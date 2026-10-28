# Double-click Install SCOM.cmd after extracting the entire archive.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
. (Join-Path $PSScriptRoot 'Installer.Core.ps1')

function Find-ScomGame {
    $libraries = New-Object 'Collections.Generic.List[string]'
    foreach ($key in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam')) {
        $item = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
        if ($item) {
            foreach ($name in @('SteamPath', 'InstallPath')) {
                if ($item.PSObject.Properties[$name] -and $item.$name) { $libraries.Add([string]$item.$name) }
            }
        }
    }
    foreach ($steam in @($libraries.ToArray())) {
        $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
        if ([IO.File]::Exists($vdf)) {
            foreach ($match in [regex]::Matches([IO.File]::ReadAllText($vdf), '"path"\s+"([^"]+)"')) {
                $libraries.Add($match.Groups[1].Value.Replace('\\', '\'))
            }
        }
    }
    foreach ($library in @($libraries | Select-Object -Unique)) {
        foreach ($name in @('Sanctuary Shattered Sun Playtest', 'Sanctuary Shattered Sun')) {
            $candidate = Join-Path $library ('steamapps\common\' + $name + '\engine')
            if ([IO.File]::Exists((Join-Path $candidate 'Sanctuary.exe'))) { return $candidate }
        }
    }
    return ''
}

function Assert-ScomGameClosed {
    if (@(Get-Process -Name 'Sanctuary' -ErrorAction SilentlyContinue).Count) {
        throw 'Close Sanctuary before running setup. Nothing was installed.'
    }
}

function Read-ScomChoice {
    param([string]$Prompt, [string[]]$Allowed, [string]$Default)
    do {
        $answer = (Read-Host $Prompt).Trim().ToUpperInvariant()
        if (-not $answer) { $answer = $Default }
    } until ($Allowed -contains $answer)
    return $answer
}

function Invoke-ScomInstaller {
    param(
        [string]$DesktopPath = [Environment]::GetFolderPath('Desktop'),
        [string]$DocumentsPath = [Environment]::GetFolderPath('MyDocuments')
    )
    try {
        Write-Host 'SCOM Setup 1.0.1' -ForegroundColor Cyan
        Write-Host 'Installs SCOM, SupCom Style UI, AI-Scom and required components.'
        Write-Host 'Existing settings and other mods are kept. You can back up your mods before installing.'
        Write-Host ''
        $suggested = Find-ScomGame
        if ($suggested) { Write-Host ('Detected: ' + $suggested) }
        $entered = (Read-Host 'Game or engine folder (Enter uses the detected folder)').Trim().Trim('"')
        if (-not $entered) { $entered = $suggested }
        if (-not $entered) { throw 'No game folder selected. Setup cancelled.' }
        $engine = [IO.Path]::GetFullPath($entered)
        if (-not [IO.File]::Exists((Join-Path $engine 'Sanctuary.exe'))) { $engine = Join-Path $engine 'engine' }
        Assert-ScomGameClosed
        Write-Host 'Checking files and game version...'
        $package = Read-ScomPackage $PSScriptRoot
        $plan = Get-ScomInstallPlan $package $engine
        Write-Host ('Install folder: ' + $plan.EngineRoot)
        if ($plan.BepInExVersion) { Write-Host ('BepInEx {0} found. Existing loader settings are kept.' -f $plan.BepInExVersion) }

        $choice = Read-ScomChoice 'Back up existing mods? [Y]es / [N]o / [C]ancel (default N)' @('Y', 'N', 'C') 'N'
        if ($choice -eq 'C') { Write-Host 'Cancelled. Nothing installed.'; return 0 }
        if ($choice -eq 'Y') {
            Assert-ScomGameClosed
            $backupFolder = Join-Path $DesktopPath 'Sanctuary_Mods'
            Assert-ScomNoReparsePoint $backupFolder
            $createdBackupDirectories = New-Object 'Collections.Generic.List[string]'
            New-ScomDirectories $DesktopPath $backupFolder $createdBackupDirectories
            $createdBackupFolder = $createdBackupDirectories.Contains($backupFolder)
            $backupPath = Join-Path $backupFolder 'ExistingMods-before-SCOM.zip'
            Write-Host ('Backup: ' + $backupPath)
            Write-Host 'A matching backup is reused; a different backup is never overwritten.'
            $userMods = Join-Path $DocumentsPath 'My Games\Enhearten Media\Sanctuary\Mods'
            try {
                Assert-ScomGameClosed
                $backup = New-ScomBackup $package $plan.EngineRoot $backupPath -UserModsRoot $userMods
                Write-Host ('Backup verified: {0} files. Reused: {1}' -f $backup.Files, $backup.Reused)
            }
            catch {
                Assert-ScomNoReparsePoint $backupFolder
                if ($createdBackupFolder -and [IO.Directory]::Exists($backupFolder) -and @([IO.Directory]::EnumerateFileSystemEntries($backupFolder)).Count -eq 0) {
                    [IO.Directory]::Delete($backupFolder, $false)
                }
                throw
            }
        }

        if ($plan.Conflicts.Count) {
            Write-Host ('Setup found {0} file conflicts:' -f $plan.Conflicts.Count) -ForegroundColor Yellow
            foreach ($conflict in $plan.Conflicts) { Write-Host ('  ' + $conflict) }
            throw 'Setup stopped to protect the files listed above. Nothing was installed.'
        }
        if ($plan.Create.Count -eq 0 -and $plan.Replace.Count -eq 0 -and $plan.Remove.Count -eq 0) { Write-Host 'This version is already installed. Nothing to do.' -ForegroundColor Green; return 0 }
        $bytes = [long]0
        foreach ($file in @($plan.Create) + @($plan.Replace)) { $bytes += $file.Bytes }
        Write-Host ('Files: {0} new, {1} updates ({2:N1} MiB), {3} obsolete removals, {4} matching, {5} preserved.' -f $plan.Create.Count, $plan.Replace.Count, ($bytes / 1MB), $plan.Remove.Count, $plan.Skip.Count, $plan.Preserve.Count)
        if ((Read-ScomChoice 'Install here? [Y]es / [C]ancel (default C)' @('Y', 'C') 'C') -ne 'Y') {
            Write-Host 'Cancelled. Nothing installed.'; return 0
        }
        Assert-ScomGameClosed
        Write-Host 'Installing and checking files...'
        $result = Invoke-ScomInstall $package $plan.EngineRoot
        Write-Host ('Setup complete. Added: {0}; updated: {1}; removed: {2}; already present: {3}; preserved: {4}.' -f $result.Installed, $result.Updated, $result.Removed, $result.Skipped, $result.Preserved) -ForegroundColor Green
        return 0
    }
    catch {
        Write-Host ''
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host 'Setup reverses its changes when the files still match. Any unrestored originals are kept at the paths shown above.'
        return 1
    }
}

if ($MyInvocation.InvocationName -ne '.') { exit (Invoke-ScomInstaller) }
