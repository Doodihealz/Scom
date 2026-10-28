# SCOM — Supreme Commander Overhaul

A **Supreme Commander: Forged Alliance** overhaul for **Sanctuary: Shattered Sun**.

**[Download SCOM 1.0.0](https://github.com/Doodihealz/Scom/releases/download/V1.0/ScomInstaller.zip)** · [Releases](https://github.com/Doodihealz/Scom/releases) · [Report a bug](https://github.com/Doodihealz/Scom/issues)

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

## Development status

SCOM is in active development. The latest AI changes have been source-reviewed and still need in-game validation. The reviewed AI adapter does not support teleport, spawned-drone upgrades, manual tactical missiles, or transport loading/unloading.

## Credits and licensing

SCOM is a community fan project. Original game assets belong to their respective creators. Source code, a repository license, and full component credits have not yet been added here; third-party assets retain their own terms.
