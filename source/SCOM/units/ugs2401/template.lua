-- ugs2401: ED1
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorShieldLoopRetained"] = false,
            ["mapping"] = "URB4202 -> ugs2401",
            ["modelSafeShieldAnchorUsed"] = true,
            ["progressionSubstitution"] = "ugs3401/URB4207",
            ["sanctuaryDamageRechargeHPRatio"] = 1,
            ["sanctuaryRegenAssistMultiplierSupported"] = false,
            ["sanctuaryShieldRadius"] = 9,
            ["sanctuaryUpgradesTo"] = "ugs3401",
            ["separateEnergyDrainRechargeSupported"] = true,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URB4202/URB4202_unit.bp",
            ["sourceBlueprintSha256"] = "4053e6d1379b4bfa280932e1790346a4a722e8368dcf3be77325b5fa08bd12c4",
            ["sourceDamageRechargeRestoresFullHealth"] = true,
            ["sourceEmitterGraphSupported"] = false,
            ["sourceRegenAssistMultiplier"] = 60,
            ["sourceScript"] = "units/URB4202/URB4202_script.lua",
            ["sourceScriptSha256"] = "015e26800449fb3cbff51580931227dda794e631c06b2990ccbb46074228bf6d",
            ["sourceShieldAudioBanksImported"] = false,
            ["sourceShieldEnergyDrainRechargeTime"] = 5,
            ["sourceShieldSizeDiameter"] = 18,
            ["sourceShieldVerticalOffset"] = -3,
            ["sourceSkirtOffsetSupported"] = false,
            ["sourceUpgradesTo"] = "URB4204",
        },
        ["faSupportShield"] = {
            ["energyDrainRechargeTime"] = 5,
            ["initialRotatorSpeeds"] = {
                [1] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 30,
                },
            },
            ["sanctuaryAccelerationSupported"] = false,
            ["sanctuarySpinDownSupported"] = false,
            ["sourceAcceleration"] = 5,
            ["sourceInitialSpeed"] = 30,
            ["sourceUpgradeSpinDown"] = false,
            ["steadyRotatorSpeeds"] = {
                [1] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 10,
                },
            },
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 1.33333337306976,
            ["restAnimationKey"] = "walk",
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Shaft",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 10,
                },
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.62,
                ["z"] = 0.24,
            },
            ["size"] = {
                ["x"] = 4.7,
                ["y"] = 4.7,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 4.4,
            ["y"] = 4.5,
        },
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
            ["y"] = 1.62,
            ["z"] = 0.24,
        },
        ["collisionSize"] = {
            ["x"] = 4.7,
            ["y"] = 6.9,
            ["z"] = 4.7,
        },
    },
    ["construction"] = {
        ["buildPower"] = 18,
        ["canBuild"] = "(Tags.ugs5012) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ugs5012",
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
                ["max"] = 4000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 1.5202198,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 9,
                    ["y"] = 9,
                    ["z"] = 9,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 18,
                ["regen"] = 45,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 4000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 160,
            ["energy"] = 2000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 100,
        },
    },
    ["footprint"] = {
        ["x"] = 4.7,
        ["y"] = 4.7,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardImportedAnimatedStructure",
        },
        ["displayName"] = "ED1",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "ED1",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Shield"] = true,
        },
        ["tpId"] = "ugs2401",
        ["unitTypeName"] = "GuardT2Shield",
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
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CONSTRUCTION",
        [4] = "DEFENCE",
        [5] = "GUARD",
        [6] = "SHIELD",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_CYBRAN",
        [15] = "SCFA_DEFENSE",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_OVERLAYDEFENSE",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SHIELD",
        [22] = "SCFA_SHOWQUEUE",
        [23] = "SCFA_SIZE12",
        [24] = "SCFA_SORTDEFENSE",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH2",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2401/LOD0/ugs2401.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2401/LOD0/ugs2401.sananimation",
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
                    ["x"] = 0.846,
                    ["y"] = 3.345,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.034,
                    ["y"] = 2.862,
                    ["z"] = 1.0859999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.9400000000000001,
                    ["y"] = 3.5520000000000005,
                    ["z"] = 0.992,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.846,
                    ["y"] = 4.518000000000001,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.034,
                    ["y"] = 4.380000000000001,
                    ["z"] = 1.0859999999999999,
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
                ["y"] = 1.62,
                ["z"] = 0.24,
            },
            ["size"] = {
                ["x"] = 4.7,
                ["y"] = 4.7,
            },
        },
    },
}
