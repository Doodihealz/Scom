-- ucs1602: Mass Storage
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "storage_level",
            ["mapping"] = "UAB1106 -> ucs1602",
            ["rotatorCount"] = 0,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1106/UAB1106_unit.bp",
            ["sourceBlueprintSha256"] = "67fa5432484ba5a246f0ed1920b3de446472d3d424d06547bdae20977b38776d",
            ["sourceClips"] = {},
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "c48e19b72b6498fded1b3ca8cb154b21316c1e66c41a528b962c22f1524b17c7",
            ["sourceScript"] = "units/UAB1106/UAB1106_script.lua",
            ["sourceScriptSha256"] = "457a7b3caff209098b4c15cf6c40e55c979d255bd33ab5509ce13ceed9e750b8",
            ["stateOwner"] = "AnimStorageLevel samples the army alloys storage ratio at exact clip time; B01 travels +0.0615 target-local Z from Rest.",
            ["storageClip"] = {
                ["assetPackBytes"] = 9166,
                ["assetPackSha256"] = "1c343fb3c33848d3e16e546edbee827f66b4a8f25fe4324c302829eef979c297",
                ["durationSeconds"] = 1,
                ["key"] = "source_animstoragelevel",
                ["localZDelta"] = 0.0615,
                ["name"] = "AnimStorageLevel",
                ["resource"] = "alloys",
            },
            ["targetAnimation"] = {
                ["bytes"] = 3784,
                ["path"] = "Units/ucs1602/LOD0/ucs1602.sananimation",
                ["sha256"] = "df18bf803e7b60b51e24ad3cf560f357902213ee10413ab0ea78e28dcd4ca544",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 80097,
                ["path"] = "Units/ucs1602/LOD0/ucs1602_lod0.sanmodel",
                ["sha256"] = "c95b0335578c28a8a9a3a2dba87feea0de95b2e81233ff4a867c2e1eaa6b8786",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 1972,
                ["path"] = "Units/ucs1602/LOD0/ucs1602.sanskeleton",
                ["sha256"] = "f4189318f001749dc350420c5e1ce0c9d24d8fb90c0ca68166ebc65f34d01bf1",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {},
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
            ["sourceBlueprint"] = "units/UAB1106/UAB1106_unit.bp",
            ["sourceBlueprintSha256"] = "67fa5432484ba5a246f0ed1920b3de446472d3d424d06547bdae20977b38776d",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER1ENGINEER",
                [3] = "BUILTBYTIER2COMMANDER",
                [4] = "BUILTBYTIER2ENGINEER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "DRAGBUILD",
                [7] = "ECONOMIC",
                [8] = "MASSSTORAGE",
                [9] = "PRODUCTSC1",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "SIZE4",
                [13] = "SORTECONOMY",
                [14] = "STRUCTURE",
                [15] = "TECH1",
                [16] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB1106",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs1602",
            ["weapons"] = {},
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["adjacency"] = "T1AlloyStorageAdjacencyBuff",
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
            ["x"] = 0.85,
            ["y"] = 0.5,
            ["z"] = 0.85,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1600,
            ["regen"] = 0,
            ["value"] = 1600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 250,
        ["cost"] = {
            ["alloys"] = 200,
            ["energy"] = 1500,
        },
        ["storage"] = {
            ["alloys"] = 500,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStorage",
        },
        ["displayName"] = "Mass Storage",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 340,
        ["iconUIType"] = "amphibious",
        ["name"] = "Mass Storage",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs1602",
        ["unitTypeName"] = "Mass Storage",
    },
    ["intel"] = {
        ["visionRadius"] = 0,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ALLOYS_STORAGE",
        [2] = "BUILDABLE_BY_T1_ENGINEER",
        [3] = "BUILDABLE_BY_T2_ENGINEER",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "CHOSEN",
        [6] = "ECONOMIC",
        [7] = "STRUCTURE",
        [8] = "TECH1",
        [9] = "SCFA_AEON",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER1ENGINEER",
        [12] = "SCFA_BUILTBYTIER2COMMANDER",
        [13] = "SCFA_BUILTBYTIER2ENGINEER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_DRAGBUILD",
        [16] = "SCFA_ECONOMIC",
        [17] = "SCFA_MASSSTORAGE",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SIZE4",
        [22] = "SCFA_SORTECONOMY",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH1",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animstoragelevel"] = {
                ["clipName"] = "AnimStorageLevel",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1602/LOD0/ucs1602.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1602/LOD0/ucs1602.sananimation",
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
                    ["x"] = 0.153,
                    ["y"] = 0.375,
                    ["z"] = -0.17,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.187,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.153,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.17,
                    ["y"] = 0.39,
                    ["z"] = 0.136,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.153,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.17,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.187,
                    ["y"] = 0.45,
                    ["z"] = 0.153,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 81,
            ["lod1distance"] = 211,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
}
