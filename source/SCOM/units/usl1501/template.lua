-- usl1501: Iya-istle
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle",
        },
        ["buildBeamEffectName"] = "beam1",
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.39200816345215034,
                [3] = -1.524998086199249e-08,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0105",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 46151,
                ["entry"] = "units/XSL0105/XSL0105_lod0.scm",
                ["sha256"] = "e4c65bb673aa57cfdfda34374f6e1f5d6b23814e32edc8c5ba2d9b2b4ccf77a0",
            },
        },
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1410",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.1,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 0.7,
            ["z"] = 0.8,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Turret_Muzzle",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 5,
        ["canBuild"] = "(Tags.SERAPHIM * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 125,
            ["regen"] = 0,
            ["value"] = 125,
        },
    },
    ["economy"] = {
        ["buildTime"] = 260,
        ["cost"] = {
            ["alloys"] = 52,
            ["energy"] = 260,
        },
        ["storage"] = {
            ["alloys"] = 10,
        },
    },
    ["footprint"] = {
        ["x"] = 0.8,
        ["y"] = 0.8,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimEngineer",
        },
        ["displayName"] = "Iya-istle",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "engineer",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_engineer.png",
        ["iconUIBuildSortPriority"] = 150,
        ["iconUIType"] = "amphibious",
        ["name"] = "Iya-istle",
        ["orders"] = {
            ["Assist"] = true,
            ["AttackMove"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Pause"] = false,
            ["Repair"] = true,
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
        ["tpId"] = "usl1501",
        ["unitTypeName"] = "UnknownT1Engineer",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 1.9,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["deceleration"] = 1.9,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0.5,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 120,
        ["sortOrder"] = 6,
        ["speed"] = 1.9,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
    },
    ["tags"] = {
        [1] = "ALLOYS_STORAGE",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CONSTRUCTION",
        [6] = "ENGINEER",
        [7] = "HARVEST",
        [8] = "MOBILE",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER1FACTORY",
        [11] = "SCFA_BUILTBYTIER2FACTORY",
        [12] = "SCFA_BUILTBYTIER3FACTORY",
        [13] = "SCFA_CAPTURE",
        [14] = "SCFA_CONSTRUCTION",
        [15] = "SCFA_ENGINEER",
        [16] = "SCFA_HOVER",
        [17] = "SCFA_LAND",
        [18] = "SCFA_MOBILE",
        [19] = "SCFA_PATROLHELPER",
        [20] = "SCFA_PRODUCTFA",
        [21] = "SCFA_RECLAIM",
        [22] = "SCFA_RECLAIMABLE",
        [23] = "SCFA_REPAIR",
        [24] = "SCFA_SELECTABLE",
        [25] = "SCFA_SERAPHIM",
        [26] = "SCFA_SHOWQUEUE",
        [27] = "SCFA_TECH1",
        [28] = "SCFA_VISIBLETORECON",
        [29] = "SERAPHIM",
        [30] = "TECH1",
        [31] = "HOVER",
        [32] = "LAND",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl1501/LOD0/usl1501.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.275,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.226,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.29600000000000004,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.394,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.38,
                    ["z"] = 0.144,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 66,
            ["lod1distance"] = 173,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
            },
        },
    },
}
