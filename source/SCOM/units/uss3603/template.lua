-- uss3603: Hyaliya
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["sourceBlueprint"] = "units/XSB1303/XSB1303_unit.bp",
            ["sourceBlueprintSha256"] = "009adb261deefbb544dba5abb8785da2bcf1c1e84ec6abcc12a314228755bf75",
            ["sourceId"] = "XSB1303",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1551,
                ["entry"] = "units/XSB1303/XSB1303_script.lua",
                ["sha256"] = "4f511d03ea361847bb861381b92d65ec06227370e7a5f2b214464ec2cb5cf8d8",
            },
            ["targetId"] = "uss3603",
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {},
            ["forceSimulatedRotators"] = true,
            ["legacyTemplateClass"] = "SeraphimAlloyExtractor",
            ["meshes"] = {},
            ["rotators"] = {
                [1] = {
                    ["acceleration"] = 15,
                    ["axis"] = "y",
                    ["bone"] = "Blades01",
                    ["condition"] = "production",
                    ["delay"] = 0,
                    ["disabledAcceleration"] = 15,
                    ["initialSpeed"] = 0,
                    ["speed"] = -30,
                },
                [2] = {
                    ["acceleration"] = 15,
                    ["axis"] = "y",
                    ["bone"] = "Blades02",
                    ["condition"] = "production",
                    ["delay"] = 0,
                    ["disabledAcceleration"] = 15,
                    ["initialSpeed"] = 0,
                    ["speed"] = 45,
                },
                [3] = {
                    ["acceleration"] = 15,
                    ["axis"] = "y",
                    ["bone"] = "Blades03",
                    ["condition"] = "production",
                    ["delay"] = 0,
                    ["disabledAcceleration"] = 15,
                    ["initialSpeed"] = 0,
                    ["speed"] = -60,
                },
            },
            ["sourceBlueprint"] = "units/XSB1303/XSB1303_unit.bp",
            ["sourceBlueprintSha256"] = "009adb261deefbb544dba5abb8785da2bcf1c1e84ec6abcc12a314228755bf75",
            ["sourceId"] = "XSB1303",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 152071,
                ["entry"] = "units/XSB1303/XSB1303_lod0.scm",
                ["sha256"] = "0f9d52289cfc929423b7955d134efc9578a5b58372c4c6ac675c9cc21d21720c",
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1551,
                ["entry"] = "units/XSB1303/XSB1303_script.lua",
                ["sha256"] = "4f511d03ea361847bb861381b92d65ec06227370e7a5f2b214464ec2cb5cf8d8",
            },
            ["targetId"] = "uss3603",
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
    ["adjacency"] = "AlloyExtractorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
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
            ["energy"] = 3500,
        },
        ["production"] = {
            ["alloys"] = 12,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimAlloyExtractor",
        },
        ["displayName"] = "Hyaliya",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 350,
        ["iconUIType"] = "land",
        ["name"] = "Hyaliya",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Production"] = true,
        },
        ["tpId"] = "uss3603",
        ["unitTypeName"] = "UnknownT3AlloyFurnace",
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
        [3] = "SERAPHIM",
        [4] = "ECONOMIC",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_ECONOMIC",
        [12] = "SCFA_MASSFABRICATION",
        [13] = "SCFA_MASSPRODUCTION",
        [14] = "SCFA_PRODUCTFA",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SERAPHIM",
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
                ["sanAnimationPath"] = "Units/uss3603/LOD0/uss3603.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
            ["lod0distance"] = 91,
            ["lod1distance"] = 237,
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
            ["damageRadius"] = 10,
            ["damageType"] = "Normal",
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoSourceSecondaryVisuals"]["sourceScript"] = UnitTemplate["additions"]["faSourceContract"]["sourceScript"]
