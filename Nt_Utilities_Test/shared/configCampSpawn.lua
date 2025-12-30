configCampSpawn = {}

configCampSpawn.Settings = {
    DamageModifier = 1.0,
    SightRange = 70.0,
    HearingRange = 40.0,
    CombatRange = 70,
    ScanInterval = 500,
}

configCampSpawn.Models = {
    ["BossModels"] = {
        { hash = "MP_U_F_M_LEGENDARYBOUNTY_001" },
        { hash = "MP_U_F_M_LEGENDARYBOUNTY_002" },
        { hash = "MP_U_F_M_LEGENDARYBOUNTY_03" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_001" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_002" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_003" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_004" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_005" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_006" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_007" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_08" },
        { hash = "MP_U_M_M_LEGENDARYBOUNTY_09" },
    },

    ["UnderlingModels"] = {
        { hash = "mp_u_m_m_bountytarget_001" },
        { hash = "mp_u_m_m_bountytarget_002" },
        { hash = "mp_u_m_m_bountytarget_003" },
        { hash = "mp_u_m_m_bountytarget_005" },
        { hash = "mp_u_m_m_bountytarget_008" },
        { hash = "mp_u_m_m_bountytarget_009" },
        { hash = "mp_u_m_m_bountytarget_010" },
        { hash = "mp_u_m_m_bountytarget_011" },
        { hash = "mp_u_m_m_bountytarget_012" },
        { hash = "mp_u_m_m_bountytarget_013" },
        { hash = "mp_u_m_m_bountytarget_014" },
        { hash = "mp_u_m_m_bountytarget_015" },
        { hash = "mp_u_m_m_bountytarget_016" },
        { hash = "mp_u_m_m_bountytarget_017" },
        { hash = "mp_u_m_m_bountytarget_018" },
        { hash = "mp_u_m_m_bountytarget_019" },
        { hash = "mp_u_m_m_bountytarget_020" },
        { hash = "mp_u_m_m_bountytarget_021" },
        { hash = "mp_u_m_m_bountytarget_022" },
        { hash = "mp_u_m_m_bountytarget_023" },
        { hash = "mp_u_m_m_bountytarget_024" },
        { hash = "mp_u_m_m_bountytarget_025" },
        { hash = "mp_u_m_m_bountytarget_026" },
        { hash = "mp_u_m_m_bountytarget_027" },
        { hash = "mp_u_m_m_bountytarget_028" },
        { hash = "mp_u_m_m_bountytarget_029" },
        { hash = "mp_u_m_m_bountytarget_030" },
        { hash = "mp_u_m_m_bountytarget_031" },
        { hash = "mp_u_m_m_bountytarget_032" },
        { hash = "mp_u_m_m_bountytarget_033" },
        { hash = "mp_u_m_m_bountytarget_034" },
        { hash = "mp_u_m_m_bountytarget_035" },
        { hash = "mp_u_m_m_bountytarget_036" },
        { hash = "mp_u_m_m_bountytarget_037" },
        { hash = "mp_u_m_m_bountytarget_038" },
        { hash = "mp_u_m_m_bountytarget_039" },
        { hash = "mp_u_m_m_bountytarget_044" },
        { hash = "mp_u_m_m_bountytarget_045" },
        { hash = "mp_u_m_m_bountytarget_046" },
        { hash = "mp_u_m_m_bountytarget_047" },
        { hash = "mp_u_m_m_bountytarget_048" },
        { hash = "mp_u_m_m_bountytarget_049" },
        { hash = "mp_u_m_m_bountytarget_050" },
        { hash = "mp_u_m_m_bountytarget_051" },
        { hash = "mp_u_m_m_bountytarget_052" },
        { hash = "mp_u_m_m_bountytarget_053" },
        { hash = "mp_u_m_m_bountytarget_054" },
        { hash = "mp_u_m_m_bountytarget_055" },
        { hash = "mp_u_f_m_bountytarget_001" },
        { hash = "mp_u_f_m_bountytarget_002" },
        { hash = "mp_u_f_m_bountytarget_003" },
        { hash = "mp_u_f_m_bountytarget_004" },
        { hash = "mp_u_f_m_bountytarget_005" },
        { hash = "mp_u_f_m_bountytarget_006" },
        { hash = "mp_u_f_m_bountytarget_007" },
        { hash = "mp_u_f_m_bountytarget_008" },
        { hash = "mp_u_f_m_bountytarget_009" },
        { hash = "mp_u_f_m_bountytarget_010" },
        { hash = "mp_u_f_m_bountytarget_011" },
        { hash = "mp_u_f_m_bountytarget_012" },
        { hash = "mp_u_f_m_bountytarget_013" },
        { hash = "mp_u_f_m_bountytarget_014" },
    },


    ["Skinner"] = {
        { hash = "u_m_m_bht_skinnerbrother" },
        { hash = "u_m_m_bht_skinnersearch" },
    },
}

