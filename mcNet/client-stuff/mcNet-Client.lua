----------------------configurations----------------------

-- if this is true will show more in depth system out puts where ever i need them! (disclaimer: will not be pretty to look at!)
local debugMode = false --default: false
-- this is the minimum time that as to elapse between page loop begin and end iff it goes beneath that a time out will be set
local minElapsedTime = 0.5 --default: 0.5
--this is the length of the timeout mentioned above
local errTimeout = 2 --default: 2
--this is the time that a disconnect function is allowed to run for in seconds can't be lower than 60
local disconnectTime = 600 --default: 600

----------------------------------------------------------


local path = shell.getRunningProgram()
local pathDiv = string.find(path,"/",nil,true)
path = string.sub(path,1,pathDiv)

if disconnectTime < 60 then disconnectTime = 60 end

term.write("path root: ")
print(path)
if debugMode then sleep(1) end

fs.makeDir(path.."pages")
fs.makeDir(path.."libs")

os.loadAPI(path.."libs/openUILib.lua")

local function consolePrintLine(self, line)
    -- Put the line on the screen at current cursorY
    for i = 1, #line do
        local char = line:sub(i,i)
        self.screen[i][self.cursorY] = {
            char,
            self.currentTextColor,
            self.currentBackgroundColor
        }
    end
    return true
end

Stack = {}
Stack.__index = Stack

function Stack:init()
    local stackObj = {}

    stackObj.list = {}

    setmetatable(stackObj,self)
    self.__index = self
    return stackObj
end

