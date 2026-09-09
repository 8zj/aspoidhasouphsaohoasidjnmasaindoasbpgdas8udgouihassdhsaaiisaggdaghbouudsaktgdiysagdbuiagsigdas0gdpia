getgenv().PickHubLOL = {
    Main = {
        AutoStrat       = true,
        AutoRestart     = true,
        AutoReturnLobby = false,
        AutoSkip        = true,
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
        Enabled  = true,
        MapIndex = 1,
        VIPMap   = "",
        Mode     = "Hardcore",
        Maps     = {
            ["Wretched Front"] = {
                Loadout = { "Pyromancer", "Shotgunner" },
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Hardcore/Losingstrat1.lua",
            },
        },
        Modifiers = {},
    },
}
loadstring(game:HttpGet("http://pickscripthub.xyz/api/execute/tds-multi-map"))()
