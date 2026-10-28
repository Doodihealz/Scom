-- ucs3601: Mass Extractor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "pump_state_machine",
            ["mapping"] = "UAB1302 -> ucs3601",
            ["primaryClip"] = {
                ["durationSeconds"] = 12.666667,
                ["key"] = "source_animpump",
                ["rate"] = 1,
            },
            ["rotatorCount"] = 0,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1302/UAB1302_unit.bp",
            ["sourceBlueprintSha256"] = "18a5d6b6e2a027d0d599dc47177e48883190de7fadc97e3da3eab25a0010ad83",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 12.666667,
                    ["frames"] = 381,
                    ["key"] = "source_animpump",
                    ["name"] = "AnimPump",
                    ["rate"] = 1,
                    ["role"] = "pump",
                    ["sha256"] = "537d1d819f5748328656e6e5c60832844c996a13a7921be7c6d488da4807101f",
                    ["source"] = "units/UAB1302/UAB1302_Apump.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "3546d16d728faf30adf4235aae50ac2df481eb23f599c72e7cfd985acaa47c53",
            ["sourceScript"] = "units/UAB1302/UAB1302_script.lua",
            ["sourceScriptSha256"] = "82adc4592cd340e43abe1be841c797bbbcf3b8a67bb31055286bafc1a34a2a49",
            ["stateOwner"] = "Original AnimPump preserves the authored 12.666667-second Shaft rotation and 0.75-unit vertical pump stroke; continuous pump clocks let native Loop playback cross the cycle seam, pause finishes the current source cycle and holds its endpoint, and resume starts the next cycle without a second owner.",
            ["targetAnimation"] = {
                ["bytes"] = 832202,
                ["path"] = "Units/ucs3601/LOD0/ucs3601.sananimation",
                ["sha256"] = "1a4babd08cff018faa0ccb14eef46785b2f3340e34f1431270a444fd4c565deb",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 281193,
                ["path"] = "Units/ucs3601/LOD0/ucs3601_lod0.sanmodel",
                ["sha256"] = "fc1b574dcaa18a134426d840859d715a06501dc322b811b3e805880ee197e76d",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 12380,
                ["path"] = "Units/ucs3601/LOD0/ucs3601.sanskeleton",
                ["sha256"] = "de71eaae8673da8c90ff36818191880b18a21b182761e5092dc0e476aaa840e4",
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
                    ["x"] = 2,
                    ["z"] = 2,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
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
            ["sourceBlueprint"] = "units/UAB1302/UAB1302_unit.bp",
            ["sourceBlueprintSha256"] = "18a5d6b6e2a027d0d599dc47177e48883190de7fadc97e3da3eab25a0010ad83",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3COMMANDER",
                [3] = "BUILTBYTIER3ENGINEER",
                [4] = "ECONOMIC",
                [5] = "MASSEXTRACTION",
                [6] = "MASSPRODUCTION",
                [7] = "PRODUCTSC1",
                [8] = "RECLAIMABLE",
                [9] = "SELECTABLE",
                [10] = "SIZE4",
                [11] = "SORTECONOMY",
                [12] = "STRUCTURE",
                [13] = "TECH3",
                [14] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB1302",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB1202",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3601",
            ["weapons"] = {},
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixAeonUpgradeRouting"] = {
            ["target"] = "terminal",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.7,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["adjacency"] = "AlloyExtractorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.7,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.75,
            ["y"] = 1.4,
            ["z"] = 0.75,
        },
    },
    ["construction"] = {
        ["buildableOnResources"] = {
            [1] = "alloys",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 8400,
            ["regen"] = 0,
            ["value"] = 8400,
        },
    },
    ["economy"] = {
        ["buildTime"] = 2875,
        ["cost"] = {
            ["alloys"] = 4600,
            ["energy"] = 31625,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 54,
        },
        ["production"] = {
            ["alloys"] = 18,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAlloyExtractor",
        },
        ["displayName"] = "Mass Extractor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 370,
        ["iconUIType"] = "amphibious",
        ["name"] = "Mass Extractor",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ucs3601",
        ["unitTypeName"] = "Mass Extractor",
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ALLOYS_EXTRACTION",
        [2] = "ALLOYS_PRODUCTION",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CHOSEN",
        [5] = "ECONOMIC",
        [6] = "STRUCTURE",
        [7] = "TECH3",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_ECONOMIC",
        [13] = "SCFA_MASSEXTRACTION",
        [14] = "SCFA_MASSPRODUCTION",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SIZE4",
        [19] = "SCFA_SORTECONOMY",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animpump"] = {
                ["clipName"] = "AnimPump",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ucs3601/LOD0/ucs3601.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3601/LOD0/ucs3601.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 1.0499999999999998,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.952,
                    ["z"] = 0.135,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.15000000000000002,
                    ["y"] = 1.092,
                    ["z"] = 0.12,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 1.2879999999999998,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 1.2599999999999998,
                    ["z"] = 0.135,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 70,
            ["lod1distance"] = 182,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.7,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
}
