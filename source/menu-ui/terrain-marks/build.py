#!/usr/bin/env python3
"""Compile and integrate the terrain-mark source repair without modifying its base."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess


def newest(parent):
    choices = [p for p in parent.glob('8.*') if p.is_dir()]
    if not choices:
        raise ValueError('A .NET 8 SDK and reference pack are required: ' + str(parent))
    return max(choices, key=lambda p: tuple(int(v) for v in p.name.split('-')[0].split('.')))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('engine', 'dotnet', 'base-patcher', 'work', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    here = Path(__file__).resolve().parent
    engine, dotnet, base, work, output = (p.resolve() for p in
        (args.engine, args.dotnet, args.base_patcher, args.work, args.output))
    if base == output:
        parser.error('--output must differ from the read-only base patcher.')
    sdk = newest(dotnet.parent / 'sdk')
    refs = newest(dotnet.parent / 'packs/Microsoft.NETCore.App.Ref') / 'ref/net8.0'
    mscorlib = engine / 'Sanctuary_Data/Managed/mscorlib.dll'
    cecil = engine / 'BepInEx/core/Mono.Cecil.dll'
    for path in (base, mscorlib, cecil):
        if not path.is_file():
            raise FileNotFoundError(path)
    work.mkdir(parents=True, exist_ok=True)
    output.parent.mkdir(parents=True, exist_ok=True)
    environment = dict(os.environ, DOTNET_ROOT=str(dotnet.parent),
        DOTNET_CLI_HOME=str(work / 'dotnet-home'), DOTNET_CLI_TELEMETRY_OPTOUT='1',
        DOTNET_SKIP_FIRST_TIME_EXPERIENCE='1')

    def compile_source(name, source, references, kind):
        destination = work / (name + '.dll')
        options = ['-nologo', '-nostdlib+', '-optimize+', '-deterministic+',
            '-langversion:12', '-target:' + kind, '-out:' + str(destination)]
        options += ['-r:' + str(p) for p in references] + [str(source)]
        response = work / (name + '.rsp')
        response.write_text('\n'.join('"' + value.replace('"', '\\"') + '"' for value in options) + '\n')
        subprocess.run([str(dotnet), str(sdk / 'Roslyn/bincore/csc.dll'), '@' + str(response)],
            env=environment, check=True)
        return destination

    runtime = compile_source('SCOM.GroundMarks.Runtime', here / 'GroundMarksSourceTransform.cs', [mscorlib], 'library')
    installer = compile_source('InstallGroundMarks', here / 'InstallGroundMarks.cs',
        sorted(refs.glob('*.dll')) + [cecil], 'exe')
    shutil.copy2(cecil, work / cecil.name)
    installer.with_suffix('.runtimeconfig.json').write_text(json.dumps({'runtimeOptions': {
        'tfm': 'net8.0', 'framework': {'name': 'Microsoft.NETCore.App', 'version': '8.0.0'}}}))
    subprocess.run([str(dotnet), str(installer), str(base), str(runtime), str(output)],
        env=environment, check=True)


if __name__ == '__main__':
    main()
