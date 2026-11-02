table.contains = function(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

table.sub = function(table, startIndex, endIndex)
    local subArray = {}

    startIndex = math.max(1, startIndex or 1)
    endIndex = math.min(#arr, endIndex or #arr)

    for i = startIndex, endIndex do
        table.insert(subArray, arr[i])
    end
    return subArray
end

string.split = function(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

base64 = {}
do
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

    base64.encode = function(data)
        return ((data:gsub('.', function(x)
            local r, b = '', x:byte()
            for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
            return r;
        end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c = 0
            for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
            return b:sub(c + 1, c + 1)
        end) .. ({ '', '==', '=' })[#data % 3 + 1])
    end

    base64.decode = function(data)
        data = string.gsub(data, '[^' .. b .. '=]', '')
        return (data:gsub('.', function(x)
            if (x == '=') then return '' end
            local r, f = '', (b:find(x) - 1)
            for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c = 0
            for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
            return string.char(c)
        end))
    end
end

TimerService = {
    timers = {},
    
    update = function(self, deltaSecs)
        for i = #self.timers, 1, -1 do
            local timer = self.timers[i]
            timer.elapsed = timer.elapsed + deltaSecs
            if timer.elapsed >= timer.interval then
                timer.elapsed = timer.elapsed - timer.interval
                timer.callback(timer)
                if not timer.running then
                    table.remove(self.timers, i)
                end
            end
        end
    end,
}

EventManager.Listen("Server:UpdatePre", TimerService.update, TimerService)

Timer = {}
Timer.__index = Timer

function Timer:new(interval, callback)
    local obj = setmetatable({}, self)
    obj.interval = interval
    obj.callback = callback
    obj.elapsed = 0
    obj.running = true
    table.insert(TimerService.timers, obj)
    return obj
end

function Timer:cancel()
    self.running = false
end

function SetTimeout(callback, delay)
    Timer:new(delay, function(timer)
        callback()
        timer:cancel()
    end)
end

return {
    Timer = Timer,
    SetTimeout = SetTimeout
}