function Stack:pop()
    local val = self.list[#self.list]

    table.remove(self.list,#self.list)

    return val
end

function Stack:push(val)
    self.list[#self.list+1] = val
end

function Stack:peak()
    return self.list[#self.list]
end

function Stack:size()
    return #self.list
end

function Stack:clear()
    self.list = {}
end

_G.Console = {}
_G.Console.__index = _G.Console

function _G.Console:init(x,y,width,height)
    x = x or 1
    y = y or 2
    local termX, termY = term.getSize()
    width = width or termX-(x-1)
    height = height or termY-(y-1)

    local obj={}
    obj.screen={}
    for i=1,width do
        obj.screen[i]={}
        for j=1,height+1 do
            obj.screen[i][j] = {}
            obj.screen[i][j][1] = nil
            obj.screen[i][j][2] = colors.white
            obj.screen[i][j][3] = colors.black
        end
    end

    obj.X = x-1
    obj.Y = y-1

    obj.cursorX = 1
    obj.cursorY = 1
    obj.currentTextColor = colors.white
    obj.currentBackgroundColor = colors.black

    setmetatable(obj,self)
    self.__index = self

    return obj
end

function _G.Console:display()
    local currentTextColor = term.getTextColor()
    local currentBackgroundColor = term.getBackgroundColor()
    for i=1,#self.screen do
        for j=1,#self.screen[i] do
            if self.screen[i][j][1] then
                term.setCursorPos(self.X+i,self.Y+j)
                term.setTextColor(self.screen[i][j][2])
                term.setBackgroundColor(self.screen[i][j][3])
                term.write(self.screen[i][j][1])
            end
        end
    end
    term.setTextColor(currentTextColor)
    term.setBackgroundColor(currentBackgroundColor)
end

function _G.Console:setCursorPos(x,y)
    x = x or 1
    y = y or 1

    self.cursorX = x
    self.cursorY = y
end

function _G.Console:getCursorPos()
    return self.cursorX ,self.cursorY
end

function _G.Console:setTextColor(color,posX,posY)
    if posX then
        for i=1,#self.screen[posX] do
            for _=1,#self.screen[posX][i] do
                self.screen[posX][i][2] = color
            end
        end
    elseif posY then
        for i=1,#self.screen do
            for _=1,#self.screen[i][posY] do
                self.screen[i][posY][2] = color
            end
        end
    elseif posX and posY then
        self.screen[posX][posY][2] = color
    else
        self.currentTextColor = color
    end
end

function _G.Console:setBackgroundColor(color,posX,posY)
    if posX then
        for i=1,#self.screen[posX] do
            if self.screen[posX][i] then
                for _=1,#self.screen[posX][i] do
                        self.screen[posX][i][3] = color
                end
            end
        end
    elseif posY then
        for i=1,#self.screen do
            if self.screen[i][posY] then
                for _=1,#self.screen[i][posY] do
                    self.screen[i][posY][3] = color
                end
            end
        end
    elseif posX and posY then
        if self.screen[posX] then
            if self.screen[posX][posY] then
                self.screen[posX][posY][3] = color
            end
        end
    else
        self.currentBackgroundColor = color
    end
end

function _G.Console:getTextColor()
    return self.currentTextColor
end

function _G.Console:getBackgroundColor()
    return self.currentBackgroundColor
end

function _G.Console:scroll(n)
    n = n or 1
    n = math.abs(n)
    for _ = 1,n do
        for i = 1,#self.screen do
            for j = 1,#self.screen[i] do
                if self.screen[i][j-1] then
                    self.screen[i][j-1] = self.screen[i][j]
                end
            end
        end
        for i=1,#self.screen do
            self.screen[i][#self.screen[i]] = {nil,self.currentTextColor,self.currentBackgroundColor}
        end
    end
end

function _G.Console:write(str)
    str = tostring(str)
    local moveX = 0
    for i=1,#str do
        if self.screen[(self.cursorX-1)+i] then
            if self.screen[(self.cursorX-1)+i][self.cursorY] then
                self.screen[(self.cursorX-1)+i][self.cursorY][1] = str:sub(i,i)
                self.screen[(self.cursorX-1)+i][self.cursorY][2] = self.currentTextColor
                self.screen[(self.cursorX-1)+i][self.cursorY][3] = self.currentBackgroundColor
                moveX = moveX + 1
            end
        end
    end
    self.cursorX = self.cursorX + moveX
    self:display()
end

function _G.Console:print(str)
    str = tostring(str)
    local line = ""
    for word in str:gmatch("%S+%s*") do
        if #line + #word > #self.screen then
            consolePrintLine(self, line)
            self.cursorY = self.cursorY + 1
            if self.cursorY > #self.screen[1] then
                self:scroll()
                self.cursorY = #self.screen[1]
            end
            line = word
        else
            line = line .. word
        end
    end

    if #line > 0 then
        consolePrintLine(self, line)
        self.cursorY = self.cursorY + 1
        if self.cursorY > #self.screen[1] then
            self:scroll()
            self.cursorY = #self.screen[1]
        end
    end

    self:display()
end

function _G.Console:clear(posX,posY)
    if posX then
        for i=1,#self.screen[posX] do
            if self.screen[posX] then
                for _=1,#self.screen[posX][i] do
                    self.screen[posX][i][1] = nil
                    self.screen[posX][i][2] = self.currentTextColor
                    self.screen[posX][i][3] = self.currentBackgroundColor
                end
            end
        end
    elseif posY then
        for i=1,#self.screen do
            for _=1,#self.screen[i][posY] do
                if self.screen[i][posY] then
                    self.screen[i][posY][1] = nil
                    self.screen[i][posY][2] = self.currentTextColor
                    self.screen[i][posY][3] = self.currentBackgroundColor
                end
            end
        end
    elseif posX and posY then
        if self.screen[posX] then
            if self.screen[posX][posY] then
                self.screen[posX][posY][1] = nil
                self.screen[posX][posY][2] = self.currentTextColor
                self.screen[posX][posY][3] = self.currentBackgroundColor
            end
        end
    else
        local currentTextColor = term.getTextColor()
        local currentBackgroundColor = term.getBackgroundColor()
        term.setTextColor(self.currentTextColor)
        term.setBackgroundColor(self.currentBackgroundColor)
        for i=1,#self.screen do
            for j=1,#self.screen[i] do
                self.screen[i][j][1] = nil
                self.screen[i][j][2] = self.currentTextColor
                self.screen[i][j][3] = self.currentBackgroundColor
            end
        end
        self.cursorX = 1
        self.cursorY = 1
        term.setTextColor(currentTextColor)
        term.setBackgroundColor(currentBackgroundColor)
    end
    self:display()
end

term.clear()

sleep(0.5)

local function findCenter(len1,len2)
    local sizeX,_ = term.getSize()
    len1 = len1 or sizeX
    len2 = len2 or 0

    return math.floor((len1-len2)/2)
end

local colorTable = {
    colors.white, colors.orange, colors.magenta, colors.lightBlue,
    colors.yellow, colors.lime, colors.pink, colors.gray,
    colors.lightGray, colors.cyan, colors.purple, colors.blue,
    colors.brown, colors.green, colors.red, colors.black,
}
local colorList={}

local function gatherColorValues()
    local r, g, b
    for i = 1,#colorTable do
        if monitor then
            r,g,b = monitor.getPaletteColor(colorTable[i])
        else
            r,g,b = term.getPaletteColor(colorTable[i])
        end

        table.insert(colorList,{r,g,b})
    end
end

local function useColorValues()
    for i =1,#colorList do
        if monitor then
            monitor.setPaletteColor(colorTable[i],colorList[i][1],colorList[i][2],colorList[i][3])
        else
            term.setPaletteColor(colorTable[i],colorList[i][1],colorList[i][2],colorList[i][3])
        end
    end
end

local function receive(timeout)
    local senderID,message = rednet.receive(timeout)
    if type(message) ~= "table" then message = {} end

    return senderID,message
end

local function printDebug(str,clear)
    if debugMode then
        local currentTextColor = term.getTextColor()
        local currentBackgroundColor = term.getBackgroundColor()
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        if clear then
            term.clear()
            term.setCursorPos(1,1)
        end
        print(str)
        sleep(0.5)
        term.setTextColor(currentTextColor)
        term.setBackgroundColor(currentBackgroundColor)
    end 
end

gatherColorValues()

local sizeX,sizeY = term.getSize()

openUILib.init("mcNet")
_G.systemOut = Console:init()
local pageStack = Stack:init()
local backPageStack = Stack:init()

printDebug("initiating start UI...",true)
openUILib.setPaletteColor(colors.gray,"#444444")
openUILib.setPaletteColor(colors.lightGray,"#333333")
openUILib.setPaletteColor(colors.white,"#ffffff")

local defaultBackground = {}
for i=0,sizeX do
    defaultBackground[i]={}
    for j=0,sizeY do
        defaultBackground[i][j] = colors.gray
    end
end
local startPageImage = openUILib.loadImage(path.."libs/logo.nfp")

local searchBarYPos = findCenter(sizeY,1)
if searchBarYPos < 8 then
    searchBarYPos = 8
end

local startSprite = openUILib.sprite:addSprite(startPageImage,nil,findCenter(nil,22),2)
local searchBar = openUILib.hologram:addHologram("Loading...",{white=1},{lightGray=1},nil,findCenter(nil,10),searchBarYPos)

openUILib.setBackgroundImage(defaultBackground)
openUILib.render()

local active = true

peripheral.find("modem",function (name,_)
    if peripheral.call(name,"isWireless") then
        modemSide = name
    end
end)
if not modemSide then error("could not find ender modem please in stall one!") end

rednet.open(modemSide)

local dnsServers,answer = {}, true
while #dnsServers == 0 and answer do
    dnsServers = {rednet.lookup("DNSServer")}

    if #dnsServers == 0 then
        searchBar:changeHologramData(nil,nil,nil,findCenter(nil,24))
        answer = searchBar:read(2,"no dns try again? y/n:")

        if string.find(answer,"y",nil,true) then
            answer = true
        else
            answer = false
        end
        searchBar:changeHologramData("loading...",nil,nil,findCenter(nil,10))
        openUILib.render()
    end
end
printDebug("dns servers found: "..#dnsServers,true)
printDebug("server list:")
printDebug(textutils.serialise(dnsServers,{compact = true}))

searchBar:changeHologramData(nil,nil,nil,2)

local function findAddress(search)
    for _,DNSServerIP in pairs(dnsServers) do
        printDebug("calling DNS IP: "..DNSServerIP)
        rednet.send(DNSServerIP,{message="get server ip",serverName=search})
        local _, replie = rednet.receive(2)
        if not  replie then printDebug("2 seconds elapsed did not get response! (timeout error)") replie={} end
        if type(replie.message) == "number" then
            printDebug("found! IP: "..replie.message)
            return replie.message
        end
    end
end

local function searchForAddress()
    startSprite:changeSpriteData(startPageImage)
    openUILib.setBackgroundImage(defaultBackground)
    openUILib.render()

    local search = searchBar:read(sizeX-10,"Address:")

    return search
end

local activeLibs={}

local function downloadLibs(libList)
    if not libList then return end

    for i=1,#libList[1] do
        if libList[1][i] ~= "libs/openUILib.lua" then
            printDebug("importing: "..libList[1][i])
            if debugMode then print("lib content:") end
            printDebug(libList[2][i])

            table.insert(activeLibs,path..libList[1][i])

            local temp = io.open(path..libList[1][i],"w")
            temp:write(libList[2][i])
            temp:close()
        end
    end
end

local function unloadLibs()
    for i=1,#activeLibs do
        local libPath = string.gsub(activeLibs[i],".lua","")
        local lasLibPathDiv = 0
        while string.find(libPath,"/",lasLibPathDiv+1,true) do
            local libPathDiv = string.find(libPath,"/",lasLibPathDiv+1,true)
            if libPathDiv then lasLibPathDiv = libPathDiv end
        end
        local libName = string.sub(libPath,lasLibPathDiv+1,#libPath)
        printDebug("unloading: "..libName)

        _G[libName] = nil
        fs.delete(activeLibs[i])
        table.remove(activeLibs,i)
    end
end

local function hud(homeButton,backButton,reloadButton,exitButton)
    local output = nil
    while output == nil do
        openUILib.render()
        if currentPage.hubUsed then
            parallel.waitForAny(function() currentPage.hubUsed(path) end,function() sleep(disconnectTime) end)
        end
        local _,_,x,y = os.pullEvent("mouse_click")
        if openUILib.isCollidingRaw(x,y,homeButton) then
            output = "home"
        elseif openUILib.isCollidingRaw(x,y,backButton) then
            output = "back"
        elseif openUILib.isCollidingRaw(x,y,reloadButton) then
            output = "reload"
        elseif openUILib.isCollidingRaw(x,y,exitButton) then
            output = "exit"
        end
        sleep(0.2)
    end

    return output
end

local function initHudButtons()
    openUILib.hologram:addHologram(string.rep(" ",sizeX),nil,{lightGray=1},nil,1,1,nil,false)
    local debugText
    if debugMode then debugText = openUILib.hologram:addHologram("Measuring...",{white=1},{lightGray=1},nil,7,1) end

    local homeButton = openUILib.hologram:addHologram("H",{black=1},{white=1},nil,1,1)
    local backButton = openUILib.hologram:addHologram("\027",{black=1},{white=1},nil,3,1)
    local reloadButton = openUILib.hologram:addHologram("@",{black=1},{white=1},nil,5,1)
    local exitButton = openUILib.hologram:addHologram("x",{red=1},{white=1},nil,sizeX,1)

    return debugText, homeButton, backButton, reloadButton, exitButton
end

local function talkWithServer(serverIP)
    rednet.send(serverIP,{message="connection test"})
    _,message = receive(2)
    printDebug("received:"..textutils.serialise(message,{compact=true}))
    if message.content then
        printDebug("success!")
        pageStack:push("connection test")

        openUILib.clearFrameWork()
        openUILib.setBackgroundImage({{}})

        local debugText, homeButton, backButton, reloadButton, exitButton = initHudButtons()

        downloadLibs(message.libs)

        local temp = io.open(path.."pages/currentPage.lua","w")
        temp:write(message.content)
        temp:close()

        os.loadAPI(path.."pages/currentPage.lua")

        currentPage.init(path)

        local repeatLoop = true
        local output,additionalReturnValue, elapsedTime1,elapsedTime2,elapsedTimeDifference, preElapsedTimeDifference


        while repeatLoop do

            parallel.waitForAny(function() output = hud(homeButton,backButton,reloadButton,exitButton) end ,function()
                elapsedTime1 = os.clock()
                output,additionalReturnValue = currentPage.main(path)
                elapsedTime2 = os.clock()
                elapsedTimeDifference = elapsedTime2 - elapsedTime1
                if debugMode and elapsedTimeDifference ~= preElapsedTimeDifference then
                    local timeStr = tostring(elapsedTimeDifference)
                    if #timeStr > (sizeX-2) then
                        timeStr = timeStr:sub(1, sizeX-5) .. "..."
                    end
                    debugText:changeHologramData("TLap:" .. timeStr .. "s")
                    debugText:render()
                end
                if elapsedTimeDifference < minElapsedTime then
                    local currentTextColor = systemOut:getTextColor()
                    local currentX, currentY = systemOut:getCursorPos()

                    systemOut:setCursorPos(1, 1)
                    systemOut:setTextColor(colors.red)
                    systemOut:print("ERR: Code executes too fast! timeout for "..errTimeout.." second(s)...")
                    systemOut:setCursorPos(currentX, currentY)
                    systemOut:setTextColor(currentTextColor)

                    sleep(errTimeout)
                else
                    preElapsedTimeDifference = elapsedTimeDifference
                end
            end)

            if output == 2 then
                if debugMode then term.clear() term.setCursorPos(1,1) print("loading new page") sleep(0.5) end
                rednet.send(serverIP,{message = additionalReturnValue})
                _,message = receive(2)
                printDebug("received:"..textutils.serialise(message,{compact=true})) sleep(0.5)
                if message.content ~= nil then
                    printDebug("success!")
                    _G.currentPage = nil
                    unloadLibs()
                    openUILib.clearFrameWork()

                    debugText, homeButton, backButton, reloadButton, exitButton = initHudButtons() -- re add hud buttons

                    pageStack:push(additionalReturnValue)

                    systemOut:setTextColor(colors.white)
                    systemOut:setBackgroundColor(colors.black)
                    systemOut:clear()

                    downloadLibs(message.libs)

                    local temp = io.open(path.."pages/currentPage.lua","w")
                    temp:write(message.content)
                    temp:close()

                    os.loadAPI(path.."pages/currentPage.lua")
                    currentPage.init(path)
                end
            elseif output == "back" or output == -1 then
                printDebug("back",true)
                if pageStack:size() > 1 then
                    rednet.send(serverIP,{message = pageStack:peak()})
                    _,message = receive(2)
                    printDebug("received:"..textutils.serialise(message,{compact=true}))
                    if message.content ~= nil then
                        printDebug("success!")
                        _G.currentPage = nil
                        unloadLibs()
                        openUILib.clearFrameWork()

                        debugText, homeButton, backButton, reloadButton, exitButton = initHudButtons()

                        pageStack:pop()

                        systemOut:setTextColor(colors.white)
                        systemOut:setBackgroundColor(colors.black)
                        systemOut:clear()

                        downloadLibs(message.libs)

                        local temp = io.open(path.."pages/currentPage.lua","w")
                        temp:write(message.content)
                        temp:close()

                        os.loadAPI(path.."pages/currentPage.lua")
                        currentPage.init(path)
                    end
                else
                    repeatLoop = false
                end
            elseif output == "reload" or output == 1 then
                printDebug("reload",true)
                rednet.send(serverIP,{message = pageStack:peak()})
                _,message = receive(2)
                printDebug("received:"..textutils.serialise(message,{compact=true}))
                if message.content ~= nil then
                    printDebug("success!")
                    _G.currentPage = nil
                    unloadLibs()
                    openUILib.clearFrameWork()

                    debugText, homeButton, backButton, reloadButton, exitButton = initHudButtons()

                    systemOut:setTextColor(colors.white)
                    systemOut:setBackgroundColor(colors.black)
                    systemOut:clear()

                    downloadLibs(message.libs)

                    local temp = io.open(path.."pages/currentPage.lua","w")
                    temp:write(message.content)
                    temp:close()

                    os.loadAPI(path.."pages/currentPage.lua")
                    currentPage.init(path)
                end
            elseif output == "home" or output == -2 then
                printDebug("home",true)
                repeatLoop = false
            elseif output == "exit" or output == -3 then
                printDebug("exit",true)
                repeatLoop = false
                active = false
            end
        end

        if currentPage.disconnect then
            parallel.waitForAny(function() currentPage.disconnect(path) end,function() sleep(disconnectTime) end)
        end

        unloadLibs()
        _G.currentPage = nil

        fs.delete(path.."pages/currentPage.lua")

        pageStack:clear()

        systemOut:setTextColor(colors.white)
        systemOut:setBackgroundColor(colors.black)
        systemOut:clear()

        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)

        openUILib.clearFrameWork()

        startSprite = openUILib.sprite:addSprite(startPageImage,nil,findCenter(nil,22),2)
        searchBar = openUILib.hologram:addHologram("Loading...",{white=1},{lightGray=1},nil,2,searchBarYPos)
    end
end


local function  homePageHud(exitButton)
    local output = nil
    while output == nil do
        openUILib.render()
        local _,_,x,y = os.pullEvent("mouse_click")
        if openUILib.isCollidingRaw(x,y,exitButton) then
            output = "exit"
        end
    end
    return output
end

-- if you are searching start ui initiation then you'll have to go the the openUILib and systemOut init functions
while active and #dnsServers > 0 do
    openUILib.setPaletteColor(colors.gray,"#444444")
    openUILib.setPaletteColor(colors.lightGray,"#333333")
    openUILib.setPaletteColor(colors.white,"#ffffff")
    local serverIP, search, exitButton
    if not exitButton then
        exitButton = openUILib.hologram:addHologram("x",{red=1},{white=1},nil,sizeX,1)
    end
    parallel.waitForAny(function() search = searchForAddress() end, function() search = homePageHud(exitButton) term.setTextColor(colors.white) term.setBackgroundColor(colors.black) end)

    if search:lower() == "exit" then
        active = false
    elseif  search:lower() == "reload" then
        searchBar:changeHologramData("Loading...",nil,nil,findCenter(nil,10))
        openUILib.render()
        dnsServers = {rednet.lookup("DNSServer")}
        searchBar:changeHologramData(nil,nil,nil,2)
    else
        useColorValues()
        startSprite:changeSpriteData({{}})
        searchBar:changeHologramData("")
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        serverIP = findAddress(search)
    end

    if serverIP then
        term.clear()
        term.setCursorPos(1,1)
        talkWithServer(serverIP)
    end
end

_G.systemOut = nil
_G.Console = nil

rednet.close(modemSide)
openUILib.quit()

_G.openUILib = nil
