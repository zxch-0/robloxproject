--!strict
--[[
    EconomyService.luau
    Authoritative server-side currency management for Essence, Harmony Crystals, and Prestige Tickets.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(script.Parent.DataService)
local NetworkUtil = require(ReplicatedStorage.Common.Network.NetworkUtil)
local Signal = require(ReplicatedStorage.Common.Utils.Signal)

local EconomyService = {
    BalanceChanged = Signal.new(),
}

function EconomyService:Init()
    -- Subscribes to events or remote requests if needed
end

function EconomyService:GetBalance(player: Player, currency: string): number
    local profile = DataService:GetProfile(player)
    if not profile then return 0 end
    return profile.Currencies[currency] or 0
end

function EconomyService:HasEnough(player: Player, currency: string, amount: number): boolean
    return self:GetBalance(player, currency) >= amount
end

function EconomyService:AddCurrency(player: Player, currency: string, amount: number): boolean
    if amount <= 0 then return false end
    local success = DataService:UpdateProfile(player, function(profile)
        local current = profile.Currencies[currency] or 0
        profile.Currencies[currency] = current + amount
    end)

    if success then
        local newBalance = self:GetBalance(player, currency)
        self.BalanceChanged:Fire(player, currency, newBalance)
        pcall(function()
            local remote = NetworkUtil.getRemoteEvent("BalanceChanged")
            remote:FireClient(player, currency, newBalance)
        end)
    end
    return success
end

function EconomyService:SpendCurrency(player: Player, currency: string, amount: number): boolean
    if amount < 0 then return false end
    if not self:HasEnough(player, currency, amount) then return false end

    local success = DataService:UpdateProfile(player, function(profile)
        local current = profile.Currencies[currency] or 0
        profile.Currencies[currency] = current - amount
    end)

    if success then
        local newBalance = self:GetBalance(player, currency)
        self.BalanceChanged:Fire(player, currency, newBalance)
        pcall(function()
            local remote = NetworkUtil.getRemoteEvent("BalanceChanged")
            remote:FireClient(player, currency, newBalance)
        end)
    end
    return success
end

return EconomyService
