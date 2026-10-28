-- ucs4102: Paragon
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["deathClip"] = {
                ["durationSeconds"] = 1,
                ["key"] = "source_animadeath",
                ["rate"] = 1,
            },
            ["kind"] = "paragon_rotor_death",
            ["mapping"] = "XAB1401 -> ucs4102",
            ["rotatorCount"] = 1,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/XAB1401/XAB1401_unit.bp",
            ["sourceBlueprintSha256"] = "8002739b4c792f498d8dc4ed779f26bfdffe2c748e629163170158d0a66222b9",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 1,
                    ["frames"] = 31,
                    ["key"] = "source_animadeath",
                    ["name"] = "AnimAdeath",
                    ["rate"] = 1,
                    ["role"] = "death",
                    ["sha256"] = "aea31fdc1a6f905aafc3d60524cfa55276f04e727514d8dd3a813b7a53b4cff9",
                    ["source"] = "units/XAB1401/XAB1401_Adeath.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "6eac84a1404e73ce1d56ce802865499f6e15d0febfa9a11296442eff2241bcb4",
            ["sourceScript"] = "units/XAB1401/XAB1401_script.lua",
            ["sourceScriptSha256"] = "e0cc2ad914d66ef43330a1536d0220066eafd382f775eb5e00d36aad041ab855",
            ["stateOwner"] = "Orb/y accelerates at 15 to deterministic source expression 80 +/- 0..20 continuously, independent of production Pause; death owns the one-second authored clip before stock wreck/delete.",
            ["targetAnimation"] = {
                ["bytes"] = 15146,
                ["path"] = "Units/ucs4102/LOD0/ucs4102.sananimation",
                ["sha256"] = "dd91105c12a86947fe7a8cceff74cbe7c977f2ed04ee2fd3cfe39e0ea14fd8d8",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 254157,
                ["path"] = "Units/ucs4102/LOD0/ucs4102_lod0.sanmodel",
                ["sha256"] = "86308b50e880b3c1b537bdb9d3bc50e216c3c8ed29ba2f7c54a89a554492b03c",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 1966,
                ["path"] = "Units/ucs4102/LOD0/ucs4102.sanskeleton",
                ["sha256"] = "67c5ce6e621918873e416dfb6908bc77c53b26c471175c42bf6ec5446c613cd8",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 15,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 7,
                    ["z"] = 7,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 10,
                    ["sizeZ"] = 10,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/XAB1401/XAB1401_unit.bp",
            ["sourceBlueprintSha256"] = "8002739b4c792f498d8dc4ed779f26bfdffe2c748e629163170158d0a66222b9",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3COMMANDER",
                [3] = "BUILTBYTIER3ENGINEER",
                [4] = "DRAGBUILD",
                [5] = "ECONOMIC",
                [6] = "ENERGYPRODUCTION",
                [7] = "EXPERIMENTAL",
                [8] = "MASSFABRICATION",
                [9] = "MASSPRODUCTION",
                [10] = "PRODUCTFA",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "SIZE12",
                [14] = "STRUCTURE",
                [15] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "XAB1401",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB1104",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs4102",
            ["weapons"] = {
                [1] = {
                    ["label"] = "DeathWeapon",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {},
                    ["rateOfFire"] = 0,
                    ["reloadTime"] = 0,
                    ["sourceCategory"] = "Death",
                    ["sourceProjectile"] = "",
                },
            },
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Orb",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixParagonDeath"] = {
            ["damageFriendly"] = true,
            ["rings"] = {
                [1] = {
                    ["damage"] = 35000,
                    ["radius"] = 25,
                },
                [2] = {
                    ["damage"] = 35000,
                    ["radius"] = 25,
                },
            },
            ["sourceBlueprintSha256"] = "8002739b4c792f498d8dc4ed779f26bfdffe2c748e629163170158d0a66222b9",
            ["sourceId"] = "XAB1401",
        },
        ["scoFieldFixParagonEconomy"] = {
            ["baselineAlloysPerSecond"] = 20,
            ["baselineEnergyPerSecond"] = 1000,
            ["maxAlloysPerSecond"] = 10000,
            ["maxEnergyPerSecond"] = 1000000,
            ["sampleSeconds"] = 0.5,
            ["sourceId"] = "XAB1401",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.4,
                ["y"] = 3.4,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 2,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 4,
            ["y"] = 4,
            ["z"] = 4,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 5000,
            ["regen"] = 0,
            ["value"] = 5000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 125100,
        ["cost"] = {
            ["alloys"] = 250200,
            ["energy"] = 7506000,
        },
        ["production"] = {
            ["alloys"] = 20,
            ["energy"] = 1000,
        },
    },
    ["footprint"] = {
        ["x"] = 7,
        ["y"] = 7,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Paragon",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_experimental1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Paragon",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs4102",
        ["unitTypeName"] = "Paragon",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
    },
    ["skirtSize"] = {
        ["x"] = 10,
        ["y"] = 10,
    },
    ["tags"] = {
        [1] = "ALLOYS_PRODUCTION",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CHOSEN",
        [4] = "ECONOMIC",
        [5] = "ENERGY_PRODUCTION",
        [6] = "STRUCTURE",
        [7] = "TECH4",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_ECONOMIC",
        [14] = "SCFA_ENERGYPRODUCTION",
        [15] = "SCFA_EXPERIMENTAL",
        [16] = "SCFA_MASSFABRICATION",
        [17] = "SCFA_MASSPRODUCTION",
        [18] = "SCFA_PRODUCTFA",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SIZE12",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs4102/LOD0/ucs4102.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs4102/LOD0/ucs4102.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 20,
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 3,
                    ["z"] = -0.8,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 2.7199999999999998,
                    ["z"] = 0.72,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8,
                    ["y"] = 3.12,
                    ["z"] = 0.64,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 3.6799999999999997,
                    ["z"] = -0.8,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 3.6,
                    ["z"] = 0.72,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 67,
            ["lod1distance"] = 175,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.4,
                ["y"] = 3.4,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 0,
            ["damageFriendly"] = true,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
        },
    },
}
