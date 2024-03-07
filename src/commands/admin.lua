commands:Register("adminvip", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end

    player:HideMenu()
    player:ShowMenu("admin_vip")
end)

commands:Register("reloadvipconfig", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end

    config:Reload("vips")
    LoadVipGroups()
    LoadVipPlayers()
    player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.success_reloadconfig"), config:Fetch("vips.prefix")))
end)

commands:Register("onlinevipsmenu", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end

    local players = {}

    for i=0,playermanager:GetPlayerCap()-1,1 do 
        local pl = GetPlayer(i)
        if pl then
            if pl:IsFakeClient() == 0 and pl:vars():Get("vip.group") ~= "none" and groupsMap[pl:vars():Get("vip.group")] then
                table.insert(players, { string.format("%s (%s)", pl:GetName(), groups[groupsMap[pl:vars():Get("vip.group")] + 1].display_name), "" })
            end
        end
    end

    if #players == 0 then
        table.insert(players, { FetchTranslation("vips.no_vips"), "" })
    end

    menus:Unregister("onlinevipmenustemp_"..playerid)
    menus:Register("onlinevipmenustemp_"..playerid, FetchTranslation("vips.online_vips"), config:Fetch("vips.color"), players)

    player:HideMenu()
    player:ShowMenu("onlinevipmenustemp_"..playerid)
end)

commands:Register("vipgroupsavailablemenu", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end

    local options = {}

    for i=1,#groups do
        table.insert(options, { groups[i].display_name, "sw_openvipfeaturesadmin "..groups[i].id })
    end

    menus:Unregister("vipgroupsavailablemenu_"..playerid)
    menus:Register("vipgroupsavailablemenu_"..playerid, FetchTranslation("vips.see_vip_groups"), config:Fetch("vips.color"), options)

    player:HideMenu()
    player:ShowMenu("vipgroupsavailablemenu_"..playerid)
end)

commands:Register("openvipfeaturesadmin", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end

    local groupid = args[1]
    if not groupsMap[groupid] then return end

    local options = {}
    local groupidx = groupsMap[groupid]

    for i=1,#features do 
        if config:Exists("vips.groups["..groupidx.."].features."..features[i]) == 1 then
            table.insert(options, { FetchTranslation(featuresTranslationMap[features[i]]), "" })
        end
    end

    menus:Unregister("vipfeaturesadminmenu_"..playerid)
    menus:Register("vipfeaturesadminmenu_"..playerid, string.format("%s - %s", groups[groupidx + 1].display_name, FetchTranslation("vips.features")), config:Fetch("vips.color"), options)

    player:HideMenu()
    player:ShowMenu("vipfeaturesadminmenu_"..playerid)
end)

local AddVipMenuSelectedPlayer = {}
local AddVipMenuSelectedGroup = {}
local AddVipMenuSelectedTime = {}

commands:Register("addvipmenu", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end

    AddVipMenuSelectedPlayer[playerid] = nil
    AddVipMenuSelectedGroup[playerid] = nil
    AddVipMenuSelectedTime[playerid] = nil

    local players = {}

    for i=0,playermanager:GetPlayerCap()-1,1 do 
        local pl = GetPlayer(i)
        if pl then
            if pl:IsFakeClient() == 0 and pl:vars():Get("vip.group") == "none" then
                table.insert(players, { pl:GetName(), "sw_addvipmenu_selectplayer "..i })
            end
        end
    end

    if #players == 0 then
        table.insert(players, { FetchTranslation("vips.no_players_without_vip"), "" })
    end

    menus:Unregister("addvipmenuadmintempplayer_"..playerid)
    menus:Register("addvipmenuadmintempplayer_"..playerid, FetchTranslation("vips.add_vip"), config:Fetch("vips.color"), players)

    player:HideMenu()
    player:ShowMenu("addvipmenuadmintempplayer_"..playerid)
end)

