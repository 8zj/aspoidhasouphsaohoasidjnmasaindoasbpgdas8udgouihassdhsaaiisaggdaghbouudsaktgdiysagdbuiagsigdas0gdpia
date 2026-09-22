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
        VIPMap   = "",
        Mode      = "Easy",
        Maps      = {
            ["GrassIsle"] = {
                Loadout = {"Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/GrassIsle.lua"
            },
            ["DustyBridges"] = {
                Loadout = {"Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/DustyBridges.lua"
            },
            ["Crossroads "] = {
                Loadout = {"Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/CrossRoads.lua"
            },
            ["ConstructionCrazy"] = {
                Loadout = {"Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/ConstructionCrazy.lua"
            },
            ["AbyssalTrench"] = {
                Loadout = {"Scout"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/EasyMode/AbyssalTrench.lua"
            },
        },
        Modifiers = {}
    },
}
loadstring(game:HttpGet("http://pickscripthub.xyz/api/execute/tds-multi-map"))()
