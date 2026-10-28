-- ucs3603: Mass Fabricator
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "fabricator_rotators",
            ["mapping"] = "UAB1303 -> ucs3603",
            ["rotatorCount"] = 4,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1303/UAB1303_unit.bp",
            ["sourceBlueprintSha256"] = "dfc725ed7309bf0bb00f1bd07b83cd25d356413cc9783cee81be55463f237be1",
            ["sourceClips"] = {},
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "4a42b7acc86c3f52f89b8bcea260654156cb33c9c6fd298d34d0c2ae8e20f040",
            ["sourceScript"] = "units/UAB1303/UAB1303_script.lua",
            ["sourceScriptSha256"] = "92f909396efb0438cf29af3316b394746a24e6efbc769566433cb34460fb3f79",
            ["stateOwner"] = "All axes accelerate at 15: B01/x=45, B02/x=-45, while B03/y and B04/x/y/z use one deterministic source sign with 80 +/- 0..20. Production toggle-off spins down at 15 and selects the next deterministic source-range goals; toggle-on accelerates to them. Generic Pause does not own these rotators.",
            ["targetAnimation"] = {
                ["bytes"] = 3763,
                ["path"] = "Units/ucs3603/LOD0/ucs3603.sananimation",
                ["sha256"] = "3bb785db258beda23e2d5a68f5cf2e0b48b045fb16fd74ab5d3692be4f149200",
            },
            ["targetClipCount"] = 1,
            ["targetModel"] = {
                ["bytes"] = 399249,
                ["path"] = "Units/ucs3603/LOD0/ucs3603_lod0.sanmodel",
                ["sha256"] = "a069a0660e28b3d9310c263b7aa641f6e069f2246f857e90d4ea6720f389b52d",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 4951,
                ["path"] = "Units/ucs3603/LOD0/ucs3603.sanskeleton",
                ["sha256"] = "1afc8f0ae1372353634b280df30b338d6568e412b8315235cc3f1e99fa3f1422",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 20,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 3,
                    ["z"] = 3,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 6,
                    ["sizeZ"] = 6,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1303/UAB1303_unit.bp",
            ["sourceBlueprintSha256"] = "dfc725ed7309bf0bb00f1bd07b83cd25d356413cc9783cee81be55463f237be1",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3COMMANDER",
                [3] = "BUILTBYTIER3ENGINEER",
                [4] = "DRAGBUILD",
                [5] = "ECONOMIC",
                [6] = "MASSFABRICATION",
                [7] = "MASSPRODUCTION",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "SIZE12",
                [12] = "SORTECONOMY",
                [13] = "STRUCTURE",
                [14] = "TECH3",
                [15] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB1303",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB1104",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3603",
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
                ["boneName"] = "B01",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["boneName"] = "B02",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [3] = {
                ["boneName"] = "B03",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [4] = {
                ["boneName"] = "B04",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFaAdjacency"] = {
            ["nativeAdjacency"] = "T3AlloyFabricatorAdjacencyBuff",
            ["parityLimitation"] = "Native T3 alloy-fabricator adjacency uses its native discount instead of FA's -0.075 footprint buffs.",
            ["sourceAdjacency"] = "T3MassFabricatorAdjacencyBuffs",
            ["sourceBlueprintSha256"] = "dfc725ed7309bf0bb00f1bd07b83cd25d356413cc9783cee81be55463f237be1",
            ["sourceId"] = "UAB1303",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.625,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.55,
                ["y"] = 1.55,
            },
        },
    },
    ["adjacency"] = "T3AlloyFabricatorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.625,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.75,
            ["y"] = 1.75,
            ["z"] = 1.75,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 6000,
            ["regen"] = 0,
            ["value"] = 6000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 3750,
        ["cost"] = {
            ["alloys"] = 3000,
            ["energy"] = 65000,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 3500,
        },
        ["production"] = {
            ["alloys"] = 12,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
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
        ["tpId"] = "ucs3603",
        ["unitTypeName"] = "Mass Fabricator",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["skirtSize"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "ALLOYS_PRODUCTION",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CHOSEN",
        [4] = "ECONOMIC",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_ECONOMIC",
        [13] = "SCFA_MASSFABRICATION",
        [14] = "SCFA_MASSPRODUCTION",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SIZE12",
        [19] = "SCFA_SORTECONOMY",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3603/LOD0/ucs3603.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 1.0625,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 0.94,
                    ["z"] = 0.315,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.35000000000000003,
                    ["y"] = 1.115,
                    ["z"] = 0.28,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 1.3599999999999999,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 1.3250000000000002,
                    ["z"] = 0.315,
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
                ["y"] = 0.625,
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
            ["damage"] = 5000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 14,
            ["damageType"] = "Normal",
        },
    },
}
