Config = {}

Config.Debug = false

Config.ScanForEnemies = {
    ["Settings"] = { -- not a group
        cacheDistance = 250, -- Only if it has a blip cached.
        scanRadius = 225,
        scanInterval = 500,
        blipDespawn = 10,
    },
    ["Group1"] = {
        ["Settings"] = {
            EnemyGroups = {
                "Group2",
                "Group4",
                "Group5",
            },
            BlipDisplayRelation = 5, -- Blips is only displayed when GetRelationshipBetweenGroups returns this value.
        },
        ["Nt_Enemy"] = {
            blip = true,
            Sprite = "blip_ambient_ped_medium",
            Color = "BLIP_MODIFIER_ENEMY", -- Red color
            Scale = .75,
            distance = 150, -- distance blip will show on radar.
            name = "Enemy",
            offRadar = false, -- if true adds the blip modifier BLIP_MODIFIER_RADAR_EDGE_ALWAYS
        },
        ["Nt_Enemy_NoBlip"] = {
            blip = false,
            Sprite = "blip_ambient_ped_medium",
            Color = "BLIP_MODIFIER_ENEMY", -- Red color
            Scale = .75,
            distance = 150, -- distance blip will show on radar.
            name = "Enemy",
            offRadar = false, -- if true adds the blip modifier BLIP_MODIFIER_RADAR_EDGE_ALWAYS
        },
        ["Nt_Enemy_Hideout"] = {
            blip = true,
            Sprite = "blip_objective",
            Color = "BLIP_MODIFIER_ENEMY", -- Red color
            Scale = .75,
            distance = 200,
            name = "Boss",
            offRadar = true, 
        },
        ["Nt_Enemy_Bounty"] = {
            blip = true,
            Sprite = "blip_ambient_bounty_target",
            Color = "BLIP_MODIFIER_ENEMY", -- Red color
            Scale = .75,
            distance = 200,
            name = "Bounty",
            offRadar = true,
        },
    },
    ["Group2"] = {
        ["Settings"] = {
            EnemyGroups = {
                "Group1",
            },
            BlipDisplayRelation = 1,
        },
        ["Nt_Ally"] = {
            blip = true,
            Sprite = "blip_ambient_ped_medium",
            Color = "BLIP_MODIFIER_MP_PLAYER_ALLY", -- Blue color
            Scale = .75,
            distance = 200,
            name = "Ally",
            offRadar = false,
        },
        ["PLAYER"] = {
            Native = true,
            blip = false, -- Cannot assign blips to player peds.
            Sprite = "blip_ambient_ped_medium",
            Color = "BLIP_MODIFIER_MP_PLAYER_ALLY", -- Blue color
            Scale = .75,
            distance = 200,
            name = "Ally",
            offRadar = false,
        },
    },
    ["Group3"] = {
        ["Settings"] = {
            EnemyGroups = {
                "Group4",
            },
            BlipDisplayRelation = 5,
        },
        ["707888648"] = {
            isHash = true,
            Native = true,
            blip = true,
            Sprite = "blip_ambient_law",
            Color = "BLIP_MODIFIER_ENEMY", -- red color
            Scale = .75,
            distance = 200,
            name = "Law",
            offRadar = false,
        },
    },
    ["Group4"] = {
        ["Settings"] = {
            EnemyGroups = {
                "Group3",
            },
        },
        ["PLAYER_Wanted"] = {
            blip = false, -- Cannot assign blips to player peds.
            Sprite = "blip_ambient_ped_medium",
            Color = "BLIP_MODIFIER_MP_PLAYER_ALLY", -- Blue color
            Scale = .75,
            distance = 200,
            name = "Ally",
            offRadar = false,
        },
        ["PLAYER_Surrender"] = {
            blip = false, -- Cannot assign blips to player peds.
            Sprite = "blip_ambient_ped_medium",
            Color = "BLIP_MODIFIER_MP_PLAYER_ALLY", -- Blue color
            Scale = .75,
            distance = 200,
            name = "Ally",
            offRadar = false,
        },
    },
}




Config.CombatAI = {
    DisableCombat = false,
    DeadBodyDetection = {
        ScanRadius = 50,
        BodyExpirationTime = 15000,
        MaxInvestigationsPerBody = 3,
        MaxInvestigatorsPerGroup = 3,
        ScanInterval = 2000,
    },
    
    ThreatScanning = {
        Interval = 1000,
        TargetTimeoutMs = 5000,
    },
    
    NpcMovement = {
        TaskGoToCoordSpeed = 2.0,
        TaskGoToCoordFlags = 786603,
        TaskGoToCoordFlag2 = 0xbf800000,
        TaskWanderRadius = 10.0,
        ScenarioSearchRadius = 10.0,
        SearchPointMoveSpeed = 1.5,
    },
    
    Investigation = {
        ApproachBodyTimeout = 10000,
        ExamineBodyTimeout = 2000,
        InspectionDuration = 10000,
        LookAroundDuration = 500,
        SuspiciousLookDuration = 2500,
        SuspiciousLookRepetitions = 3,
        SearchPointRadius = 30,
        NearbyBodyCheckRadius = 20,
    },
    
    Ambient = {
        PhaseScenarioDuration = 60000,
        PhaseWanderDuration = 8000,
        PhaseIdleDuration = 5000,
        PhaseLookAroundDuration = 500,
        PhaseStandStillDuration = 3000,
    },
    
    Guard = {
        PositionCheckInterval = 2000,
    },
    
    Reset = {
        WalkbackTimeout = 30000,
        TargetDistance = 2.0,
    },
    
    Detection = {
        SightRangeCheck = 17,
        HearingRangeCheck = 17,
        CloseProximitySpeedThreshold = 6,
        StandardSpeedThreshold = 5,
    },
}
