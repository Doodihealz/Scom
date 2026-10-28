# SCOM — Supreme Commander Overhaul

**A Supreme Commander: Forged Alliance overhaul for Sanctuary: Shattered Sun.**

SCOM adapts Forged Alliance factions, units, structures, and gameplay systems to Sanctuary. The project covers UEF, Cybran, Aeon, and Seraphim forces, with land, air, and naval combat, experimental units, commander progression, and a companion AI profile.

Maintained by [Doodihealz](https://github.com/Doodihealz).

[Report a bug](https://github.com/Doodihealz/Scom/issues) · [Releases](https://github.com/Doodihealz/Scom/releases) · [Project activity](https://github.com/Doodihealz/Scom/commits/main/)

## Project status

SCOM is in active development. **This GitHub repository currently contains project documentation; the mod files, installer, and downloadable releases have not been uploaded here.** GitHub's **Code → Download ZIP** therefore does not provide an installable copy of SCOM.

This overview describes the existing development work and its scope. It does not mean that every feature has been verified in the latest Sanctuary build. The latest AI changes have received source review; they have not been validated through live matches, benchmarks, or automated tests.

Documentation refreshed: **October 27, 2026**.

## Factions

SCOM adapts three of Sanctuary's faction slots and adds Seraphim as a fourth faction.

| SCOM faction | Sanctuary integration |
| --- | --- |
| **UEF** | Uses the EDA faction slot |
| **Cybran** | Uses the Guard faction slot |
| **Aeon** | Uses the Chosen faction slot |
| **Seraphim** | Adds a separate fourth faction |

## Overhaul scope

- **Units and structures:** Forged Alliance adaptations spanning engineers, factories, economy, defenses, ground forces, aircraft, and naval forces.
- **Experimental units:** Work includes the Fatboy, Monkeylord, Megalith, Scathis, Galactic Colossus, and Czar.
- **Commander enhancements:** Faction-specific upgrade paths, costs, prerequisites, slot conflicts, economy effects, and interface integration.
- **Economy and technology:** Extractors, power generation, storage, fabrication, factory progression, and construction support.
- **Veterancy:** Forged Alliance-style kill credit, health and regeneration progression, and unit-panel information.
- **Construction and presentation:** Construction Plans, structure footprints and placement, factory exits, faction construction beams, unit names, and animation integration.

The overhaul and its companion AI are separate parts of the project. An enhancement implemented by SCOM is not automatically available to AI-Scom.

## AI-Scom

**AI-Scom** is the companion Lua AI profile for the overhaul. Its development covers:

| Area | Scope |
| --- | --- |
| Economy | Opening construction, extractor expansion and upgrades, power planning, storage adjacency, and surplus-energy fabrication |
| Production | Factory queues, engineer availability, construction assistance, and technology progression that preserves fighting forces |
| Land combat | Independent attack groups, raiding, frontline support, defense across multiple approaches, and experimental construction |
| Air combat | Interceptors, gunships, bomber wings, scouting, and target selection that considers visible threats and anti-air exposure |
| Naval combat | Fleet composition, weapon-appropriate targets, amphibious warships, and coastal pressure |
| Expansion | Persistent resource expansion, outposts, and coastal beachheads using capable amphibious or hover engineers |
| Commanders | Construction, repairs, reclaim, combat support, shelter, and compatible enhancement planning |
| Coordination | Shared resource commitments, native pathfinding and movement rules, order ownership, and recovery of idle or interrupted work |

AI planning uses the installed faction templates, actual build menus, real costs, and live construction power. Native build permissions, placement restrictions, and accepted work remain authoritative.

### Current AI integration limits

The current AI adapter does not activate teleport, spawned-drone upgrades, or manually launched tactical missiles because the required SCOM host implementations were not included in its supplied source set. These abilities should not be treated as completed AI features.

Coastal beachheads use actual amphibious or hover movement. Transport loading and unloading are not implemented in the supplied host path.

These are limits of the reviewed AI integration, not a claim that the underlying overhaul lacks those systems.

## Installation and upgrades

**There is no installer attached to this repository yet.** The following procedure is for a complete `ScomInstaller.zip` bundle obtained separately; it is not a procedure for installing this repository's documentation ZIP.

The current installation notes describe a bundle containing SCOM, SupCom Style UI, AI-Scom, and required components:

1. Close Sanctuary.
2. Extract the entire `ScomInstaller.zip` to a folder.
3. Run `Install SCOM.cmd` from that folder.
4. Select the installed Sanctuary game folder when prompted.
5. Let the installer perform its compatibility and existing-file checks.
6. Launch the game and select **AI-Scom** for AI players in the lobby.

Keep the extracted scripts and payload folder together. Use the installer for upgrades so its compatibility and overwrite checks run.

The AI profile installs under:

```text
engine/LJ/lua/AI/mods/AI-Scom
```

The AI package includes `INSTALL.txt`, `AI Patchnotes.txt`, and `Balance Rules.txt`. Follow the instructions packaged with the particular build you are installing. A current supported Sanctuary build and public release package have not yet been documented in this repository.

## Reporting problems

Open an [issue](https://github.com/Doodihealz/Scom/issues) and include:

- Your Sanctuary build and SCOM / AI-Scom package versions.
- The affected faction, unit, structure, or AI behavior.
- The map, game mode, and relevant lobby settings.
- Steps to reproduce the problem.
- What you expected and what actually happened.
- A relevant log excerpt and, when useful, a screenshot or replay.

For AI reports, describe the situation that led to the behavior: available resources, factories and engineers, technology level, visible threats, and whether the problem repeats. This helps distinguish an economy or placement restriction from an AI decision or recovery problem.

## Development information

The main overhaul includes cache-patcher and game-integration components. AI-Scom uses Lua modules with `formers/` and `strategies/` directories for production, construction, and combat behavior.

Source code and reproducible build instructions are not yet present in this repository. When reviewing development changes, distinguish source review from successful in-game verification; no measured performance or win-rate improvement is claimed here.

## Credits and licensing

SCOM is a community fan project built around **Sanctuary: Shattered Sun** and **Supreme Commander: Forged Alliance**. Credit for the original games, designs, and assets belongs to their respective creators.

A complete component attribution list and a repository license have not yet been added. This README does not grant redistribution rights to third-party assets.
