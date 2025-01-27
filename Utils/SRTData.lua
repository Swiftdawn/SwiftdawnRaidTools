local SwiftdawnRaidTools = SwiftdawnRaidTools
local defaultAssignments = {
    [1022] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Searing Flames",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 77840,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
    },
    [1023] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Systems Failure",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 88853,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Heal to full for P2!",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 82848,
                    ["type"] = "SPELL_CAST",
                    ["conditions"] = {
                        {
                            ["pct_lt"] = 25,
                            ["type"] = "UNIT_HEALTH",
                            ["unit"] = "boss1",
                        }, -- [1]
                    },
                }, -- [1]
            },
        }, -- [2]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Phase 2",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 10,
                }, -- [2]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 20,
                }, -- [3]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 30,
                }, -- [4]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 40,
                }, -- [5]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 50,
                }, -- [6]
            },
        }, -- [3]
    },
    [1024] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Lava Spew",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 77690,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
    },
    [1025] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Acid Nova",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 78225,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["untriggers"] = {
                {
                    ["spell_id"] = 77991,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
                {
                    ["text"] = "blue||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                }, -- [2]
                {
                    ["text"] = "green||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                }, -- [3]
                {
                    ["text"] = "dark||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                }, -- [4]
            },
            ["metadata"] = {
                ["name"] = "Scorching Blast",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 3,
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["delay"] = 19,
                    ["text"] = "red||r vial into the cauldron!",
                }, -- [1]
                {
                    ["spell_id"] = 77679,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 7,
                    ["countdown"] = 3,
                }, -- [2]
            },
        }, -- [2]
    },
    [1026] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Electrocute/Crackle",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 5,
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["text"] = "The air crackles with electricity!",
                }, -- [1]
            },
        }, -- [1]
    },
    [1027] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Incineration",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 79023,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Grip of Death",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 91849,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [2]
    },
    [1028] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Aegis Flames",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 82631,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Lava Seeds",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 84913,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [2]
    },
    [1029] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Empowered Shadows",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 81572,
                    ["type"] = "SPELL_AURA",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Phase 2",
            },
            ["triggers"] = {
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [1]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 10,
                    ["unit"] = "boss1",
                }, -- [2]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 20,
                    ["unit"] = "boss1",
                }, -- [3]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 30,
                    ["unit"] = "boss1",
                }, -- [4]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 40,
                    ["unit"] = "boss1",
                }, -- [5]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 50,
                    ["unit"] = "boss1",
                }, -- [6]
            },
        }, -- [2]
    },
    [1030] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Proto Breath",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 83707,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
    },
    [1032] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Blackout",
                ["notification"] = "Blackout > %(dest_name)s",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 86788,
                    ["type"] = "SPELL_AURA",
                }, -- [1]
            },
        }, -- [1]
    },
    [1034] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Acid Rain",
                ["notification"] = "Acid Rain - %(unit_name)s %(health_pct).0f%",
            },
            ["triggers"] = {
                {
                    ["pct_lt"] = 80,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [1]
                {
                    ["pct_lt"] = 70,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [2]
                {
                    ["pct_lt"] = 60,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [3]
                {
                    ["pct_lt"] = 50,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [4]
                {
                    ["pct_lt"] = 40,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [5]
                {
                    ["pct_lt"] = 30,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [6]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [7]
            },
        }, -- [1]
    },
    [1035] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Sleet Storm",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 84644,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Storm Shield",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 93059,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [2]
    },
    [1082] = {
        {
            ["assignments"] = {},
            ["untriggers"] = {
                {
                    ["spell_id"] = 87299,
                    ["type"] = "SPELL_AURA",
                }, -- [1]
            },
            ["metadata"] = {
                ["name"] = "Flame Breath",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 3,
                    ["type"] = "ENCOUNTER_START",
                    ["delay"] = 18,
                }, -- [1]
                {
                    ["countdown"] = 3,
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["delay"] = 18,
                    ["text"] = "Enough! Drawing upon this source will set us back months.",
                }, -- [2]
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 18,
                    ["countdown"] = 3,
                }, -- [3]
            },
        }, -- [1]
    },
    [1205] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Is This Shannox?",
                ["notification"] = "It is %(unit_name)!",
            },
            ["triggers"] = {
                {
                    ["delay"] = 10,
                    ["type"] = "ENCOUNTER_START",
                }
            },
        }
    },
    [42001] = {
        {
            ["assignments"] = {
            },
            ["untriggers"] = {
                {
                    ["delay"] = 18,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["text"] = "Test emote by the boss",
                    ["type"] = "RAID_BOSS_EMOTE",
                },
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_CAST",
                },
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_AURA",
                },
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_AURA_REMOVED",
                },
                {
                    ["unit"] = "boss1",
                    ["pct_lt"] = 50,
                    ["type"] = "UNIT_HEALTH",
                },
                {
                    ["key"] = "numen.key",
                    ["type"] = "FOJJI_NUMEN_TIMER",
                },
                {
                    ["delay"] = 18,
                    ["type"] = "ENCOUNTER_START",
                    ["conditions"] = {
                        {
                            ["type"] = "UNIT_HEALTH",
                            ["lt"] = 50,
                            ["unit"] = "boss1",
                        },
                    },
                },
                {
                    ["text"] = "Test emote by the boss",
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["conditions"] = {
                        {
                            ["type"] = "SPELL_CAST_COUNT",
                            ["gt"] = 1,
                            ["spell_id"] = 90125,
                        },
                    },
                }
            },
            ["metadata"] = {
                ["name"] = "Test Ability",
            },
            ["triggers"] = {
                {
                    ["delay"] = 18,
                    ["type"] = "ENCOUNTER_START",
                    ["countdown"] = 0,
                    ["throttle"] = 0
                },
                {
                    ["text"] = "Other test emote by the boss",
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["delay"] = 0,
                    ["countdown"] = 0,
                    ["throttle"] = 0
                },
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 0,
                    ["countdown"] = 0,
                    ["throttle"] = 0
                },
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 0,
                    ["countdown"] = 0,
                    ["throttle"] = 0
                },
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_AURA_REMOVED",
                    ["delay"] = 0,
                    ["countdown"] = 0,
                    ["throttle"] = 0
                },
                {
                    ["unit"] = "boss1",
                    ["pct_lt"] = 50,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 0,
                    ["countdown"] = 0,
                    ["throttle"] = 0
                },
                {
                    ["key"] = "numen.key",
                    ["type"] = "FOJJI_NUMEN_TIMER",
                    ["delay"] = 0,
                    ["countdown"] = 0,
                    ["throttle"] = 0
                },
                {
                    ["delay"] = 18,
                    ["type"] = "ENCOUNTER_START",
                    ["countdown"] = 0,
                    ["throttle"] = 0,
                    ["conditions"] = {
                        {
                            ["type"] = "UNIT_HEALTH",
                            ["pct_lt"] = 50,
                            ["unit"] = "boss1",
                        },
                    },
                },
                {
                    ["text"] = "Yet another test emote by the boss",
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["delay"] = 0,
                    ["countdown"] = 0,
                    ["throttle"] = 0,
                    ["conditions"] = {
                        {
                            ["type"] = "UNIT_HEALTH",
                            ["lt"] = 50,
                            ["unit"] = "boss1",
                        },
                    },
                },
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 0,
                    ["countdown"] = 0,
                    ["throttle"] = 0,
                    ["conditions"] = {
                        {
                            ["type"] = "SPELL_CAST_COUNT",
                            ["gt"] = 1,
                            ["spell_id"] = 90125,
                        },
                    },
                }
            },
        },
    },
    [1206] = {
        {
            ["assignments"] = {},
            ["encounter"] = 1206,
            ["triggers"] = {
                {
                    ["spell_id"] = 99432,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 32,
                },
                {
                    ["spell_id"] = 99432,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 42,
                },
                {
                    ["spell_id"] = 99432,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 52,
                },
                {
                    ["spell_id"] = 99432,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 62,
                },
                {
                    ["spell_id"] = 99432,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 72,
                },
            },
            ["metadata"] = {
                ["name"] = "Ignited",
            },
        },
        {
            ["assignments"] = {},
            ["encounter"] = 1206,
            ["triggers"] = {
                {
                    ["spell_id"] = 99757,
                    ["type"] = "SPELL_CAST",
                },
                {
                    ["spell_id"] = 99756,
                    ["type"] = "SPELL_CAST",
                },
            },
            ["metadata"] = {
                ["name"] = "Knockback",
            },
        },
    },
    [1203] = {
        {
            ["assignments"] = {},
            ["encounter"] = 1203,
            ["triggers"] = {
                {
                    ["countdown"] = 5,
                    ["type"] = "ENCOUNTER_START",
                    ["delay"] = 52,
                },
                {
                    ["countdown"] = 5,
                    ["type"] = "ENCOUNTER_START",
                    ["delay"] = 105,
                },
            },
            ["metadata"] = {
                ["name"] = "P1 Traps",
                ["notification"] = "Trap Explosion Soon...",
            },
        },
        {
            ["assignments"] = {},
            ["untriggers"] = {
                {
                    ["spell_id"] = 98175,
                    ["type"] = "SPELL_CAST",
                },
            },
            ["encounter"] = 1203,
            ["triggers"] = {
                {
                    ["countdown"] = 5,
                    ["type"] = "SPELL_CAST",
                    ["spell_id"] = 100171,
                    ["conditions"] = {
                        {
                            ["type"] = "UNIT_HEALTH",
                            ["pct_gt"] = 50,
                            ["unit"] = "boss1",
                        },
                    },
                    ["delay"] = 15,
                },
            },
            ["metadata"] = {
                ["name"] = "P2 Traps",
                ["notification"] = "Trap Explosion Soon...",
            },
        },
        {
            ["assignments"] = {},
            ["encounter"] = 1203,
            ["triggers"] = {
                {
                    ["spell_id"] = 98333,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 7,
                    ["countdown"] = 3,
                },
            },
            ["metadata"] = {
                ["name"] = "Seeds",
                ["notification"] = "Seed Explosion Soon...",
            },
        },
        {
            ["assignments"] = {},
            ["encounter"] = 1203,
            ["triggers"] = {
                {
                    ["spell_id"] = 98333,
                    ["type"] = "SPELL_CAST",
                },
            },
            ["metadata"] = {
                ["name"] = "Seeds",
                ["notification"] = "RUN!",
            },
        },
    },
    [1200] = {
        {
            ["assignments"] = {},
            ["encounter"] = 1200,
            ["triggers"] = {
                {
                    ["delay"] = 40,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 80,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 120,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 160,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 200,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 240,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 280,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 320,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 360,
                    ["type"] = "ENCOUNTER_START",
                },
                {
                    ["delay"] = 400,
                    ["type"] = "ENCOUNTER_START",
                },
            },
            ["metadata"] = {
                ["name"] = "Mana Return...",
            },
        },
    },
    [1204] = {
        {
            ["assignments"] = {},
            ["encounter"] = 1204,
            ["triggers"] = {
                {
                    ["spell_id"] = 97282,
                    ["type"] = "SPELL_CAST",
                },
            },
            ["metadata"] = {
                ["name"] = "Concussive Stomp",
            },
        },
        {
            ["assignments"] = {},
            ["encounter"] = 1204,
            ["triggers"] = {
                {
                    ["spell_id"] = 99846,
                    ["type"] = "SPELL_AURA",
                },
                {
                    ["spell_id"] = 99846,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 10,
                },
                {
                    ["spell_id"] = 99846,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 20,
                },
                {
                    ["spell_id"] = 99846,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 30,
                },
                {
                    ["spell_id"] = 99846,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 40,
                },
                {
                    ["spell_id"] = 99846,
                    ["type"] = "SPELL_AURA",
                    ["delay"] = 50,
                },
            },
            ["metadata"] = {
                ["name"] = "Phase 2",
            },
        },
    },
    [1197] = {
        {
            ["assignments"] = {},
            ["encounter"] = 1197,
            ["triggers"] = {
                {
                    ["spell_id"] = 99052,
                    ["type"] = "SPELL_CAST",
                    ["throttle"] = 7,
                    ["conditions"] = {
                        {
                            ["spell_id"] = 99052,
                            ["type"] = "SPELL_CAST_COUNT",
                            ["gt"] = 1,
                        },
                    },
                },
            },
            ["metadata"] = {
                ["name"] = "Smoldering Devastation",
            },
        },
        {
            ["assignments"] = {},
            ["encounter"] = 1197,
            ["triggers"] = {
                {
                    ["countdown"] = 3,
                    ["type"] = "SPELL_CAST",
                    ["spell_id"] = 99859,
                    ["conditions"] = {
                        {
                            ["spell_id"] = 100522,
                            ["type"] = "SPELL_CAST_COUNT",
                            ["gt"] = 9,
                        },
                    },
                    ["delay"] = 2,
                },
            },
            ["metadata"] = {
                ["name"] = "Ember Flare",
            },
        },
    },
}
local testAssignments = {
    [42001] = {
        {
            ["assignments"] = {
                {
                    {
                        ["spell_id"] = 740,
                        ["type"] = "SPELL",
                        ["player"] = "Aeolyne",
                    } -- [1]
                }, -- [1]
            },
            ["version"] = 1,
            ["encounter"] = 42001,
            ["triggers"] = {
                {
                    ['type'] = "ENCOUNTER_START",
                    ['delay'] = 4,
                    ['countdown'] = 3
                }
            },
            ["uuid"] = "113efe46-3fe2-4dd2-85a9-0e0b51689f69",
            ["metadata"] = {
                ["name"] = "Encounter Start",
            },
        }, -- [1]  Encounter Start Phase
        {
            ["assignments"] = {
                {
                    {
                        ["spell_id"] = 62618,
                        ["type"] = "SPELL",
                        ["player"] = "Kondec",
                    } -- [1]
                }, -- [1]
            },
            ["version"] = 1,
            ["encounter"] = 42001,
            ["triggers"] = {
                {
                    ["spell_id"] = 81572,
                    ["type"] = "SPELL_AURA",
                } -- [1]
            },
            ["uuid"] = "437efe45-3fe2-4dd2-85a9-0e0b51689f69",
            ["metadata"] = {
                ["name"] = "Spell Aura",
            },
        }, -- [2]  Spell Aura Phase
        {
            ["assignments"] = {
                {
                    {
                        ["spell_id"] = 31821,
                        ["type"] = "SPELL",
                        ["player"] = "Anticipâte",
                    }, -- [1]
                }, -- [1]
            },
            ["version"] = 1,
            ["untriggers"] = {
                {
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["text"] = "I will spill water on you!",
                }, -- [1]
            },
            ["encounter"] = 42001,
            ["triggers"] = {
                {
                    ["countdown"] = 3,
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["delay"] = 1,
                    ["text"] = "I will breathe fire on you!",
                }, -- [1]
            },
            ["uuid"] = "5450a7eb-cb42-4719-ba6d-e8a7ecca8f98",
            ["metadata"] = {
                ["name"] = "Raid Boss Emote",
            },
        }, -- [3]  Raid Boss Emote Phase
        {
            ["assignments"] = {
                {
                    {
                        ["spell_id"] = 740,
                        ["type"] = "SPELL",
                        ["player"] = "Clutex",
                    }, -- [1]
                    {
                        ["spell_id"] = 31821,
                        ["type"] = "SPELL",
                        ["player"] = "Elí",
                    }, -- [2]
                }, -- [1]
                {
                    {
                        ["spell_id"] = 64843,
                        ["type"] = "SPELL",
                        ["player"] = "Managobrr",
                    }, -- [1]
                    {
                        ["spell_id"] = 31821,
                        ["type"] = "SPELL",
                        ["player"] = "Anticipâte",
                    }, -- [2]
                }, -- [2]
            },
            ["version"] = 1,
            ["encounter"] = 1023,
            ["triggers"] = {
                {
                    ["spell_id"] = 88853,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
            ["uuid"] = "e8b42653-abbe-418d-b675-6d323d8d78c8",
            ["metadata"] = {
                ["name"] = "Spell Cast",
            },
        }, -- [4]  Spell Cast Phase
        --{
        --    ["assignments"] = {
        --        {
        --            {
        --                ["spell_id"] = 64843,
        --                ["type"] = "SPELL",
        --                ["player"] = "Kondec",
        --            }, -- [1]
        --            {
        --                ["spell_id"] = 98008,
        --                ["type"] = "SPELL",
        --                ["player"] = "Venmir",
        --            }, -- [2]
        --        }, -- [1]
        --        {
        --            {
        --                ["spell_id"] = 740,
        --                ["type"] = "SPELL",
        --                ["player"] = "Aeolyne",
        --            }, -- [1]
        --            {
        --                ["spell_id"] = 740,
        --                ["type"] = "SPELL",
        --                ["player"] = "Crawlern",
        --            }, -- [2]
        --        }, -- [2]
        --    },
        --    ["version"] = 1,
        --    ["encounter"] = 1023,
        --    ["triggers"] = {
        --        {
        --            ["spell_id"] = 82848,
        --            ["type"] = "SPELL_CAST",
        --            ["conditions"] = {
        --                {
        --                    ["pct_lt"] = 25,
        --                    ["type"] = "UNIT_HEALTH",
        --                    ["unit"] = "boss1",
        --                }, -- [1]
        --            },
        --        }, -- [1]
        --    },
        --    ["uuid"] = "765b0f4c-141a-4286-b97f-24390a8001c5",
        --    ["metadata"] = {
        --        ["name"] = "Conditional Spell Cast Test",
        --    },
        --}, -- [5]  Conditional Spell Cast Phase
        --{
        --    ["assignments"] = {
        --        {
        --            {
        --                ["spell_id"] = 64843,
        --                ["type"] = "SPELL",
        --                ["player"] = "Kondec",
        --            }, -- [1]
        --        }, -- [1]
        --        {
        --            {
        --                ["spell_id"] = 740,
        --                ["type"] = "SPELL",
        --                ["player"] = "Aeolyne",
        --            }, -- [1]
        --        }, -- [2]
        --    },
        --    ["version"] = 1,
        --    ["encounter"] = 42001,
        --    ["triggers"] = {
        --        {
        --            ["pct_lt"] = 70,
        --            ["type"] = "UNIT_HEALTH",
        --            ["unit"] = "boss1",
        --        }, -- [1]
        --        {
        --            ["pct_lt"] = 70,
        --            ["type"] = "UNIT_HEALTH",
        --            ["delay"] = 10,
        --            ["unit"] = "boss1",
        --        }, -- [2]
        --    },
        --    ["uuid"] = "b5aeb9ec-9f2a-4f03-b5bf-764ac5cec091",
        --    ["metadata"] = {
        --        ["name"] = "Unit Health Test",
        --    },
        --}, -- [6]  Unit Health Phase
    }
}

--- Database class for Swiftdawn Raid Tools
---@class SRTData
SRTData = {}

function SRTData.Initialize()
    SRT_Global().srt_data = SRT_Global().srt_data or {
        pool = {},
        players = {},
        rosters = {},
        activeRosterID = nil,
        syncedRosterID = nil,
        syncedRosterLastUpdated = -1
    }
    if DevTool then DevTool:AddData(SRT_Global().srt_data, "SRTData") end
    -- Preseed our database with static information
    SRT_Global().srt_data.defaultAssignments = defaultAssignments
    SRT_Global().srt_data.spells = {
        -- Death Knight
        IceboundFortitude = SRTSpell:New(48792, "Icebound Fortitude", 60 * 3, 12),
        VampiricBlood = SRTSpell:New(55233, "Vampiric Blood", 60 * 1, 10),
        AntiMagicZone = SRTSpell:New(51052, "Anti-Magic Zone", 60 * 2, 10),
        -- Druid
        Innervate = SRTSpell:New(29166, "Innervate", 60 * 3, 10),
        Barkskin = SRTSpell:New(22812, "Barkskin", 60 * 1, 12),
        SurvivalInstincts = SRTSpell:New(61336, "Survival Instincts", 60 * 3, 12),
        FrenziedRegeneration = SRTSpell:New(22842, "Frenzied Regeneration", 60 * 3, 20),
        Tranquility = SRTSpell:New(740, "Tranquility", 60 * 8, 8),
        StampedingRoar = SRTSpell:New(77764, "Stampeding Roar", 60 * 2, 8),
        -- Paladin
        DivineProtection = SRTSpell:New(498, "Divine Protection", 60 * 1, 10),
        GuardianOfAncientKings = SRTSpell:New(86659, "Guardian of Ancient Kings", 0, 12),
        ArdentDefender = SRTSpell:New(31850, "Ardent Defender", 60 * 3, 10),
        HandOfSalvation = SRTSpell:New(1038, "Hand of Salvation", 60 * 2, 10),
        HandOfProtection = SRTSpell:New(1022, "Hand of Protection", 60 * 5, 10),
        AuraMastery = SRTSpell:New(31821, "Aura Mastery", 60 * 2, 6),
        HandOfSacrifice = SRTSpell:New(6940, "Hand of Sacrifice", 60 * 2, 12),
        DivineGuardian = SRTSpell:New(70940, "Divine Guardian", 60 * 3, 6),
        -- Priest
        HymnOfHope = SRTSpell:New(64901, "Hymn of Hope", 60 * 6, 8),
        DivineHymn = SRTSpell:New(64843, "Divine Hymn", 60 * 8, 8),
        PainSuppression = SRTSpell:New(33206, "Pain Suppression", 60 * 3, 8),
        PowerWordBarrier = SRTSpell:New(62618, "Power Word: Barrier", 60 * 3, 10),
        -- Shaman
        ManaTideTotem = SRTSpell:New(16190, "Mana Tide Totem", 60 * 3, 12),
        SpiritLinkTotem = SRTSpell:New(98008, "Spirit Link Totem", 60 * 3, 6),
        -- Warrior
        ShieldWall = SRTSpell:New(871, "Shield Wall", 60 * 5, 12),
        LastStand = SRTSpell:New(12975, "Last Stand", 60 * 3, 0),
        EnragedRegeneration = SRTSpell:New(55694, "Enraged Regeneration", 60 * 3, 10),
        RallyingCry = SRTSpell:New(97462, "Rallying Cry", 60 * 3, 10),
        -- Rogue
        -- Vanish = SRTSpell:New(1856, "Vanish", 60 * 3, 0),
    }
    SRT_Global().srt_data.classes = {
        DeathKnight = Class:New("Death Knight", "DEATHKNIGHT", {
            SRT_Global().srt_data.spells.IceboundFortitude,
            SRT_Global().srt_data.spells.VampiricBlood,
            SRT_Global().srt_data.spells.AntiMagicZone,
        }),
        Druid = Class:New("Druid", "DRUID", {
            SRT_Global().srt_data.spells.Innervate,
            SRT_Global().srt_data.spells.Barkskin,
            SRT_Global().srt_data.spells.SurvivalInstincts,
            SRT_Global().srt_data.spells.FrenziedRegeneration,
            SRT_Global().srt_data.spells.Tranquility,
            SRT_Global().srt_data.spells.StampedingRoar,
        }),
        Hunter = Class:New("Hunter", "HUNTER", {}),
        Mage = Class:New("Mage", "MAGE", {}),
        Paladin = Class:New("Paladin", "PALADIN", {
            SRT_Global().srt_data.spells.DivineProtection,
            SRT_Global().srt_data.spells.GuardianOfAncientKings,
            SRT_Global().srt_data.spells.ArdentDefender,
            SRT_Global().srt_data.spells.HandOfSalvation,
            SRT_Global().srt_data.spells.HandOfProtection,
            SRT_Global().srt_data.spells.AuraMastery,
            SRT_Global().srt_data.spells.HandOfSacrifice,
            SRT_Global().srt_data.spells.DivineGuardian,
        }),
        Priest = Class:New("Priest", "PRIEST", {
            SRT_Global().srt_data.spells.HymnOfHope,
            SRT_Global().srt_data.spells.DivineHymn,
            SRT_Global().srt_data.spells.PainSuppression,
            SRT_Global().srt_data.spells.PowerWordBarrier,
        }),
        Rogue = Class:New("Rogue", "ROGUE", {
            -- SRT_Global().srt_data.spells.Vanish,
        }),
        Shaman = Class:New("Shaman", "SHAMAN", {
            SRT_Global().srt_data.spells.ManaTideTotem,
            SRT_Global().srt_data.spells.SpiritLinkTotem,
        }),
        Warlock = Class:New("Warlock", "WARLOCK", {}),
        Warrior = Class:New("Warrior", "WARRIOR", {
            SRT_Global().srt_data.spells.ShieldWall,
            SRT_Global().srt_data.spells.LastStand,
            SRT_Global().srt_data.spells.EnragedRegeneration,
            SRT_Global().srt_data.spells.RallyingCry,
        })
    }
    SRT_Global().srt_data.specs = {
        Blood = Spec:New("Blood", SRT_Global().srt_data.classes.DeathKnight),
        FrostDK = Spec:New("Frost", SRT_Global().srt_data.classes.DeathKnight),
        Unholy = Spec:New("Unholy", SRT_Global().srt_data.classes.DeathKnight),
        Balance = Spec:New("Balance", SRT_Global().srt_data.classes.Druid),
        Feral = Spec:New("Feral", SRT_Global().srt_data.classes.Druid),
        Guardian = Spec:New("Guardian", SRT_Global().srt_data.classes.Druid),
        RestorationDruid = Spec:New("Restoration", SRT_Global().srt_data.classes.Druid),
        BeastMaster = Spec:New("Beast Master", SRT_Global().srt_data.classes.Hunter),
        Marksmanship = Spec:New("Marksmanship", SRT_Global().srt_data.classes.Hunter),
        Survival = Spec:New("Survival", SRT_Global().srt_data.classes.Hunter),
        Arcane = Spec:New("Arcane", SRT_Global().srt_data.classes.Mage),
        FrostMage = Spec:New("Frost", SRT_Global().srt_data.classes.Mage),
        Fire = Spec:New("Fire", SRT_Global().srt_data.classes.Mage),
        HolyPaladin = Spec:New("HolyPaladin", SRT_Global().srt_data.classes.Paladin),
        ProtectionPaladin = Spec:New("Protection", SRT_Global().srt_data.classes.Paladin),
        Retribution = Spec:New("Retribution", SRT_Global().srt_data.classes.Paladin),
        Discipline = Spec:New("Discipline", SRT_Global().srt_data.classes.Priest),
        HolyPriest = Spec:New("Holy", SRT_Global().srt_data.classes.Priest),
        Shadow = Spec:New("Shadow", SRT_Global().srt_data.classes.Priest),
        Assassin = Spec:New("Assassin", SRT_Global().srt_data.classes.Rogue),
        Combat = Spec:New("Combat", SRT_Global().srt_data.classes.Rogue),
        Subtility = Spec:New("Subtility", SRT_Global().srt_data.classes.Rogue),
        Elemental = Spec:New("Elemental", SRT_Global().srt_data.classes.Shaman),
        Enhancement = Spec:New("Enhancement", SRT_Global().srt_data.classes.Shaman),
        RestorationShaman = Spec:New("Restoration", SRT_Global().srt_data.classes.Shaman),
        Affliction = Spec:New("Affliction", SRT_Global().srt_data.classes.Warlock),
        Demonology = Spec:New("Demonology", SRT_Global().srt_data.classes.Warlock),
        Destruction = Spec:New("Destruction", SRT_Global().srt_data.classes.Warlock),
        Arms = Spec:New("Arms", SRT_Global().srt_data.classes.Warrior),
        Fury = Spec:New("Fury", SRT_Global().srt_data.classes.Warrior),
        ProtectionWarrior = Spec:New("Protection", SRT_Global().srt_data.classes.Warrior),
    }
    
    if not SRT_Global().srt_data.activeRosterID and SwiftdawnRaidTools.db.profile.data.encountersId then
        SRT_Global().srt_data.activeRosterID = SwiftdawnRaidTools.db.profile.data.encountersId
    end
    if not (#SRT_Global().srt_data.rosters > 0) and (#SwiftdawnRaidTools.db.profile.data.encounters > 0) then
        SRT_Global().srt_data.rosters[SRT_Global().srt_data.activeRosterID] = { encounters = SwiftdawnRaidTools.db.profile.data.encounters }
    end
end

---Add player to pool; will not overwrite!
---@param name string
---@param class Class
---@param spec? Spec
function SRTData.AddPlayerToPool(name, class, spec)
    local data = SRT_Global().srt_data
    if not data.players[name] then
        data.players[name] = Player:New(name, class, spec)
    end
end

---Retrieve player object from player pool
---@param name string
---@return Player?
function SRTData.GetPlayerFromPool(name)
    local data = SRT_Global().srt_data
    return data.players[name]
end

---@return Roster[]
function SRTData.GetRosters()
    local data = SRT_Global().srt_data
    return data.rosters
end

function SRTData.GetClass(className)
    local data = SRT_Global().srt_data
    for name, class in pairs(data.classes) do
        if name == className or class.name == className or class.fileName == className then
            return class
        end
    end
end

---Create new roster
---@return Roster
function SRTData.CreateNewRoster()
    local data = SRT_Global().srt_data
    local roster = Roster:New("Roster", time(), Utils:GetFullPlayerName())
    data.rosters[roster.id] = roster
    return roster
end

function SRTData.RemoveRoster(rosterID)
    local data = SRT_Global().srt_data
    if data.rosters[rosterID] then
        data.rosters[rosterID] = nil
    end
end

---Set spec for player in pool
---@param name string
---@param spec Spec
function SRTData.SetPlayerSpec(name, spec)
    local data = SRT_Global().srt_data
    if not data.players[name] then
        Log.info("Unable to set spec for "..name..". Player not in SRTData player pool yet!")
        return
    end
    data.players[name].spec = spec
end

function SRTData.GetAssignmentDefaults()
    local data = SRT_Global().srt_data
    return Utils:DeepClone(data.defaultAssignments)
end

---Retrieve spell object by it's in-game ID
---@param spellID number
---@return SRTSpell?
function SRTData.GetSpellByID(spellID)
    local data = SRT_Global().srt_data
    for _, spell in pairs(data.spells) do
        if spell.id == spellID then
            return spell
        end
    end
    return nil
end

---comment
---@param spellID number
---@return ColorMixin_RCC
function SRTData.GetClassColorBySpellID(spellID)
    local data = SRT_Global().srt_data
    for _, class in pairs(data.classes) do
        for _, spell in pairs(class.spells) do
            if spell.id == spellID then
                return Class.GetColor(class)
            end
        end
    end
    return { r = 0.8, g = 0.8, b = 0.8, colorStr = "ffcccccc" }
end

---comment
---@param spellID number
---@return Class?
function SRTData.GetClassBySpellID(spellID)
    local data = SRT_Global().srt_data
    for _, class in pairs(data.classes) do
        for _, spell in pairs(class.spells) do
            if spell.id == spellID then
                return class
            end
        end
    end
    return nil
end

function SRTData.GetActiveRosterID()
    return SRT_Global().srt_data.activeRosterID
end

function SRTData.SetActiveRosterID(rosterID)
    local data = SRT_Global().srt_data
    data.activeRosterID = rosterID
end

function SRTData.AddRoster(rosterID, roster)
    local data = SRT_Global().srt_data
    Log.debug("Adding new roster with ID: "..rosterID)
    data.rosters[rosterID] = roster
end

function SRTData.GetActiveRoster()
    local data = SRT_Global().srt_data
    if not data.activeRosterID then
        Log.debug("Cannot get active roster; no active roster ID set")
        return {}
    end
    if not data.rosters[data.activeRosterID] then
        Log.debug("Cannot get active roster; roster not found")
        return {}
    end
    return data.rosters[data.activeRosterID]
end

function SRTData.GetActiveEncounters()
    if SRT_IsTesting() then
        return testAssignments
    end
    local activeRoster = SRTData.GetActiveRoster()
    if not activeRoster.encounters then
        Log.debug("Cannot get active encounters; encounters not found")
        return {}
    end
    local encountersWithAssignments = {}
    for encounterID, encounter in pairs(activeRoster.encounters) do
        for _, ability in pairs(encounter) do
            if #ability.assignments > 0 then
                encountersWithAssignments[encounterID] = encounter
                break
            end
        end
    end
    return encountersWithAssignments
end

function SRTData.UpdateSyncedRosterInfo(rosterID, lastUpdated)
    local data = SRT_Global().srt_data
    data.syncedRosterID = rosterID
    data.syncedRosterLastUpdated = lastUpdated
end

function SRTData.GetSyncedRosterID()
    return SRT_Global().srt_data.syncedRosterID or "none-yet"
end

function SRTData.GetSyncedRosterLastUpdated()
    return SRT_Global().srt_data.syncedRosterLastUpdated or -1
end