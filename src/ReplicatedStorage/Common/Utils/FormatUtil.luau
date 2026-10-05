--!strict
--[[
    FormatUtil.luau
    Utility functions for formatting numbers, currency strings, and timers.
]]

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

local FormatUtil = {}

function FormatUtil.formatNumber(n: number): string
    if n < 0 then
        return "-" .. FormatUtil.formatNumber(-n)
    end
    if n < 1000 then
        return tostring(math.floor(n))
    end

    local magnitude = math.floor(math.log10(n) / 3)
    if magnitude > #SUFFIXES - 1 then
        magnitude = #SUFFIXES - 1
    end

    local divisor = 10 ^ (magnitude * 3)
    local formatted = n / divisor
    local suffix = SUFFIXES[magnitude + 1]

    if formatted >= 100 then
        return string.format("%.0f%s", formatted, suffix)
    elseif formatted >= 10 then
        return string.format("%.1f%s", formatted, suffix)
    else
        return string.format("%.2f%s", formatted, suffix)
    end
end

function FormatUtil.formatTime(seconds: number): string
    local s = math.max(0, math.floor(seconds))
    local mins = math.floor(s / 60)
    local secs = s % 60
    return string.format("%02d:%02d", mins, secs)
end

function FormatUtil.formatPercentage(ratio: number): string
    return string.format("%.0f%%", math.clamp(ratio, 0, 1) * 100)
end

return FormatUtil
