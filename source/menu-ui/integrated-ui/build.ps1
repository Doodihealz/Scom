param(
    [Parameter(Mandatory = $true)]
    [string]$Engine,
    [string]$Output = (Join-Path $PSScriptRoot '..\Scom.UI.Runtime.dll')
)
$ErrorActionPreference = 'Stop'
$managed = Join-Path $Engine 'Sanctuary_Data\Managed'
$core = Join-Path $Engine 'BepInEx\core'
$sdk = (& dotnet --list-sdks | Select-Object -Last 1)
if ($LASTEXITCODE -ne 0 -or $sdk -notmatch '^([^ ]+) \[(.+)\]$') { throw 'A .NET SDK is required.' }
$compiler = Join-Path $Matches[2] ($Matches[1] + '\Roslyn\bincore\csc.dll')
$argsList = @('-nologo', '-target:library', '-langversion:12', '-unsafe', '-nostdlib+', '-optimize+', '-deterministic+', "-out:$Output")
$argsList += Get-ChildItem -LiteralPath $managed -Filter '*.dll' | ForEach-Object { '-r:' + $_.FullName }
$argsList += ('-r:' + (Join-Path $core 'BepInEx.dll'))
$argsList += ('-r:' + (Join-Path $core '0Harmony.dll'))
$argsList += Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.cs' -Recurse | ForEach-Object { $_.FullName }
$argsList += Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.lua' | ForEach-Object { '-resource:' + $_.FullName + ',' + $_.Name }
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\ScomMainMenu.png') + ',SCOM.MainMenu.Background.png'
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\ScomLobby.png') + ',SCOM.Lobby.Background.png'
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\ScomMainMenuGold.png') + ',SCOM.MainMenu.Gold.png'
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\ScomMainMenuBattleship.png') + ',SCOM.MainMenu.Battleship.Original.png'
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\ScomMainMenuBattleshipGold.png') + ',SCOM.MainMenu.Battleship.Gold.png'
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\ScomMainMenuCity.png') + ',SCOM.MainMenu.City.Original.png'
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\ScomMainMenuCityGold.png') + ',SCOM.MainMenu.City.Gold.png'
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\ScomLobbyGold.png') + ',SCOM.Lobby.Gold.png'
$argsList += '-resource:' + (Join-Path $PSScriptRoot 'Assets\SupremeCommanderTextShine.gif') + ',SCOM.MainMenu.TextShine.gif'
$outputPath = [System.IO.Path]::GetFullPath($Output)
$outputDirectory = [System.IO.Path]::GetDirectoryName($outputPath)
[System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
$response = [System.IO.Path]::GetTempFileName()
try {
    # A response file keeps paths containing spaces intact on Windows PowerShell
    # and PowerShell Core without relying on native argument-array quoting.
    $quoted = $argsList | ForEach-Object { '"' + $_.Replace('"', '\"') + '"' }
    [System.IO.File]::WriteAllLines($response, $quoted, [System.Text.UTF8Encoding]::new($false))
    & dotnet $compiler ('@' + $response)
}
finally {
    Remove-Item -LiteralPath $response -ErrorAction SilentlyContinue
}
if ($LASTEXITCODE -ne 0) { throw "Compilation failed ($LASTEXITCODE)." }
