-- ues4101: Tier 4: Mavor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["basisYawDegrees"] = 180,
            ["footprint"] = {
                ["x"] = 5,
                ["y"] = 5,
            },
            ["skirt"] = {
                ["sourceOffsetX"] = -1.5,
                ["sourceOffsetZ"] = -1.5,
                ["x"] = 8,
                ["y"] = 8,
            },
            ["sourceAnimationSha256"] = "624d3089c7b27f12d96211b415452263e1145672036ec3818ac0f62dd93a2d05",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprintSha256"] = "4e0242d1113c20d75f77426b35b40713b580f08500683ac92e8d17c22e794c6a",
            ["sourceId"] = "UEB2401",
            ["sourceModelSha256"] = "869fc9557ab36c420830e22ee47f3dfa0e5d732e6078452ed67ef64142506753",
            ["sourceProjectile"] = "TIFHETacticalNuclearShell01",
            ["sourceProjectileSha256"] = "9b03d8d92f76cfcf9472cc01aa74c4e4e3edacc33177b27aaeeab39bffbcc3be",
            ["sourceProjectilesArchiveSha256"] = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            ["sourceScriptSha256"] = "7c708cec3e940bd422bf215dd64389dd42c53e287b91b97d93ffb98c754cc4a7",
            ["sourceUniformScale"] = 0.08,
            ["targetId"] = "ues4101",
            ["textureResolution"] = 2048,
        },
        ["scoFaArtillery"] = {
            ["aimTolerance"] = 0.5,
            ["alloys"] = 299700,
            ["buildSortPriority"] = 150,
            ["buildTime"] = 99900,
            ["collideFriendly"] = false,
            ["collisionOffset"] = {
                ["x"] = 0,
                ["y"] = -0.25,
                ["z"] = 0,
            },
            ["collisionSize"] = {
                ["x"] = 5,
                ["y"] = 2,
                ["z"] = 5,
            },
            ["damage"] = 12000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 7,
            ["deathAudio"] = "aeod2120",
            ["deathEffect"] = "VFX/Death/vcd2301_death_building_large.sanvfx",
            ["displayName"] = "Tier 4: Mavor",
            ["energy"] = 5994000,
            ["energyDrainPerSecond"] = 7500,
            ["energyRequired"] = 30000,
            ["fireAudio"] = "aeom1130",
            ["firingRandomness"] = 0.22,
            ["firstShotRequiresCharge"] = false,
            ["footprint"] = {
                ["x"] = 5,
                ["y"] = 5,
            },
            ["health"] = 8000,
            ["iconTech"] = "t4",
            ["impactEffect"] = "VFX/Impact/vei1301_cannon_large_impact.sanvfx",
            ["meshLod0Distance"] = 200,
            ["muzzle"] = "Turret_Muzzle",
            ["muzzleEffect"] = "VFX/Muzzle/vem1301_cannon_large_muzzle.sanvfx",
            ["muzzleVelocityRandom"] = 0.7,
            ["muzzleVelocityReduceDistance"] = 4000,
            ["name"] = "Mavor",
            ["openingAnimation"] = "fa_open",
            ["openingDuration"] = 3.6666667,
            ["pitchBone"] = "Turret_Barrel_B01",
            ["pitchRange"] = 90,
            ["pitchSpeed"] = 3,
            ["projectile"] = "psm401",
            ["projectileLifetime"] = 1000,
            ["projectileSpeed"] = 160,
            ["rackReloadTimeout"] = 0,
            ["rangeMax"] = 4000,
            ["rangeMin"] = 150,
            ["recoil"] = {
                [1] = {
                    ["bone"] = "Turret_Barrel_B02",
                    ["distance"] = -3.2,
                    ["returnSpeed"] = 0.5,
                },
                [2] = {
                    ["bone"] = "Turret_Barrel_B03",
                    ["distance"] = -3.2,
                    ["returnSpeed"] = 0.5,
                },
            },
            ["recoilHoldSeconds"] = 0.1,
            ["recoilTime"] = 6.4,
            ["reduceMuzzleVelocityToTarget"] = true,
            ["reloadTime"] = 8,
            ["selectionOffset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["selectionSize"] = {
                ["x"] = 4.25,
                ["y"] = 4,
            },
            ["selectionThickness"] = 0.24,
            ["skirt"] = {
                ["sourceOffsetX"] = -1.5,
                ["sourceOffsetZ"] = -1.5,
                ["x"] = 8,
                ["y"] = 8,
            },
            ["solverType"] = "HighArc",
            ["sourceAnimationSha256"] = "624d3089c7b27f12d96211b415452263e1145672036ec3818ac0f62dd93a2d05",
            ["sourceBlueprintSha256"] = "4e0242d1113c20d75f77426b35b40713b580f08500683ac92e8d17c22e794c6a",
            ["sourceId"] = "UEB2401",
            ["sourceModelSha256"] = "869fc9557ab36c420830e22ee47f3dfa0e5d732e6078452ed67ef64142506753",
            ["sourceProjectile"] = "TIFHETacticalNuclearShell01",
            ["sourceProjectileSha256"] = "9b03d8d92f76cfcf9472cc01aa74c4e4e3edacc33177b27aaeeab39bffbcc3be",
            ["sourceScriptSha256"] = "7c708cec3e940bd422bf215dd64389dd42c53e287b91b97d93ffb98c754cc4a7",
            ["sourceUniformScale"] = 0.08,
            ["targetBones"] = {
                [1] = "Target01",
                [2] = "Target02",
                [3] = "Target03",
                [4] = "Target04",
            },
            ["targetCheckInterval"] = 4,
            ["targetId"] = "ues4101",
            ["threat"] = {
                ["air"] = 0,
                ["economy"] = 4667,
                ["sub"] = 0,
                ["surface"] = 0,
            },
            ["trailEffect"] = "VFX/Trails/vet1301_cannon_large_trail.sanvfx",
            ["version"] = "1.0.0",
            ["vision"] = 28,
            ["yawBone"] = "Turret",
            ["yawRange"] = 180,
            ["yawSpeed"] = 3,
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
            ["x"] = 5,
            ["y"] = 2,
            ["z"] = 5,
        },
        ["targetBones"] = {
            [1] = "Target01",
            [2] = "Target02",
            [3] = "Target03",
            [4] = "Target04",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 8000,
            ["regen"] = 0,
            ["value"] = 8000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 99900,
        ["cost"] = {
            ["alloys"] = 299700,
            ["energy"] = 5994000,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "Tier 4: Mavor",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "indirect",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_experimental1_indirect.png",
        ["iconUIBuildSortPriority"] = 150,
        ["iconUIType"] = "land",
        ["name"] = "Mavor",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threat"] = 0,
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ues4101",
        ["unitTypeName"] = "UEFExperimentalArtillery",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
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
        ["x"] = 8,
        ["y"] = 8,
    },
    ["tags"] = {
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "EDA",
        [4] = "STRUCTURE",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_ARTILLERY",
        [7] = "SCFA_BUILTBYTIER3COMMANDER",
        [8] = "SCFA_BUILTBYTIER3ENGINEER",
        [9] = "SCFA_DRAGBUILD",
        [10] = "SCFA_EXPERIMENTAL",
        [11] = "SCFA_INDIRECTFIRE",
        [12] = "SCFA_OVERLAYINDIRECTFIRE",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SHOWATTACKRETICLE",
        [17] = "SCFA_SIZE16",
        [18] = "SCFA_STRATEGIC",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_UEF",
        [21] = "SCFA_VISIBLETORECON",
        [22] = "INDIRECT_FIRE",
        [23] = "STRATEGIC",
        [24] = "EXPERIMENTAL",
        [25] = "TECH4",
    },
    ["visuals"] = {
        ["animations"] = {
            ["fa_open"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues4101/LOD0/ues4101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues4101/LOD0/ues4101.sananimation",
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8999999999999999,
                    ["y"] = 0.25,
                    ["z"] = -1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.1,
                    ["y"] = 0.10999999999999999,
                    ["z"] = 0.8999999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1,
                    ["y"] = 0.31000000000000005,
                    ["z"] = 0.8,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8999999999999999,
                    ["y"] = 0.59,
                    ["z"] = -1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.1,
                    ["y"] = 0.55,
                    ["z"] = 0.8999999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 200,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 4.25,
                ["y"] = 4,
            },
            ["thickness"] = 0.24,
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
                    ["aimTolerance"] = 0.5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel_B01",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 3,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 160,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 3,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom1130",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 12000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 7,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ues4101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0.22,
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
                        ["Turret_Barrel_B02"] = -3.2,
                        ["Turret_Barrel_B03"] = -3.2,
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
            ["projectileLifetime"] = 1000,
            ["projectileTemplate"] = "psm401",
            ["rangeMax"] = 4000,
            ["rangeMin"] = 150,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["recoilTime"] = 6.4,
            ["reloadTime"] = 8,
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