configCampSpawn.WeaponLists = {
    ["BossLongarms"] = {
        "WEAPON_SNIPERRIFLE_CARCANO",
        "WEAPON_REPEATER_HENRY",
        "WEAPON_REPEATER_HENRY",
        "WEAPON_REPEATER_HENRY"
    },
    ["BossSidearms"] = {
        "WEAPON_REVOLVER_SCHOFIELD",
        "WEAPON_PISTOL_SEMIAUTO",
        "WEAPON_PISTOL_MAUSER"
    },
    ["UnderlingLongarms"] = {
        "WEAPON_REPEATER_CARBINE",
        "WEAPON_REPEATER_CARBINE",
        "WEAPON_REPEATER_CARBINE",
        "WEAPON_REPEATER_WINCHESTER",
        "WEAPON_REPEATER_WINCHESTER",
        "WEAPON_RIFLE_BOLTACTION"
    },
    ["UnderlingSidearms"] = {
        "WEAPON_REVOLVER_CATTLEMAN",
        "WEAPON_REVOLVER_CATTLEMAN",
        "WEAPON_REVOLVER_CATTLEMAN",
        "WEAPON_REVOLVER_DOUBLEACTION",
        "WEAPON_REVOLVER_DOUBLEACTION",
        "WEAPON_REVOLVER_DOUBLEACTION",
        "WEAPON_REVOLVER_SCHOFIELD"
    },
    ["All Sidearms"] = {
        -- Sidearms
        "WEAPON_REVOLVER_CATTLEMAN",
        "WEAPON_REVOLVER_DOUBLEACTION",
        "WEAPON_REVOLVER_SCHOFIELD",
        "WEAPON_PISTOL_SEMIAUTO",
        "WEAPON_PISTOL_MAUSER"

    },
    ["All Longarms"] = {
        -- Longarms
        "WEAPON_SNIPERRIFLE_CARCANO",
        "WEAPON_REPEATER_HENRY",
        "WEAPON_REPEATER_CARBINE",
        "WEAPON_REPEATER_WINCHESTER",
        "WEAPON_SHOTGUN_REPEATING",
        "WEAPON_SHOTGUN_SEMIAUTO",
        "WEAPON_RIFLE_BOLTACTION",
        "WEAPON_SHOTGUN_DOUBLEBARREL",
        "WEAPON_SHOTGUN_PUMP"
    },
    ["No_Guns"] = { } -- Empty list, no weapon given. Sidearm or longarm use.
}

configCampSpawn.Camps = {
    ["Fort_Brennand"] = {
        coords = vector3(2453.7043, 293.8479, 70.2727),
        MaxAlive = 10,
        ViewRadius = 70,
        Boss = {
            BossModels = "BossModels",
            Sidearms = "BossSidearms",
            Longarms = "BossLongarms",
            BossGroup = "Nt_Enemy_Hideout",
            Spawns = {
                vector4(2444.0964, 290.9430, 70.3478, 127.9282)
            }
        },

        Underlings = {
            UnderlingModels = "UnderlingModels",
            Sidearms = "UnderlingSidearms",
            Longarms = "UnderlingLongarms",
            UnderlingGroup = "Nt_Enemy",
            Spawns = {
                Guard = {
                    vector4(2456.1326, 274.7788, 70.9964, 186.2261),
                    vector4(2450.6448, 275.0480, 70.4537, 190.5408),
                    vector4(2465.6646, 276.8522, 78.3381, 265.8823),
                    vector4(2440.4214, 288.9642, 74.1965, 90.9776)
                },
                Ambient = {
                    vector4(2449.1045, 292.5354, 70.2381, 261.8271),
                    vector4(2454.7664, 294.6057, 70.2908, 149.2123),
                    vector4(2457.6196, 288.3338, 70.8036, 67.2043),
                    vector4(2453.0688, 280.8065, 70.5141, 133.9856)
                },
            }
        }
    },
}