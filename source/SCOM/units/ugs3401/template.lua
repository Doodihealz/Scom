-- ugs3401: ED5
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
            ["mapping"] = "URB4207 -> ugs3401",
            ["sanctuaryEnergyDrainRechargeTimeSupported"] = false,
            ["sanctuaryPublicTechCategory"] = "TECH3",
            ["sanctuaryRegenAssistMultiplierSupported"] = false,
            ["sanctuaryShieldRadius"] = 20,
            ["sanctuarySkirtOffsetSupported"] = false,
            ["sanctuaryUpgradesFrom"] = "ugs2401",
            ["sourceBlueprintSha256"] = "7442a10729ab814418f0201aed463b1acda55a8dc135ead974b399d709e210e3",
            ["sourceEmitterGraphSupported"] = false,
            ["sourceRegenAssistMultiplier"] = 60,
            ["sourceScriptSha256"] = "357879b75e0d17dfd9330fa72efa5c2dc69d085aaa1573dcd9b543f95e86ea49",
            ["sourceShieldEnergyDrainRechargeTime"] = 5,
            ["sourceShieldSizeDiameter"] = 40,
            ["sourceSkirtOffset"] = {
                ["x"] = -2.5,
                ["z"] = -2.5,
            },
            ["sourceTechCategory"] = "TECH2",
            ["sourceUpgradesFrom"] = "URB4206",
            ["spinner"] = {
                ["acceleration"] = 5,
                ["axis"] = "z",
                ["bone"] = "Shaft",
                ["enabledSpeed"] = 10,
                ["initialSpeed"] = 30,
                ["maximumSpeed"] = 30,
            },
            ["terminalAopen"] = {
                ["clip"] = "AnimUpgrade",
                ["durationSeconds"] = 5.333333492279053,
                ["frames"] = 161,
                ["sourceBound"] = false,
            },
            ["terminalProgressionSubstitution"] = true,
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Shaft",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
    },
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
            ["x"] = 2,
            ["y"] = 5,
            ["z"] = 2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["max"] = 14000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -6,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 20,
                    ["y"] = 20,
                    ["z"] = 20,
                },
                ["rechargeHPRatio"] = 0.5,
                ["rechargeTime"] = 22,
                ["regen"] = 140,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 14000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 1600,
        ["cost"] = {
            ["alloys"] = 2400,
            ["energy"] = 40000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 500,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardSupComShieldFinal",
        },
        ["displayName"] = "ED5",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 160,
        ["iconUIType"] = "land",
        ["name"] = "ED5",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "ugs3401",
        ["unitTypeName"] = "GuardT3Shield",
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
        [1] = "DEFENCE",
        [2] = "GUARD",
        [3] = "SHIELD",
        [4] = "STRUCTURE",
        [5] = "TECH3",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_CYBRAN",
        [8] = "SCFA_DEFENSE",
        [9] = "SCFA_DRAGBUILD",
        [10] = "SCFA_OVERLAYDEFENSE",
        [11] = "SCFA_PRODUCTSC1",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SHIELD",
        [15] = "SCFA_SHOWQUEUE",
        [16] = "SCFA_SIZE12",
        [17] = "SCFA_SORTDEFENSE",
        [18] = "SCFA_STRUCTURE",
        [19] = "SCFA_TECH2",
        [20] = "SCFA_VISIBLETORECON",
        [21] = "BUILDABLE_BY_T3_ENGINEER",
    },
    ["visuals"] = {
        ["animations"] = {
            ["terminalOpen"] = {
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs3401/LOD0/ugs3401.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs3401/LOD0/ugs3401.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 1,
                    ["z"] = -0.4,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.6499999999999999,
                    ["z"] = 0.36,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.4,
                    ["y"] = 1.1500000000000001,
                    ["z"] = 0.32,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 1.85,
                    ["z"] = -0.4,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 1.75,
                    ["z"] = 0.36,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 99,
            ["lod1distance"] = 257,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.2,
                ["y"] = 2.2,
            },
        },
    },
}
