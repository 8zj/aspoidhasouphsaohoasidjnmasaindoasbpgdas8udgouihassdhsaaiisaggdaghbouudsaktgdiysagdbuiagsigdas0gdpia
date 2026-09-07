if getgenv().PSH_CheckerRunning then
    warn("[PSH Checker] already running - skipping")
    return
end
getgenv().PSH_CheckerRunning = true

local WAIT_TIMEOUT  = 300
local POLL_INTERVAL = 10 

local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")

task.spawn(function()
    local plr = Players.LocalPlayer
    while not plr do task.wait(0.5) plr = Players.LocalPlayer end
    pcall(function()
        local GC = getconnections or get_signal_cons
        if GC then
            for _, v in pairs(GC(plr.Idled)) do
                if v.Disable then v:Disable()
                elseif v.Disconnect then v:Disconnect() end
            end
        end
    end)
    local VU = game:GetService("VirtualUser")
    while getgenv().PSH_CheckerRunning do
        task.wait(120)
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

local function pickhub_running()
    local b = getgenv().PickHubLOL_Boot
    return type(b) == "table"
        and type(b.Heartbeat) == "number"
        and (os.clock() - b.Heartbeat) < 15
end


local function queue_boot_for_next_server()
    pcall(function()
        local q = queue_on_teleport or queueonteleport or queueteleport
            or (syn and syn.queue_on_teleport)
            or (fluxus and fluxus.queue_on_teleport)
        if typeof(q) ~= "function" then return end
        local code = 'pcall(function() '
            .. 'repeat task.wait() until game:IsLoaded() '
            .. 'if isfile and isfile("PSHBoot.lua") then loadstring(readfile("PSHBoot.lua"))() end '
            .. 'end)'
        q(code)
    end)
end


local function hop_server()
    print("[PSH Checker] PickHub never started - hopping to another server...")
    queue_boot_for_next_server()

    local plr = Players.LocalPlayer
    local opts = Instance.new("TeleportOptions")
    pcall(function()
        local cfg = getgenv().PickHubLOL
        if type(cfg) == "table" then opts:SetTeleportData({ PickHubLOL = cfg }) end
    end)ce
    local hopped = pcall(function()
        local url = "https://games.roblox.com/v1/games/"
            .. game.PlaceId
            .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        local candidates = {}
        for _, s in ipairs(data.data or {}) do
            if s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 50) then
                table.insert(candidates, s.id)
            end
        end
        if #candidates == 0 then error("no other servers found") end
        local target = candidates[math.random(1, #candidates)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, plr)
    end)
    if not hopped then
        warn("[PSH Checker] server list failed - rejoining the game normally")
        pcall(function() TeleportService:Teleport(game.PlaceId, plr, opts) end)
    end
end
if not game:IsLoaded() then
    repeat task.wait(0.5) until game:IsLoaded()
end
while not Players.LocalPlayer do
    task.wait(0.5)
end

if pickhub_running() then
    print("[PSH Checker] PickHub already running - continuing")
    getgenv().PSH_CheckerRunning = false
    return
end

print("[PSH Checker] PickHub not running - waiting up to 5 minutes...")

local waited = 0
while waited < WAIT_TIMEOUT do
    task.wait(POLL_INTERVAL)
    waited += POLL_INTERVAL
    if pickhub_running() then
        print("[PSH Checker] PickHub started after "
            .. tostring(waited) .. "s - continuing")
        getgenv().PSH_CheckerRunning = false
        return
    end
end

hop_server()
