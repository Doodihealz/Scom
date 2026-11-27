"""Build SCOM 1.5.1 from the public 1.5.0 core and verify AI compatibility."""
import argparse
import hashlib
import sys
import os
from pathlib import Path
from subprocess import run
import shutil
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
for name in ("engine", "sdk", "pack_shatter", "input", "mod_sources", "output"):
    parser.add_argument(name, type=Path)
args = parser.parse_args()
engine = args.engine.resolve()
sdk = args.sdk.resolve()
pack_shatter = args.pack_shatter.resolve()
original = args.input.resolve()
mod_sources = args.mod_sources.resolve()
output = args.output.resolve()
if output.exists():
    parser.error("Choose a new output path for the verified build.")
here = Path(__file__).resolve().parent
dev = here.parent
dotnet = sdk / ("dotnet.exe" if os.name == "nt" else "dotnet")
sdk_version = sdk / "sdk/8.0.428"
ref = next((sdk / "packs/Microsoft.NETCore.App.Ref").glob("8.0.*/ref/net8.0"))
compiler = [dotnet, sdk_version / "Roslyn/bincore/csc.dll", "-nologo", "-nostdlib+", "-deterministic+", "-optimize+"]
managed = sorted((engine / "Sanctuary_Data/Managed").glob("*.dll"))
cecil = engine / "BepInEx/core/Mono.Cecil.dll"

with tempfile.TemporaryDirectory(prefix="scom-ai-", dir=output.parent) as temp:
    staging = Path(temp)
    def compile_to(name, sources, references, *options):
        dll = staging / name
        run([*compiler, *("-r:" + str(p) for p in references), "-out:" + str(dll), *options, *sources], check=True)
        return dll

    edits = compile_to("AiCompatibilityEdits.dll", [here / "OptionalAiSource.cs", here / "AiRepairs.cs",
        dev / "guard-ai/GuardConstructionRepairs.cs", dev / "scom-wandering/LocalConstructionRoutes.cs",
        dev / "scom-optimize/ReclaimWorkSavings.cs"], managed, "-target:library", "-langversion:9")
    directory = dev / "scom-battle-presentation"
    resources = ["-resource:" + str(directory / "transport" / (name + ".lua")) +
                 ",Scom.TransportColossus." + name + ".lua" for name in ("template", "transport", "attachments", "prefab", "tractor")]
    presentation = compile_to("SCOM.GameplayPresentation.dll", [directory / "GameplayPresentation.cs",
        directory / "ObserverEconomyRepairs.cs", directory / "ground/GroundContacts.cs",
        directory / "transport/TransportColossus.cs"], managed, "-target:library", *resources)
    builder = compile_to("BuildAiCompatibility.dll", [here / "BuildAiCompatibility.cs", pack_shatter],
                         [*sorted(ref.glob("*.dll")), cecil], "-main:BuildAiCompatibility")
    shutil.copy2(cecil, staging / cecil.name)
    builder.with_suffix(".runtimeconfig.json").write_text('{"runtimeOptions":{"tfm":"net8.0","framework":{"name":"Microsoft.NETCore.App","version":"8.0.0"}}}')
    candidate = staging / "Scom-patcher.dll"
    run([dotnet, builder, engine, original, edits, presentation, candidate], check=True)
    checks = compile_to("VerifyAiDrift.dll", [here / "VerifyAiDrift.cs"], sorted(ref.glob("*.dll")))
    shutil.copy2(builder.with_suffix(".runtimeconfig.json"), checks.with_suffix(".runtimeconfig.json"))
    release = staging / "release" / "Scom-patcher.dll"
    with candidate.open("rb") as stream:
        digest = hashlib.file_digest(stream, "sha256").hexdigest()
    version_builder = dev.parent / "menu-ui/rebuild/build_version.py"
    run([sys.executable, version_builder, "--engine", engine, "--dotnet", dotnet,
         "--input", candidate, "--output", release, "--work", staging / "version",
         "--expected-sha256", digest], check=True)
    run([dotnet, checks, engine, mod_sources, original, release], check=True)
    os.link(release, output)
