-- uss2510: Aezthu-uhthe
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoFactoryEgress"] = {
            targetId = "uss2510",
            sourceId = "XSB0304",
            domain = "land",
            buildOffset = { x = 0, y = 0.41512866973877, z = 0 },
            bounds = {
                min = { x = -3.01929330825806, y = 0.00735238008201122, z = -2.40421104431152 },
                max = { x = 3.01929402351379, y = 5.10689926147461, z = 3.3740394115448 },
            },
            exitRoutes = {
                {
                    headingDegrees = 0,
                    waypoints = {
                        { x = 0, y = 0.41251, z = 0 },
                        { x = 0, y = 0.41251, z = 0.125 },
                        { x = 0, y = 0.41251, z = 0.25 },
                        { x = 0, y = 0.41251, z = 0.375 },
                        { x = 0, y = 0.41251, z = 0.5 },
                        { x = 0, y = 0.41251, z = 0.625 },
                        { x = 0, y = 0.412509, z = 0.75 },
                        { x = 0, y = 0.412509, z = 0.875 },
                        { x = 0, y = 0.404472, z = 1 },
                        { x = 0, y = 0.343711, z = 1.125 },
                        { x = 0, y = 0.267703, z = 1.25 },
                        { x = 0, y = 0.996796, z = 1.375 },
                        { x = 0, y = 0, z = 1.5 },
                        { x = 0, y = 0, z = 1.625 },
                        { x = 0, y = 0.113184, z = 1.75 },
                        { x = 0, y = 0.267083, z = 1.875 },
                        { x = 0, y = 0.267083, z = 2 },
                        { x = 0, y = 0.267083, z = 2.125 },
                        { x = 0, y = 0.267083, z = 2.25 },
                        { x = 0, y = 0.267083, z = 2.375 },
                        { x = 0, y = 0.267082, z = 2.5 },
                        { x = 0, y = 0.267082, z = 2.625 },
                        { x = 0, y = 0.267082, z = 2.75 },
                        { x = 0, y = 0.267082, z = 2.875 },
                        { x = 0, y = 0.160316, z = 3 },
                    },
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixSeraphimGateway"] = {
            ["canBuild"] = "Tags.usl4002",
            ["factoryClass"] = "SeraphimLandFactory",
            ["version"] = "1.0.0",
        },
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
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 4,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 1,
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
        ["canBuild"] = "(Tags.usl4002) * Tags.SCFA_ALLUNITS",
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
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandFactory",
        },
        ["displayName"] = "Aezthu-uhthe",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "none",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure2_none.png",
        ["iconUIBuildSortPriority"] = 400,
        ["iconUIType"] = "land",
        ["name"] = "Aezthu-uhthe",
        ["orders"] = {
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["RepeatBuild"] = true,
        },
        ["tpId"] = "uss2510",
        ["unitTypeName"] = "UnknownT3Structure",
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
        [2] = "LAND",
        [3] = "SCFA_ALLUNITS",
        [4] = "SCFA_BUILTBYTIER3COMMANDER",
        [5] = "SCFA_BUILTBYTIER3ENGINEER",
        [6] = "SCFA_DRAGBUILD",
        [7] = "SCFA_FACTORY",
        [8] = "SCFA_GATE",
        [9] = "SCFA_PRODUCTFA",
        [10] = "SCFA_RALLYPOINT",
        [11] = "SCFA_RECLAIMABLE",
        [12] = "SCFA_SELECTABLE",
        [13] = "SCFA_SERAPHIM",
        [14] = "SCFA_SHOWQUEUE",
        [15] = "SCFA_SIZE20",
        [16] = "SCFA_SORTSTRATEGIC",
        [17] = "SCFA_STRUCTURE",
        [18] = "SCFA_TECH3",
        [19] = "SCFA_VISIBLETORECON",
        [20] = "SERAPHIM",
        [21] = "STRUCTURE",
        [22] = "TECH3",
        [23] = "FACTORY",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2510/LOD0/uss2510.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2510/LOD0/uss2510.sananimation",
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
            ["onDeath"] = {
                [1] = {
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd2301_death_building_large.sanvfx",
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
            ["lod0distance"] = 167,
            ["lod1distance"] = 436,
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
