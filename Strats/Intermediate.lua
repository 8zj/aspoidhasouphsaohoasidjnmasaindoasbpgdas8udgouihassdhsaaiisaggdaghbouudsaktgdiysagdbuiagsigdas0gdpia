getgenv().PickHubLOL = {
    Main = {
        AutoStrat       = true,
        AutoRestart     = false,
        AutoReturnLobby = true,
        AutoSkip        = false,
        SendWebhook     = false,
        TimeScale       = 2,
    },
    Mis = {
        AntiLag    = false,
        AutoPickup = true,
        ANTIAFK    = true,
        FreeCam    = false,
    },
    Marco = {
        AutoDJ          = false,
        Autocommander   = false,
        APCSpam         = false,
        AutoMercenary   = false,
        AutoMilitary    = false,
        AutoNecromancer = false,
    },
    Urls = {
        Webhook  = "",
        macroURL = "",
    },
    GameInfo = {
        Enabled   = true,
        MapIndex  = 1,
        Mode      = "Intermediate",
        Maps      = {
            ["Cataclysm"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/Cataclysm.lua"
            },
            ["Retro Crossroads"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/Crossroads.lua"
            },
            ["Farm Lands"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/FarmLands.lua"
            },
            ["Simplicity"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/Simplicity.lua"
            },
            ["U-Turn"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/U-Turn.lua"
            },
            ["Night Station"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/Night-Station.lua"
            },
            ["Summer Castle"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/Summer%20Castle.lua"
            },
            ["Sugar Rush"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/Sugar%20Rush.lua"
            },
            ["Wrecked Battlefield"] = {
                Loadout = {"Soldier","Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/Wrecked%20Battlefield.lua"
            },
        },
        Modifiers = {}
    },
}

local LOADER_URL = "http://pickscripthub.xyz/api/execute/tds-multi-map"
if getgenv().PSH_BootWatchdog then
    warn("[PSH Boot] Watchdog already running - skipping")
    return
end
getgenv().PSH_BootWatchdog = true
task.spawn(function()
    if not game:IsLoaded() then
        repeat task.wait(0.5) until game:IsLoaded()
    end

    local function is_running()
        local b = getgenv().PickHubLOL_Boot
        return type(b) == "table"
            and type(b.Heartbeat) == "number"
            and (os.clock() - b.Heartbeat) < 15
    end

    local monitored = true
    local function boot_once()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(LOADER_URL))()
        end)
        if not ok then
            warn("[PSH Boot] loader failed: " .. tostring(err))
            return false
        end
        local deadline = os.clock() + 15
        while os.clock() < deadline do
            if is_running() then
                print("[PSH Boot] script is running (exec #" .. tostring(getgenv().PickHubLOL_Boot.ExecCount) .. ")")
                return true
            end
            task.wait(1)
        end
        if shared and shared.AutoStratGUI then
            warn("[PSH Boot] old MultiLoader detected - started, but death monitoring is unavailable")
            monitored = false
            return true
        end
        warn("[PSH Boot] script did not start")
        return false
    end
    local started = false
    for attempt = 1, 10 do
        if is_running() then started = true break end
        if boot_once() then started = true break end
        warn("[PSH Boot] retrying (" .. attempt .. "/10)...")
        task.wait(3)
    end
    if not started then
        warn("[PSH Boot] could not start the script after 10 attempts - check your loader URL")
        getgenv().PSH_BootWatchdog = false
        return
    end
    while true do
        task.wait(5)
        if monitored and not is_running() then
            warn("[PSH Boot] script died - rebooting...")
            for attempt = 1, 3 do
                if boot_once() then break end
                task.wait(3)
            end
        end
    end
end)
