local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

if getgenv().PSH_CheckerRunning then
    warn("[PSH Checker] already running")
    return
end

getgenv().PSH_CheckerRunning = true

local LocalPlayer = Players.LocalPlayer
local Teleporting = false
local InMatch = false
local CheckerStart = os.clock()

local function playerGui()
    return LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
end

local function lobby()
    local pg = playerGui()
    return pg and pg:FindFirstChild("ReactLobbyHud") ~= nil
end

local function gameStarted()
    local pg = playerGui()
    return pg and pg:FindFirstChild("ReactUniversalHotbar") ~= nil
end

local function stop(reason)
    getgenv().PSH_CheckerRunning = false

    if reason then
        print("[PSH Checker] " .. reason)
    end
end

local function validLobbyState()
    if not getgenv().PSH_CheckerRunning then
        return false
    end

    if Teleporting then
        return false
    end

    if InMatch then
        return false
    end

    if gameStarted() then
        InMatch = true
        stop("Match detected")
        return false
    end

    if not lobby() then
        return false
    end

    return true
end

local function isPickHubRunning()
    if not validLobbyState() then
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

local function normalRejoin()
    if not validLobbyState() then
        return
    end

    Teleporting = true

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

    print("[PSH Checker] Using normal public-server rejoin")

    local success = pcall(function()
        TeleportService:Teleport(
            game.PlaceId,
            player,
            options
        )
    end)

    if not success then
        Teleporting = false
        warn("[PSH Checker] Rejoin failed")
    end
end

local function getServers()
    local success, result = pcall(function()
        local url =
            "https://games.roblox.com/v1/games/"
            .. tostring(game.PlaceId)
            .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"

        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)

        local servers = {}

        for _, server in ipairs(data.data or {}) do
            local id = server.id
            local playing = tonumber(server.playing) or 0
            local maxPlayers = tonumber(server.maxPlayers) or 0

            if id
                and id ~= game.JobId
                and maxPlayers > 0
                and playing < maxPlayers then

                servers[#servers + 1] = {
                    id = id,
                    playing = playing,
                    maxPlayers = maxPlayers
                }
            end
        end

        return servers
    end)

    if not success or type(result) ~= "table" then
        return {}
    end

    return result
end

local function serverHop()
    if not validLobbyState() then
        return
    end

    local servers = getServers()

    if #servers == 0 then
        warn("[PSH Checker] No available public servers")
        normalRejoin()
        return
    end

    queueBoot()

    local attempts = math.min(#servers, 5)

    print("[PSH Checker] Found " .. tostring(#servers) .. " available servers")

    for _ = 1, attempts do
        if not validLobbyState() then
            return
        end

        if #servers == 0 then
            break
        end

        local index = math.random(1, #servers)
        local selected = table.remove(servers, index)

        if not selected then
            continue
        end

        task.wait(0.5)

        if not validLobbyState() then
            return
        end

        Teleporting = true

        print(
            "[PSH Checker] Joining server "
            .. tostring(selected.playing)
            .. "/"
            .. tostring(selected.maxPlayers)
        )

        local success = pcall(function()
            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                selected.id,
                LocalPlayer
            )
        end)

        if success then
            return
        end

        Teleporting = false

        task.wait(2)

        if gameStarted() then
            InMatch = true
            stop("Match detected")
            return
        end
    end

    if getgenv().PSH_CheckerRunning
        and not InMatch
        and not gameStarted()
        and lobby() then

        warn("[PSH Checker] Specific server attempts failed")
        normalRejoin()
    end
end

repeat
    task.wait(0.5)
    LocalPlayer = Players.LocalPlayer
until game:IsLoaded() and LocalPlayer

if gameStarted() then
    InMatch = true
    stop("Already in-game")
    return
end

local waitForLobbyStart = os.clock()

while getgenv().PSH_CheckerRunning do
    if gameStarted() then
        InMatch = true
        stop("Match detected")
        return
    end

    if lobby() then
        break
    end

    if os.clock() - waitForLobbyStart > 30 then
        stop("Lobby not detected")
        return
    end

    task.wait(0.5)
end

if not getgenv().PSH_CheckerRunning or InMatch then
    return
end

print("[PSH Checker] Player is in lobby")
print("[PSH Checker] Checking PickHub for 1 minute...")

CheckerStart = os.clock()

while getgenv().PSH_CheckerRunning do
    if gameStarted() then
        InMatch = true
        stop("Match detected")
        return
    end

    if not lobby() then
        task.wait(0.5)

        if gameStarted() then
            InMatch = true
            stop("Match detected")
            return
        end

        if not lobby() then
            stop("Player left lobby")
            return
        end
    end

    if isPickHubRunning() then
        print("[PSH Checker] PickHub started")
        stop()
        return
    end

    if os.clock() - CheckerStart >= 60 then
        break
    end

    task.wait(1)
end

if not getgenv().PSH_CheckerRunning then
    return
end

if InMatch or gameStarted() then
    InMatch = true
    stop("Match detected")
    return
end

if not lobby() then
    stop("Player left lobby")
    return
end

print("[PSH Checker] 1 minute passed, PickHub didn't start")

task.wait(1)

if not getgenv().PSH_CheckerRunning then
    return
end

if InMatch or gameStarted() or not lobby() then
    stop("State changed before server hop")
    return
end

serverHop()
