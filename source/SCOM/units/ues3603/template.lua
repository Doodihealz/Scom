-- ues3603: Mass Fabricator
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["audio"] = {
                ["donorDestroyedOneShotRetained"] = true,
                ["donorRootPersistentLoopRetained"] = false,
                ["sourceActivationCuesSupported"] = false,
                ["sourceBanksImported"] = false,
            },
            ["mapping"] = "UEB1303 -> ues3603",
            ["sanctuaryAdjacency"] = "T3AlloyFabricatorAdjacencyBuff",
            ["sanctuarySkirtOffsetSupported"] = false,
            ["sourceAdjacency"] = "T3MassFabricatorAdjacencyBuffs",
            ["sourceAmbientEmitter"] = "/effects/emitters/uef_t3_massfab_ambient_01_emit.bp",
            ["sourceBlueprint"] = "units/UEB1303/UEB1303_unit.bp",
            ["sourceBlueprintSha256"] = "fbb11aa62f87e520fea91e63f7f7f9bedb83fb1f2f59f7e78bd031522496ba4b",
            ["sourceEmitterGraphSupported"] = false,
            ["sourceScript"] = "units/UEB1303/UEB1303_script.lua",
            ["sourceScriptSha256"] = "4377bad9f2c57249e54cca725bc6b201b6d287e6239dd1cb139f593ff1435bf7",
            ["sourceSkirtOffset"] = {
                ["x"] = -1.5,
                ["z"] = -1.5,
            },
            ["spinner"] = {
                ["acceleration"] = 10,
                ["axis"] = "z",
                ["bone"] = "Spinner",
                ["targetSpeed"] = 40,
            },
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Spinner",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
    },
    ["adjacency"] = "T3AlloyFabricatorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.75,
            ["y"] = 2.1,
            ["z"] = 1.875,
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
            [1] = "unitsDefaultEDA",
            [2] = "EDASupComMassFabricator",
        },
        ["displayName"] = "Mass Fabricator",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 350,
        ["iconUIType"] = "land",
        ["name"] = "Mass Fabricator",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Production"] = true,
        },
        ["tpId"] = "ues3603",
        ["unitTypeName"] = "EDAT3AlloyFurnace",
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
        [3] = "ECONOMIC",
        [4] = "EDA",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_ECONOMIC",
        [12] = "SCFA_MASSFABRICATION",
        [13] = "SCFA_MASSPRODUCTION",
        [14] = "SCFA_PRODUCTSC1",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SIZE12",
        [18] = "SCFA_SORTECONOMY",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH3",
        [21] = "SCFA_UEF",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
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
                    ["particleName"] = "VFX/Death/ved2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 0.275,
                    ["z"] = -0.375,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 0.128,
                    ["z"] = 0.33749999999999997,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.35000000000000003,
                    ["y"] = 0.3380000000000001,
                    ["z"] = 0.3,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 0.632,
                    ["z"] = -0.375,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 0.5900000000000001,
                    ["z"] = 0.33749999999999997,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 106,
            ["lod1distance"] = 276,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
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
