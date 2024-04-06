local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GlobalEvent = ReplicatedStorage:FindFirstChild("Global")

local GlobalUnreliableEvent = ReplicatedStorage:FindFirstChild("GlobalUnreliable")


local PlayersService = game:GetService("Players")

local RemoteEvents = {}
local BindableEvents = {}
local UnreliableEvents = {}

export type Remote = {
	Connect: (self: Remote, func: (...any) -> ...any) -> nil,
	Disconnent: (self: Remote, func: (...any) -> ...any) -> nil,
	Destroy: (self: Remote) -> nil,
	Wait: (self: Remote, timeout: number?) -> nil,
	Once: (self: Remote, func: (...any) -> ...any) -> nil,
	Single: (self: Remote, func: (...any) -> ...any) -> nil,
	
	FireAllClients: (self: Remote, ...any) -> nil,
	FireClient: (self: Remote, client: Player, ...any) -> nil,
	FireServer: (self: Remote, ...any) -> nil,
	FireClientsInRadius: (self: Remote, origin: Vector3, radius: number, ...any) -> nil,
}

export type Unreliable = {
	Connect: (self: Unreliable, func: (...any) -> ...any) -> nil,
	Disconnent: (self: Unreliable, func: (...any) -> ...any) -> nil,
	Destroy: (self: Unreliable) -> nil,
	Wait: (self: Unreliable, timeout: number?) -> nil,
	Once: (self: Unreliable, func: (...any) -> ...any) -> nil,
	Single: (self: Unreliable, func: (...any) -> ...any) -> nil,

	FireAllClients: (self: Unreliable, ...any) -> nil,
	FireClient: (self: Unreliable, client: Player, ...any) -> nil,
	FireServer: (self: Unreliable, ...any) -> nil,
	FireClientsInRadius: (self: Unreliable, origin: Vector3, radius: number, ...any) -> nil,
}

local Events = {}

function Events:Connect( func ): number
	self.ConnectionsCount += 1
	table.insert(self.Functions, self.ConnectionsCount, func)
	return self.ConnectionsCount
end

function Events:Disconnect( connectionId )
	table.remove(self.Functions, connectionId)
end

function Events:Destroy()
	for _, func in ipairs(self.Functions) do
		self:Disconnect(func)
	end

	BindableEvents[self.Name] = nil
end

function Events:Wait( timeout: number?)
	local waiting = coroutine.create(function()
		coroutine.yield()
	end)

	local start = tick()
	local thread = setmetatable({}, {__call = function() coroutine.close(waiting) end})

	self:Connect(thread)
	repeat task.wait() until coroutine.status(waiting) ~= 'suspended' or tick() - start > (timeout or 10)
	self:Disconnect(thread)
end

function Events:Once( func )
	table.insert(self.Functions, function(...)
		func(...)
		self:Disconnect(func)
	end)
end

function Events:Single( func )
	self.Functions['Single'] = func
end

local Remote = {}

function Remote:FireAllClients(... )
	GlobalEvent:FireAllClients(self.Name, ...)
end

function Remote:FireClient(player, ... )
	GlobalEvent:FireClient(player, self.Name, ...)
end

function Remote:FireServer( ... )
	GlobalEvent:FireServer(self.Name, ...)
end

function Remote:FireClientsInRadius(origin:Vector3, radius:number, ... )
	for name, player in pairs( PlayersService:GetPlayers() ) do
		local character = player.Character or player.CharacterAdded:Wait()
		if not character then continue end

		if ( origin - character.PrimaryPart.Position ).Magnitude <= radius then
			self:FireClient( player, ... )
		end
	end
end

local Unreliable = {}

function Unreliable:FireAllClients( ... )
	GlobalUnreliableEvent:FireAllClients(self.Name, ...)
end

function Unreliable:FireClient( player, ... )
	GlobalUnreliableEvent:FireClient(player, self.Name, ...)
end

function Unreliable:FireServer( ... )
	GlobalUnreliableEvent:FireServer(self.Name, ...)
end

function Unreliable:FireClientsInRadius( origin:Vector3, radius:number, ... )
	for name, player in pairs( PlayersService:GetPlayers() ) do
		local character = player.Character or player.CharacterAdded:Wait()
		if not character then continue end

		if ( origin - character.PrimaryPart.Position ).Magnitude <= radius then
			GlobalUnreliableEvent:FireClient( player, ... )
		end
	end
end

local EventCreator = {}

local function CreateEvent(name)
	local event = setmetatable(
		{
			Name = name,
			Functions = {},
			ConnectionsCount = 0
		},

		{
			__index = Events,
		}
	)
	return event
end

--Create Remote Event
function EventCreator:NewRemote( name:string ): Remote
	if RemoteEvents[ name ] ~= nil then return RemoteEvents[ name ] end

	local event = CreateEvent(name)

	getmetatable(event).__index =
		function(t, i)
			return Events[i] or Remote[i]
		end

	RemoteEvents[name] = event
	return event
end

--Create Unreliable Event
function EventCreator:NewUnreliable( name:string ): Unreliable
	if UnreliableEvents[ name ] ~= nil then return UnreliableEvents[ name ] end

	local event = CreateEvent(name)
	
	getmetatable(event).__index =
		function(t, i)
			return Events[i] or Unreliable[i]
		end

	UnreliableEvents[name] = event
	return event
end

-- Check for type of requiring script
if RunService:IsServer() then


	if not GlobalEvent then
		warn("[Event Creator] Not found 'Global' event, creating new one")
		GlobalEvent = Instance.new("RemoteEvent", ReplicatedStorage)
		GlobalEvent.Name = "Global"
	end

	if not GlobalUnreliableEvent then
		warn("[Event Creator] Not found 'GlobalUnreliable' event, creating new one")
		GlobalUnreliableEvent = Instance.new("UnreliableRemoteEvent", ReplicatedStorage)
		GlobalUnreliableEvent.Name = "GlobalUnreliable"
	end

	GlobalEvent.OnServerEvent:Connect(function(player, name, ...)
		if RemoteEvents[ name ] == nil then return warn("[Event Creator] Event",name,"not found!") end
		return RemoteEvents[ name ](player, ...)
	end)
	
	GlobalUnreliableEvent.OnServerEvent:Connect(function(player, name, ...)
		if UnreliableEvents[ name ] == nil then return warn("[Event Creator] Event",name,"not found!") end
		return UnreliableEvents[ name ](player, ...)
	end)

elseif RunService:IsClient() then

	if not GlobalEvent then
		repeat
			task.wait(2)
			GlobalEvent = ReplicatedStorage:FindFirstChild("Global")
		until GlobalEvent
	end

	if not GlobalUnreliableEvent then
		repeat
			task.wait(2)
			GlobalUnreliableEvent = ReplicatedStorage:FindFirstChild("GlobalUnreliable")
		until GlobalUnreliableEvent
	end

	GlobalEvent.OnClientEvent:Connect(function(name, ...)
		if RemoteEvents[ name ] == nil then return warn("[Event Creator] Event",name,"not found!") end
		return RemoteEvents[ name ](...)
	end)

	GlobalUnreliableEvent.OnClientEvent:Connect(function(name, ...)
		if UnreliableEvents[ name ] == nil then return warn("[Event Creator] Event",name,"not found!") end
		return UnreliableEvents[ name ](...)
	end)
end

return EventCreator