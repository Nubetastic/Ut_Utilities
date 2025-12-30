Config = {}

Config.Debug = false

-- Nt_Enemy_NoBlip used for enemy peds no blips.
Config.ScanForEnemies = {
    ["Settings"] = { -- not a group
        cacheDistance = 250, -- Only if it has a blip cached.
        scanRadius = 225,
        scanInterval = 500,
        blipDespawn = 10,
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
        CloseProximityMultiplier = 0.25,
        CloseProximitySpeedThreshold = 2,
        StandardSpeedThreshold = 5,
    },
}
