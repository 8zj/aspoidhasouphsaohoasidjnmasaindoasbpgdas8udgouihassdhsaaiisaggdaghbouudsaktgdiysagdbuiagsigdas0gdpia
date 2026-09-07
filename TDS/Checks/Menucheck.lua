local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/TDS/Checks/check1.lua"))()
end)

if getgenv().PSH_CheckerRunning then
    warn("[PSH Checker] already running")
    return
end

getgenv().PSH_CheckerRunning = true

local function getGameState()
    local player = Players.LocalPlayer
    if not player then
        return "UNKNOWN"
    end

    local gui = player:FindFirstChildOfClass("PlayerGui")
    if not gui then
        return "UNKNOWN"
    end

    if gui:FindFirstChild("ReactUniversalHotbar") then
        return "GAME"
    end

    if gui:FindFirstChild("ReactLobbyHud") then
        return "LOBBY"
    end

    return "UNKNOWN"
end

local function isInGame()
    return getGameState() == "GAME"
end

local function isRunning()
    local boot = getgenv().PickHubLOL_Boot

    if type(boot) ~= "table" or type(boot.Heartbeat) ~= "number" then
        return false
    end

    return os.clock() - boot.Heartbeat < 15
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
    if isInGame() then
        print("[PSH Checker] [ Skipping in game ]")
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

    local success, err = pcall(function()
        if isInGame() then
            error("in game")
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

        if isInGame() then
            error("in game")
        end

        local target = servers[math.random(1, #servers)]

        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            target,
            player,
            options
        )
    end)

    if not success then
        warn("[PSH Checker] server hop failed: " .. tostring(err))
    end
end

repeat
    task.wait(0.5)
until game:IsLoaded() and Players.LocalPlayer

if isInGame() then
    print("[PSH Checker] [ Skipping in game ]")
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

    if isInGame() then
        print("[PSH Checker] [ Skipping in game ]")
        getgenv().PSH_CheckerRunning = false
        return
    end

    if isRunning() then
        print("[PSH Checker] PickHub started")
        getgenv().PSH_CheckerRunning = false
        return
    end
end

if isInGame() then
    print("[PSH Checker] [ Skipping in game ]")
    getgenv().PSH_CheckerRunning = false
    return
end

if isRunning() then
    print("[PSH Checker] PickHub started")
    getgenv().PSH_CheckerRunning = false
    return
end

print("[PSH Checker] 1 minute passed, PickHub didn't start")

serverHop()

getgenv().PSH_CheckerRunning = false
