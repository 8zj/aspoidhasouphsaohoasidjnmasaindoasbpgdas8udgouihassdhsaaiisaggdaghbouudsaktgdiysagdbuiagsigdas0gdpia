local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

if getgenv().PSH_CheckerRunning then
    warn("[PSH Checker] already running")
    return
end

getgenv().PSH_CheckerRunning = true

local function isRunning()
    local boot = getgenv().PickHubLOL_Boot

    if type(boot) ~= "table" then
        return false
    end

    if type(boot.Heartbeat) ~= "number" then
        return false
    end

    return os.clock() - boot.Heartbeat < 15
end

local function isInGameCheck1()
    local player = Players.LocalPlayer
    local gui = player and player:FindFirstChildOfClass("PlayerGui")

    if not gui then
        return false
    end

    return gui:FindFirstChild("ReactUniversalHotbar") ~= nil
end

local function isInGameCheck2()
    return game_state == "GAME"
end

local function isInGame()
    return isInGameCheck1() or isInGameCheck2()
end

task.spawn(function()
    local player = Players.LocalPlayer

    repeat
        task.wait()
        player = Players.LocalPlayer
    until player

    pcall(function()
        local connections = getconnections or get_signal_cons

        if connections then
            for _, connection in pairs(connections(player.Idled)) do
                if connection.Disable then
                    connection:Disable()
                elseif connection.Disconnect then
                    connection:Disconnect()
                end
            end
        end
    end)

    while getgenv().PSH_CheckerRunning do
        task.wait(120)

        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

local function queueBoot()
    pcall(function()
        local queue =
            queue_on_teleport
            or queueonteleport
            or queueteleport
            or (syn and syn.queue_on_teleport)
            or (fluxus and fluxus.queue_on_teleport)

        if typeof(queue) ~= "function" then
            return
        end

        queue([[
            pcall(function()
                repeat task.wait() until game:IsLoaded()

                if isfile and isfile("PSHBoot.lua") then
                    loadstring(readfile("PSHBoot.lua"))()
                end
            end)
        ]])
    end)
end

local function serverHop()
    if isInGameCheck1() then
        print("[PSH Checker] [ Skipping in game - Check 1 ]")
        getgenv().PSH_CheckerRunning = false
        return
    end

    if isInGameCheck2() then
        print("[PSH Checker] [ Skipping in game - Check 2 ]")
        getgenv().PSH_CheckerRunning = false
        return
    end

    print("[PSH Checker] PickHub didn't start, hopping...")

    queueBoot()

    local player = Players.LocalPlayer
    local options = Instance.new("TeleportOptions")

    pcall(function()
        local config = getgenv().PickHubLOL

        if type(config) == "table" then
            options:SetTeleportData({
                PickHubLOL = config
            })
        end
    end)

    local success = pcall(function()
        if isInGameCheck1() then
            error("in game - check 1")
        end

        if isInGameCheck2() then
            error("in game - check 2")
        end

        local url =
            "https://games.roblox.com/v1/games/"
            .. tostring(game.PlaceId)
            .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"

        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)

        local servers = {}

        for _, server in ipairs(data.data or {}) do
            if server.id ~= game.JobId
                and (server.playing or 0) < (server.maxPlayers or 50) then

                servers[#servers + 1] = server.id
            end
        end

        if #servers == 0 then
            error("no servers")
        end

        local target = servers[math.random(1, #servers)]

        if isInGameCheck1() then
            error("in game - check 1")
        end

        if isInGameCheck2() then
            error("in game - check 2")
        end

        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            target,
            player
        )
    end)

    if not success then
        warn("[PSH Checker] server hop failed")
    end
end

repeat
    task.wait(0.5)
until game:IsLoaded() and Players.LocalPlayer

if isInGameCheck1() then
    print("[PSH Checker] [ Skipping in game - Check 1 ]")
    getgenv().PSH_CheckerRunning = false
    return
end

if isInGameCheck2() then
    print("[PSH Checker] [ Skipping in game - Check 2 ]")
    getgenv().PSH_CheckerRunning = false
    return
end

if isRunning() then
    print("[PSH Checker] PickHub is already running")
    getgenv().PSH_CheckerRunning = false
    return
end

print("[PSH Checker] PickHub hasn't started, waiting 1 minute...")

local started = os.clock()

while os.clock() - started < 60 do
    task.wait(5)

    if isInGameCheck1() then
        print("[PSH Checker] [ Skipping in game - Check 1 ]")
        getgenv().PSH_CheckerRunning = false
        return
    end

    if isInGameCheck2() then
        print("[PSH Checker] [ Skipping in game - Check 2 ]")
        getgenv().PSH_CheckerRunning = false
        return
    end

    if isRunning() then
        print("[PSH Checker] PickHub started")
        getgenv().PSH_CheckerRunning = false
        return
    end
end

if isInGameCheck1() then
    print("[PSH Checker] [ Skipping in game - Check 1 ]")
    getgenv().PSH_CheckerRunning = false
    return
end

if isInGameCheck2() then
    print("[PSH Checker] [ Skipping in game - Check 2 ]")
    getgenv().PSH_CheckerRunning = false
    return
end

print("[PSH Checker] 1 minute passed, PickHub didn't start")

serverHop()
