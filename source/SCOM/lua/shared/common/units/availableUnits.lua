-- List of "working" units. Validated by CreateAvailableUnitsList().
-- Make sure to update it before using again.

-- If the unit isnt on this list, it's handled as restricted
AvailableUnits = {

    -- EDA

    -- land
    uel0000 = true,  -- EDACommander                        -- OK
    uel1001 = true,  -- EDAT1Tank                           -- OK
    uel1002 = true,  -- EDAT1FastUnit                       -- OK
    uel1101 = true,  -- EDAT1MobileArty                     -- OK
    uel1201 = true,  -- EDAT1MAA                            -- OK
    uel1501 = true,  -- EDAT1Engineer                       -- OK
    uel1701 = true,  -- EDAT1LandScout                      -- OK
    uel1801 = false, -- EDAT1MobileBomp                     -- NO_MODEL (DEMO_UI_ONLY)
    uel2002 = false, -- EDAT2FastUnit                       -- NO_MODEL (DEMO_UI_ONLY)
    uel2101 = false, -- EDAT2LandDroneCarrier               -- NO_MODEL (DEMO_UI_ONLY)
    uel2201 = true,  -- EDAT2MAA                            -- OK
    uel2501 = true,  -- EDAT2Engineer                       -- OK
    uel2806 = false, -- EDAT2MobileRepairStation            -- NO_MODEL (DEMO_UI_ONLY)
    uel3001 = true,  -- EDAT3Tank                           -- OK
    uel3002 = true,  -- EDAT2FastUnit2                      -- OK
    uel3101 = true,  -- EDAT3MobileArty                     -- OK
    uel3401 = false, -- EDAT3MobileStealthShieldGenerator   -- NO_MODEL (DEMO_UI_ONLY)
    uel3501 = true,  -- EDAT3Engineer                       -- OK
    uel3801 = true,  -- EDAT3SniperBot                      -- OK
    uel4001 = true,  -- EDAT4RailgunSniper                  -- OK
    uel4002 = true,  -- EDAT4MobileBattleStation            -- OK
    uel4511 = false, -- Captain Crunch                      -- NO_MODEL (DEMO_UI_ONLY)
    -- air
    uea1001 = false, -- EDAT1Bomber                         -- BONE_MISSMATCH (DEMO_UI_ONLY)
    uea1201 = true,  -- EDAT1AAFighter                      -- OK
    uea1502 = false, -- EDAT1Transport                      -- NO_MODEL (DEMO_UI_ONLY)
    uea1701 = true,  -- EDAT1AirScout                       -- OK
    uea2011 = true,  -- EDAT2Gunship                        -- OK
    uea2101 = false, -- EDAT2DroneCarrier                   -- NO_MODEL (DEMO_UI_ONLY)
    uea2301 = false, -- EDAT2TorpedoBomber                  -- NO_MODEL (DEMO_UI_ONLY)
    uea2502 = false, -- EDAT2Transport                      -- NO_MODEL (DEMO_UI_ONLY)
    uea2806 = false, -- EDAT2FlyingRepairStation            -- NO_MODEL (DEMO_UI_ONLY)
    uea3001 = false, -- EDAT3Bomber                         -- BONE_MISSMATCH (DEMO_UI_ONLY)
    uea3011 = true,  -- EDAT3Gunship                        -- OK
    uea3201 = false, -- EDAT3AAFighter                      -- BONE_MISSMATCH
    uea3701 = false, -- EDAT3AirScout                       -- BONE_MISSMATCH
    uea4001 = false, -- EDAT4CarpetBomber                   -- TEMPLATE_INVALID_PREFAB (DEMO_UI_ONLY)
    -- naval
    uen1001 = false, -- EDAT1Frigate                        -- OK_PENDING_APPROVAL
    uen1304 = false, -- EDAT1NavalUnit                      -- BATTLE_NO_DAMAGE
    uen2001 = false, -- EDAT2NavalUnit                      -- OK_PENDING_APPROVAL
    uen3001 = false, -- EDAT3Battleship                     -- OK_PENDING_APPROVAL
    uen3304 = false, -- EDAT3NavalUnit                      -- BATTLE_NO_DAMAGE
    -- naval structures
    ues1301 = false, -- EDAT1TorpedoLauncher                -- NO_MODEL
    ues1513 = false, -- EDAT1NavalFactory                   -- NO_MODEL
    ues1702 = false, -- EDAT1Sonar                          -- NO_MODEL
    ues1803 = false, -- EDAT2NavalTechCentre                -- NO_MODEL
    ues2301 = false, -- EDAT2TorpedoLauncher                -- NO_MODEL
    ues2513 = false, -- EDAT2NavalFactory                   -- NO_MODEL
    ues2702 = false, -- EDAT2Sonar                          -- NO_MODEL
    ues2803 = false, -- EDAT3NavalTechCentre                -- NO_MODEL
    ues3513 = false, -- EDAT3NavalFactory                   -- NO_MODEL
    ues3702 = false, -- EDAT3Sonar                          -- NO_MODEL
    -- anti-naval
    -- structures
    ues1001 = true,  -- EDAT1PointDefence                   -- OK
    ues1201 = true,  -- EDAT1AA                             -- OK
    ues1501 = true,  -- EDAT1EngineeringStation             -- OK
    ues1511 = true,  -- EDAT1LandFactory                    -- OK
    ues1512 = true,  -- EDAT1AirFactory                     -- OK
    ues1601 = true,  -- EDAT1AlloyExtractor                 -- OK
    ues1602 = true,  -- EDAT1AlloyStorage                   -- OK
    ues1611 = true,  -- EDAT1EnergyGenerator                -- OK
    ues1612 = true,  -- EDAT1EnergyStorage                  -- OK
    ues1614 = false, -- EDAT1SolarConvertor                 -- NO_MODEL (DEMO_UI_ONLY)
    ues1701 = true,  -- EDAT1Radar                          -- OK
    ues1801 = false, -- EDAT2LandTechCentre                 -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ues1802 = false, -- EDAT2AirTechCentre                  -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ues1804 = false, -- EDAT1Wall                           -- NO_MODEL (DEMO_UI_ONLY)
    ues2001 = true,  -- EDAT2PointDefence                   -- OK
    ues2101 = false, -- EDAT2Arty                           -- NO_MODEL
    ues2102 = false, -- EDAT2DroneLauncher                  -- NO_MODEL (DEMO_UI_ONLY)
    ues2201 = true,  -- EDAT2AA                             -- OK
    ues2401 = true,  -- EDAT2Shield                         -- OK
    ues2402 = false, -- EDAT2AntiDroneDefence               -- NO_MODEL (DEMO_UI_ONLY)
    ues2501 = true,  -- EDAT2EngineeringStation             -- OK
    ues2510 = false, -- EDAT2OperatingTheatre               -- NO_MODEL (DEMO_UI_ONLY)
    ues2511 = true,  -- EDAT2LandFactory                    -- OK
    ues2512 = true,  -- EDAT2AirFactory                     -- OK
    ues2601 = true,  -- EDAT2AlloyExtractor                 -- OK
    ues2611 = true,  -- EDAT2EnergyGenerator                -- OK
    ues2701 = true,  -- EDAT2Radar                          -- OK
    ues2801 = false, -- EDAT3LandTechCentre                 -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ues2802 = false, -- EDAT3AirTechCentre                  -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ues2806 = false, -- EDAT2RepairStation                  -- NO_MODEL (DEMO_UI_ONLY)
    ues3102 = false, -- EDAT3StrategicLauncher              -- NO_MODEL (DEMO_UI_ONLY)
    ues3201 = true,  -- EDAT3AA                             -- OK
    ues3401 = true,  -- EDAT3Shield                         -- OK
    ues3402 = false, -- EDAT3StrategicDefense               -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ues3501 = true,  -- EDAT3EngineeringStation             -- OK
    ues3511 = true,  -- EDAT3LandFactory                    -- OK
    ues3512 = true,  -- EDAT3AirFactory                     -- OK
    ues3601 = true,  -- EDAT3AlloyExtractor                 -- OK
    ues3603 = true,  -- EDAT3AlloyFurnace                   -- OK
    ues3611 = true,  -- EDAT3EnergyGenerator                -- OK
    ues3701 = true,  -- EDAT3Radar                          -- OK
    ues4101 = false, -- EDAT4HeavyArty                      -- NO_MODEL (DEMO_UI_ONLY)

    -- CHOSEN

    -- land
    ucl0000 = true,  -- ChosenCommander                     -- OK
    ucl1001 = true,  -- ChosenT1Tank                        -- OK
    ucl1002 = true,  -- ChosenT1FastUnit                    -- OK
    ucl1101 = true,  -- ChosenT1MobileArty                  -- OK
    ucl1201 = false, -- ChosenT1MAA                         -- OK (DEMO_UI_ONLY)
    ucl1501 = true,  -- ChosenT1Engineer                    -- OK
    ucl1701 = true,  -- ChosenT1LandScout                   -- OK
    ucl2002 = true,  -- ChosenT2FastUnit                    -- OK
    ucl2101 = true,  -- ChosenT2LandDroneCarrier            -- OK
    ucl2201 = true,  -- ChosenT2MAA                         -- OK
    ucl2501 = true,  -- ChosenT2Engineer                    -- OK
    ucl2806 = false, -- ChosenT2MobileShieldBooster         -- OK (DEMO_UI_ONLY)
    ucl3001 = true,  -- ChosenT3Tank                        -- OK
    ucl3101 = true,  -- ChosenT3MobileArty                  -- OK
    ucl3501 = true,  -- ChosenT3Engineer                    -- OK
    ucl3701 = true,  -- ChosenT3LandScout                   -- OK
    ucl3801 = true,  -- ChosenT3SniperBot                   -- OK
    ucl4001 = true,  -- ChosenT4Bot                         -- OK
    ucl4002 = true,  -- ChosenT4TripodBot                   -- OK
    ucl4003 = true,  -- ChosenT4BotHover                    -- OK
    ucl4004 = true,  -- ChosenT4BotBig                      -- OK
    ucl4005 = false, -- ChosenT4BotMega                     -- BONE_MISSMATCH (DEMO_UI_ONLY)
    ucl4401 = true,  -- ChosenT4MobileShield                -- OK
    ugl2806 = false, -- GuardT2MobileTransmitter            -- OK (DEMO_UI_ONLY)
    -- air
    uca1001 = true,  -- ChosenT1Bomber                      -- OK
    uca1201 = true,  -- ChosenT1AAFighter                   -- OK
    uca1502 = false, -- ChosenT1Transport                   -- NO_MODEL (DEMO_UI_ONLY)
    uca1701 = true,  -- ChosenT1AirScout                    -- OK
    uca2011 = true,  -- ChosenT2Gunship                     -- OK
    uca2101 = false, -- ChosenT2DroneCarrier                -- NO_MODEL (DEMO_UI_ONLY)
    uca2301 = false, -- ChosenT2TorpedoBomber               -- NO_MODEL (DEMO_UI_ONLY)
    uca2502 = false, -- ChosenT2Transport                   -- NO_MODEL (DEMO_UI_ONLY)
    uca2701 = true,  -- ChosenT2AirScout                    -- OK
    uca2806 = false, -- ChosenT2FlyingShieldBooster         -- NO_MODEL (DEMO_UI_ONLY)
    uca3001 = false, -- ChosenT3Bomber                      -- NO_MODEL (DEMO_UI_ONLY)
    uca3011 = true,  -- ChosenT3Gunship                     -- OK
    uca3201 = true,  -- ChosenT3AAFighter                   -- OK
    uca3701 = true,  -- ChosenT3AirScout                    -- OK
    uca4011 = true,  -- ChosenT4Gunship                     -- OK
    -- naval
    ucn1001 = true,  -- ChosenT1Frigate                     -- OK
    ucn1304 = false, -- ChosenT1NavalUnit                   -- BATTLE_NO_DAMAGE
    ucn2001 = false, -- ChosenT2NavalUnit                   -- OK_PENDING_APPROVAL
    ucn3001 = true,  -- ChosenT3Frigate                     -- OK
    ucn3304 = false, -- ChosenT3NavalUnit                   -- BATTLE_NO_DAMAGE
    -- naval structures
    ucs1301 = false, -- ChosenT1TorpedoLauncher             -- NO_MODEL
    ucs1513 = true,  -- ChosenT1NavalFactory                -- OK
    ucs1702 = false, -- ChosenT1Sonar                       -- NO_MODEL
    ucs1803 = false, -- ChosenT2NavalTechCentre             -- NO_MODEL
    ucs2301 = false, -- ChosenT2TorpedoLauncher             -- NO_MODEL
    ucs2513 = true,  -- ChosenT2NavalFactory                -- OK
    ucs2702 = false, -- ChosenT2Sonar                       -- NO_MODEL
    ucs2803 = false, -- ChosenT3NavalTechCentre             -- NO_MODEL
    ucs3513 = true,  -- ChosenT3NavalFactory                -- OK
    ucs3702 = false, -- ChosenT3Sonar                       -- NO_MODEL
    -- anti-naval
    -- structures
    ucs1001 = true,  -- ChosenT1PointDefence                -- OK
    ucs1201 = true,  -- ChosenT1AA                          -- OK
    ucs1501 = true,  -- ChosenT1EngineeringStation          -- OK
    ucs1511 = true,  -- ChosenT1LandFactory                 -- OK
    ucs1512 = true,  -- ChosenT1AirFactory                  -- OK
    ucs1601 = true,  -- ChosenT1AlloyExtractor              -- OK
    ucs1602 = true,  -- ChosenT1AlloyStorage                -- OK
    ucs1611 = true,  -- ChosenT1EnergyGenerator             -- OK
    ucs1612 = true,  -- ChosenT1EnergyStorage               -- OK
    ucs1614 = false, -- ChosenT1SolarConvertor              -- NO_MODEL (DEMO_UI_ONLY)
    ucs1701 = true,  -- ChosenT1Radar                       -- OK
    ucs1801 = false, -- ChosenT2LandTechCentre              -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ucs1802 = false, -- ChosenT2AirTechCentre               -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ucs1804 = false, -- ChosenT1Wall                        -- NO_MODEL (DEMO_UI_ONLY)
    ucs2001 = true,  -- ChosenT2PointDefence                -- OK
    ucs2101 = true,  -- ChosenT2Arty                        -- OK
    ucs2102 = false, -- ChosenT2DroneLauncher               -- OK (DEMO_UI_ONLY)
    ucs2201 = true,  -- ChosenT2AA                          -- OK
    ucs2401 = true,  -- ChosenT2Shield                      -- OK
    ucs2402 = false, -- ChosenT2AntiDroneDefence            -- NO_MODEL (DEMO_UI_ONLY)
    ucs2501 = true,  -- ChosenT2EngineeringStation          -- OK
    ucs2510 = false, -- ChosenT2OperatingTheatre            -- NO_MODEL (DEMO_UI_ONLY)
    ucs2511 = true,  -- ChosenT2LandFactory                 -- OK
    ucs2512 = true,  -- ChosenT2AirFactory                  -- OK
    ucs2601 = true,  -- ChosenT2AlloyExtractor              -- OK
    ucs2611 = true,  -- ChosenT2EnergyGenerator             -- OK
    ucs2701 = true,  -- ChosenT2Radar                       -- OK
    ucs2711 = false, -- ChosenT2StealthField                -- OK (DEMO_UI_ONLY)
    ucs2801 = false, -- ChosenT3LandTechCentre              -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ucs2802 = false, -- ChosenT3AirTechCentre               -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ucs2806 = false, -- ChosenT2ShieldBoosterStation        -- NO_MODEL (DEMO_UI_ONLY)
    ucs3001 = true,  -- ChosenT3PointDefence                -- OK
    ucs3101 = true,  -- ChosenT3Arty                        -- OK
    ucs3102 = false, -- ChosenT3StrategicLauncher           -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ucs3201 = true,  -- ChosenT3AA                          -- OK
    ucs3401 = true,  -- ChosenT3Shield                      -- OK
    ucs3402 = false, -- ChosenT3StrategicDefense            -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ucs3501 = true,  -- ChosenT3EngineeringStation          -- OK
    ucs3511 = true,  -- ChosenT3LandFactory                 -- OK
    ucs3512 = true,  -- ChosenT3AirFactory                  -- OK
    ucs3601 = true,  -- ChosenT3AlloyExtractor              -- OK
    ucs3603 = true,  -- ChosenT3AlloyFurnace                -- OK
    ucs3611 = true,  -- ChosenT3EnergyGenerator             -- OK
    ucs3701 = true,  -- ChosenT3Radar                       -- OK
    ucs4102 = false, -- ChosenT4StrategicLauncher           -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)

    -- GUARD

    -- land
    ugl0000 = true,  -- GuardCommander                      -- OK
    ugl1001 = true,  -- GuardT1Tank                         -- OK
    ugl1002 = true,  -- GuardT1FastUnit                     -- OK
    ugl1101 = true,  -- GuardT1MobileArty                   -- OK
    ugl1201 = true,  -- GuardT1MAA                          -- OK
    ugl1501 = true,  -- GuardT1Engineer                     -- OK
    ugl1701 = true,  -- GuardT1LandScout                    -- OK
    ugl2002 = true,  -- GuardT2FastUnit                     -- OK
    ugl2101 = true,  -- GuardT2GranadeBot                   -- OK
    ugl2201 = true,  -- GuardT2MAA                          -- OK
    ugl2501 = true,  -- GuardT2Engineer                     -- OK
    ugl3001 = true,  -- GuardT3Tank                         -- OK
    ugl3002 = true,  -- GuardT3FastUnit                     -- OK
    ugl3101 = false, -- GuardT3MobileDroneCarrier           -- OK (DEMO_UI_ONLY)
    ugl3501 = true,  -- GuardT3Engineer                     -- OK
    ugl3502 = false, -- GuardT3CombatEngineer               -- OK (DEMO_UI_ONLY)
    ugl4001 = true,  -- GuardT4Bot                          -- OK
    ugl4011 = true,  -- GuardT4Bot                          -- OK
    -- air
    uga1001 = false, -- GuardT1Bomber                       -- BONE_MISSMATCH (DEMO_UI_ONLY)
    uga1011 = true,  -- GuardT1Gunship                      -- OK
    uga1201 = true,  -- GuardT1AAFighter                    -- OK
    uga1502 = false, -- GuardT1Transport                    -- NO_MODEL (DEMO_UI_ONLY)
    uga1701 = true,  -- GuardT1AirScout                     -- OK
    uga2011 = true,  -- GuardT2Gunship                      -- OK
    uga2101 = false, -- GuardT2DroneCarrier                 -- OK (DEMO_UI_ONLY)
    uga2301 = false, -- GuardT2TorpedoBomber                -- OK (DEMO_UI_ONLY)
    uga2502 = false, -- GuardT2Transport                    -- OK (DEMO_UI_ONLY)
    uga2806 = false, -- GuardT2FlyingTransmitter            -- NO_MODEL (DEMO_UI_ONLY)
    uga3001 = false, -- GuardT3Bomber                       -- BONE_MISSMATCH (DEMO_UI_ONLY)
    uga3011 = false, -- GuardT3Gunship                      -- NO_MODEL
    uga3201 = false, -- GuardT3AAFighter                    -- BONE_MISSMATCH
    uga3701 = true,  -- GuardT3AirScout                     -- OK
    uga4001 = false, -- GuardT4MothershipShatterer          -- TEMPLATE_INVALID_PREFAB (DEMO_UI_ONLY)
    uga4801 = false, -- GuardT4Mothership                   -- NO_MODEL (DEMO_UI_ONLY)
    -- naval
    ugn1001 = false, -- GuardT1Frigate                      -- OK_PENDING_APPROVAL
    ugn1304 = false, -- GuardT1NavalUnit                    -- BATTLE_NO_DAMAGE
    ugn2001 = false, -- GuardT2NavalUnit                    -- OK_PENDING_APPROVAL
    ugn2304 = false, -- GuardT2NavalUnit                    -- BATTLE_NO_DAMAGE
    ugn3001 = false, -- GuardT3Battleship                   -- OK_PENDING_APPROVAL
    -- naval structures
    ugs1301 = true,  -- GuardT1TorpedoLauncher              -- OK
    ugs1513 = true,  -- GuardT1NavalFactory                 -- OK
    ugs1702 = true,  -- GuardT1Sonar                        -- OK
    ugs1803 = false, -- GuardT2NavalTechCentre              -- OK_PENDING_APPROVAL
    ugs2301 = true,  -- GuardT2TorpedoLauncher              -- OK
    ugs2513 = true,  -- GuardT2NavalFactory                 -- OK
    ugs2702 = true,  -- GuardT2Sonar                        -- OK
    ugs2803 = false, -- GuardT3NavalTechCentre              -- OK_PENDING_APPROVAL
    ugs3513 = true,  -- GuardT3NavalFactory                 -- OK
    ugs3702 = true,  -- GuardT3Sonar                        -- OK
    -- anti-naval
    -- structures
    ugs1001 = true,  -- GuardT1PointDefence                 -- OK
    ugs1201 = true,  -- GuardT1AA                           -- OK
    ugs1501 = true,  -- GuardT1EngineeringStation           -- OK
    ugs1511 = true,  -- GuardT1LandFactory                  -- OK
    ugs1512 = true,  -- GuardT1AirFactory                   -- OK
    ugs1601 = true,  -- GuardT1AlloyExtractor               -- OK
    ugs1602 = true,  -- GuardT1AlloyStorage                 -- OK
    ugs1611 = true,  -- GuardT1EnergyGenerator              -- OK
    ugs1612 = true,  -- GuardT1EnergyStorage                -- OK
    ugs1614 = false, -- GuardT1SolarConvertor               -- NO_MODEL (DEMO_UI_ONLY)
    ugs1701 = true,  -- GuardT1Radar                        -- OK
    ugs1801 = false, -- GuardT2LandTechCentre               -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ugs1802 = false, -- GuardT2AirTechCentre                -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ugs1804 = false, -- GuardT1Wall                         -- OK (DEMO_UI_ONLY)
    ugs1805 = true,  -- GuardT1Airfield                     -- OK
    ugs1806 = false, -- GuardT1Transmitter                  -- OK (DEMO_UI_ONLY)
    ugs2001 = true,  -- GuardT2PointDefence                 -- OK
    ugs2101 = true,  -- GuardT2Arty                         -- OK
    ugs2102 = false, -- GuardT2DroneLauncher                -- OK (DEMO_UI_ONLY)
    ugs2201 = true,  -- GuardT2AA                           -- OK
    ugs2401 = true,  -- GuardT2Shield                       -- OK
    ugs2402 = false, -- GuardT2AntiDroneDefence             -- OK (DEMO_UI_ONLY)
    ugs2501 = true,  -- GuardT2EngineeringStation           -- OK
    ugs2510 = false, -- GuardT2OperatingTheatre             -- NO_MODEL (DEMO_UI_ONLY)
    ugs2511 = true,  -- GuardT2LandFactory                  -- OK
    ugs2512 = true,  -- GuardT2AirFactory                   -- OK
    ugs2601 = true,  -- GuardT2AlloyExtractor               -- OK
    ugs2611 = true,  -- GuardT2EnergyGenerator              -- OK
    ugs2701 = true,  -- GuardT2Radar                        -- OK
    ugs2711 = false, -- GuardT2StealthField                 -- OK (DEMO_UI_ONLY)
    ugs2801 = false, -- GuardT3LandTechCentre               -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ugs2802 = false, -- GuardT3AirTechCentre                -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ugs2805 = false, -- GuardT2Airfield                     -- OK (DEMO_UI_ONLY)
    ugs2806 = false, -- GuardT2Transmitter                  -- OK (DEMO_UI_ONLY)
    ugs2807 = false, -- Terminal                            -- NO_MODEL (DEMO_UI_ONLY)
    ugs3101 = true,  -- GuardT3Arty                         -- OK
    ugs3102 = false, -- GuardT3StrategicLauncher            -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ugs3201 = true,  -- GuardT3AA                           -- OK
    ugs3401 = true,  -- GuardT3Shield                       -- OK
    ugs3402 = false, -- GuardT3StrategicDefense             -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
    ugs3501 = true,  -- GuardT3EngineeringStation           -- OK
    ugs3511 = true,  -- GuardT3LandFactory                  -- OK
    ugs3512 = true,  -- GuardT3AirFactory                   -- OK
    ugs3601 = true,  -- GuardT3AlloyExtractor               -- OK
    ugs3603 = true,  -- GuardT3AlloyFurnace                 -- OK
    ugs3611 = true,  -- GuardT3EnergyGenerator              -- OK
    ugs3701 = true,  -- GuardT3Radar                        -- OK
    ugs3805 = false, -- GuardT3Airfield                     -- NO_MODEL
    ugs4012 = false, -- GuardT4Arty                         -- OK (DEMO_UI_ONLY)
    ugs4102 = false, -- GuardT4HiveHole                     -- NO_MODEL (DEMO_UI_ONLY)
    ugs4621 = true,  -- GuardT4ExperimetalGenerator         -- OK
    uws1000 = false, -- CryoTank                            -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)

    -- Unknown

    -- land
    -- air
    -- naval
    -- naval structures
    -- anti-naval
    -- structures
    ues1111 = false, -- FreezeStation                       -- OK_PENDING_APPROVAL (DEMO_UI_ONLY)
}


