#!/usr/bin/env python3
"""Update SCOM 1.3.0 release metadata to 1.4.0, preserving IL and resources."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine', required=True, type=Path)
    parser.add_argument('--dotnet', required=True, type=Path)
    parser.add_argument('--work', required=True, type=Path)
    parser.add_argument('--input', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--expected-sha256', required=True)
    args = parser.parse_args()
    here = Path(__file__).resolve().parent
    dotnet = args.dotnet.resolve(strict=True)
    original = args.input.resolve(strict=True)
    output = args.output.resolve()
    work = args.work.resolve()
    if original == output:
        parser.error('--input and --output must differ.')
    cecil = args.engine.resolve(strict=True) / 'BepInEx/core/Mono.Cecil.dll'
    if not cecil.is_file():
        parser.error('--engine must contain BepInEx/core/Mono.Cecil.dll.')
    compilers = sorted((dotnet.parent / 'sdk').glob('*/Roslyn/bincore/csc.dll'))
    references = sorted((dotnet.parent / 'packs/Microsoft.NETCore.App.Ref').glob('8.*/ref/net8.0'))
    if not compilers or not references:
        parser.error('--dotnet requires a .NET 8 SDK and reference pack.')
    work.mkdir(parents=True, exist_ok=True)
    output.parent.mkdir(parents=True, exist_ok=True)
    updater = work / 'SetModVersion.dll'
    options = ['-nologo', '-nostdlib+', '-optimize+', '-deterministic+',
               '-target:exe', '-langversion:12', '-main:SetModVersion', '-out:' + str(updater)]
    options += ['-r:' + str(path) for path in sorted(references[-1].glob('*.dll'))]
    options += ['-r:' + str(cecil), str(here / 'ResourceUpdate.cs'), str(here / 'SetModVersion.cs')]
    response = work / 'compile.rsp'
    response.write_text('\n'.join('"' + option.replace('"', '\\"') + '"' for option in options) + '\n', encoding='utf-8')
    environment = dict(os.environ, DOTNET_ROOT=str(dotnet.parent),
                       DOTNET_CLI_HOME=str(work / 'dotnet-home'),
                       DOTNET_CLI_TELEMETRY_OPTOUT='1', DOTNET_SKIP_FIRST_TIME_EXPERIENCE='1')
    subprocess.run([str(dotnet), str(compilers[-1]), '@' + str(response)], env=environment, check=True)
    shutil.copy2(cecil, work / cecil.name)
    updater.with_suffix('.runtimeconfig.json').write_text(json.dumps({
        'runtimeOptions': {'tfm': 'net8.0', 'framework': {
            'name': 'Microsoft.NETCore.App', 'version': '8.0.0'}}}), encoding='utf-8')
    subprocess.run([str(dotnet), str(updater), str(original), str(output), args.expected_sha256],
                   env=environment, check=True)


if __name__ == '__main__':
    main()
