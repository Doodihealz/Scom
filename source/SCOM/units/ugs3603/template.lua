-- ugs3603: Mass Fabricator
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
            ["mapping"] = "URB1303 -> ugs3603",
            ["sanctuaryAdjacency"] = "T3AlloyFabricatorAdjacencyBuff",
            ["sanctuarySkirtOffsetSupported"] = false,
            ["sourceAdjacency"] = "T3MassFabricatorAdjacencyBuffs",
            ["sourceBlueprint"] = "units/URB1303/URB1303_unit.bp",
            ["sourceBlueprintSha256"] = "bf7930986d1b416fc4db68e070f4b1249d2edce04c82415c03791f62ab79ae75",
            ["sourceScript"] = "units/URB1303/URB1303_script.lua",
            ["sourceScriptSha256"] = "5a29e3fb5be7a66c892cfaa23021777d4773be82a7fa00abf20dd302eac35400",
            ["sourceSkirtOffset"] = {
                ["x"] = -1.5,
                ["z"] = -1.5,
            },
            ["spinner"] = {
                ["acceleration"] = 10,
                ["axis"] = "z",
                ["bone"] = "Spinner",
                ["targetSpeed"] = 60,
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
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.3,
            ["y"] = 3.2,
            ["z"] = 1.3,
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
            [1] = "unitsDefaultGuard",
            [2] = "GuardSupComMassFabricator",
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
        ["tpId"] = "ugs3603",
        ["unitTypeName"] = "GuardT3AlloyFurnace",
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
        [4] = "GUARD",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_CYBRAN",
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
                    ["particleName"] = "VFX/Death/vgd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.23399999999999999,
                    ["y"] = 0.55,
                    ["z"] = -0.26,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.28600000000000003,
                    ["y"] = 0.32599999999999996,
                    ["z"] = 0.23399999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.26,
                    ["y"] = 0.6460000000000001,
                    ["z"] = 0.20800000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.23399999999999999,
                    ["y"] = 1.094,
                    ["z"] = -0.26,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.28600000000000003,
                    ["y"] = 1.0300000000000002,
                    ["z"] = 0.23399999999999999,
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
