local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

if getgenv().PSH_CheckerRunning then
    warn("[PSH Checker] already running")
    return
end

getgenv().PSH_CheckerRunning = true

local LocalPlayer = Players.LocalPlayer

local function isInLobby()
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    return pg and pg:FindFirstChild("ReactLobbyHud") ~= nil
end

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

local function stopChecker()
    getgenv().PSH_CheckerRunning = false
end

repeat
    task.wait(0.5)
    LocalPlayer = Players.LocalPlayer
until game:IsLoaded() and LocalPlayer

if not isInLobby() then
    print("[PSH Checker] [ Skipping not in lobby ]")
    stopChecker()
    return
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

    if not isInLobby() then
        print("[PSH Checker] [ Skipping not in lobby ]")
        stopChecker()
        return
    end

    if isRunning() then
        print("[PSH Checker] PickHub started")
        stopChecker()
        return
    end
end

if not isInLobby() then
    print("[PSH Checker] [ Skipping not in lobby ]")
    stopChecker()
    return
end

print("[PSH Checker] 1 minute passed, PickHub didn't start")

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

queueBoot()

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
        LocalPlayer
    )
end)

if not success then
    warn("[PSH Checker] server hop failed, rejoining...")

    pcall(function()
        TeleportService:Teleport(
            game.PlaceId,
            LocalPlayer,
            options
        )
    end)
end

stopChecker()
