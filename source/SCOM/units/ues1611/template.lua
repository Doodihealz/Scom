-- ues1611: Power Generator
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["activationSeconds"] = 0.6,
            ["adjacencyMagnitudeSourceOwned"] = false,
            ["adjacentStructureEnergyMod"] = -2,
            ["damageCloseAnimationSupported"] = false,
            ["damageRecoverySeconds"] = 10,
            ["sourceBlueprintSha256"] = "0382700aa10d13a2ef2e02e5fd95e42baf51962f51268c61c929324860ca23ec",
            ["sourceExhaustEmitterSupported"] = false,
            ["sourceId"] = "UEB1101",
            ["sourceScriptSha256"] = "31889e4b3e310cfc3b99c39c248c92433d5a99e4353ea94bca498cb612ef2d64",
            ["spinnerRampSupported"] = false,
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "B01",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 180,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["boneName"] = "B02",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = -90,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.3,
                ["y"] = 1.3,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.3,
            ["y"] = 1.3,
        },
    },
    ["adjacency"] = "T1EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aelu2310",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.175,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 0.85,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 600,
            ["regen"] = 0,
            ["value"] = 600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 125,
        ["cost"] = {
            ["alloys"] = 75,
            ["energy"] = 750,
        },
        ["production"] = {
            ["energy"] = 25,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAImportedAnimatedEnergyGenerator",
        },
        ["displayName"] = "Power Generator",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "Power Generator",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ues1611",
        ["unitTypeName"] = "EDAT1EnergyGenerator",
    },
    ["intel"] = {
        ["visionRadius"] = 10,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 10,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 10,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "ECONOMIC",
        [5] = "EDA",
        [6] = "ENERGY_PRODUCTION",
        [7] = "STRUCTURE",
        [8] = "TECH1",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYCOMMANDER",
        [11] = "SCFA_BUILTBYTIER1ENGINEER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_ECONOMIC",
        [16] = "SCFA_ENERGYPRODUCTION",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SIZE4",
        [21] = "SCFA_SORTECONOMY",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_TECH1",
        [24] = "SCFA_UEF",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1611/LOD0/ues1611.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "AnimActivate",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1611/LOD0/ues1611.sananimation",
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
                    ["particleName"] = "VFX/Death/ved2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.38749999999999996,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.32799999999999996,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.41300000000000003,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.532,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.515,
                    ["z"] = 0.108,
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
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.3,
                ["y"] = 1.3,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 250,
            ["damageFriendly"] = true,
            ["damageRadius"] = 2,
            ["damageType"] = "Normal",
        },
    },
}
