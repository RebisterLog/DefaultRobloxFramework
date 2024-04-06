local ServerScriptService = game:GetService("ServerScriptService")

local ReplicaService = require(ServerScriptService.Server.Modules.ReplicaService)
local ProfileService = require(ServerScriptService.Server.Modules.ProfileService)
local PlayerProfile = require(ServerScriptService.Server.Modules.PlayerProfile)

local ProfileTemplate = {
    Cash = 0
}

local Players = game:GetService("Players")

local PlayerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile")

local GameProfileStore = ProfileService.GetProfileStore("Main", ProfileTemplate)

local function PlayerAdded(player)
    local profile = GameProfileStore:LoadProfileAsync(
        "Player_" .. player.UserId,
        "ForceLoad"
    )
    if profile ~= nil then
		profile:AddUserId(player.UserId)
        profile:Reconcile()

		local playerProfile = PlayerProfile:Get(player)

		profile:ListenToRelease(function()
			playerProfile.Replica:Destroy()
            PlayerProfile:Remove(player)
            player:Kick()
        end)
		
		if player:IsDescendantOf(Players) == true then
			local player_profile = {
				Profile = profile,
				Replica = ReplicaService.NewReplica({
					ClassToken = PlayerProfileClassToken,
					Tags = {Player = player},
					Data = profile.Data,
					Replication = "All",
				}),
				Instance = player,
			}
			setmetatable(player_profile, PlayerProfile)
            playerProfile = player_profile
            playerProfile:Init()
        else
            profile:Release()
        end
    else
        player:Kick() 
    end
end

----- Initialize -----

for _, player in ipairs(Players:GetPlayers()) do
    coroutine.wrap(PlayerAdded)(player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    local playerProfile = PlayerProfile:Get(player)
    if playerProfile ~= nil then
        playerProfile.Profile:Release()
    end
end)