local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L, _, ns = {}, ...
setmetatable(L, { __index = function(t, k) t[k] = k return k end })
ns.L = L

--Localization table managed via CurseForge.
--  Please feel free to suggest updates / corrections to the localizations below via 
--  http://wow.curseforge.com/addons/fishing-shack-pro/localization/
--
--  Special thanks to the following individuals for their assistance in translations / localizations:
--  German (deDE)
--  pas06: http://wow.curseforge.com/profiles/pas06/ 
--  laurenz1337: http://wow.curseforge.com/profiles/laurenz1337/

local CURRENT_LOCALE = GetLocale()
-- English (enUS)
if CURRENT_LOCALE == "enUS" then return end

-- Brazilian Portuguese (ptBR)
if CURRENT_LOCALE == "ptBR" then
--@localization(locale="ptBR", format="lua_additive_table",handle-unlocalized="english")@
end

-- French (frFR)
if CURRENT_LOCALE == "frFR" then
--@localization(locale="frFR", format="lua_additive_table",handle-unlocalized="english")@
end

-- German (deDE)
if CURRENT_LOCALE == "deDE" then
--@localization(locale="deDE", format="lua_additive_table",handle-unlocalized="english")@
end

-- Italian (itIT)
if CURRENT_LOCALE == "itIT" then
--@localization(locale="itIT", format="lua_additive_table",handle-unlocalized="english")@
end

-- Korean (koKR)
if CURRENT_LOCALE == "koKR" then
--@localization(locale="koKR", format="lua_additive_table",handle-unlocalized="english")@
end

-- Latin American Spanish (esMX)
if CURRENT_LOCALE == "esMX" then
--@localization(locale="esMX", format="lua_additive_table",handle-unlocalized="english")@
end

-- Russian (ruRU)
if CURRENT_LOCALE == "ruRU" then
--@localization(locale="ruRU", format="lua_additive_table",handle-unlocalized="english")@
end

-- Simplified Chinese (zhCN)
if CURRENT_LOCALE == "zhCN" then
--@localization(locale="zhCN", format="lua_additive_table",handle-unlocalized="english")@
end

-- Spanish (esES)
if CURRENT_LOCALE == "esES" then
--@localization(locale="esES", format="lua_additive_table",handle-unlocalized="english")@
end

-- Traditional Chinese (zhTW)
if CURRENT_LOCALE == "zhTW" then
--@localization(locale="zhTW", format="lua_additive_table",handle-unlocalized="english")@
end