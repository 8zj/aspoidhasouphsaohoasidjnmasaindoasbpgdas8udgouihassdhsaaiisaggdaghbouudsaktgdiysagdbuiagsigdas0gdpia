getgenv().PickHubLOL = {
    Main = {
        AutoStrat       = true,
        AutoRestart     = false,
        AutoReturnLobby = true,
        AutoSkip        = false,
        SendWebhook     = false,
        TimeScale       = false,
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
            ["Farm Lands"] = {
                Loadout = {"Soldier","Shotgunner"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/NTS/Farm%20Lands.lua"
            },
            ["U-Turn"] = {
                Loadout = {"Soldier","Shotgunner"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/NTS/U-Turn.lua"
            },
            [" Necropolis"] = {
                Loadout = {"Soldier","Shotgunner"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/NTS/Necropolis"
            },
            ["Crossroads"] = {
                Loadout = {"Soldier","Shotgunner"},
                URL = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/NTS/Crossroads.lua"
            },
            ["Simplicity"] = {
                Loadout = {"Soldier","Shotgunner"},
                URL = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/NTS/Simplicity.lua"
            },
            ["Spring Fever"] = {
                Loadout = {"Soldier","Shotgunner"},
                URL = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/NTS/Spring%20Fever"
            },
            ["Night Station"] = {
                Loadout = {"Soldier","Shotgunner"},
                URL = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/NTS/Night%20Station.lua"
            },
            ["Toyboard"] = {
                Loadout = {"Soldier","Shotgunner"},
                URL = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Intermediate/NTS/Toyboard"
            },
        },
        Modifiers = {}
    },
}
loadstring(game:HttpGet("http://pickscripthub.xyz/api/execute/tds-multi-map"))()
