-- ucs2402: T2 Tactical Missile Defense
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "dome_recoil",
            ["mapping"] = "UAB4201 -> ucs2402",
            ["rotatorCount"] = 1,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4201/UAB4201_unit.bp",
            ["sourceBlueprintSha256"] = "96d6ae783a48f8c18d929e707a710e0d0a54fa9df16fed6d27c3f986d764533a",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 3,
                    ["frames"] = 91,
                    ["key"] = "source_animopen",
                    ["name"] = "AnimOpen",
                    ["rate"] = 10,
                    ["role"] = "preserved_deploy",
                    ["sha256"] = "93379bccb9b67a40ca862bb4d7171fa178fea3c25ae2722164650259d7582828",
                    ["source"] = "units/UAB4201/UAB4201_Aopen.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "27846a1b56f710d9b7c7d9a89004f4b6a1efa62771c2bb82286cbbd497e6ba35",
            ["sourceScript"] = "units/UAB4201/UAB4201_script.lua",
            ["sourceScriptSha256"] = "f6b6092a57a2baff5a0634233ab9651286c91c3c7cc9c02edbae6c473e054459",
            ["stateOwner"] = "Preserve FA Animation Closure deploy/repack owner. Each actual projectile advances Dome/z exactly 45 degrees; step 8 reaches 360 and clears the counter.",
            ["targetAnimation"] = {
                ["bytes"] = 114730,
                ["path"] = "Units/ucs2402/LOD0/ucs2402.sananimation",
                ["sha256"] = "3cd77eb2a9586fdb85018422c83516e8f486a787e0d1f2f9f98e0ebcd3545847",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 284177,
                ["path"] = "Units/ucs2402/LOD0/ucs2402_lod0.sanmodel",
                ["sha256"] = "e626eb99c192c70943892d1d40d9015a7fe77e4e2c3be0006b6a4a47918db8e5",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 8048,
                ["path"] = "Units/ucs2402/LOD0/ucs2402.sanskeleton",
                ["sha256"] = "b7902cff74373d4afb48fda17717ee6bdfe40fbbb2ef8ca23173c9eadaad8a35",
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
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -0.5,
                    ["offsetZ"] = -0.5,
                    ["sizeX"] = 2,
                    ["sizeZ"] = 2,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4201/UAB4201_unit.bp",
            ["sourceBlueprintSha256"] = "96d6ae783a48f8c18d929e707a710e0d0a54fa9df16fed6d27c3f986d764533a",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ANTIMISSILE",
                [3] = "BUILTBYTIER2COMMANDER",
                [4] = "BUILTBYTIER2ENGINEER",
                [5] = "BUILTBYTIER3COMMANDER",
                [6] = "BUILTBYTIER3ENGINEER",
                [7] = "DEFENSE",
                [8] = "DRAGBUILD",
                [9] = "OVERLAYDEFENSE",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "SIZE4",
                [14] = "SORTDEFENSE",
                [15] = "STRUCTURE",
                [16] = "TECH2",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB4201",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs2402",
            ["weapons"] = {
                [1] = {
                    ["label"] = "AntiMissile",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Barrel",
                            },
                            ["rackBone"] = "Dome",
                        },
                    },
                    ["rateOfFire"] = 0.32,
                    ["reloadTime"] = 3.125,
                    ["sourceCategory"] = "Defense",
                    ["sourceProjectile"] = "/projectiles/AIMAntiMissile01/AIMAntiMissile01_proj.bp",
                },
            },
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Dome",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoTactical"] = {
            ["barrelSpin"] = false,
            ["beam"] = false,
            ["beamLifetime"] = 0,
            ["buildPower"] = 0,
            ["buildTime"] = 0,
            ["charge"] = 0,
            ["cost"] = {
                ["alloys"] = 0,
                ["energy"] = 0,
            },
            ["cycleReload"] = 0,
            ["damage"] = 30,
            ["damageFriendly"] = true,
            ["damageRadius"] = 0,
            ["deployDuration"] = 3,
            ["deployKey"] = "fa_deploy",
            ["deployRate"] = 10,
            ["domeRecoil"] = true,
            ["initialAmmo"] = 0,
            ["lifetime"] = 4,
            ["maxAmmo"] = 0,
            ["muzzleVelocity"] = 5,
            ["muzzles"] = {
                [1] = "Barrel",
            },
            ["packedKey"] = "fa_packed",
            ["projectile"] = "pst007",
            ["rangeMax"] = 30,
            ["rangeMin"] = 0,
            ["reload"] = 3.125,
            ["repackTimeout"] = 1,
            ["role"] = "defense",
            ["sourceId"] = "UAB4201",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.95,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.65,
            ["y"] = 0.5,
            ["z"] = 1.25,
        },
    },
    ["construction"] = {
        ["buildPower"] = 0,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["value"] = 500,
        },
    },
    ["economy"] = {
        ["buildPower"] = 0,
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 280,
            ["energy"] = 3200,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "T2 Tactical Missile Defense",
        ["faDualWaterPlacement"] = true,
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Volcano",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ucs2402",
        ["unitTypeName"] = "Volcano",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 30,
        },
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ANTI_PROJECTILE",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CHOSEN",
        [5] = "DEFENCE",
        [6] = "STRUCTURE",
        [7] = "TECH2",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ANTIMISSILE",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_DEFENSE",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_OVERLAYDEFENSE",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SIZE4",
        [22] = "SCFA_SORTDEFENSE",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["fa_deploy"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2402/LOD0/ucs2402.sananimation",
            },
            ["fa_packed"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2402/LOD0/ucs2402.sananimation",
            },
            ["source_animopen"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2402/LOD0/ucs2402.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2402/LOD0/ucs2402.sananimation",
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.11699999999999999,
                    ["y"] = 0.375,
                    ["z"] = -0.25,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.14300000000000002,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.22499999999999998,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13,
                    ["y"] = 0.39,
                    ["z"] = 0.2,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.11699999999999999,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.25,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.14300000000000002,
                    ["y"] = 0.45,
                    ["z"] = 0.22499999999999998,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 67,
            ["lod1distance"] = 175,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.95,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Barrel",
                    ["aimTolerance"] = 360,
                    ["leadTarget"] = false,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                },
            },
            ["damage"] = 30,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Barrel",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Barrel"] = {
                    ["aimController"] = "Barrel",
                },
            },
            ["name"] = "AntiMissile",
            ["projectileLifetime"] = 4,
            ["projectileTemplate"] = "pst007",
            ["rangeMax"] = 30,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.2,
            ["reloadTime"] = 3.125,
            ["scoTacticalOwned"] = true,
        },
    },
}