-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0
AvailableUnits["uel4511"] = true

-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0
-- The current engine already lists UGS3201 as available.  Reassert that roster
-- state only after URB2304's complete weapon/muzzle contract is installed in
-- this same cache transaction, so the marker attests one complete generation.
-- This is a roster-loader gate only.  The stock UGS3201 tags still determine
-- builder eligibility; this patch does not create a factory rule or canBuild
-- expression.
AvailableUnits["ugs3201"] = true
-- Supreme Commander Overhaul UEF Percival 1.0.0
-- uel3401 is a stock NO_MODEL demonstration placeholder. The source-pinned
-- overlay and gameplay transaction make it a real factory-buildable unit.
AvailableUnits["uel3401"] = true
-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0
-- The source-pinned Trebuchet now has its complete model, template, projectile,
-- and deterministic deploy lifecycle. Enable the existing Guard T3 factory
-- route; template tags remain the builder-eligibility contract.
AvailableUnits["ugl3101"] = true
-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0
-- Physical templates provide scanner discovery. This closed roster append is
-- committed in the same cache transaction as both behavior states and gates.
AvailableUnits["ugl4002"] = true
AvailableUnits["ugs4902"] = true
AvailableUnits["ugs4903"] = true
AvailableUnits["ugs4904"] = true
AvailableUnits["ugs4905"] = true

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
-- Explicitly keep all virtual Seraphim templates loadable when either development gate is enabled.
AvailableUnits["usa1001"] = true
AvailableUnits["usa1201"] = true
AvailableUnits["usa1502"] = true
AvailableUnits["usa1701"] = true
AvailableUnits["usa2011"] = true
AvailableUnits["usa2101"] = true
AvailableUnits["usa2301"] = true
AvailableUnits["usa2502"] = true
AvailableUnits["usa3001"] = true
AvailableUnits["usa3201"] = true
AvailableUnits["usa3701"] = true
AvailableUnits["usa4011"] = true
AvailableUnits["usl0000"] = true
AvailableUnits["usl1001"] = true
AvailableUnits["usl1101"] = true
AvailableUnits["usl1201"] = true
AvailableUnits["usl1501"] = true
AvailableUnits["usl1701"] = true
AvailableUnits["usl2002"] = true
AvailableUnits["usl2101"] = true
AvailableUnits["usl2201"] = true
AvailableUnits["usl2501"] = true
AvailableUnits["usl2806"] = true
AvailableUnits["usl3001"] = true
AvailableUnits["usl3101"] = true
AvailableUnits["usl3501"] = true
AvailableUnits["usl3801"] = true
AvailableUnits["usl4002"] = true
AvailableUnits["usl4004"] = true
AvailableUnits["usl4401"] = true
AvailableUnits["usn1001"] = true
AvailableUnits["usn1002"] = true
AvailableUnits["usn2001"] = true
AvailableUnits["usn2002"] = true
AvailableUnits["usn3001"] = true
AvailableUnits["usn3003"] = true
AvailableUnits["usn3004"] = true
AvailableUnits["uss1001"] = true
AvailableUnits["uss1201"] = true
AvailableUnits["uss1301"] = true
AvailableUnits["uss1511"] = true
AvailableUnits["uss1512"] = true
AvailableUnits["uss1513"] = true
AvailableUnits["uss1601"] = true
AvailableUnits["uss1602"] = true
AvailableUnits["uss1611"] = true
AvailableUnits["uss1612"] = true
AvailableUnits["uss1614"] = true
AvailableUnits["uss1701"] = true
AvailableUnits["uss1702"] = true
AvailableUnits["uss1804"] = true
AvailableUnits["uss2001"] = true
AvailableUnits["uss2101"] = true
AvailableUnits["uss2102"] = true
AvailableUnits["uss2201"] = true
AvailableUnits["uss2301"] = true
AvailableUnits["uss2401"] = true
AvailableUnits["uss2402"] = true
AvailableUnits["uss2510"] = true
AvailableUnits["uss2511"] = true
AvailableUnits["uss2512"] = true
AvailableUnits["uss2513"] = true
AvailableUnits["uss2601"] = true
AvailableUnits["uss2611"] = true
AvailableUnits["uss2701"] = true
AvailableUnits["uss2702"] = true
AvailableUnits["uss2711"] = true
AvailableUnits["uss2806"] = true
AvailableUnits["uss3101"] = true
AvailableUnits["uss3102"] = true
AvailableUnits["uss3201"] = true
AvailableUnits["uss3401"] = true
AvailableUnits["uss3402"] = true
AvailableUnits["uss3501"] = true
AvailableUnits["uss3511"] = true
AvailableUnits["uss3512"] = true
AvailableUnits["uss3513"] = true
AvailableUnits["uss3601"] = true
AvailableUnits["uss3603"] = true
AvailableUnits["uss3611"] = true
AvailableUnits["uss3701"] = true
AvailableUnits["uss4102"] = true


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
do
    -- Own exactly the 94 replaced Chosen slots.
    -- The independently patched ucl0000 entry is untouched.
    AvailableUnits["uca1001"] = true
    AvailableUnits["uca1201"] = true
    AvailableUnits["uca1502"] = true
    AvailableUnits["uca1701"] = true
    AvailableUnits["uca2011"] = true
    AvailableUnits["uca2101"] = true
    AvailableUnits["uca2301"] = true
    AvailableUnits["uca2502"] = true
    AvailableUnits["uca2701"] = true
    AvailableUnits["uca2806"] = true
    AvailableUnits["uca3001"] = true
    AvailableUnits["uca3011"] = true
    AvailableUnits["uca3201"] = true
    AvailableUnits["uca3701"] = true
    AvailableUnits["uca4011"] = true
    AvailableUnits["ucl1001"] = true
    AvailableUnits["ucl1002"] = true
    AvailableUnits["ucl1101"] = true
    AvailableUnits["ucl1201"] = true
    AvailableUnits["ucl1501"] = true
    AvailableUnits["ucl1701"] = true
    AvailableUnits["ucl2002"] = true
    AvailableUnits["ucl2101"] = true
    AvailableUnits["ucl2201"] = true
    AvailableUnits["ucl2501"] = true
    AvailableUnits["ucl2806"] = true
    AvailableUnits["ucl3001"] = true
    AvailableUnits["ucl3101"] = true
    AvailableUnits["ucl3501"] = true
    AvailableUnits["ucl3701"] = true
    AvailableUnits["ucl3801"] = true
    AvailableUnits["ucl4001"] = true
    AvailableUnits["ucl4002"] = true
    AvailableUnits["ucl4003"] = true
    AvailableUnits["ucl4004"] = true
    AvailableUnits["ucl4005"] = true
    AvailableUnits["ucl4401"] = true
    AvailableUnits["ucn1001"] = true
    AvailableUnits["ucn3001"] = true
    AvailableUnits["ucs1001"] = true
    AvailableUnits["ucs1201"] = true
    AvailableUnits["ucs1301"] = true
    AvailableUnits["ucs1501"] = false
    AvailableUnits["ucs1511"] = true
    AvailableUnits["ucs1512"] = true
    AvailableUnits["ucs1513"] = true
    AvailableUnits["ucs1601"] = true
    AvailableUnits["ucs1602"] = true
    AvailableUnits["ucs1611"] = true
    AvailableUnits["ucs1612"] = true
    AvailableUnits["ucs1614"] = true
    AvailableUnits["ucs1701"] = true
    AvailableUnits["ucs1702"] = true
    AvailableUnits["ucs1801"] = true
    AvailableUnits["ucs1802"] = true
    AvailableUnits["ucs1803"] = true
    AvailableUnits["ucs1804"] = true
    AvailableUnits["ucs2001"] = true
    AvailableUnits["ucs2101"] = true
    AvailableUnits["ucs2102"] = true
    AvailableUnits["ucs2201"] = true
    AvailableUnits["ucs2301"] = true
    AvailableUnits["ucs2401"] = true
    AvailableUnits["ucs2402"] = true
    AvailableUnits["ucs2501"] = true
    AvailableUnits["ucs2510"] = true
    AvailableUnits["ucs2511"] = true
    AvailableUnits["ucs2512"] = true
    AvailableUnits["ucs2513"] = true
    AvailableUnits["ucs2601"] = true
    AvailableUnits["ucs2611"] = true
    AvailableUnits["ucs2701"] = true
    AvailableUnits["ucs2702"] = true
    AvailableUnits["ucs2711"] = true
    AvailableUnits["ucs2801"] = false
    AvailableUnits["ucs2802"] = false
    AvailableUnits["ucs2803"] = true
    AvailableUnits["ucs2806"] = true
    AvailableUnits["ucs3001"] = true
    AvailableUnits["ucs3101"] = true
    AvailableUnits["ucs3102"] = true
    AvailableUnits["ucs3201"] = true
    AvailableUnits["ucs3401"] = true
    AvailableUnits["ucs3402"] = true
    AvailableUnits["ucs3501"] = true
    AvailableUnits["ucs3511"] = true
    AvailableUnits["ucs3512"] = true
    AvailableUnits["ucs3513"] = true
    AvailableUnits["ucs3601"] = true
    AvailableUnits["ucs3603"] = true
    AvailableUnits["ucs3611"] = true
    AvailableUnits["ucs3701"] = true
    AvailableUnits["ucs3702"] = true
    AvailableUnits["ucs4102"] = true
