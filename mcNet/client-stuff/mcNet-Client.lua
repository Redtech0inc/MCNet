local path = shell.getRunningProgram()
local pathDiv = string.find(path,"/",nil,true)
path = string.sub(path,1,pathDiv)

print(path)
print()

fs.makeDir(path.."pages")
fs.makeDir(path.."libs")

os.loadAPI(path.."libs/openUILib.lua")

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

Console = {}
Console.__index = Console

function Console:init(x,y,width,height)
    x = x or 1
    y = y or 2
    local termX, termY = term.getSize()
    width = width or termX-(x-1)
    height = height or termY-(y-1)

    local obj={}
    obj.screen={}
    for i=1,width do
        obj.screen[i]={}
        for j=1,height do
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

function Console:display()
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

function Console:setCursorPos(x,y)
    x = x or 1
    y = y or 1

    self.cursorX = x
    self.cursorY = y
end

function Console:setTextColor(color,posX,posY)
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

function Console:setBackgroundColor(color,posX,posY)
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

function Console:write(str)
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

function Console:print(str)
    for i=1,#str do
        if self.screen[(self.cursorX-1)+i] then
            if self.screen[(self.cursorX-1)+i][self.cursorY] then
                self.screen[(self.cursorX-1)+i][self.cursorY][1] = str:sub(i,i)
                self.screen[(self.cursorX-1)+i][self.cursorY][2] = self.currentTextColor
                self.screen[(self.cursorX-1)+i][self.cursorY][3] = self.currentBackgroundColor
            end
        end
    end
    self.cursorX = 1
    self.cursorY = self.cursorY + 1
    self:display()
end

function Console:clear(posX,posY)
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

gatherColorValues()

local sizeX,sizeY = term.getSize()

openUILib.init("mcNet")
_G.systemOut = Console:init()
local pageStack = Stack:init()

local active = true

local defaultBackground = {}
for i=0,sizeX do
    defaultBackground[i]={}
    for j=0,sizeY do
        defaultBackground[i][j] = colors.gray
    end
end

openUILib.setPaletteColor(colors.gray,"#444444")
openUILib.setPaletteColor(colors.lightGray,"#333333")
openUILib.setPaletteColor(colors.white,"#ffffff")

local startPageImage = openUILib.loadImage(path.."libs/logo.nfp")

local searchBarYPos = findCenter(sizeY,1)
if searchBarYPos < 8 then
    searchBarYPos = 8
end

local startSprite = openUILib.sprite:addSprite(startPageImage,nil,findCenter(nil,22),2)
local searchBar = openUILib.hologram:addHologram("Loading...",{white=1},{lightGray=1},nil,findCenter(nil,10),searchBarYPos)

openUILib.setBackgroundImage(defaultBackground)
openUILib.render()

peripheral.find("modem",function (name,_)
    if peripheral.call(name,"isWireless") then
        modemSide = name
    end
end)
if not modemSide then error("could not find ender modem please in stall one!") end

rednet.open(modemSide)

local dnsServers = {rednet.lookup("DNSServer")}

searchBar:changeHologramData(nil,nil,nil,2)

local function findAddress(search)
    for _,DNSServerIP in pairs(dnsServers) do
        rednet.send(DNSServerIP,{message="get server ip",serverName=search})
        local _, replie = rednet.receive(2)
        if not  replie then replie={} end
        if type(replie.message) == "number" then
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
            table.insert(activeLibs,path..libList[1][i])

            local temp = io.open(path..libList[1][i],"w")
            temp:write(libList[2][i])
            temp:close()
        end
    end
end

local function unloadLibs()
    for i=1,#activeLibs do
        os.unloadAPI(activeLibs[i])
        fs.delete(activeLibs[i])
        table.remove(activeLibs,i)
    end
end

local function hud(homeButton,backButton,exitButton)
    local output = nil
    while output == nil do
        openUILib.render()
        local _,_,x,y = os.pullEvent("mouse_click")
        if openUILib.isCollidingRaw(x,y,homeButton) then
            output = "home"
        elseif openUILib.isCollidingRaw(x,y,backButton) then
            output = "back"
        elseif openUILib.isCollidingRaw(x,y,exitButton) then
            output = "exit"
        end
        sleep(0.2)
    end

    return output
end

local function talkWithServer(serverIP)
    rednet.send(serverIP,{message="connection test"})
    local _,message=rednet.receive(2)
    pageStack:push("connection test")
    if message then
        openUILib.clearFrameWork()
        openUILib.setBackgroundImage({{}})

        openUILib.hologram:addHologram(string.rep(" ",sizeX),nil,{lightGray=1},nil,1,1)
        local homeButton = openUILib.hologram:addHologram("H",{black=1},{white=1},nil,1,1)
        local backButton = openUILib.hologram:addHologram("\027",{black=1},{white=1},nil,3,1)
        local exitButton = openUILib.hologram:addHologram("x",{red=1},{white=1},nil,sizeX,1)

        _,message = receive(2)

        if not (message.content) then return end

        downloadLibs(message.libs)

        local temp = io.open(path.."pages/currentPage.lua","w")
        temp:write(message.content)
        temp:close()

        os.loadAPI(path.."pages/currentPage.lua")

        currentPage.init(path)

        local repeatLoop = true
        local output,additionalReturnValue


        while repeatLoop do

            parallel.waitForAny(function() output = hud(homeButton,backButton,exitButton) end ,function() output,additionalReturnValue = currentPage.main(path) end)

            if output == -1 then
                repeatLoop = false
            elseif output == 1 then
                os.unloadAPI(path.."pages/currentPage.lua")
                unloadLibs()

                rednet.send(serverIP,{message = additionalReturnValue})
                local _,message = receive(2)
                if message.content then

                    pageStack:push(additionalReturnValue)

                    downloadLibs(message.libs)

                    local temp = io.open(path.."pages/currentPage.lua","w")
                    temp:write(message.content)
                    temp:close()

                    os.loadAPI(path.."pages/currentPage.lua")
                    currentPage.init(path)
                end
            elseif output == "back" then
                if pageStack:size() > 1 then
                    os.unloadAPI(path.."pages/currentPage.lua")
                    unloadLibs()

                    rednet.send(serverIP,{message = pageStack:peak()})
                    local _,message = receive(2)
                    if message.content then
                        pageStack:pop()

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
            elseif output == "home"  then
                repeatLoop = false
            elseif output == "exit" then
                repeatLoop = false
                active = false
            else
                sleep(0.1)
            end
        end

        unloadLibs()
        os.unloadAPI(path.."pages/currentPage.lua")

        fs.delete(path.."pages/currentPage.lua")

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

while active do
    openUILib.setPaletteColor(colors.gray,"#444444")
    openUILib.setPaletteColor(colors.lightGray,"#333333")
    openUILib.setPaletteColor(colors.white,"#ffffff")
    local serverIP
    local search = searchForAddress()

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
        serverIP = findAddress(search)
    end

    if serverIP then
        talkWithServer(serverIP)
    end
end

_G.systemOut = nil
_G.currentPage = nil

rednet.close(modemSide)
openUILib.quit()
