events:on("OnClientFullConnected", function(playerid)
    LoadPlayerGroup(playerid)
end)

events:on("OnClientDisconnect", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return end

    expiretimes[tostring(player:GetSteamID())] = nil
end)