end

-- Supreme Commander Overhaul sea parity 1.0.0
-- Keep generated naval content loadable for AI and reduced quick launch.
AvailableUnits["uen1001"] = true
AvailableUnits["uen1002"] = true
AvailableUnits["uen2001"] = true
AvailableUnits["uen2002"] = true
AvailableUnits["uen3001"] = true
AvailableUnits["uen3004"] = true
AvailableUnits["uen3005"] = true
AvailableUnits["uen4001"] = true
AvailableUnits["ues1512"] = true
AvailableUnits["ues1513"] = true
AvailableUnits["ues2513"] = true
AvailableUnits["ues3513"] = true
AvailableUnits["ugn1001"] = true
AvailableUnits["ugn1002"] = true
AvailableUnits["ugn2001"] = true
AvailableUnits["ugn2002"] = true
AvailableUnits["ugn3001"] = true
AvailableUnits["ugn3003"] = true
AvailableUnits["ugn3004"] = true
AvailableUnits["ugn3005"] = true
AvailableUnits["ugs1512"] = true
AvailableUnits["ugs1513"] = true
AvailableUnits["ugs2513"] = true
AvailableUnits["ugs3513"] = true

-- SCOM mock Hydro placement 2.1.88.6
-- Availability does not bypass native construction validation or builder tags.
do
    assert(type(AvailableUnits) == "table", "SCOM mock Hydro: missing availability table")
    for _, id in ipairs({"ucs1614", "ues5015", "ugs5003", "uss1614"}) do
        AvailableUnits[id] = true
    end
