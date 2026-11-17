#!/usr/bin/env python3
"""Compile SCOM's embedded UI against the installed Unity/BepInEx assemblies."""
import argparse
import os
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--engine', required=True, type=Path)
parser.add_argument('--dotnet', required=True, type=Path)
parser.add_argument('--work', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--source', type=Path, default=Path(__file__).resolve().parent)
args = parser.parse_args()
dotnet = args.dotnet.resolve()
work = args.work.resolve()
work.mkdir(parents=True, exist_ok=True)
source = args.source.resolve()
output = args.output.resolve()
output.parent.mkdir(parents=True, exist_ok=True)
sdk = sorted((dotnet.parent / 'sdk').iterdir())[-1]
engine = args.engine.resolve()
switches = ['-nologo', '-target:library', '-langversion:12', '-unsafe',
            '-nostdlib+', '-optimize+', '-deterministic+', '-out:' + str(output)]
switches += ['-r:' + str(p) for p in sorted((engine / 'Sanctuary_Data/Managed').glob('*.dll'))]
switches += ['-r:' + str(engine / 'BepInEx/core' / p) for p in ('BepInEx.dll', '0Harmony.dll')]
switches += [str(p) for p in sorted(source.rglob('*.cs'))]
switches += ['-resource:' + str(p) + ',' + p.name for p in sorted(source.glob('*.lua'))]
switches += ['-resource:' + str(source / 'Assets/ScomMainMenu.png') + ',SCOM.MainMenu.Background.png']
switches += ['-resource:' + str(source / 'Assets/ScomLobby.png') + ',SCOM.Lobby.Background.png']
switches += ['-resource:' + str(source / 'Assets/ScomMainMenuGold.png') + ',SCOM.MainMenu.Gold.png']
switches += ['-resource:' + str(source / 'Assets/ScomMainMenuBattleship.png') + ',SCOM.MainMenu.Battleship.Original.png']
switches += ['-resource:' + str(source / 'Assets/ScomMainMenuBattleshipGold.png') + ',SCOM.MainMenu.Battleship.Gold.png']
switches += ['-resource:' + str(source / 'Assets/ScomMainMenuCity.png') + ',SCOM.MainMenu.City.Original.png']
switches += ['-resource:' + str(source / 'Assets/ScomMainMenuCityGold.png') + ',SCOM.MainMenu.City.Gold.png']
switches += ['-resource:' + str(source / 'Assets/ScomLobbyGold.png') + ',SCOM.Lobby.Gold.png']
switches += ['-resource:' + str(source / 'Assets/SupremeCommanderTextShine.gif') + ',SCOM.MainMenu.TextShine.gif']
response = work / 'ui-compile.rsp'
response.write_text('\n'.join('"' + s + '"' for s in switches) + '\n')
env = dict(os.environ, DOTNET_ROOT=str(dotnet.parent), DOTNET_CLI_HOME=str(work / 'dotnet-home'),
           DOTNET_CLI_TELEMETRY_OPTOUT='1', DOTNET_SKIP_FIRST_TIME_EXPERIENCE='1',
           DOTNET_GENERATE_ASPNET_CERTIFICATE='false')
subprocess.run([str(dotnet), str(sdk / 'Roslyn/bincore/csc.dll'), '@' + str(response)], env=env, check=True)
print('Compiled embedded UI:', output)
