local players, toRemove = {}, {}

local snippet = {
    time = 5,
    delay = 900,
    xml = [[<C><P MEDATA=";0,1;;;-0;0:::1-"/><Z><S><S T="0" X="408" Y="320" L="663" H="10" P="0,0,0.3,0.2,0,0,0,0"/></S><D><DS X="365" Y="303"/></D><O/><L/></Z></C>]]
}

local keys = {
    left = 0,
    right = 2,
    duck = 3,
    shift = 16,
    space = 32,
}

local enums = {
    left = 1,
    right = 2,
}

local keyboardFunctions = {}

keyboardFunctions[0] = function(player)
    players[player].directions = enums.left
end

keyboardFunctions[2] = function(player)
    players[player].directions = enums.right
end

keyboardFunctions[3] = function(player, x, y)
    local user = players[player]
    local isFacingRight = user.directions and user.directions == enums.right

    if not user.currentTime then 
        user.currentTime = os.time()
    end

    if user and user.currentTime <= os.time() then
        toRemove[#toRemove + 1] = {
            id = tfm.exec.addShamanObject(17,(isFacingRight and x + 30) or x - 30, y + 20, (isFacingRight and 90) or -90, nil, nil, false),
            time = os.time() 
        }

        user.currentTime = os.time() + snippet.delay
    end
end

keyboardFunctions[32] = function(player, x, y)
    tfm.exec.movePlayer(player,0,0,true,0,-50,false)
end

function bindKeys(player, boolean)
    for _, key in pairs(keys) do
        system.bindKeyboard(player, key, true, boolean)
    end
end

function bindDirections(player, boolean)
    if boolean then 
        if not players[player] then 
            players[player] = {} 
        end

        players[player].directions = enums.right
    end
end

function eventNewGame()
    local mapInfo = tfm.get.room.xmlMapInfo
    local isModuleRoom = mapInfo and mapInfo.xml == snippet.xml
    
    if isModuleRoom then
        tfm.exec.setGameTime(snippet.time * 60, true)
    end
    
    for player in next, tfm.get.room.playerList do
        bindKeys(player, isModuleRoom)
        bindDirections(player, isModuleRoom)
    end
end

function eventKeyboard(player, key, down, x, y)
    if keyboardFunctions[key] then
        keyboardFunctions[key](player, x, y)
    end
end

function eventLoop(time, n)
    for i, object in ipairs(toRemove) do
        if object.time <= os.time() - 500 then
            tfm.exec.removeObject(object.id)
            toRemove[i] = nil

            break
        end
    end
end

tfm.exec.disableAutoScore(true)
tfm.exec.disablePhysicalConsumables(true)

tfm.exec.newGame(snippet.xml)
