--[[
    Author: MadDog (steam id md-maddog)

    TODO: finish removing unneeded stuff for spacebuild
]]
local function removeOldTabls()
     for k, v in pairs( g_SpawnMenu.CreateMenu.Items ) do
        if (v.Tab:GetText() == language.GetPhrase("spawnmenu.category.npcs") or
            --v.Tab:GetText() == language.GetPhrase("spawnmenu.category.entities") or
            --v.Tab:GetText() == language.GetPhrase("spawnmenu.category.weapons") or
            --v.Tab:GetText() == language.GetPhrase("spawnmenu.category.vehicles") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.postprocess") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.dupes") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.saves")) then
            g_SpawnMenu.CreateMenu:CloseTab( v.Tab, true )
            removeOldTabls()
        end
    end
end
hook.Add("SpawnMenuOpen", "blockmenutabs", removeOldTabls)