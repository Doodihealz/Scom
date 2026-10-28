-- ugn3005: Tier 3: Flood XR
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 1.5,
            ["sourceBlueprintSha256"] = "D8CF3A5638BCE8E0BE1ABD73F3E574A1F0A8B2CFE2AAB89ACD3DE3D867E8ED1E",
            ["sourceId"] = "URS0305",
            ["sourceMinimumWaterDepth"] = 1.5,
            ["sourceUniformScale"] = 0.125,
            ["targetId"] = "ugn3005",
            ["textureResolution"] = 2048,
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSeaParityMinimumWaterDepth"] = 1.5,
        ["scoSeaParityPlacementMode"] = "WaterOnly",
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "URS0305",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 24.066667556762695,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1.5,
                    ["rateMin"] = 0.9,
                    ["weight"] = 100,
                },
            },
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "URS0305",
            ["targetId"] = "ugn3005",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.35,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 1.2,
            ["z"] = 0.8,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 850,
            ["regen"] = 0,
            ["value"] = 850,
        },
    },
    ["economy"] = {
        ["buildTime"] = 900,
        ["cost"] = {
            ["alloys"] = 480,
            ["energy"] = 14400,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardNavalUnit",
        },
        ["displayName"] = "Tier 3: Flood XR",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Flood XR",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["requiresWaterPlacement"] = true,
        ["tpId"] = "ugn3005",
    },
    ["intel"] = {
        ["radarRadius"] = 0,
        ["sonarRadius"] = 450,
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 4.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 4.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 100,
        ["sortOrder"] = 5,
        ["speed"] = 4.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 450,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "GUARD",
        [3] = "MOBILE",
        [4] = "NAVAL",
        [5] = "TECH3",
        [6] = "NEEDMOBILEBUILD",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_CYBRAN",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_INTELLIGENCE",
        [13] = "SCFA_MOBILE",
        [14] = "SCFA_MOBILESONAR",
        [15] = "SCFA_NEEDMOBILEBUILD",
        [16] = "SCFA_OVERLAYCOUNTERINTEL",
        [17] = "SCFA_OVERLAYSONAR",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SONAR",
        [22] = "SCFA_SORTINTEL",
        [23] = "SCFA_TECH3",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAsink01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3005/LOD0/ugn3005.sananimation",
            },
            ["source_animasink01_1"] = {
                ["clipName"] = "AnimAsink01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3005/LOD0/ugn3005.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3005/LOD0/ugn3005.sananimation",
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
                    ["y"] = 0.6499999999999999,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.566,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.6859999999999999,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.854,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.83,
                    ["z"] = 0.144,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 150,
            ["lod1distance"] = 390,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
            },
            ["thickness"] = 0.78,
        },
    },
    ["weapons"] = {},
}
