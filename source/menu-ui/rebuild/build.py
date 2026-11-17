#!/usr/bin/env python3
"""Rebuild SCOM's embedded menu UI using an existing SCOM 1.3.0 patcher.

Requires Python 3 and an existing .NET 8 SDK. The game supplies the Unity,
BepInEx and Mono.Cecil references; no machine-specific paths are assumed.
The base patcher is read-only. Only the requested output candidate is written.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine', required=True, type=Path,
                        help="The game's engine directory, containing BepInEx and Sanctuary_Data.")
    parser.add_argument('--dotnet', required=True, type=Path,
                        help='Path to the dotnet executable in an existing .NET 8 SDK installation.')
    parser.add_argument('--work', required=True, type=Path,
                        help='Directory for compiler response files and intermediate assemblies.')
    parser.add_argument('--base-patcher', required=True, type=Path,
                        help='Existing Scom-patcher.dll with the integrated UI resource.')
    parser.add_argument('--output', required=True, type=Path,
                        help='Candidate Scom-patcher.dll path; must differ from --base-patcher.')
    parser.add_argument('--ui-source', type=Path,
                        default=Path(__file__).resolve().parent.parent / 'integrated-ui',
                        help='UI source directory; defaults to sibling integrated-ui.')
    args = parser.parse_args()
    here = Path(__file__).resolve().parent
    engine = args.engine.resolve(strict=True)
    dotnet = args.dotnet.resolve(strict=True)
    base = args.base_patcher.resolve(strict=True)
    output = args.output.resolve()
    source = args.ui_source.resolve(strict=True)
    work = args.work.resolve()
    if output == base:
        parser.error('--output must differ from --base-patcher; the base is never overwritten.')
    if not dotnet.is_file() or not base.is_file():
        parser.error('--dotnet and --base-patcher must refer to files.')
    cecil = engine / 'BepInEx/core/Mono.Cecil.dll'
    if not cecil.is_file() or not (source / 'build.py').is_file():
        parser.error('The engine must contain BepInEx/core/Mono.Cecil.dll and UI source must contain build.py.')
    sdk_root = dotnet.parent
    compilers = sorted((sdk_root / 'sdk').glob('*/Roslyn/bincore/csc.dll'))
    references = sorted((sdk_root / 'packs/Microsoft.NETCore.App.Ref').glob('8.*/ref/net8.0'))
    if not compilers or not references:
        parser.error('--dotnet must belong to an installation with a .NET 8 SDK/reference pack.')
    work.mkdir(parents=True, exist_ok=True)
    output.parent.mkdir(parents=True, exist_ok=True)
    environment = dict(os.environ, DOTNET_ROOT=str(sdk_root),
                       DOTNET_CLI_HOME=str(work / 'dotnet-home'),
                       DOTNET_CLI_TELEMETRY_OPTOUT='1',
                       DOTNET_SKIP_FIRST_TIME_EXPERIENCE='1',
                       DOTNET_GENERATE_ASPNET_CERTIFICATE='false')

    runtime = work / 'ui/Scom.UI.Runtime.dll'
    subprocess.run([sys.executable, str(source / 'build.py'),
                    '--engine', str(engine), '--dotnet', str(dotnet),
                    '--work', str(work / 'ui'), '--output', str(runtime),
                    '--source', str(source)], env=environment, check=True)

    updater_directory = work / 'updater'
    updater_directory.mkdir(parents=True, exist_ok=True)
    updater = updater_directory / 'ResourceUpdate.dll'
    options = ['-nologo', '-nostdlib+', '-optimize+', '-deterministic+',
               '-target:exe', '-langversion:12', '-out:' + str(updater)]
    options += ['-r:' + str(path) for path in sorted(references[-1].glob('*.dll'))]
    options += ['-r:' + str(cecil), str(here / 'ResourceUpdate.cs')]
    response = updater_directory / 'compile.rsp'
    response.write_text('\n'.join('"' + option.replace('"', '\\"') + '"'
                                  for option in options) + '\n', encoding='utf-8')
    subprocess.run([str(dotnet), str(compilers[-1]), '@' + str(response)],
                   env=environment, check=True)
    shutil.copy2(cecil, updater_directory / cecil.name)
    updater.with_suffix('.runtimeconfig.json').write_text(json.dumps({
        'runtimeOptions': {'tfm': 'net8.0', 'framework': {
            'name': 'Microsoft.NETCore.App', 'version': '8.0.0'}}}), encoding='utf-8')
    subprocess.run([str(dotnet), str(updater), 'replace', str(base),
                    str(runtime), str(output)], env=environment, check=True)
    print('Rebuilt embedded menu UI; verified candidate:', output)


if __name__ == '__main__':
    main()
