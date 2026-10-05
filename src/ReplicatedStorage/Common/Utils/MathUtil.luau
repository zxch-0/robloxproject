--!strict
--[[
    MathUtil.luau
    Math utilities for grid snapping, weighted RNG, and spatial bounding checks.
]]

local MathUtil = {}

-- Snaps a world vector to a grid step
function MathUtil.snapToGrid(pos: Vector3, cellSize: number): Vector3
    local x = math.floor((pos.X + cellSize / 2) / cellSize) * cellSize
    local z = math.floor((pos.Z + cellSize / 2) / cellSize) * cellSize
    return Vector3.new(x, pos.Y, z)
end

-- Snaps an angle in degrees to 90 degree increments
function MathUtil.snapRotation(degrees: number): number
    local rounded = math.floor((degrees + 45) / 90) * 90
    return rounded % 360
end

-- Performs weighted selection from a table of { weight: number, ... }
function MathUtil.weightedRoll<T>(items: { [string]: { Weight: number } }): string?
    local totalWeight = 0
    for _, item in pairs(items) do
        totalWeight += item.Weight
    end

    if totalWeight <= 0 then
        return nil
    end

    local randomValue = math.random() * totalWeight
    local cumulative = 0

    for id, item in pairs(items) do
        cumulative += item.Weight
        if randomValue <= cumulative then
            return id
        end
    end

    -- Fallback to first element
    for id, _ in pairs(items) do
        return id
    end
    return nil
end

-- Checks if two 2D Axis-Aligned Bounding Boxes overlap on the grid
function MathUtil.checkAABBOverlap(
    posA: Vector2,
    sizeA: Vector2,
    posB: Vector2,
    sizeB: Vector2
): boolean
    local halfA = sizeA / 2
    local halfB = sizeB / 2

    local minAx, maxAx = posA.X - halfA.X, posA.X + halfA.X
    local minAy, maxAy = posA.Y - halfA.Y, posA.Y + halfA.Y

    local minBx, maxBx = posB.X - halfB.X, posB.X + halfB.X
    local minBy, maxBy = posB.Y - halfB.Y, posB.Y + halfB.Y

    return (minAx < maxBx and maxAx > minBx and minAy < maxBy and maxAy > minBy)
end

return MathUtil
