keys = {
    -- Letters
    ["A"] = 0x7065027D,["B"] = 0x4CC0E2FE,["C"] = 0x9959A6F0,["D"] = 0xB4E465B4,["E"] = 0xCEFD9220,["F"] = 0xB2F377E8,["G"] = 0x760A9C6F,
    ["H"] = 0x24978A28,["I"] = 0xC1989F95,["J"] = 0xF3830D8E,["L"] = 0x80F28E95,["M"] = 0xE31C6A41,["N"] = 0x4BC9DABB,["O"] = 0xF1301666,
    ["P"] = 0xD82E0BD2,["Q"] = 0xDE794E3E,["R"] = 0xE30CD707,["S"] = 0xD27782E3,["U"] = 0xD8F73058,["V"] = 0x7F8D09B8,["W"] = 0x8FD015D8,
    ["X"] = 0x8CC9CD42,["Z"] = 0x26E9DC00,["RIGHTBRACKET"] = 0xA5BDCD3C,["LEFTBRACKET"] = 0x430593AA,["MOUSE1"] = 0x07CE1E61,
    ["MOUSE2"] = 0xF84FA74F,["MOUSE3"] = 0xCEE12B50,["MWUP"] = 0x3076E97C,["CTRL"] = 0xDB096B85,["SPACEBAR"] = 0xD9D0E1C0,["TAB"] = 0xB238FE0B,
    ["SHIFT"] = 0x8FFC75D6,["ENTER"] = 0xC7B5340A,["BACKSPACE"] = 0x156F7119,["LALT"] = 0x8AAA0AD4,["DEL"] = 0x4AF4D473,["PGUP"] = 0x446258B6,
    ["PGDN"] = 0x3C3DD371,["F1"] = 0xA8E3F467,["F4"] = 0x1F6D95E5,["F6"] = 0x3C0A40F2,["1"] = 0xE6F612E4,["2"] = 0x1CE6D9EB,["3"] = 0x4F49CC4C,
    ["4"] = 0x8F9F9E58,["5"] = 0xAB62E997,["6"] = 0xA1FDE2A6,["7"] = 0xB03A913B,["8"] = 0x42385422,["DOWN"] = 0x05CA7C52,["UP"] = 0x6319DB71,
    ["LEFT"] = 0xA65EBAB4,["RIGHT"] = 0xDEB34313
}

isFarmer = false
totalGathered = 0
locationsSet = false
gatherBlips = {}
active = false
PickPrompt = nil

--=============================================--
--   DRAW BLIPS AND TEXT FOR START LOCATIONS   --
--=============================================--
Citizen.CreateThread(function()
    Citizen.Wait(0)

    for k,v in pairs(Config.startLocations) do
        local blip = N_0x554d9d53f696d002(1664425300, v.x, v.y, v.z)
        SetBlipSprite(blip, 0x3C5469D5, 1)
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Farm Work')
    end

    while true do
        Citizen.Wait(0)
        player = PlayerPedId()
        coords = GetEntityCoords(player)
        for k,v in pairs(Config.startLocations) do
            local dist = GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true)
            if dist <= Config.drawDistance then
                if IsDisabledControlJustReleased(0, keys['E']) and IsInputDisabled(0) then
                    toggleWork()
                end
                if isFarmer == false then
                    DrawText3D(v.x, v.y, v.z+0.2, Config.startText)
                else
                    DrawText3D(v.x, v.y, v.z+0.2, Config.stopText)
                end
            end
        end
    end

end)

--=============================--
-- DRAW FARMING LOCATION BLIPS --
--=============================--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if isFarmer == true and locationsSet == false then
            TriggerEvent('farmwork:setBlips')
        elseif isFarmer == false and locationsSet == true then
            TriggerEvent('farmwork:removeBlips')
        end
    end
end)

--=============================--
--         MAIN THREAD         --
--=============================--
Citizen.CreateThread(function()
    
    while true do
        Citizen.Wait(0)
        if isFarmer == true then 
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            for k,v in pairs(Config.gatherLocations) do
                local dist = GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true)
                if dist <= 3.0 then
                    DrawTxt('Press [E] to begin farming', 0.50, 0.90, 0.7, 0.7, true, 255, 255, 255, 255, true)
                end
            end
        end
    end
end)

--============================--
--          FUNCTIONS         --
--============================--
RegisterNetEvent('farmwork:setBlips')
AddEventHandler('farmwork:setBlips', function()
    for k,v in pairs(Config.gatherLocations) do
        gatherblip = N_0x554d9d53f696d002(1664425300, v.x, v.y, v.z)
        SetBlipSprite(gatherblip, 0xDDFBA6AB, 1)
        SetBlipScale(gatherblip, 0.07)
        Citizen.InvokeNative(0x9CB1A1623062F402, gatherblip, 'Farming Spot')
        table.insert(gatherBlips, gatherblip)
    end
    locationsSet = true
end)

RegisterNetEvent('farmwork:removeBlips')
AddEventHandler('farmwork:removeBlips', function()
    for i = 1, #gatherBlips, 1 do
        RemoveBlip(gatherBlips[i])
        gatherBlips[i] = nil
    end
    locationsSet = false
end)

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
    local factor = (string.len(text)) / 150
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 100, 1, 1, 190, 0)
end

function toggleWork()
    isFarmer = not isFarmer
    if isFarmer == true then
        TriggerEvent("redemrp_notification:start", "You have started working. Check your map for farming locations", 2, "success")
    else
        TriggerEvent("redemrp_notification:start", "You have finished your work", 2, "error")
    end
end