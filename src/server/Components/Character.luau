local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ClassSystem = require(ReplicatedStorage.Shared.Modules.ClassSystem)

local Types = require(ServerScriptService.Server.Types)
local Maid = require(ReplicatedStorage.Shared.Modules.MadworkMaid)


local Character = ClassSystem.Create("Character")

function Character:constructor(character: Model, playerProfile: Types.PlayerProfile?)
    self.Instance = character

    if playerProfile then
        self.PlayerProfile = playerProfile
        self.Player = playerProfile.Instance
    end

    local maid: Types.Maid = Maid.new()
    self.Maid = maid

    character:AddTag("Character")

    local humanoid = self.Instance:FindFirstChildOfClass("Humanoid")

    maid:GiveTask(humanoid.Died:Connect(function()
        self:Destroy()
    end))
    
    maid:GiveTask(self.Instance.Destroying:Connect(function()
        self:Destroy()
    end))

end

function Character:Destroy()
    self.Maid:DoCleaning()
end

return Character