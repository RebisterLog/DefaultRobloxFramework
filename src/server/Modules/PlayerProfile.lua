local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Character = require(ServerScriptService.Server.Components.Character)
local Maid = require(ReplicatedStorage.Shared.Modules.MadworkMaid)
local Types = require(ServerScriptService.Server.Types)

local PlayerProfiles = {}

local PlayerProfile = {}
PlayerProfile.__index = PlayerProfile


function PlayerProfile:Init()
	self.Maid = Maid.new()

	self.Maid:GiveTask(self.Instance.CharacterAdded:Connect(function(character)
		local component = Character.new(character, self)

		PlayerProfiles[self.Instance] = self
		self.CharacterComponent = component
	end))

	if self.Instance.Character and self.CharacterComponent == nil then
		local component = Character.new(self.Instance.Character, self)
		if not component then return end

		PlayerProfiles[self.Instance] = self
		self.CharacterComponent = component
	end

	print(self.CharacterComponent)
end

function PlayerProfile:IsActive(): boolean
	return PlayerProfiles[self.Instance] ~= nil
end

function PlayerProfile:Get(player: Player): Types.IPlayerProfile
    return PlayerProfiles[player]
end

function PlayerProfile:Remove(player: Player)
    PlayerProfiles[player] = nil
end

return PlayerProfile