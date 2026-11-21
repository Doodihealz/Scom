# SCOM — Supreme Commander Overhaul

SCOM brings the UEF, Cybran, Aeon, and Seraphim factions from *Supreme Commander: Forged Alliance* to *Sanctuary: Shattered Sun*. It includes land, air, and naval forces, experimental units, commander enhancements, veterancy, Construction Plans, an optional SupCom-style interface, and the AI-Scom opponent.

**[Download SCOM 1.4.0](https://github.com/Doodihealz/Scom/releases/tag/V1.4.0)** · [Discord community](https://discord.gg/quqwHcDb3A) · [Report a bug](https://github.com/Doodihealz/Scom/issues)

## New in 1.4.0

The Seraphim T4 Yolona now fractures the terrain on impact. The ground collapses into a chasm, land units route around the opening, and waterfalls form where the fracture meets water. The effect and its assets ship inside `Scom-patcher.dll`.

| Faction | Sanctuary slot |
| --- | --- |
| UEF | EDA |
| Cybran | Guard |
| Aeon | Chosen |
| Seraphim | Added fourth faction |

## Installation

1. Download [ScomInstaller.zip](https://github.com/Doodihealz/Scom/releases/download/V1.4.0/ScomInstaller.zip) and [ScomAssets.zip](https://github.com/Doodihealz/Scom/releases/download/V1.4.0/ScomAssets.zip).
2. Close Sanctuary. Extract **both ZIPs into the same folder**, so `Install SCOM.cmd` and `payload` sit side by side.
3. Run `Install SCOM.cmd` and select your Sanctuary installation. To verify the extracted package first, run `Install SCOM.cmd /check`.

Use setup for upgrades. It preserves settings, retires recognized standalone UI and shatter DLLs, and reports conflicts with modified files. For a manual installation, follow `Manual Installation.txt` in the extracted folder.

To use **AI-Scom 10.0.0**, select **AI-Scom** for an AI player in the lobby. The installed profile is under `engine/LJ/lua/AI/mods/AI-Scom`.

## Source

| Component | Contents |
| --- | --- |
| [Unit definitions](source/SCOM/units/index.lua) | Unit index, templates, host scripts, and client scripts |
| [Shared gameplay Lua](source/SCOM/lua) | Gameplay systems, movement settings, and source manifest |
| [AI-Scom](source/AI-Scom) | Economy, production, expansion, and combat logic |
| [Yolona Shatter](source/yolona-shatter) | C# runtime and integration code for the 1.4.0 terrain fracture |
| [Menu and UI](source/menu-ui) | Editable interface source and rebuild tools |
| [Installer](installer) | Release setup scripts and payload manifest |
| [Historical managed source](source/managed) | C# recovered from the October 28, 2026 binaries, with [binary provenance](source/managed/provenance.json) |

The release downloads include the compiled runtime, game assets, and dependencies. The recovered C# projects are provided for inspection and have not been verified as standalone builds.

## Project and support

SCOM is a community fan project in active development. The author used ChatGPT Astra throughout development. When [reporting a bug](https://github.com/Doodihealz/Scom/issues), include the game and SCOM versions, faction, map, steps to reproduce, and relevant logs.

Original game assets belong to their respective creators. Source is available for inspection and modification under the applicable component terms. There is no repository-wide license. Third-party code and assets retain their existing terms.
