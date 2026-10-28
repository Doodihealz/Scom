-- ucs2806: Mass Fabricator
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "alternating_fabricator",
            ["mapping"] = "UAB1104 -> ucs2806",
            ["primaryClip"] = {
                ["durationSeconds"] = 4.4,
                ["key"] = "source_animaopen01",
                ["rate"] = 1,
            },
            ["rotatorCount"] = 1,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1104/UAB1104_unit.bp",
            ["sourceBlueprintSha256"] = "3c4eb4cef01985a92ce78af0b587346f9df08d3fc471cb52f22b307e3e47ff5f",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 4.4,
                    ["frames"] = 45,
                    ["key"] = "source_animaopen01",
                    ["name"] = "AnimAopen01",
                    ["rate"] = 1,
                    ["role"] = "open",
                    ["sha256"] = "7e0405219700d0b225dab5a0c6eeb97496a5025185f187a16356011f2196a21f",
                    ["source"] = "units/UAB1104/UAB1104_Aopen01.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "db853eca1d39f76b69609027f38efaa06d94e9dc04803ea086980591233baee9",
            ["sourceScript"] = "units/UAB1104/UAB1104_script.lua",
            ["sourceScriptSha256"] = "ee15feaca98ab858f2e658a77d565b47daf8584dd55c865d34ae88b689dbf295",
            ["stateOwner"] = "Open at rate 1; Axis/z accelerates at 50 through deterministic 120..300 alternating goals; pause stops and reverses open.",
            ["targetAnimation"] = {
                ["bytes"] = 146611,
                ["path"] = "Units/ucs2806/LOD0/ucs2806.sananimation",
                ["sha256"] = "f274c2dd5aaf0e9ef91331ab8e00898a8b77354cb841aaf428dedda01cfb848a",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 120889,
                ["path"] = "Units/ucs2806/LOD0/ucs2806_lod0.sanmodel",
                ["sha256"] = "44d077b4526e16c17a178f2285f1ec595e0fc66a509533de91895500dc0a8247",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 16141,
                ["path"] = "Units/ucs2806/LOD0/ucs2806.sanskeleton",
                ["sha256"] = "96a83e40cef3dc85f32271d9e5666ca8912ea929f6dbc932e3c31c84cbaa2839",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {},
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 2,
                    ["z"] = 2,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = -0.5,
                    ["offsetZ"] = -0.5,
                    ["sizeX"] = 2,
                    ["sizeZ"] = 2,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1104/UAB1104_unit.bp",
            ["sourceBlueprintSha256"] = "3c4eb4cef01985a92ce78af0b587346f9df08d3fc471cb52f22b307e3e47ff5f",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2COMMANDER",
                [3] = "BUILTBYTIER2ENGINEER",
                [4] = "BUILTBYTIER3COMMANDER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "DRAGBUILD",
                [7] = "ECONOMIC",
                [8] = "MASSFABRICATION",
                [9] = "MASSPRODUCTION",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "SIZE4",
                [14] = "SORTECONOMY",
                [15] = "STRUCTURE",
                [16] = "TECH2",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB1104",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "UAB1303",
            ["targetId"] = "ucs2806",
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
                ["boneName"] = "Axis",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFaAdjacency"] = {
            ["nativeAdjacency"] = "T1AlloyFabricatorAdjacencyBuff",
            ["parityLimitation"] = "Native T1 alloy-fabricator adjacency uses one factory/station discount instead of FA footprint scaling.",
            ["sourceAdjacency"] = "T1MassFabricatorAdjacencyBuffs",
            ["sourceBlueprintSha256"] = "3c4eb4cef01985a92ce78af0b587346f9df08d3fc471cb52f22b307e3e47ff5f",
            ["sourceId"] = "UAB1104",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["adjacency"] = "T1AlloyFabricatorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.175,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.75,
            ["y"] = 0.35,
            ["z"] = 0.75,
        },
    },
    ["construction"] = {
        ["upgradesTo"] = "ucs3603",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 360,
            ["regen"] = 0,
            ["value"] = 360,
        },
    },
    ["economy"] = {
        ["buildTime"] = 500,
        ["cost"] = {
            ["alloys"] = 100,
            ["energy"] = 4000,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 150,
        },
        ["production"] = {
            ["alloys"] = 1,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Mass Fabricator",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Mass Fabricator",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Production"] = true,
        },
        ["tpId"] = "ucs2806",
        ["unitTypeName"] = "Mass Fabricator",
    },
    ["intel"] = {
        ["visionRadius"] = 0,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ALLOYS_PRODUCTION",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CHOSEN",
        [5] = "ECONOMIC",
        [6] = "STRUCTURE",
        [7] = "TECH2",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_ECONOMIC",
        [16] = "SCFA_MASSFABRICATION",
        [17] = "SCFA_MASSPRODUCTION",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SIZE4",
        [22] = "SCFA_SORTECONOMY",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animaopen01"] = {
                ["clipName"] = "AnimAopen01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2806/LOD0/ucs2806.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2806/LOD0/ucs2806.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 0.26249999999999996,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.238,
                    ["z"] = 0.135,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.15000000000000002,
                    ["y"] = 0.273,
                    ["z"] = 0.12,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 0.32199999999999995,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.31499999999999995,
                    ["z"] = 0.135,
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
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 370,
            ["damageFriendly"] = true,
            ["damageRadius"] = 5,
            ["damageType"] = "Normal",
        },
    },
}
