function FormatTime(seconds)
    if seconds == 0 then return FetchTranslation("vips.never")
    elseif seconds < 60 then return string.format(FetchTranslation("vips.seconds"), seconds)
    elseif seconds < 3600 then return string.format(FetchTranslation("vips.minutes"), math.floor(seconds / 60))
    elseif seconds < 86400 then return string.format(FetchTranslation("vips.hours"), math.floor(seconds / 3600))
    else return string.format(FetchTranslation("vips.days"), math.floor(seconds / 86400)) end
end
