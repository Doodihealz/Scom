-- ucs2510: Portal
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoFactoryEgress"] = {
            targetId = "ucs2510",
            sourceId = "UAB0304",
            domain = "land",
            buildOffset = { x = 0, y = 0.392288935184479, z = 0 },
            bounds = {
                min = { x = -3.11280035972595, y = 0.00999885704368353, z = -3.26431632041931 },
                max = { x = 3.11280035972595, y = 2.21375608444214, z = 3.26431679725647 },
            },
            exitRoutes = {
                {
                    headingDegrees = 0,
                    waypoints = {
                        { x = 0, y = 0.389781, z = 0 },
                        { x = 0, y = 0.389781, z = 0.125 },
                        { x = 0, y = 0.389781, z = 0.25 },
                        { x = 0, y = 0.389781, z = 0.375 },
                        { x = 0, y = 0.389781, z = 0.5 },
                        { x = 0, y = 0.389781, z = 0.625 },
                        { x = 0, y = 0.389781, z = 0.75 },
                        { x = 0, y = 0.389781, z = 0.875 },
                        { x = 0, y = 0.389781, z = 1 },
                        { x = 0, y = 0.389781, z = 1.125 },
                        { x = 0, y = 0.361969, z = 1.25 },
                        { x = 0, y = 0.361969, z = 1.375 },
                        { x = 0, y = 0.361969, z = 1.5 },
                        { x = 0, y = 0.361969, z = 1.625 },
                        { x = 0, y = 0.361969, z = 1.75 },
                        { x = 0, y = 0.361969, z = 1.875 },
                        { x = 0, y = 0.361969, z = 2 },
                        { x = 0, y = 0.361969, z = 2.125 },
                        { x = 0, y = 0.325426, z = 2.25 },
                        { x = 0, y = 0.288745, z = 2.375 },
                        { x = 0, y = 0.252065, z = 2.5 },
                        { x = 0, y = 0.215384, z = 2.625 },
                        { x = 0, y = 0.178704, z = 2.75 },
                        { x = 0, y = 0.142029, z = 2.875 },
                        { x = 0, y = 0.105365, z = 3 },
                    },
                },
                {
                    headingDegrees = 180,
                    waypoints = {
                        { x = 0, y = 0.389781, z = 0 },
                        { x = 0, y = 0.389781, z = -0.125 },
                        { x = 0, y = 0.389781, z = -0.25 },
                        { x = 0, y = 0.389781, z = -0.375 },
                        { x = 0, y = 0.389781, z = -0.5 },
                        { x = 0, y = 0.389781, z = -0.625 },
                        { x = 0, y = 0.389781, z = -0.75 },
                        { x = 0, y = 0.389781, z = -0.875 },
                        { x = 0, y = 0.389781, z = -1 },
                        { x = 0, y = 0.389781, z = -1.125 },
                        { x = 0, y = 0.361969, z = -1.25 },
                        { x = 0, y = 0.361969, z = -1.375 },
                        { x = 0, y = 0.361969, z = -1.5 },
                        { x = 0, y = 0.361969, z = -1.625 },
                        { x = 0, y = 0.361969, z = -1.75 },
                        { x = 0, y = 0.361969, z = -1.875 },
                        { x = 0, y = 0.361969, z = -2 },
                        { x = 0, y = 0.361969, z = -2.125 },
                        { x = 0, y = 0.325425, z = -2.25 },
                        { x = 0, y = 0.288745, z = -2.375 },
                        { x = 0, y = 0.252064, z = -2.5 },
                        { x = 0, y = 0.215384, z = -2.625 },
                        { x = 0, y = 0.178703, z = -2.75 },
                        { x = 0, y = 0.142028, z = -2.875 },
                        { x = 0, y = 0.105365, z = -3 },
                    },
                },
            },
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
            ["sourceBlueprint"] = "units/UAB0304/UAB0304_unit.bp",
            ["sourceBlueprintSha256"] = "3e0029f156b49dd168a2f0bd3b46086c3f1e3be1c4f7ec4c899fa9e49f7a71d7",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3COMMANDER",
                [3] = "BUILTBYTIER3ENGINEER",
                [4] = "DRAGBUILD",
                [5] = "FACTORY",
                [6] = "GATE",
                [7] = "PRODUCTSC1",
                [8] = "RALLYPOINT",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "SHOWQUEUE",
                [12] = "SIZE20",
                [13] = "SORTSTRATEGIC",
                [14] = "STRUCTURE",
                [15] = "TECH3",
                [16] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB0304",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs2510",
            ["weapons"] = {},
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.75,
                ["y"] = 3.5,
            },
        },
    },
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aclu2520",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.75,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 5,
            ["y"] = 1.5,
            ["z"] = 5,
        },
    },
    ["construction"] = {
        ["platformBoneName"] = "Attachpoint",
        ["buildPower"] = 120,
        ["canBuild"] = "(Tags.ucl4002) * Tags.SCFA_ALLUNITS",
        ["rollOffPoints"] = {
            [1] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 3,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 0,
            },
            [2] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -3,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 180,
            },
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10000,
            ["regen"] = 0,
            ["value"] = 10000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 3000,
        ["cost"] = {
            ["alloys"] = 3000,
            ["energy"] = 30000,
        },
    },
    ["footprint"] = {
        ["x"] = 7,
        ["y"] = 7,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandFactory",
        },
        ["displayName"] = "Portal",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "land",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure2_land.png",
        ["iconUIBuildSortPriority"] = 400,
        ["iconUIType"] = "land",
        ["name"] = "Portal",
        ["orders"] = {
            ["Assist"] = true,
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["RepeatBuild"] = true,
        },
        ["tpId"] = "ucs2510",
        ["unitTypeName"] = "Portal",
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
        ["x"] = 10,
        ["y"] = 10,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "CHOSEN",
        [3] = "FACTORY",
        [4] = "STRUCTURE",
        [5] = "TECH3",
        [6] = "SCFA_AEON",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_FACTORY",
        [12] = "SCFA_GATE",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RALLYPOINT",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SHOWQUEUE",
        [18] = "SCFA_SIZE20",
        [19] = "SCFA_SORTSTRATEGIC",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2510/LOD0/ucs2510.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 1,
                ["y"] = 1,
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
            ["onConstructionCompleted"] = {
                [1] = {
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Unit/vcu1311_factory_finish_t1.sanvfx",
                },
            },
            ["onDeath"] = {
                [1] = {
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8999999999999999,
                    ["y"] = 1.125,
                    ["z"] = -1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.1,
                    ["y"] = 1.02,
                    ["z"] = 0.8999999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1,
                    ["y"] = 1.17,
                    ["z"] = 0.8,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8999999999999999,
                    ["y"] = 1.38,
                    ["z"] = -1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.1,
                    ["y"] = 1.35,
                    ["z"] = 0.8999999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 132,
            ["lod1distance"] = 345,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.75,
                ["y"] = 3.5,
            },
        },
    },
}
