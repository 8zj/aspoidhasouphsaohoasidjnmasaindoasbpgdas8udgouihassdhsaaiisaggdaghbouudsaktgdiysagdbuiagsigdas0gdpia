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
        Mode      = "Easy",
        Maps      = {
            ["U-Turn"] = {
                Loadout = {"Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/map1.lua"
            },
            ["Grass Isle"] = {
                Loadout = {"Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/map2.lua"
            },
            ["Crossroads"] = {
                Loadout = {"Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/map3.lua"
            },
            ["Simplicity"] = {
                loadout = {"Scout"},
                URL = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/map4.lua"
            },
            ["Forest Camp"] = {
                loadout = {"Scout"},
                URL = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/map5.lua"
            },
        },
        Modifiers = {}
    },
}
loadstring(game:HttpGet("http://pickscripthub.xyz/api/execute/tds-multi-map"))()
