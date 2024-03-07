events:on("OnPluginStart", function()
    db = Database("swiftly_vipcore")
    if db:IsConnected() == 0 then return end

    db:Query(string.format("CREATE TABLE IF NOT EXISTS %s (`steamid` VARCHAR(64) NOT NULL, `groupid` TEXT NOT NULL, `expiretime` INT NOT NULL, `features_status` JSON NOT NULL DEFAULT '{}', UNIQUE (`steamid`)) ENGINE = InnoDB; ", config:Fetch("vips.table_name")))

    LoadVipGroups()
    LoadVipPlayers()
    GenerateMenu()
end)

function GetPluginAuthor()
    return "Swiftly Solutions"
end

function GetPluginVersion()
    return "1.0.0"
end

function GetPluginName()
    return "[VIP] Core"
end

function GetPluginWebsite()
    return "https://github.com/swiftly-solution/swiftly_vipcore"
end