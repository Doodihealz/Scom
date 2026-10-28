-- ucs2711: Veil
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "jammer",
            ["mapping"] = "UAB4203 -> ucs2711",
            ["primaryClip"] = {
                ["durationSeconds"] = 3.3333333,
                ["key"] = "source_animopen",
                ["rate"] = 1,
            },
            ["rotatorCount"] = 1,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4203/UAB4203_unit.bp",
            ["sourceBlueprintSha256"] = "4e6fc2e1040b81a2683494f85bfbadab1205f664f3d4a337a095ea236017a9b8",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 3.3333333,
                    ["frames"] = 101,
                    ["key"] = "source_animopen",
                    ["name"] = "AnimOpen",
                    ["rate"] = 1,
                    ["role"] = "intel_open",
                    ["sha256"] = "dbf1f85a05305367c1f093b66fb2043d183ac717e11682afa311ff68a45f81e6",
                    ["source"] = "units/UAB4203/UAB4203_Aopen.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "bc0af136e56e3a726d7c17631ef0a576d0f3c75198b35bf4db1933f6e5d5f042",
            ["sourceScript"] = "units/UAB4203/UAB4203_script.lua",
            ["sourceScriptSha256"] = "0861390a66c4182a12a39d08a2c358ddbc22eb00d7473a1a4d02d0c480388c4f",
            ["stateOwner"] = "Because Sanctuary does not implement FA radar-stealth fields, completed operational intent drives AnimOpen while B02/z concurrently accelerates at 50 to 60: optional Intel toggle and army energy gate start/reverse the clamped timeline and spin B02 down at 50. This is visual parity only; RadarStealthFieldRadius remains provenance-only.",
            ["targetAnimation"] = {
                ["bytes"] = 228578,
                ["path"] = "Units/ucs2711/LOD0/ucs2711.sananimation",
                ["sha256"] = "e15196830680348b10ff08ed8bfd8f1721343a0e9abe733ac1cc62669066ab1b",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 214593,
                ["path"] = "Units/ucs2711/LOD0/ucs2711_lod0.sanmodel",
                ["sha256"] = "7e292a3d11f5a655fb414a66346b9b2a3c0f6779d5022a651ff7728cf82891f5",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 11168,
                ["path"] = "Units/ucs2711/LOD0/ucs2711.sanskeleton",
                ["sha256"] = "72432de6977fe91d13ef7636aded50cecb4c4a42ad77f8eb88818c9f3517ddbc",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["radarStealthFieldRadius"] = 24,
                    ["reactivateTime"] = 5,
                    ["sonarStealthFieldRadius"] = 24,
                },
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
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4203/UAB4203_unit.bp",
            ["sourceBlueprintSha256"] = "4e6fc2e1040b81a2683494f85bfbadab1205f664f3d4a337a095ea236017a9b8",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2COMMANDER",
                [3] = "BUILTBYTIER2ENGINEER",
                [4] = "BUILTBYTIER3COMMANDER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "COUNTERINTELLIGENCE",
                [7] = "DRAGBUILD",
                [8] = "INTELLIGENCE",
                [9] = "OVERLAYCOUNTERINTEL",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "SIZE12",
                [14] = "SORTINTEL",
                [15] = "STRUCTURE",
                [16] = "TECH2",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB4203",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs2711",
            ["weapons"] = {},
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "B02",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.7,
                ["y"] = 1.7,
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
            ["y"] = 1.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2,
            ["y"] = 3,
            ["z"] = 2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 175,
            ["regen"] = 0,
            ["value"] = 175,
        },
    },
    ["economy"] = {
        ["buildTime"] = 500,
        ["cost"] = {
            ["alloys"] = 400,
            ["energy"] = 6000,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 125,
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
        ["displayName"] = "Veil",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Veil",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs2711",
        ["unitTypeName"] = "Veil",
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
        [4] = "STRUCTURE",
        [5] = "TECH2",
        [6] = "SCFA_AEON",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER2COMMANDER",
        [9] = "SCFA_BUILTBYTIER2ENGINEER",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_COUNTERINTELLIGENCE",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_INTELLIGENCE",
        [15] = "SCFA_OVERLAYCOUNTERINTEL",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SIZE12",
        [20] = "SCFA_SORTINTEL",
        [21] = "SCFA_STRUCTURE",
        [22] = "SCFA_TECH2",
        [23] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animopen"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2711/LOD0/ucs2711.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2711/LOD0/ucs2711.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 2,
                    ["z"] = -0.4,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 1.79,
                    ["z"] = 0.36,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.4,
                    ["y"] = 2.09,
                    ["z"] = 0.32,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 2.51,
                    ["z"] = -0.4,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 2.45,
                    ["z"] = 0.36,
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
                ["y"] = 1.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.7,
                ["y"] = 1.7,
            },
        },
    },
}
