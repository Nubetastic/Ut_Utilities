# Nt_Utilities

There are two scripts here.
Nt_Utilities - contains working exports to use.
Nt_Utilities_Test - contains working example code to use/modify.

## Description
Utilities are custom exports I made for my scripts that I am sharing to help others.

One of the key features is how relationship groups are being used.
Ped relationship groups assign blips to npcs, fully client side. No need to sync netID's or any other data.
Ped relationship groups also handel all combat with one native command. TaskCombatHatedTargets(ped)
With TaskCombatHatedTargets(ped) npcs will attack any player/ped that is in a hostile group to theirs in range. In my testing combat range cannot be changed.

In Nt_Utilities there is an export called InitializeCombatAI
This is an indepth customized npc AI that allows the npc to do ambient tasks, stand at guard, investigate dead bodies and will use TaskCombatHatedTargets to attack when it sees a hostile target.
Players can sneak up on the AI.
AI will warn each other of an enemy being spotted.
