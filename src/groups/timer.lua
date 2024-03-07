timers:create(10000, function()
    for i=0,playermanager:GetPlayerCap()-1,1 do 
        local player = GetPlayer(i)
        if player then
            if player:IsFakeClient() == 0 then
                local expiretime = expiretimes[tostring(player:GetSteamID())]
                local group = player:vars():Get("vip.group")
                if (expiretime or os.time()) - os.time() < 0 or not groupsMap[group] then
                    db:Query(string.format("delete from %s where steamid = '%s' limit 1", config:Fetch("vips.table_name"), tostring(player:GetSteamID())))
                    player:vars():Set("vip.group", "none")
                    expiretimes[tostring(player:GetSteamID())] = nil
                end
            end
        end
    end
end)