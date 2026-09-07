local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

if getgenv().PSH_CheckerRunning then
    warn("[PSH Checker] already running")
    return
end

getgenv().PSH_CheckerRunning = true

local LocalPlayer = Players.LocalPlayer

local function getPlayerGui()
    return LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
end

local function isInLobby()
    local pg = getPlayerGui()
    return pg and pg:FindFirstChild("ReactLobbyHud") ~= nil
end

local function isInGame()
    local pg = getPlayerGui()
    return pg and pg:FindFirstChild("ReactUniversalHotbar") ~= nil
end

local function isRunning()
    if isInGame() then
        return false
    end

    local boot = getgenv().PickHubLOL_Boot

    if type(boot) ~= "table" then
        return false
    end

    if type(boot.Heartbeat) ~= "number" then
        return false
    end

    return os.clock() - boot.Heartbeat < 15
end

local function stopChecker(reason)
    if reason then
        print("[PSH Checker] " .. reason)
    end

    getgenv().PSH_CheckerRunning = false
end

repeat
    task.wait(0.5)
    LocalPlayer = Players.LocalPlayer
until game:IsLoaded() and LocalPlayer

task.spawn(function()
    pcall(function()
        local connections = getconnections or get_signal_cons

        if connections then
            for _, connection in pairs(connections(LocalPlayer.Idled)) do
                if connection.Disable then
                    connection:Disable()
                elseif connection.Disconnect then
                    connection:Disconnect()
                end
            end
        end
    end)

    while getgenv().PSH_CheckerRunning do
        if isInGame() then
            stopChecker("Player entered game, stopping checker")
            break
        end

        if isInLobby() then
            task.wait(120)

            if not getgenv().PSH_CheckerRunning then
                break
            end

            if isInGame() then
                stopChecker("Player entered game, stopping checker")
                break
            end

            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        else
            task.wait(1)
        end
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
                repeat
                    task.wait()
                until game:IsLoaded()

                if isfile and isfile("PSHBoot.lua") then
                    loadstring(readfile("PSHBoot.lua"))()
                end
            end)
        ]])
    end)
end

local function serverHop()
    if isInGame() then
        stopChecker("Player is in-game, cancelling server hop")
        return
    end

    if not isInLobby() then
        stopChecker("Player is no longer in lobby, cancelling server hop")
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

        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            target,
            player
        )
    end)

    if not success then
        warn("[PSH Checker] server hop failed, rejoining...")

        if isInGame() or not isInLobby() then
            stopChecker("Player entered game, cancelling rejoin")
            return
        end

        pcall(function()
            TeleportService:Teleport(
                game.PlaceId,
                player,
                options
            )
        end)
    end
end

repeat
    task.wait(0.5)
until game:IsLoaded() and Players.LocalPlayer

if isInGame() then
    print("[PSH Checker] Player is already in-game, stopping checker")
    stopChecker()
    return
end

if not isInLobby() then
    print("[PSH Checker] Waiting for lobby...")

    repeat
        task.wait(1)

        if isInGame() then
            stopChecker("Player entered game, stopping checker")
            return
        end

    until isInLobby()
end

print("[PSH Checker] Player is in lobby")

if isRunning() then
    print("[PSH Checker] PickHub is already running")
    stopChecker()
    return
end

print("[PSH Checker] PickHub hasn't started, waiting 1 minute...")

local started = os.clock()

while os.clock() - started < 60 do
    task.wait(5)

    if isInGame() then
        stopChecker("Player entered game, stopping checker")
        return
    end

    if not isInLobby() then
        print("[PSH Checker] Player left lobby, stopping checker")
        stopChecker()
        return
    end

    if isRunning() then
        print("[PSH Checker] PickHub started")
        stopChecker()
        return
    end
end

if isInGame() then
    stopChecker("Player entered game, stopping checker")
    return
end

if not isInLobby() then
    stopChecker("Player left lobby, stopping checker")
    return
end

print("[PSH Checker] 1 minute passed, PickHub didn't start")

serverHop()
