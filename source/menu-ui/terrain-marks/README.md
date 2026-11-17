# Terrain-mark repair

Global sea height cannot identify a dry crater floor. This repair removes that assumption from nuclear scorch eligibility and the footprint/track contact samplers. Actual sampled terrain, bone contact, clearance, movement, visibility, unit-state checks, native decal sizes, projection depth, lifetimes, and budgets remain in control.

The fixed Lua files are shipped as defaults. An embedded, game-compatible `SCOM.GroundMarks.Runtime.dll` also repairs the supported blocks after editable source composition. This reaches existing installations without rewriting local Lua files. All blocks in a module must match before any replacement occurs; unsupported customizations or malformed bytes are preserved, with one bounded diagnostic. Repeated cache rebuilds are idempotent. The repair works independently of the UI and optional terrain-deformation settings.

`GroundMarksSourceTransform.cs` is the runtime source. `InstallGroundMarks.cs` integrates it into the existing source-composition bridge, verifying that only that bridge method, one private cache field, and the new embedded resource change. Existing resources, including the menu/HUD runtime, are retained.

## Build

Use Python 3, a .NET 8 SDK, the supported game installation with BepInEx, and a base SCOM patcher **without this repair already integrated**:

```sh
python build.py --engine "/path/to/game/engine" --dotnet "/path/to/dotnet" --base-patcher "/path/to/pre-repair/Scom-patcher.dll" --work "/path/to/build" --output "/path/to/candidate/Scom-patcher.dll"
```

The base is read-only. The runtime uses the game's `mscorlib.dll`; the build utility uses .NET 8 and the installed Mono.Cecil. The integration deliberately rejects duplicate installation. The menu/HUD rebuild tool can use this release's already-repaired base directly and preserves the repair.
