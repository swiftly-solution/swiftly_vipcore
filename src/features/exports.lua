function HasFeature(playerid, feature)
    if not featuresMap[feature] then return false end
    if playerid < 0 then return false end
    local player = GetPlayer(playerid)
    if not player then return false end
    if player:IsFakeClient() == 1 then return false end

    local group = player:vars():Get("vip.group")

    if group == "none" or group == "" or group == nil then return false end
    if not groupsMap[group] then return false end

    local vipidx = groupsMap[group]
    return (config:Exists("vips.groups["..vipidx.."].features."..feature) == 1)
end

export("HasFeature", HasFeature)

export("GetFeatureValue", function(playerid, feature)
    if not featuresMap[feature] then return 0 end
    if playerid < 0 then return 0 end
    local player = GetPlayer(playerid)
    if not player then return 0 end
    if player:IsFakeClient() == 1 then return 0 end

    local group = player:vars():Get("vip.group")

    if group == "none" or group == "" or group == nil then return 0 end
    if not groupsMap[group] then return 0 end

    local vipidx = groupsMap[group]
    if config:Exists("vips.groups["..vipidx.."].features."..feature) == 0 then return 0 end
    return config:Fetch("vips.groups["..vipidx.."].features."..feature)
end)

export("IsFeatureEnabled", function(playerid, feature)
    if not featuresMap[feature] then return false end
    if playerid < 0 then return false end
    local player = GetPlayer(playerid)
    if not player then return false end
    if player:IsFakeClient() == 1 then return false end

    local group = player:vars():Get("vip.group")

    if group == "none" or group == "" or group == nil then return false end
    if not groupsMap[group] then return false end

    local vipidx = groupsMap[group]
    if config:Exists("vips.groups["..vipidx.."].features."..feature) == 0 then return false end

    local steamid = tostring(player:GetSteamID())
    if not playerfeaturesstatus[steamid] then return false end

    return (playerfeaturesstatus[steamid][feature] == nil or playerfeaturesstatus[steamid][feature] == true)
end)

export("RegisterFeature", function(feature, feature_translations)
    if featuresMap[feature] then return end

    featuresMap[feature] = true
    table.insert(features, feature)
    featuresTranslationMap[feature] = feature_translations
end)

export("UnregisterFeature", function(feature)
    if not featuresMap[feature] then return end

    featuresMap[feature] = nil
    for k in next,features,nil do 
        if features[k] == feature then
            features[k] = nil
            break
        end
    end
    featuresTranslationMap[feature] = nil
end)