end
-- End SCOM mock Hydro placement 2.1.88.6
-- SCOM source roster availability 1.0.0
for _, id in ipairs({ "uca1001", "uca1201", "uca1502", "uca1701", "uca2011", "uca2101", "uca2301", "uca2502", "uca2701", "uca2806", "uca3001", "uca3011", "uca3201", "uca3701", "uca4011", "uca5001", "ucl0000", "ucl1001", "ucl1002", "ucl1101", "ucl1201", "ucl1501", "ucl1701", "ucl2002", "ucl2101", "ucl2201", "ucl2501", "ucl2806", "ucl3001", "ucl3101", "ucl3501", "ucl3701", "ucl3801", "ucl4001", "ucl4002", "ucl4003", "ucl4004", "ucl4005", "ucl4401", "ucl5001", "ucn1001", "ucn3001", "ucn5001", "ucs1001", "ucs1201", "ucs1301", "ucs1501", "ucs1511", "ucs1512", "ucs1513", "ucs1601", "ucs1602", "ucs1611", "ucs1612", "ucs1614", "ucs1701", "ucs1702", "ucs1801", "ucs1802", "ucs1803", "ucs1804", "ucs2001", "ucs2101", "ucs2102", "ucs2201", "ucs2301", "ucs2401", "ucs2402", "ucs2501", "ucs2510", "ucs2511", "ucs2512", "ucs2513", "ucs2601", "ucs2611", "ucs2701", "ucs2702", "ucs2711", "ucs2801", "ucs2802", "ucs2803", "ucs2806", "ucs3001", "ucs3101", "ucs3102", "ucs3201", "ucs3401", "ucs3402", "ucs3501", "ucs3511", "ucs3512", "ucs3513", "ucs3601", "ucs3603", "ucs3611", "ucs3701", "ucs3702", "ucs4102", "ucs5001", "ucs5002", "ucs5003", "ucs5004", "ucs5005", "ucs5006", "ucs5007", "ucs5008", "uea0001", "uea1001", "uea1201", "uea1701", "uea2301", "uea3001", "uea5001", "uea5002", "uea5003", "uea5004", "uea5005", "uea5006", "uea5007", "uea5008", "uea5009", "uea5010", "uea5011", "uel0000", "uel1001", "uel1002", "uel1101", "uel1201", "uel1501", "uel1701", "uel2201", "uel2501", "uel3001", "uel3002", "uel3101", "uel3401", "uel3501", "uel4511", "uel5001", "uel5002", "uel5003", "uel5004", "uel5005", "uel5006", "uel5007", "uel5008", "uel5009", "uel5010", "uel5011", "uen1001", "uen1002", "uen2001", "uen2002", "uen3001", "uen3004", "uen3005", "uen4001", "uen5001", "uen5002", "uen5003", "ues1001", "ues1201", "ues1511", "ues1512", "ues1513", "ues1601", "ues1602", "ues1611", "ues1612", "ues1701", "ues2001", "ues2101", "ues2102", "ues2201", "ues2401", "ues2402", "ues2501", "ues2511", "ues2512", "ues2513", "ues2601", "ues2611", "ues2701", "ues3102", "ues3201", "ues3401", "ues3501", "ues3511", "ues3512", "ues3513", "ues3601", "ues3603", "ues3611", "ues3701", "ues4101", "ues5001", "ues5002", "ues5003", "ues5004", "ues5005", "ues5006", "ues5007", "ues5008", "ues5009", "ues5010", "ues5011", "ues5012", "ues5013", "ues5014", "ues5015", "ues5016", "ues5017", "ues5018", "ues5019", "ues5020", "ues5021", "ues5022", "ues5023", "ues5024", "ues5025", "ues5026", "ues5027", "ues5028", "ues5029", "ues5030", "ues5031", "ues5032", "ues5033", "ues5034", "ues5035", "ues5036", "ues5037", "ues5038", "ues5039", "ues5040", "ues5042", "ues5043", "ues5044", "ues5045", "ues5046", "ues5049", "ues5050", "ues5051", "ues5052", "ues5053", "ues5054", "ues5055", "ues5056", "ues5057", "ues5058", "ues5059", "ues5060", "ues5061", "ues5062", "ues5063", "ues5064", "ues5065", "ues5066", "ues5067", "ues5068", "ues5069", "ues5070", "ues5071", "ues5072", "ues5073", "ues5074", "ues5075", "ues5076", "ues5077", "ues5078", "ues5079", "ues5080", "ues5082", "ues5085", "ues5086", "ues5087", "ues5088", "ues5090", "ues5093", "ues5094", "uga1001", "uga1201", "uga1701", "uga2301", "uga3001", "uga5001", "uga5002", "uga5003", "uga5004", "uga5005", "uga5006", "uga5007", "uga5008", "uga5009", "ugl0000", "ugl1001", "ugl1002", "ugl1101", "ugl1501", "ugl1701", "ugl2002", "ugl2101", "ugl2201", "ugl2501", "ugl3001", "ugl3002", "ugl3101", "ugl3501", "ugl4001", "ugl4002", "ugl4011", "ugl5001", "ugl5002", "ugl5003", "ugl5004", "ugl5005", "ugl5006", "ugn1001", "ugn1002", "ugn2001", "ugn2002", "ugn3001", "ugn3003", "ugn3004", "ugn3005", "ugn5001", "ugn5002", "ugs1001", "ugs1201", "ugs1511", "ugs1512", "ugs1513", "ugs1601", "ugs1602", "ugs1611", "ugs1612", "ugs1701", "ugs2001", "ugs2101", "ugs2102", "ugs2201", "ugs2401", "ugs2402", "ugs2501", "ugs2511", "ugs2512", "ugs2513", "ugs2601", "ugs2611", "ugs2701", "ugs3101", "ugs3201", "ugs3401", "ugs3501", "ugs3511", "ugs3512", "ugs3513", "ugs3601", "ugs3603", "ugs3611", "ugs3701", "ugs4902", "ugs4903", "ugs4904", "ugs4905", "ugs5001", "ugs5002", "ugs5003", "ugs5004", "ugs5005", "ugs5006", "ugs5007", "ugs5008", "ugs5009", "ugs5010", "ugs5011", "ugs5012", "ugs5013", "ugs5014", "ugs5015", "ugs5016", "ugs5017", "ugs5018", "ugs5019", "ugs5020", "ugs5021", "ugs5022", "ugs5023", "ugs5024", "ugs5025", "ugs5026", "ugs5027", "ugs5028", "ugs5029", "ugs5030", "ugs5031", "ugs5032", "ugs5033", "ugs5034", "ugs5035", "ugs5036", "ugs5037", "ugs5038", "ugs5039", "ugs5040", "ugs5041", "ugs5042", "ugs5043", "ugs5044", "ugs5045", "ugs5046", "ugs5047", "ugs5048", "ugs5049", "ugs5050", "ugs5051", "ugs5052", "ugs5053", "ugs5054", "ugs5055", "ugs5056", "ugs5057", "ugs5058", "ugs5059", "ugs5060", "ugs5061", "ugs5062", "ugs5063", "ugs5064", "ugs5065", "ugs5066", "ugs5067", "ugs5068", "usa1001", "usa1201", "usa1502", "usa1701", "usa2011", "usa2101", "usa2301", "usa2502", "usa3001", "usa3201", "usa3701", "usa4011", "usl0000", "usl1001", "usl1101", "usl1201", "usl1501", "usl1701", "usl2002", "usl2101", "usl2201", "usl2501", "usl2806", "usl3001", "usl3101", "usl3501", "usl3801", "usl4002", "usl4004", "usl4401", "usl5002", "usn1001", "usn1002", "usn2001", "usn2002", "usn3001", "usn3003", "usn3004", "uss1001", "uss1201", "uss1301", "uss1511", "uss1512", "uss1513", "uss1601", "uss1602", "uss1611", "uss1612", "uss1614", "uss1701", "uss1702", "uss1804", "uss2001", "uss2101", "uss2102", "uss2201", "uss2301", "uss2401", "uss2402", "uss2510", "uss2511", "uss2512", "uss2513", "uss2601", "uss2611", "uss2701", "uss2702", "uss2711", "uss2806", "uss3101", "uss3102", "uss3201", "uss3401", "uss3402", "uss3501", "uss3511", "uss3512", "uss3513", "uss3601", "uss3603", "uss3611", "uss3701", "uss4102", "uss5002", "uss5003", "uss5004", "uss5005", "uss5006", "uss5007", "uss5008", "uss5009", "uss5010", "uss5011", "uss5012", "uss5013", "uss5014", "uss5015", "uss5016", "uss5017", "uss5018", "uss5019", "uss5020", "uss5021", "uss5022", "uss5023" }) do AvailableUnits[id] = true end
-- SCOM native Chosen Creative availability 1.0.0
AvailableUnits.ucl9505 = true
