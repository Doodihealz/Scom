-- ues2101: Tier 2: Klink Hammer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["basisYawDegrees"] = 180,
            ["footprint"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
            ["skirt"] = {
                ["sourceOffsetX"] = -0.5,
                ["sourceOffsetZ"] = -0.5,
                ["x"] = 2,
                ["y"] = 2,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprintSha256"] = "71c7238490b499fab6e2b978eea2192caa7b91659b929c163fe28602df55e90f",
            ["sourceId"] = "UEB2303",
            ["sourceModelSha256"] = "d756de188f5d551205929724bed639d212d98b57af9bd460e3da5563ba73b683",
            ["sourceProjectile"] = "TIFArtillery01",
            ["sourceProjectileSha256"] = "e78a6412e9e5ba16c9434a801189561f5b0be6a7da8cfd23b99e846ff5948e30",
            ["sourceProjectilesArchiveSha256"] = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            ["sourceScriptSha256"] = "960809c783d8a907f596325ca754c0af1d547f057ad903171066b2991bed09d7",
            ["sourceUniformScale"] = 0.35,
            ["targetId"] = "ues2101",
            ["textureResolution"] = 2048,
        },
        ["scoFaArtillery"] = {
            ["aimTolerance"] = 1,
            ["alloys"] = 2520,
            ["buildSortPriority"] = 140,
            ["buildTime"] = 1800,
            ["collideFriendly"] = false,
            ["collisionOffset"] = {
                ["x"] = 0,
                ["y"] = -0.25,
                ["z"] = 0,
            },
            ["collisionSize"] = {
                ["x"] = 1,
                ["y"] = 1.7,
                ["z"] = 1,
            },
            ["damage"] = 2000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 3,
            ["deathAudio"] = "aeod2120",
            ["deathEffect"] = "VFX/Death/ved2201_death_building_medium.sanvfx",
            ["displayName"] = "Tier 2: Klink Hammer",
            ["energy"] = 18000,
            ["energyDrainPerSecond"] = 100,
            ["energyRequired"] = 1000,
            ["fireAudio"] = "aeom1130",
            ["firingRandomness"] = 2,
            ["firstShotRequiresCharge"] = true,
            ["footprint"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
            ["health"] = 3600,
            ["iconTech"] = "t2",
            ["impactEffect"] = "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx",
            ["meshLod0Distance"] = 120,
            ["muzzle"] = "Turret_Muzzle",
            ["muzzleEffect"] = "VFX/Muzzle/vem1241_cannon_artillery_medium_muzzle.sanvfx",
            ["name"] = "Klink Hammer",
            ["pitchBone"] = "Turret_Barrel",
            ["pitchRange"] = 60,
            ["pitchSpeed"] = 6,
            ["projectile"] = "psk201",
            ["projectileLifetime"] = 15,
            ["projectileSpeed"] = 26.13,
            ["rackReloadTimeout"] = 14,
            ["rangeMax"] = 128,
            ["rangeMin"] = 5,
            ["recoil"] = {
                [1] = {
                    ["bone"] = "Turret_Recoil",
                    ["distance"] = -0.875,
                    ["returnSpeed"] = 0.0546875,
                },
            },
            ["recoilHoldSeconds"] = 0.1,
            ["recoilTime"] = 16,
            ["reduceMuzzleVelocityToTarget"] = false,
            ["reloadTime"] = 20,
            ["selectionOffset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0.4,
            },
            ["selectionSize"] = {
                ["x"] = 0.9,
                ["y"] = 0.9,
            },
            ["selectionThickness"] = 0.47,
            ["skirt"] = {
                ["sourceOffsetX"] = -0.5,
                ["sourceOffsetZ"] = -0.5,
                ["x"] = 2,
                ["y"] = 2,
            },
            ["solverType"] = "LowArc",
            ["sourceBlueprintSha256"] = "71c7238490b499fab6e2b978eea2192caa7b91659b929c163fe28602df55e90f",
            ["sourceId"] = "UEB2303",
            ["sourceModelSha256"] = "d756de188f5d551205929724bed639d212d98b57af9bd460e3da5563ba73b683",
            ["sourceProjectile"] = "TIFArtillery01",
            ["sourceProjectileSha256"] = "e78a6412e9e5ba16c9434a801189561f5b0be6a7da8cfd23b99e846ff5948e30",
            ["sourceScriptSha256"] = "960809c783d8a907f596325ca754c0af1d547f057ad903171066b2991bed09d7",
            ["sourceUniformScale"] = 0.35,
            ["targetBones"] = {
                [1] = "Target01",
                [2] = "Target02",
            },
            ["targetCheckInterval"] = 5,
            ["targetId"] = "ues2101",
            ["threat"] = {
                ["air"] = 0,
                ["economy"] = 30,
                ["sub"] = 0,
                ["surface"] = 54,
            },
            ["trailEffect"] = "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx",
            ["version"] = "1.0.0",
            ["vision"] = 28,
            ["yawBone"] = "Turret",
            ["yawRange"] = 180,
            ["yawSpeed"] = 6,
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1.7,
            ["z"] = 1,
        },
        ["targetBones"] = {
            [1] = "Target01",
            [2] = "Target02",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3600,
            ["regen"] = 0,
            ["value"] = 3600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1800,
        ["cost"] = {
            ["alloys"] = 2520,
            ["energy"] = 18000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "Tier 2: Klink Hammer",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 140,
        ["iconUIType"] = "land",
        ["name"] = "Klink Hammer",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threat"] = 54,
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 1522.6,
            ["WaterSurface"] = 1522.6,
        },
        ["tpId"] = "ues2101",
        ["unitTypeName"] = "UEFT2Artillery",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 115,
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
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "EDA",
        [5] = "INDIRECT_FIRE",
        [6] = "STRUCTURE",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_ARTILLERY",
        [9] = "SCFA_BUILTBYTIER2COMMANDER",
        [10] = "SCFA_BUILTBYTIER2ENGINEER",
        [11] = "SCFA_BUILTBYTIER3COMMANDER",
        [12] = "SCFA_BUILTBYTIER3ENGINEER",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_INDIRECTFIRE",
        [15] = "SCFA_OVERLAYINDIRECTFIRE",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SHOWATTACKRETICLE",
        [20] = "SCFA_SIZE4",
        [21] = "SCFA_SORTSTRATEGIC",
        [22] = "SCFA_STRATEGIC",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_UEF",
        [26] = "SCFA_VISIBLETORECON",
        [27] = "STRATEGIC",
        [28] = "TECH2",
    },
    ["visuals"] = {
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.175,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.055999999999999994,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.22600000000000003,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.46399999999999997,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.43000000000000005,
                    ["z"] = 0.18,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 120,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0.4,
            },
            ["size"] = {
                ["x"] = 0.9,
                ["y"] = 0.9,
            },
            ["thickness"] = 0.47,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -60,
                    ["pitchSpeed"] = 6,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 26.13,
                    ["reduceMuzzleVelocityToTarget"] = false,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 6,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom1130",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 2000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 3,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ues2101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 2,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle",
                    },
                    ["recoilBones"] = {
                        ["Turret_Recoil"] = -0.875,
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["name"] = "MainGun",
            ["projectileLifetime"] = 15,
            ["projectileTemplate"] = "psk201",
            ["rangeMax"] = 128,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["recoilTime"] = 16,
            ["reloadTime"] = 20,
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoFaArtillery"]["footprint"] = UnitTemplate["additions"]["faSourceContract"]["footprint"]
UnitTemplate["additions"]["scoFaArtillery"]["skirt"] = UnitTemplate["additions"]["faSourceContract"]["skirt"]
UnitTemplate["collisionInfo"]["centerOffset"] = UnitTemplate["additions"]["scoFaArtillery"]["collisionOffset"]
UnitTemplate["collisionInfo"]["collisionSize"] = UnitTemplate["additions"]["scoFaArtillery"]["collisionSize"]
UnitTemplate["collisionInfo"]["targetBones"] = UnitTemplate["additions"]["scoFaArtillery"]["targetBones"]
UnitTemplate["footprint"] = UnitTemplate["additions"]["faSourceContract"]["footprint"]
UnitTemplate["visuals"]["selection"]["offset"] = UnitTemplate["additions"]["scoFaArtillery"]["selectionOffset"]
UnitTemplate["visuals"]["selection"]["size"] = UnitTemplate["additions"]["scoFaArtillery"]["selectionSize"]
