-- usl4401: Athanah
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 1.1035131835937544,
                [3] = -3.803171390596245e-08,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0307",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 78790,
                ["entry"] = "units/XSL0307/XSL0307_lod0.scm",
                ["sha256"] = "c9a677abbaafc807088b869380896ea395cf943a91d8813b9c5a53e54ed88d7f",
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.7,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1144",
        },
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1440",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 0.5,
            ["z"] = 0.8,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 400,
            ["regen"] = 0,
            ["value"] = 400,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["max"] = 10000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -3,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 10,
                    ["y"] = 10,
                    ["z"] = 10,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 45,
                ["regen"] = 133,
                ["regenDelay"] = 1,
                ["scoDamageRechargeTime"] = 45,
                ["scoEnergyDrainRechargeTime"] = 5,
                ["scoFaAthanahShield"] = true,
                ["type"] = 0,
                ["value"] = 10000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 3200,
        ["cost"] = {
            ["alloys"] = 640,
            ["energy"] = 4800,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 300,
        },
    },
    ["footprint"] = {
        ["x"] = 0.8,
        ["y"] = 0.8,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Athanah",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "shield",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_land1_shield.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Athanah",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "usl4401",
        ["unitTypeName"] = "UnknownT4MobileShield",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 4,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandLarge",
            [2] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandLarge",
            [2] = "Sea",
        },
        ["deceleration"] = 4,
        ["mass"] = 0,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0.25,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 150,
        ["sortOrder"] = 4,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
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
    ["tags"] = {
        [1] = "BOT",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "MOBILE",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER3FACTORY",
        [6] = "SCFA_DEFENSE",
        [7] = "SCFA_HOVER",
        [8] = "SCFA_LAND",
        [9] = "SCFA_MOBILE",
        [10] = "SCFA_OVERLAYDEFENSE",
        [11] = "SCFA_PRODUCTFA",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SERAPHIM",
        [15] = "SCFA_SHIELD",
        [16] = "SCFA_TECH3",
        [17] = "SCFA_VISIBLETORECON",
        [18] = "SERAPHIM",
        [19] = "SHIELD",
        [20] = "TECH3",
        [21] = "HOVER",
        [22] = "LAND",
        [23] = "BUILDABLE_BY_T3_FACTORY",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl4401/LOD0/usl4401.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
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
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd0301_death_rdu.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.375,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.39,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.45,
                    ["z"] = 0.144,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 186,
            ["lod1distance"] = 485,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.7,
            },
        },
    },
}
