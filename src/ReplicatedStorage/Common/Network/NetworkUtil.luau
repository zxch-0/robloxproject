--!strict
--[[
    NetworkUtil.luau
    Safely registers and retrieves RemoteEvents and RemoteFunctions under ReplicatedStorage.
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkUtil = {}

local REMOTES_FOLDER_NAME = "BeastHavenRemotes"

local REMOTE_EVENTS = {
    -- Tycoon & Placement
    "PlaceBuilding",
    "RemoveBuilding",
    "BuildingStateUpdated",

    -- Creatures & Incubation
    "FeedCreature",
    "PetCreature",
    "StartIncubation",
    "ClaimIncubation",
    "CreatureSpawned",
    "CreatureHarvested",

    -- Tourism & Visitors
    "SetTicketPrice",
    "RateSanctuary",
    "VisitSanctuary",
    "VisitorArrived",
    "PrestigeUpdated",

    -- Economy & Data
    "BalanceChanged",
    "SyncFullProfile",
}

local REMOTE_FUNCTIONS = {
    "RequestPlotClaim",
    "GetSanctuaryCatalog",
    "GetVisitorLeaderboard",
}

function NetworkUtil.getFolder(): Folder
    local folder = ReplicatedStorage:FindFirstChild(REMOTES_FOLDER_NAME)
    if not folder then
        if RunService:IsServer() then
            folder = Instance.new("Folder")
            folder.Name = REMOTES_FOLDER_NAME
            folder.Parent = ReplicatedStorage
        else
            folder = ReplicatedStorage:WaitForChild(REMOTES_FOLDER_NAME, 10) :: Folder
            assert(folder, "Could not find BeastHavenRemotes folder on client!")
        end
    end
    return folder :: Folder
end

function NetworkUtil.initServer()
    assert(RunService:IsServer(), "NetworkUtil.initServer must only be called on the server!")
    local folder = NetworkUtil.getFolder()

    for _, eventName in ipairs(REMOTE_EVENTS) do
        if not folder:FindFirstChild(eventName) then
            local remote = Instance.new("RemoteEvent")
            remote.Name = eventName
            remote.Parent = folder
        end
    end

    for _, funcName in ipairs(REMOTE_FUNCTIONS) do
        if not folder:FindFirstChild(funcName) then
            local remote = Instance.new("RemoteFunction")
            remote.Name = funcName
            remote.Parent = folder
        end
    end
end

function NetworkUtil.getRemoteEvent(name: string): RemoteEvent
    local folder = NetworkUtil.getFolder()
    local remote = folder:WaitForChild(name, 5)
    assert(remote and remote:IsA("RemoteEvent"), "RemoteEvent not found: " .. name)
    return remote
end

function NetworkUtil.getRemoteFunction(name: string): RemoteFunction
    local folder = NetworkUtil.getFolder()
    local remote = folder:WaitForChild(name, 5)
    assert(remote and remote:IsA("RemoteFunction"), "RemoteFunction not found: " .. name)
    return remote
end

return NetworkUtil
