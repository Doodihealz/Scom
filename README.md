# SCOM — Supreme Commander Overhaul

SCOM brings the UEF, Cybran, Aeon, and Seraphim factions from *Supreme Commander: Forged Alliance* to *Sanctuary: Shattered Sun*. It includes land, air, and naval forces, experimental units, commander enhancements, veterancy, Construction Plans, an optional SupCom-style interface, and the AI-Scom opponent.

**[Download SCOM 1.5.1](https://github.com/Doodihealz/Scom/releases/tag/V1.5.1)** · [Discord community](https://discord.gg/quqwHcDb3A) · [Report a bug](https://github.com/Doodihealz/Scom/issues)

## New in 1.5.1

SCOM now skips an optional AI edit when the installed Lua file is missing or has changed. Commander and unit registration continues, and the log identifies the skipped edit. This fixes the empty map players could see at match start after a Rush update.

| Faction | Sanctuary slot |
| --- | --- |
| UEF | EDA |
| Cybran | Guard |
| Aeon | Chosen |
| Seraphim | Added fourth faction |

## Installation

1. Download [ScomInstaller.zip](https://github.com/Doodihealz/Scom/releases/download/V1.5.1/ScomInstaller.zip).
2. Close Sanctuary and extract the ZIP into a folder.
3. Run `Install SCOM.cmd` from that folder and select your Sanctuary installation.

Use setup for upgrades. It preserves settings, retires recognized standalone UI and shatter DLLs, and reports conflicts with modified files. For a manual installation, follow `Manual Installation.txt` in the extracted folder.

To use **AI-Scom 10.0.0**, select **AI-Scom** for an AI player in the lobby. The installed profile is under `engine/lua/AI/mods/AI-Scom`.

## Source

| Component | Contents |
| --- | --- |
| [Unit definitions](source/SCOM/units/index.lua) | Unit index, templates, host scripts, and client scripts |
| [Shared gameplay Lua](source/SCOM/lua) | Gameplay systems, movement settings, and source manifest |
| [AI-Scom](source/AI-Scom) | Economy, production, expansion, and combat logic |
| [AI compatibility](source/ai-compatibility) | Startup fixes and regression checks for changes to installed AI files |
| [Yolona Shatter](source/yolona-shatter) | C# runtime and integration code for the 1.4.0 terrain fracture |
| [Menu and UI](source/menu-ui) | Editable interface source and rebuild tools |
| [Installer](installer) | Release setup scripts and payload manifest |
| [Historical managed source](source/managed) | C# recovered from the October 28, 2026 binaries, with [binary provenance](source/managed/provenance.json) |

The release downloads include the compiled runtime, game assets, and dependencies. The recovered C# projects are provided for inspection and have not been verified as standalone builds.

## Project and support

SCOM is a community fan project in active development. The author used ChatGPT Astra throughout development. When [reporting a bug](https://github.com/Doodihealz/Scom/issues), include the game and SCOM versions, faction, map, steps to reproduce, and relevant logs.

Original game assets belong to their respective creators. Source is available for inspection and modification under the applicable component terms. There is no repository-wide license. Third-party code and assets retain their existing terms.
