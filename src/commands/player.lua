commands:Register("vip", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if player:vars():Get("vip.group") == "none" or not groupsMap[player:vars():Get("vip.group")] then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_vip"), config:Fetch("vips.prefix"))) end

    local options = {
        {FetchTranslation("vips.vip_info"), "sw_vipinfo"}
    }

    for i=1,#features do
        if HasFeature(playerid, features[i]) == true then
            table.insert(options, {FetchTranslation(featuresTranslationMap[features[i]]), string.format("sw_vipopenfeaturemenu %s", features[i]) })
        end
    end

    menus:Unregister(string.format("vipmenu_%d", playerid))
    menus:Register(string.format("vipmenu_%d", playerid), FetchTranslation("vips.vip_menu"), config:Fetch("vips.color"), options)

    player:HideMenu()
    player:ShowMenu(string.format("vipmenu_%d", playerid))
end)

commands:Register("vipopenfeaturemenu", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if player:vars():Get("vip.group") == "none" or not groupsMap[player:vars():Get("vip.group")] then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_vip"), config:Fetch("vips.prefix"))) end
    local steamid = tostring(player:GetSteamID())
    if not playerfeaturesstatus[steamid] then return end

    local feature = args[1]
    if HasFeature(playerid, feature) == false then return end

    local options = {
        {string.format("%s: <font color='#%s'>%s</font>", FetchTranslation("vips.status"), playerfeaturesstatus[steamid][feature] == false and "9e1e1e" or "32a852", FetchTranslation(string.format("vips.%s", (playerfeaturesstatus[steamid][feature] == false and "disabled" or "enabled")))), ""},
        {FetchTranslation("vips.toggle_status"), "sw_viptogglestatus "..feature}
    }

    menus:Unregister("vipmenu_"..feature.."_"..playerid)
    menus:Register("vipmenu_"..feature.."_"..playerid, string.format("%s - %s", FetchTranslation("vips.vip_menu"), FetchTranslation(featuresTranslationMap[feature])), config:Fetch("vips.color"), options)
    
    player:HideMenu()
    player:ShowMenu("vipmenu_"..feature.."_"..playerid)
end)

commands:Register("viptogglestatus", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if player:vars():Get("vip.group") == "none" or not groupsMap[player:vars():Get("vip.group")] then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_vip"), config:Fetch("vips.prefix"))) end
    local steamid = tostring(player:GetSteamID())
    if not playerfeaturesstatus[steamid] then return end

    local feature = args[1]
    if HasFeature(playerid, feature) == false then return end

    if playerfeaturesstatus[steamid][feature] == nil then
        playerfeaturesstatus[steamid][feature] = true
    end

    playerfeaturesstatus[steamid][feature] = not playerfeaturesstatus[steamid][feature]
    db:Query(string.format("update %s set features_status = '%s' where steamid = '%s' limit 1", config:Fetch("vips.table_name"), json.encode(playerfeaturesstatus[steamid]), steamid))

    player:ExecuteCommand("sw_vipopenfeaturemenu "..feature)
end)

commands:Register("vipinfo", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if player:vars():Get("vip.group") == "none" or not groupsMap[player:vars():Get("vip.group")] then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_vip"), config:Fetch("vips.prefix"))) end

    local expiretime = expiretimes[tostring(player:GetSteamID())]
    
    menus:Unregister(string.format("vipmenu_info_%d", playerid))
    menus:Register(string.format("vipmenu_info_%d", playerid), FetchTranslation("vips.vip_info"), config:Fetch("vips.color"), {
        { string.format("%s: %s", FetchTranslation("vips.name"), groups[groupsMap[player:vars():Get("vip.group")] + 1].display_name), "" },
        { string.format("%s: %s", FetchTranslation("vips.expires_at"), os.date("%d/%m/%Y %H:%M:%S", expiretime + (config:Fetch("vips.timezone_offset")))), "" },
    })

    player:HideMenu()
    player:ShowMenu(string.format("vipmenu_info_%d", playerid))
end)