commands:Register("addvipmenu_selectplayer", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end
    if argc == 0 then return end

    local pid = tonumber(args[1])
    if pid == nil then return end
    local pl = GetPlayer(pid)
    if not pl then return end

    AddVipMenuSelectedPlayer[playerid] = pid

    local options = {}

    for i=1,#groups do 
        table.insert(options, { groups[i].display_name, "sw_addvipmenu_selectgroup "..groups[i].id })
    end

    menus:Unregister("addvipmenuadmintempplayergroup_"..playerid)
    menus:Register("addvipmenuadmintempplayergroup_"..playerid, string.format("%s - %s", FetchTranslation("vips.add_vip"), FetchTranslation("vips.group")), config:Fetch("vips.color"), options)

    player:HideMenu()
    player:ShowMenu("addvipmenuadmintempplayergroup_"..playerid)
end)

commands:Register("addvipmenu_selectgroup", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end
    if argc == 0 then return end
    if not AddVipMenuSelectedPlayer[playerid] then return player:HideMenu() end

    local groupid = args[1]
    if not groupsMap[groupid] then return end
    AddVipMenuSelectedGroup[playerid] = groupid

    local options = {}

    for i=0,config:FetchArraySize("vips.times")-1,1 do 
        table.insert(options, { math.floor(tonumber(config:Fetch("vips.times["..i.."]"))) == 0 and "Forever" or FormatTime(tonumber(config:Fetch("vips.times["..i.."]"))), "sw_addvipmenu_selecttime "..i })
    end

    menus:Unregister("addvipmenuadmintempplayertime_"..playerid)
    menus:Register("addvipmenuadmintempplayertime_"..playerid, string.format("%s - %s", FetchTranslation("vips.add_vip"), FetchTranslation("vips.time")), config:Fetch("vips.color"), options)

    player:HideMenu()
    player:ShowMenu("addvipmenuadmintempplayertime_"..playerid)
end)

commands:Register("addvipmenu_selecttime", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end
    if argc == 0 then return end
    if not AddVipMenuSelectedPlayer[playerid] then return player:HideMenu() end
    if not AddVipMenuSelectedGroup[playerid] then return player:HideMenu() end

    local timeidx = tonumber(args[1])
    if config:Exists("vips.times["..timeidx.."]") == 0 then return end
    AddVipMenuSelectedTime[playerid] = timeidx

    local pid = AddVipMenuSelectedPlayer[playerid]
    local pl = GetPlayer(pid)
    if not pl then
        player:HideMenu()
        player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.not_connected"), config:Fetch("vips.prefix")))
        return
    end

    local options = {
        { string.format(FetchTranslation("vips.addvip_confirm"), config:Fetch("vips.color"), pl:GetName(), config:Fetch("vips.color"), groups[groupsMap[AddVipMenuSelectedGroup[playerid]] + 1].display_name, config:Fetch("vips.color"), FormatTime(tonumber(config:Fetch("vips.times["..timeidx.."]")))), "" },
        { FetchTranslation("vips.yes"), "sw_addvipmenu_confirmbox yes" },
        { FetchTranslation("vips.no"), "sw_addvipmenu_confirmbox no" }
    }

    menus:Unregister("addvipmenuadmintempplayerconfirm_"..playerid)
    menus:Register("addvipmenuadmintempplayerconfirm_"..playerid, string.format("%s - %s", FetchTranslation("vips.add_vip"), FetchTranslation("vips.confirm")), config:Fetch("vips.color"), options)

    player:HideMenu()
    player:ShowMenu("addvipmenuadmintempplayerconfirm_"..playerid)
end)

commands:Register("addvipmenu_confirmbox", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end
    if argc == 0 then return end
    if not AddVipMenuSelectedPlayer[playerid] then return player:HideMenu() end
    if not AddVipMenuSelectedGroup[playerid] then return player:HideMenu() end
    if not AddVipMenuSelectedTime[playerid] then return player:HideMenu() end

    local response = args[1]

    if response == "yes" then
        local pid = AddVipMenuSelectedPlayer[playerid]
        local pl = GetPlayer(pid)
        if not pl then
            AddVipMenuSelectedPlayer[playerid] = nil
            AddVipMenuSelectedGroup[playerid] = nil
            AddVipMenuSelectedTime[playerid] = nil
            player:HideMenu()
            player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.not_connected"), config:Fetch("vips.prefix")))
            return
        end

        server:ExecuteCommand("sw_addvip "..tostring(pl:GetSteamID()).." "..AddVipMenuSelectedGroup[playerid].." "..config:Fetch("vips.times["..AddVipMenuSelectedTime[playerid].."]"))
        player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.addvip_finish"), config:Fetch("vips.prefix"), groups[groupsMap[AddVipMenuSelectedGroup[playerid]] + 1].display_name, pl:GetName(), FormatTime(tonumber(config:Fetch("vips.times["..AddVipMenuSelectedTime[playerid].."]")))))
    end
    AddVipMenuSelectedPlayer[playerid] = nil
    AddVipMenuSelectedGroup[playerid] = nil
    AddVipMenuSelectedTime[playerid] = nil

    player:HideMenu()
end)

