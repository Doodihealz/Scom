-- ucs2401: Shield of Light
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["auditedLimitation"] = "Retail UAB4202 references shared UAB4202_Aopen.sca, but that clip is absent from every installed FA gamedata archive; no AnimOpen is required or invented.",
            ["deathClip"] = {
                ["durationSeconds"] = 2.9,
                ["key"] = "source_animadeath",
                ["rate"] = 0.5,
            },
            ["kind"] = "shield_rotators_t2",
            ["mapping"] = "UAB4202 -> ucs2401",
            ["rotatorCount"] = 2,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4202/UAB4202_unit.bp",
            ["sourceBlueprintSha256"] = "c39cfe68ae22bc35afc3b0ad385f2c10cc9cc6d2c13c5150dab76a74bea5219a",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 2.9,
                    ["frames"] = 30,
                    ["key"] = "source_animadeath",
                    ["name"] = "AnimAdeath",
                    ["rate"] = 0.5,
                    ["role"] = "death",
                    ["sha256"] = "b04902b9622b41419e417417888375018b3cc8c7c2fa6b0c35c3f12b0bef09ed",
                    ["source"] = "units/UAB4202/UAB4202_Adeath.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "1a4cd6057ca40bfe5f70c59429bc4c41b0e3674d7014b42ecfa2049928a080bb",
            ["sourceScript"] = "units/UAB4202/UAB4202_script.lua",
            ["sourceScriptSha256"] = "22742862d8595e5c3655aa0fd840c741a88786823ca0e02d0d4ab8c3b83ab398",
            ["stateOwner"] = "Rest remains the stable open baseline. Effective shield-up accelerates Pod/z to +60 at 50 deg/s^2 and Orb/x,z to -45,+45 at 45 deg/s^2; shield-down decelerates all to zero. AnimAdeath samples at source rate 0.5 before stock wreck/delete.",
            ["targetAnimation"] = {
                ["bytes"] = 21484,
                ["path"] = "Units/ucs2401/LOD0/ucs2401.sananimation",
                ["sha256"] = "096fb8f0a2df5ef68e27a36ecadc423fe18d8d92f78a9abe026932c1ba93d13e",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 222721,
                ["path"] = "Units/ucs2401/LOD0/ucs2401_lod0.sanmodel",
                ["sha256"] = "0a30075fac1ee2f41c36aa41691e9f7051d20d0eed3591d365b69f65d9debe93",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 2920,
                ["path"] = "Units/ucs2401/LOD0/ucs2401.sanskeleton",
                ["sha256"] = "ad36f60ec26e59878e00f9f47dfe97e7dd9000f203d6a2f2f78ae485012e10f0",
            },
            ["version"] = "1.0.2",
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
                    ["x"] = 3,
                    ["z"] = 3,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 6,
                    ["sizeZ"] = 6,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = true,
                ["energyDrainRechargeTime"] = 5,
                ["maxHealth"] = 11000,
                ["rechargeTime"] = 16,
                ["regenRate"] = 138,
                ["regenStartTime"] = 1,
                ["runtimeRadius"] = 10,
                ["size"] = 20,
                ["verticalOffset"] = -3,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4202/UAB4202_unit.bp",
            ["sourceBlueprintSha256"] = "c39cfe68ae22bc35afc3b0ad385f2c10cc9cc6d2c13c5150dab76a74bea5219a",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2COMMANDER",
                [3] = "BUILTBYTIER2ENGINEER",
                [4] = "BUILTBYTIER3COMMANDER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "DEFENSE",
                [7] = "DRAGBUILD",
                [8] = "OVERLAYDEFENSE",
                [9] = "PRODUCTSC1",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "SHIELD",
                [13] = "SIZE12",
                [14] = "SORTDEFENSE",
                [15] = "STRUCTURE",
                [16] = "TECH2",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB4202",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs2401",
            ["weapons"] = {},
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Pod",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["boneName"] = "Orb",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixShieldGeneratorPalette"] = {
            ["effect"] = "VFX/SCOM/FieldFixes/Shields/aeon_core_t2.sanvfx",
            ["faction"] = "aeon",
            ["positionOffset"] = {
                ["x"] = 0,
                ["y"] = -1.2976992,
                ["z"] = -3e-07,
            },
            ["sourceEffect"] = "VFX/Unit/vcu1222_active_shield_generator.sanvfx",
            ["tier"] = 2,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.5,
                ["y"] = 1.5,
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
            ["y"] = 1,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.75,
            ["y"] = 2.5,
            ["z"] = 1.75,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 150,
            ["regen"] = 0,
            ["value"] = 150,
        },
        ["shields"] = {
            [1] = {
                ["audio"] = {
                    ["active"] = {
                        ["looping"] = true,
                        ["name"] = "aclu2120",
                    },
                    ["onImpact"] = {
                        ["looping"] = false,
                        ["name"] = "acoi0025",
                    },
                },
                ["boneName"] = "Root",
                ["effectsPersistent"] = {
                    [1] = {
                        ["boneName"] = "Root",
                        ["particleName"] = "VFX/SCOM/FieldFixes/Shields/aeon_core_t2.sanvfx",
                        ["positionOffset"] = {
                            ["x"] = 0,
                            ["y"] = -1.2976992,
                            ["z"] = -3e-07,
                        },
                    },
                },
                ["max"] = 11000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["y"] = -3,
                },
                ["radii"] = {
                    ["x"] = 10,
                    ["y"] = 10,
                    ["z"] = 10,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 16,
                ["regen"] = 138,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 11000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 480,
        ["cost"] = {
            ["alloys"] = 480,
            ["energy"] = 5760,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 150,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Shield of Light",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "Shield of Light",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Shield"] = true,
        },
        ["tpId"] = "ucs2401",
        ["unitTypeName"] = "Shield of Light",
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
        [3] = "CHOSEN",
        [4] = "DEFENCE",
        [5] = "SHIELD",
        [6] = "STRUCTURE",
        [7] = "TECH2",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_DEFENSE",
        [15] = "SCFA_DRAGBUILD",
        [16] = "SCFA_OVERLAYDEFENSE",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SHIELD",
        [21] = "SCFA_SIZE12",
        [22] = "SCFA_SORTDEFENSE",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2401/LOD0/ucs2401.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2401/LOD0/ucs2401.sananimation",
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
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 1.625,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 1.45,
                    ["z"] = 0.315,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.35000000000000003,
                    ["y"] = 1.7000000000000002,
                    ["z"] = 0.28,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 2.05,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 2,
                    ["z"] = 0.315,
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
                ["y"] = 1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.5,
                ["y"] = 1.5,
            },
        },
    },
}
