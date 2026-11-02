require "common/sdk"

local skipVotes = {}
local skipPassed = false

local function CountHumans()
    local count = 0
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if not player.isBot then count = count + 1 end
    end
    return count
end

local function CountVotes()
    local count = 0
    for _ in pairs(skipVotes) do
        count = count + 1
    end
    return count
end

local function ResetVotes()
    skipVotes = {}
    skipPassed = false
end

local function Broadcast(msg)
    Console.Execute("Kyber.Broadcast " .. msg)
end

local function CheckVotes()
    if skipPassed then return end
    local votes = CountVotes()
    local humans = CountHumans()
    local needed = math.floor(humans / 2) + 1
    if votes >= needed then
        skipPassed = true
        skipVotes = {}
        Broadcast("Vote passed, skipping map.")
        Console.Execute("Kyber.endofround")
    end
end

EventManager.Listen("Level:Loaded", function(level, mode)
    ResetVotes()
    SetTimeout(function()
        Broadcast("Type !skip to vote to skip the current map.")
    end, 20.0)
end)

EventManager.Listen("ServerPlayer:Disconnect", function(player)
    if player == nil then return end
    skipVotes[player.playerId] = nil
    CheckVotes()
end)

EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if message:len() < 2 then return end
    local messageSplit = string.split(message)

    if #messageSplit <= 0 then return end
    if messageSplit[1]:len() < 3 then return end
    if messageSplit[1]:sub(1, 1) ~= '!' then return end

    local command = messageSplit[1]:lower():sub(2)
    EventManager.SetCancelled(true)

    if command == "skip" then
        if skipPassed then return end
        if skipVotes[player.playerId] then
            player:SendChatMessage("You already voted")
            return
        end

        skipVotes[player.playerId] = true
        local votes = CountVotes()
        local humans = CountHumans()
        local needed = math.floor(humans / 2) + 1
        Broadcast(player.name .. " voted to skip (" .. votes .. "/" .. needed .. ")")
        CheckVotes()
    else
        print("Invalid command: " .. command)
    end
end)