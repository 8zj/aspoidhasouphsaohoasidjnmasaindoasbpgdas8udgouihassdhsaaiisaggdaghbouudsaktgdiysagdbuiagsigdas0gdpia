getgenv().PickHubLOL = {
    Main = {
        AutoStrat       = true,   -- run the per-map strategy macro
        AutoRestart     = false,  -- auto-restart the match after it ends
        AutoReturnLobby = true,   -- return to lobby after the match
        AutoSkip        = false,  -- auto-skip wave vote popups
        SendWebhook     = false,  -- post match results to Discord
        TimeScale       = false,      -- game speed (2 = 2x, etc.)
    },
    Mis = {
        AntiLag    = false,  -- disable effects to reduce lag
        AutoPickup = true,   -- collect SnowCharms / Lorebooks
        ANTIAFK    = true,   -- idle-kick protection
        FreeCam    = false,
    },
    Marco = {
        AutoDJ          = true,
        Autocommander   = true,  -- AutoCommands / AutoChain
        APCSpam         = true,
        AutoMercenary   = false,
        AutoMilitary    = false,
        AutoNecromancer = false,
    },
    Urls = {
        Webhook  = "",  -- Discord webhook URL (only used when SendWebhook = true)
        macroURL = "",  -- fallback macro URL (per-map URL above overrides this)
    },
    GameInfo = {
        Enabled  = true,
        MapIndex = 1,
        VIPMap   = "U-Turn",
        Mode     = "Molten",
        Maps     = {
            ["U-Turn"] = {
                Loadout = { "Minigunner", "DJ Booth","Commander","Crook Boss","Brawler"},
                URL     = "https://raw.githubusercontent.com/8zj/aspoidhasouphsaohoasidjnmasaindoasbpgdas8udgouihassdhsaaiisaggdaghbouudsaktgdiysagdbuiagsigdas0gdpia/refs/heads/main/Molten/U-Turn17m.lua",
            },
        },
        Modifiers = {},
    },
}
loadstring(game:HttpGet("http://pickscripthub.xyz/api/execute/tds-multi-map"))()
