export type Profile = {
    Data: {any},
    MetaData: {
        ProfileCreateTime: number,
        SessionLoadCount: number,
        ActiveSession: {
            place_id: number,
            game_job_id: number,
        } | nil,
        MetaTags: {
            [string]: any,
        },
        MetaTagsLatest: {
            [string]: any,
        },
    },
    MetaTagsUpdated: RBXScriptSignal,
    RobloxMetaData: {any},
    UserIds: {
        [number]: number,
    },
    KeyInfo: DataStoreKeyInfo,
    KeyInfoUpdated: RBXScriptSignal,
    GlobalUpdates: {},
    IsActive: () -> boolean,
    GetMetaTag: (tag_name: string) -> any,
    Reconcile: () -> nil,
    ListenToRelease: (listener: (place_id: number | nil, game_job_id: number | nil) -> nil) -> RBXScriptConnection,
    Release: () -> nil,
    ListenToHopReady: (listener: () -> nil) -> RBXScriptConnection,
    AddUserId: (user_id: number) -> nil,
    RemoveUserId: (user_id: number) -> nil,
    Identify: () -> string,
    SetMetaTag: (tag_name: string, value: any) -> nil,
    Save: () -> nil,
    ClearGlobalUpdates: () -> nil,
    OverwriteAsync: () -> nil,
}

export type ProfileTemplate = {

}

export type DynamicTemplate = {

}

export type Replica = {
    Data: ReplicaData,
    Id: number,
    Class: string,
    Tags: {any},
    Parent: Replica,
    Children: {any},
    
    SetValue: (self: Replica, path: {string} | string, value: any) -> nil,
    SetValues: (self: Replica, path: {string} | string, values: {any}) -> nil,
    
    ArrayInsert: (self: Replica, path: string, value: any) -> number,
    ArraySet: (self: Replica, path: string, index: number, value: any) -> nil,
    ArrayRemove: (self: Replica, path: string, index: number) -> any,
    
    Write: (self: Replica, function_name: string, ...any) -> any,
    
    ConnectOnServerEvent: (self: Replica, listener: (player: any, ...any) -> nil) -> any,
    FireClient: (self: Replica, player: any, ...any) -> nil,
    FireAllClients: (self: Replica, ...any) -> nil,
    
    SetParent: (self: Replica, replica: Replica) -> nil,
    
    ReplicateFor: (self: Replica, target: any) -> nil,
    DestroyFor: (self: Replica, target: any) -> nil,
    
    Identify: (self: Replica) -> string,
    
    IsActive: (self: Replica) -> boolean,
    
    AddCleanupTask: (self: Replica, task: () -> any | any | {}) -> nil,
    RemoveCleanupTask: (self: Replica, task:  () -> any | any | {}) -> nil,
    
    Destroy: (self: Replica) -> nil,
}

export type ReplicaData = ProfileTemplate & DynamicTemplate

export type PlayerProfile = {
    Profile: Profile,
    Replica: Replica,
    Instance: Player,
    Maid: Maid,

    IsActive: (self: PlayerProfile) -> boolean,
    Get: (self: PlayerProfile, player: Player) -> PlayerProfile,
    Remove: (self: PlayerProfile, player: Player) -> nil,
}

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

export type Maid = {
    GiveTask: (self: Maid, task: any) -> (...any) -> nil;
    GivePromise: (self: Maid, task: any) -> (...any) -> nil;
    DoCleaning: (self: Maid) -> nil;
}

export type CharacterComponent = {
    Instance: Model,
    PlayerProfile: PlayerProfile?,
    Player: Player?,

    Maid: Maid,

    Destroy: (self: CharacterComponent) -> nil,
}

return nil