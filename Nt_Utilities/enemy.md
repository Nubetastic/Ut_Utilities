# NPCCombatAI Enemy Detection Review

- `StartThreatScanning` runs while any NPCs are alive and builds `hostileTargets` maps keyed by each NPC relationship group. It scans every ped pool entry, records enemy ped handles when `GetRelationshipBetweenGroups` returns `5`, and prunes entries when the target dies or exceeds `ThreatScanning.TargetTimeoutMs`.

- Each `ManageNPC` loop consults the cached `hostileTargets[myGroupHash]` list. Detection prefers sight first by checking `HasEntityClearLosToEntityInFront` and comparing distance to `sightRange`. If sight fails, it falls back to a hearing check (`HasEntityClearLosToEntity`) that also enforces distance thresholds and speed-based heuristics (`CloseProximityMultiplier`, `CloseProximitySpeedThreshold`, `StandardSpeedThreshold`). Once a target is detected, the ped clears tasks, enters the `combat` state, and runs `TaskCombatHatedTargets`.

- Combat persistence is handled via `targetDetected` flags, `combatRange` distance checks, and a 30-second `nextActionTime` timer so NPCs only re-evaluate combat range periodically. The same logic also governs rejoining `activeCombatAreas`: NPCs either create a new area or join nearby areas of the same group when entering combat, and they automatically switch to combat if they wander near an active area.

- If no immediate threat is spotted but the NPC is in `ambient` or `guard` state, `FindNearbyBodyInCache` looks for recent allied/related dead bodies within `Investigation.NearbyBodyCheckRadius`. Bodies are cached by `StartDeadBodyScanning`, which only stores corpses belonging to same group or allied relationships and enforces investigator caps (`MaxInvestigatorsPerGroup`). Investigating NPCs move through phases (approach → inspect → wander) before either clearing the body cache or flagging it as old after enough investigations.

- The detection system includes fallbacks for stuck NPCs (teleporting to spawn if no movement detected for 30 seconds) and cleanup threads to remove empty combat areas or stale dead bodies, keeping `hostileTargets`, `activeCombatAreas`, and `deadBodies` bounded.
