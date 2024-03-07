function LoadVipGroups()
    config:Reload("vips")
    groups = {}
    groupsMap = {}

    for i=0,config:FetchArraySize("vips.groups")-1,1 do
        local id = config:Fetch("vips.groups["..i.."].id")
        local display_name = config:Fetch("vips.groups["..i.."].display_name")
        table.insert(groups, { id = id, display_name = display_name })
        groupsMap[id] = i
    end

    print("[VIP] Loaded "..#groups.." VIP groups.")
end

function LoadPlayerGroup(playerid)
    if not db then return end
    if db:IsConnected() == 0 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    player:vars():Set("vip.group", "none")
    if player:IsFakeClient() == 1 then return end
    local steamid = tostring(player:GetSteamID())
    playerfeaturesstatus[steamid] = nil
    expiretimes[steamid] = nil

    local result = db:Query(string.format("select * from %s where steamid = '%s' limit 1", config:Fetch("vips.table_name"), steamid))
    if #result > 0 then
        local groupid = result[1].groupid
        local expiretime = result[1].expiretime
        local featurestatus = json.decode(result[1].features_status)
        if expiretime - os.time() <= 0 or not groupsMap[groupid] then
            db:Query(string.format("delete from %s where steamid = '%s' limit 1", config:Fetch("vips.table_name"), steamid))
            player:vars():Set("vip.group", "none")
            expiretimes[steamid] = nil
        else
            player:vars():Set("vip.group", groupid)
            playerfeaturesstatus[steamid] = featurestatus
            expiretimes[steamid] = expiretime
        end
    end
end

function LoadVipPlayers()
    for i=0,playermanager:GetPlayerCap()-1,1 do 
        LoadPlayerGroup(i)
    end
end