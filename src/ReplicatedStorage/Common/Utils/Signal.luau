--!strict
--[[
    Signal.luau
    Fast, lightweight event signal implementation for Luau.
]]

type Connection = {
    Disconnect: (self: Connection) -> (),
    Connected: boolean,
}

export type Signal<T...> = {
    Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
    Once: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
    Fire: (self: Signal<T...>, T...) -> (),
    Wait: (self: Signal<T...>) -> T...,
    Destroy: (self: Signal<T...>) -> (),
}

local Signal = {}
Signal.__index = Signal

function Signal.new<T...>(): Signal<T...>
    local self = setmetatable({
        _listeners = {},
    }, Signal)
    return (self :: any)
end

function Signal:Connect(fn: (...any) -> ()): Connection
    local listeners = self._listeners
    table.insert(listeners, fn)

    local connection = {
        Connected = true,
        Disconnect = function(conn)
            if not conn.Connected then return end
            conn.Connected = false
            local index = table.find(listeners, fn)
            if index then
                table.remove(listeners, index)
            end
        end,
    }
    return connection
end

function Signal:Once(fn: (...any) -> ()): Connection
    local conn: Connection
    conn = self:Connect(function(...)
        conn:Disconnect()
        fn(...)
    end)
    return conn
end

function Signal:Fire(...: any)
    for _, fn in ipairs(table.clone(self._listeners)) do
        task.spawn(fn, ...)
    end
end

function Signal:Wait(): ...any
    local thread = coroutine.running()
    local conn: Connection
    conn = self:Connect(function(...)
        conn:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function Signal:Destroy()
    table.clear(self._listeners)
end

return Signal