local RemoveVipMenuSelectPlayer = {}

commands:Register("removevipmenu", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end

    RemoveVipMenuSelectPlayer[playerid] = nil

    local players = {}

    for i=0,playermanager:GetPlayerCap()-1,1 do 
        local pl = GetPlayer(i)
        if pl then
            if pl:IsFakeClient() == 0 and pl:vars():Get("vip.group") ~= "none" and groupsMap[pl:vars():Get("vip.group")] then
                table.insert(players, { string.format("%s (%s)", pl:GetName(), groups[groupsMap[pl:vars():Get("vip.group")] + 1].display_name), "sw_removevipmenu_selectplayer "..i })
            end
        end
    end

    if #players == 0 then
        table.insert(players, { FetchTranslation("vips.no_vips"), "" })
    end

    menus:Unregister("removevipmenuadmintempplayer_"..playerid)
    menus:Register("removevipmenuadmintempplayer_"..playerid, FetchTranslation("vips.add_vip"), config:Fetch("vips.color"), players)

    player:HideMenu()
    player:ShowMenu("removevipmenuadmintempplayer_"..playerid)
end)

commands:Register("removevipmenu_selectplayer", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end
    if argc == 0 then return end

    local pid = tonumber(args[1])
    local pl = GetPlayer(pid)
    if not pl then return end
    RemoveVipMenuSelectPlayer[playerid] = pid

    local options = {
        { string.format(FetchTranslation("vips.removevip_confirm"), config:Fetch("vips.color"), pl:GetName(), config:Fetch("vips.color"), groups[groupsMap[pl:vars():Get("vip.group")] + 1].display_name), "" },
        { FetchTranslation("vips.yes"), "sw_removevipmenu_confirmbox yes" },
        { FetchTranslation("vips.no"), "sw_removevipmenu_confirmbox no" }
    }

    menus:Unregister("removevipmenuadmintempplayerconfirm_"..playerid)
    menus:Register("removevipmenuadmintempplayerconfirm_"..playerid, string.format("%s - %s", FetchTranslation("vips.remove_vip"), FetchTranslation("vips.confirm")), config:Fetch("vips.color"), options)

    player:HideMenu()
    player:ShowMenu("removevipmenuadmintempplayerconfirm_"..playerid)
end)

commands:Register("removevipmenu_confirmbox", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() == 1 then return end
    if exports["swiftly_admins"]:CallExport("HasFlags", playerid, config:Fetch("vips.manage_vip_flags")) == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.no_access"), config:Fetch("vips.prefix"))) end
    if argc == 0 then return end
    if not RemoveVipMenuSelectPlayer[playerid] then return end

    local answer = args[1]

    if answer == "yes" then
        local pid = RemoveVipMenuSelectPlayer[playerid]
        local pl = GetPlayer(pid)
        if not pl then
            player:HideMenu()
            player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.not_connected"), config:Fetch("vips.prefix")))
            RemoveVipMenuSelectPlayer[playerid] = nil
            return
        end
        server:ExecuteCommand(string.format("sw_removevip %s", tostring(pl:GetSteamID())))
        player:SendMsg(MessageType.Chat, string.format(FetchTranslation("vips.removevip_finish"), config:Fetch("vips.prefix"), pl:GetName()))
    end
    RemoveVipMenuSelectPlayer[playerid] = nil
    player:HideMenu()
end)