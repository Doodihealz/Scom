# SCOM — Supreme Commander Overhaul

A **Supreme Commander: Forged Alliance** overhaul for **Sanctuary: Shattered Sun**.

**[Download SCOM 1.0.1](https://github.com/Doodihealz/Scom/releases/download/V1.0/ScomInstaller.zip)** · [Releases](https://github.com/Doodihealz/Scom/releases) · [Discord community](https://discord.gg/quqwHcDb3A) · [Report a bug](https://github.com/Doodihealz/Scom/issues)

## Features

- Land, air, and naval forces, including experimental units.
- Commander enhancements, veterancy, economy systems, and Construction Plans.
- SupCom Style UI and **AI-Scom** for economy, production, expansion, and combat.

| Faction | Sanctuary slot |
| --- | --- |
| UEF | EDA |
| Cybran | Guard |
| Aeon | Chosen |
| Seraphim | Added fourth faction |

## Installation

Download **ScomInstaller.zip** using the link above. It includes SCOM, SupCom Style UI, AI-Scom, and required components.

### Recommended: setup

1. Close Sanctuary and extract the entire `ScomInstaller.zip`.
2. Run `Install SCOM.cmd` from the extracted folder.
3. Select your installed Sanctuary game folder when prompted.

Setup checks your game version and protects existing files. Keep the extracted scripts and `payload` folder together.

### Manual installation

1. Close Sanctuary and extract the entire `ScomInstaller.zip`.
2. Open the game's `engine` folder containing `Sanctuary.exe`.
3. Copy **all files and folders inside `payload`** directly into `engine`, preserving the folder structure.

Copy the contents of `payload` so there is no extra `engine/payload` folder.

### Enable AI-Scom

Select **AI-Scom** for AI players in the lobby. Its profile belongs at:

```text
engine/LJ/lua/AI/mods/AI-Scom
```

**Upgrades:** use `Install SCOM.cmd` so compatibility and file-conflict checks run.

## Bug reports

[Open an issue](https://github.com/Doodihealz/Scom/issues) with your game and mod versions, faction, map, reproduction steps, and relevant logs.

## Source code

Browse the readable source directly in this repository:

- [Unit index](source/SCOM/units/index.lua): find units by name, then open their `template.lua`, `host.lua`, or `client.lua`.
- [Shared SCOM Lua](source/SCOM/lua): shared gameplay, client, host, native movement settings, and the loader's `source-manifest.tsv`.
- [AI-Scom](source/AI-Scom): the complete installed AI profile, currently `9.0.25-rc30`.
- [Managed components](source/managed): recovered C# for the SCOM patcher, its embedded runtimes, loader, UI, and movement/tree components.
- [Installer](installer): the setup scripts and exact release payload manifest.

The Lua and installer files come directly from the installed mod and installer. C# is decompiled from the shipped mod assemblies because the original projects were unavailable; comments and original project structure are not recoverable. `source/managed/provenance.json` identifies the binaries and decompiler. Recovered projects are for inspection and are not verified as buildable replacements.

The asset pack and compiled runtime dependencies remain in the release download. They are not duplicated in the source tree, and no `.sanpack` extraction is required to read the code. Preserve the relative Lua paths and `source-manifest.tsv` when editing an installation.

## Development status

SCOM is approximately 85% complete and under heavy development.

## Credits and licensing

SCOM is a community fan project. Original game assets belong to their respective creators. Readable source is provided for inspection and modification under the applicable component terms. No repository-wide license has been assigned; third-party code and assets retain their existing terms. See the managed-source provenance for recovery details.
