-- uss3102: Hastue
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faAnimationClosureWeaponDeploy"] = {
            ["authoredDurationSeconds"] = 3.33333325386047,
            ["authoredRate"] = 0.4,
            ["deployAnimationKey"] = "fa_deploy",
            ["mapping"] = "XSB2305 -> uss3102",
            ["packedAnimationKey"] = "fa_packed",
            ["repackTimeoutSeconds"] = 5,
            ["sourceAnimation"] = "units/XSB2305/XSB2305_aopen.sca",
            ["sourceAnimationSha256"] = "fcbcd5c80aed64402cbc4e211cc4356a566442e696236676b392b97f3de6f751",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprintSha256"] = "e3ded95d2d2b1b56235c70f3b2d6bae9e3cfb220bd02156a780f3f90c79b6017",
            ["sourceModelSha256"] = "4b375c79f1521673d012021db96fd172101559fe3328e44dc423259119bae469",
            ["sourceScriptSha256"] = "2edf65be60a5d261261f4535f13a5d51a1d79c6b28472a85d5a045414f60e6cb",
            ["sourceWeaponUnpackLocksMotion"] = false,
            ["sourceWeaponUnpacks"] = true,
            ["transitionSeconds"] = 8.333333134651175,
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["scoStrategicSilo"] = {
            ["buildOrder"] = "ManualFire1",
            ["buildPower"] = 1080,
            ["buildTime"] = 324000,
            ["cost"] = {
                ["alloys"] = 12000,
                ["energy"] = 1350000,
            },
            ["damageFriendly"] = true,
            ["defaultAutoBuild"] = true,
            ["initialAmmo"] = 0,
            ["initialProjectileSpeed"] = 1,
            ["innerDamage"] = {
                ["amount"] = 70000,
                ["radius"] = 30,
                ["ticks"] = 24,
                ["totalTime"] = 0,
            },
            ["launchOrder"] = "ManualFire2",
            ["maxAmmo"] = 5,
            ["muzzle"] = "Projectile01",
            ["outerDamage"] = {
                ["amount"] = 500,
                ["radius"] = 40,
                ["ticks"] = 20,
                ["totalTime"] = 0,
            },
            ["projectileLifetime"] = 600,
            ["projectileTemplate"] = "psn004",
            ["rangeMax"] = 20000,
            ["rangeMin"] = 0,
            ["terrainClearance"] = 0.05,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.55,
                ["y"] = 1.55,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2,
            ["y"] = 1,
            ["z"] = 2,
        },
    },
    ["construction"] = {
        ["buildPower"] = 1080,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4000,
            ["regen"] = 0,
            ["value"] = 4000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 9000,
        ["cost"] = {
            ["alloys"] = 15000,
            ["energy"] = 210000,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Hastue",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "Hastue",
        ["orders"] = {
            ["ManualFire1"] = true,
            ["ManualFire2"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "uss3102",
        ["unitTypeName"] = "UnknownT3StrategicLauncher",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20000,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
    },
    ["skirtSize"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "SCFA_ALLUNITS",
        [3] = "SCFA_BUILTBYTIER3COMMANDER",
        [4] = "SCFA_BUILTBYTIER3ENGINEER",
        [5] = "SCFA_DRAGBUILD",
        [6] = "SCFA_NUKE",
        [7] = "SCFA_PRODUCTFA",
        [8] = "SCFA_RECLAIMABLE",
        [9] = "SCFA_SELECTABLE",
        [10] = "SCFA_SERAPHIM",
        [11] = "SCFA_SILO",
        [12] = "SCFA_SIZE12",
        [13] = "SCFA_SORTSTRATEGIC",
        [14] = "SCFA_STRATEGIC",
        [15] = "SCFA_STRUCTURE",
        [16] = "SCFA_TECH3",
        [17] = "SCFA_VISIBLETORECON",
        [18] = "SERAPHIM",
        [19] = "STRATEGIC",
        [20] = "STRUCTURE",
        [21] = "TECH3",
        [22] = "NUKE",
        [23] = "SILO",
        [24] = "INDIRECT_FIRE",
    },
    ["visuals"] = {
        ["animations"] = {
            ["fa_deploy"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3102/LOD0/uss3102.sananimation",
            },
            ["fa_packed"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3102/LOD0/uss3102.sananimation",
            },
            ["source_rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3102/LOD0/uss3102.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3102/LOD0/uss3102.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 15,
            },
            ["progressBars"] = {
                [1] = {
                    ["colorBackground"] = {
                        ["a"] = 1,
                        ["x"] = 0,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["colorEmpty"] = {
                        ["a"] = 1,
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["colorFull"] = {
                        ["a"] = 1,
                        ["x"] = 0,
                        ["y"] = 1,
                        ["z"] = 0,
                    },
                    ["mainBar"] = true,
                    ["name"] = "Health",
                    ["property"] = "Health_Current",
                    ["xOffset"] = 0,
                    ["xScale"] = 1,
                },
            },
            ["subBarDisplayScale"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
            ["subBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 0,
            },
        },
        ["effectsInstant"] = {
            ["onDeath"] = {
                [1] = {
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.5,
                    ["z"] = -0.4,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.43,
                    ["z"] = 0.36,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.4,
                    ["y"] = 0.53,
                    ["z"] = 0.32,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.6699999999999999,
                    ["z"] = -0.4,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.65,
                    ["z"] = 0.36,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 78,
            ["lod1distance"] = 203,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.55,
                ["y"] = 1.55,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 10000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 6,
            ["damageType"] = "Normal",
            ["scoFaMissingWeapon"] = {
                ["sourceBlueprintSha256"] = "e3ded95d2d2b1b56235c70f3b2d6bae9e3cfb220bd02156a780f3f90c79b6017",
                ["sourceId"] = "XSB2305",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "DeathWeapon",
            },
            ["scoFaSourceWeaponIndex"] = 2,
        },
    },
}
