----------------------configurations----------------------

-- if this is true will show more in depth system out puts where ever i need them! (disclaimer: will not be pretty to look at!)
local debugMode = false --default: false
-- this is the minimum time that as to elapse between page loop begin and end iff it goes beneath that a time out will be set
local minElapsedTime = 0.5 --default: 0.5
--this is the length of the timeout mentioned above
local errTimeout = 2 --default: 2
--this is the time that a once run page function is allowed to run for in seconds can't be lower than 60
local funcTimeoutTime = 150 --default: 150 (2.5 min)
--this is the time that most debug message is min on screen for
local debugSleep = 0.5 --default: 0.5

----------------------------------------------------------


local path = shell.getRunningProgram()
local pathDiv = string.find(path,"/",nil,true)
path = string.sub(path,1,pathDiv)

if funcTimeoutTime < 60 then funcTimeoutTime = 60 end

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

CookieHandle = {}
CookieHandle.__index = CookieHandle

function CookieHandle:loadCookies(filename)
    filename = tostring(filename)

    local obj = {}
    local content
    if fs.exists(path.."libs/"..filename) then
        local temp = io.open(path.."libs/"..filename)
        content = temp:read("a")
        temp:close()
    else
        content = "{}"
    end

    obj.cookies = textutils.unserialiseJSON(content)

    obj.fileName = path.."libs/"..filename

    setmetatable(obj,self)
    self.__index = self

    return obj
end

function CookieHandle:checkCookies()
    local delete={}
    for i=1,#self.cookies do
        if os.epoch("utc") >= self.cookies[i].epoch then
            table.insert(delete,i)
        end
    end
    for i=1,#delete do
        table.remove(self.cookies,delete[i])
    end
    if #self.cookies < 1 then
        fs.delete(self.filename)
    end
end

function CookieHandle:saveCookies()
    self:checkCookies()

    local temp = io.open(self.filename,"w")
    temp:write(textutils.serialiseJSON(self.cookies))
    temp:close()
end

function CookieHandle:setCookie(cookie,name,expirationEpoch)
    self:checkCookies()

    name = tostring(name)
    cookie = tostring(cookie)
    expirationEpoch = tonumber(expirationEpoch)
    table.insert(self.cookies,{cookieValue = cookie, epoch = expirationEpoch, name = name})

    self:saveCookies()
end

function CookieHandle:getCookie(name)
    self:checkCookies()

    for i=1,#self.cookies do
        if self.cookies[i].name == name then
            return self.cookies[i].cookies
        end
    end
end

HologramScreen = {}
HologramScreen.__index = HologramScreen

function HologramScreen:addDisplay()
    self.list = {}
    for i = 1,self.size do
        table.insert(self.list,openUILib.hologram:addHologram("",{white = 1},{lightGray = 1},nil,self.x,self.y+(i-1),false,false,false))
    end
end

function HologramScreen:init(y, size, x)
    size = size - 1

    local obj = {}

    obj.list={}

    obj.size = size
    obj.y = y

    if not x then x = 1 end
    obj.x = x

    obj.values = {}
    obj.offset = 0

    setmetatable(obj,self)
    self.__index = self

    obj:addDisplay()

    return obj
end

function HologramScreen:displayList(list,offset,maxX)

    for i=1,#self.list do
        local str = list[i+offset]

        if type(str) == "string" then

            local cutPos
            for i= #str, 1, -1 do
                if str:sub(i,i) == "." then
                    cutPos = i
                end
                if cutPos then break end
            end

            if cutPos then str = str:sub(1,cutPos-1) end

            if #str > maxX then
                str = string.sub(str, 1, maxX-3).."..."
            else
                str = str .. string.rep(" ",maxX-#str)
            end

            self.list[i]:changeHologramData(str,{white = 1},{lightGray = 1})
        else
            self.list[i]:changeHologramData("",{white = 1},{lightGray = 1})
        end
    end
    openUILib.render()

    self.values = list
    self.offset = offset

end

function HologramScreen:getSelected(x,y)
    for i=1,#self.list do
        self.list[i]:changeHologramData(nil,nil,{lightGray = 1})
    end
    for i=1,#self.list do
        if openUILib.isCollidingRaw(x,y,self.list[i],true) then
            self.list[i]:changeHologramData(nil,nil,{gray = 1})
            openUILib.render()
            return self.list[i],self.values[self.offset+i],self.offset+i
        end
    end
end

function HologramScreen:clear()
    for i = 1, #self.list do
        self.list[i]:changeHologramData("")
        self.list[i]:render()
    end
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
    colors.yellow, colors.lime, colors.pink, colors.lightGray,
    colors.gray, colors.cyan, colors.purple, colors.blue,
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
        sleep(debugSleep)
        term.setTextColor(currentTextColor)
        term.setBackgroundColor(currentBackgroundColor)
    end
end

local function contains(list,val)
    for i=1,#list do
        if list[i] == val then
            return i
        end
    end
    return false
end

local manifestTable = {}

local function makeManifest(manifestDir)
    local temp = io.open(manifestDir,"w")
    temp:write(textutils.serialiseJSON({}))
    temp:close()

    printDebug("loading Manifest.json",true)
    printDebug("{}")

    return {}
end

local function loadManifest(manifestDir)
    local temp = io.open(manifestDir, "r")
    local content = temp:read("a")
    temp:close()

    printDebug("loading Manifest.json",true)
    printDebug(content)

    return textutils.unserialiseJSON(content)
end

local function saveManifest(manifestDir, manifestTable)
    local manifestTable = textutils.serialiseJSON(manifestTable)

    printDebug("saving Manifest.json",true)
    printDebug(manifestTable)

    local temp = io.open(manifestDir,"w")
    temp:write(manifestTable)
    temp:close()
end

local function addToManifest(manifestDir,fileDir)
    local temp = io.open(fileDir,"r")
    local content = temp:read("a")
    temp:close()

    local activeLibs = {}

    local _,pos1 = string.find(content,"--libs",nil,true)
    local pos2 = string.find(content,"--/libs",nil,true)
    if not (pos1 and pos2) then saveManifest(manifestDir,manifestTable) return end
    local content = string.sub(content,pos1+1,pos2-1)

    while string.find(content,"--import",nil,true) do
        local _,pos1 = string.find(content,"--import<",nil,true)
        local pos2 = string.find(content,">",nil,true)

        table.insert(activeLibs,content:sub(pos1+1,pos2-1))
        content = content:sub(pos2+1,#content)
    end

    for i=1,#activeLibs do
        if not contains(manifestTable,activeLibs[i]) then
            table.insert(manifestTable,activeLibs[i])
        end
    end

    saveManifest(manifestDir,manifestTable)
end

local function removeFromManifest(manifestDir,fileDir)

    local temp = io.open(fileDir,"r")
    local content = temp:read("a")
    temp:close()

    local activeLibs = {}

    local _,pos1 = string.find(content,"--libs",nil,true)
    local pos2 = string.find(content,"--/libs",nil,true)
    if not (pos1 and pos2) then saveManifest(manifestDir,manifestTable) return end
    local content = string.sub(content,pos1+1,pos2-1)

    while string.find(content,"--import",nil,true) do
        local _,pos1 = string.find(content,"--import<",nil,true)
        local pos2 = string.find(content,">",nil,true)

        table.insert(activeLibs,content:sub(pos1+1,pos2-1))
        content = content:sub(pos2+1,#content)
    end

    for i =1,#activeLibs do
        for j =1,#manifestTable do
            if manifestTable[j] == activeLibs[i] then
                table.remove(manifestTable,j)
                break
            end
        end
    end

    saveManifest(manifestDir,manifestTable)
end

gatherColorValues()

local sizeX,sizeY = term.getSize()

if arg[1] then
    printDebug("redirect arg given: arg[1]="..arg[1],true)
    if debugMode then sleep(debugSleep) end
end

openUILib.init("mcNet")
_G.systemOut = Console:init()
local backPageStack = Stack:init()
local forwardPageStack = Stack:init()
local cookies = CookieHandle:loadCookies(path..".cookies.json")
local downloadScreen = HologramScreen:init(2,sizeY-2,2)

cookies:checkCookies()

if not fs.exists(path..".manifest.json") then
    manifestTable = makeManifest(path..".manifest.json")
else
    manifestTable = loadManifest(path..".manifest.json")
end


printDebug("initiating start UI...",true)
openUILib.setPaletteColor(colors.black,"#000000")
openUILib.setPaletteColor(colors.lightGray,"#444444")
openUILib.setPaletteColor(colors.gray,"#333333")
openUILib.setPaletteColor(colors.white,"#ffffff")
openUILib.setPaletteColor(colors.red,"#ff0000")
openUILib.setPaletteColor(colors.brown,"#884400")
openUILib.setPaletteColor(colors.green,"#00ff00")
openUILib.setPaletteColor(colors.lightBlue,"#AAFFFF")


local defaultBackground = {}
for i=0,sizeX do
    defaultBackground[i]={}
    for j=0,sizeY do
        defaultBackground[i][j] = colors.lightGray
    end
end
local startPageImage = openUILib.loadImage(path.."libs/logo.nfp")

local searchBarYPos = findCenter(sizeY,1)
if searchBarYPos < 8 then
    searchBarYPos = 8
end

local startSprite = openUILib.sprite:addSprite(startPageImage,nil,findCenter(nil,22),2)
local searchBar = openUILib.hologram:addHologram("Loading...",{white=1},{gray=1},nil,findCenter(nil,10),searchBarYPos)

openUILib.setBackgroundImage(defaultBackground)
openUILib.render()

local active = true
local search, scrollBar

peripheral.find("modem",function (name,_)
    if peripheral.call(name,"isWireless") then
        modemSide = name
    end
end)
if not modemSide then error("could not find ender modem please install one!") end

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
    printDebug("manifest:",true)
    printDebug(textutils.serialise(manifestTable))
    printDebug("")
    for i=1,#activeLibs do
        local libPath = string.gsub(activeLibs[i],".lua","")
        local lasLibPathDiv = 0
        while string.find(libPath,"/",lasLibPathDiv+1,true) do
            local libPathDiv = string.find(libPath,"/",lasLibPathDiv+1,true)
            if libPathDiv then lasLibPathDiv = libPathDiv end
        end
        local libName = string.sub(libPath,lasLibPathDiv+1,#libPath)
        printDebug("unloading: "..libName)
        printDebug("path: "..activeLibs[i])
        if debugMode then sleep(debugSleep) end

        _G[libName] = nil

        if not contains(manifestTable,string.gsub(activeLibs[i],path,"")) then
            printDebug("unloaded Lib")
            fs.delete(activeLibs[i])
        end
        table.remove(activeLibs,i)
    end
end

local deleteButton, playButton, nextPageButton, previousPageButton, scrollBar

local function initDownloadHud()
    deleteButton = openUILib.hologram:addHologram("",nil,{red=1},nil,sizeX,sizeY)
    playButton = openUILib.hologram:addHologram("",{black = 1},{white = 1},nil,4,sizeY)
    nextPageButton = openUILib.hologram:addHologram("",{black = 1},{white = 1},nil,2,sizeY)
    previousPageButton = openUILib.hologram:addHologram("",{black = 1},{white = 1},nil,1,sizeY)
end

local function restore()
    initDownloadHud()
    scrollBar = openUILib.sprite:addSprite({{}},nil,1,2)
end

local function hud(homeButton,backButton,forwardButton,reloadButton,exitButton, downloadButton)
    local output = nil
    while output == nil do
        openUILib.render()
        if currentPage.hubEvent then
            parallel.waitForAny(function() currentPage.hubEvent(path) end,function() sleep(funcTimeoutTime) end)
        end
        local _,_,x,y = os.pullEvent("mouse_click")
        if openUILib.isCollidingRaw(x,y,homeButton,true) then
            output = "home"
        elseif openUILib.isCollidingRaw(x,y,backButton,true) then
            output = "back"
        elseif openUILib.isCollidingRaw(x,y,forwardButton,true) then
            output = "forward"
        elseif openUILib.isCollidingRaw(x,y,reloadButton,true) then
            output = "reload"
        elseif openUILib.isCollidingRaw(x,y,exitButton,true) then
            output = "exit"
        elseif openUILib.isCollidingRaw(x,y,downloadButton,true) then
            output = "download"
        end
        sleep(0.2)
    end

    return output
end


local function initHudButtons()
    openUILib.hologram:addHologram(string.rep(" ",sizeX),nil,{gray=1},nil,1,1,nil,false)

    local debugText = openUILib.hologram:addHologram("",{white=1},{gray=1},nil,8,1)
    local homeButton = openUILib.hologram:addHologram("H",{black=1},{white=1},nil,1,1)
    local backButton = openUILib.hologram:addHologram("\027",{black=1},{white=1},nil,3,1)
    local forwardButton = openUILib.hologram:addHologram("\026",{black=1},{white=1},nil,4,1)
    local reloadButton = openUILib.hologram:addHologram("@",{black=1},{white=1},nil,6,1)
    local downloadButton = openUILib.hologram:addHologram("\025",{black=1},{white=1},nil,sizeX-2,1)
    local exitButton = openUILib.hologram:addHologram("x",{red=1},{white=1},nil,sizeX,1)

    return debugText, homeButton, backButton, forwardButton, reloadButton, exitButton, downloadButton
end

local function talkWithServer(serverIP)
    rednet.send(serverIP,{message="connection test"})
    _,message = receive(2)
    printDebug("received:"..textutils.serialise(message,{compact=true}))
    if message.content then
        printDebug("success!")
        backPageStack:push("connection test")

        openUILib.clearFrameWork()
        openUILib.setBackgroundImage({{}})

        local debugText, homeButton, backButton, forwardButton, reloadButton, exitButton, downloadButton = initHudButtons()

        if debugMode then debugText:changeHologramData("Measuring..") end
        downloadLibs(message.libs)

        local temp = io.open(path.."pages/currentPage.lua","w")
        temp:write(message.content)
        temp:close()

        os.loadAPI(path.."pages/currentPage.lua")

        local lastCookie = cookies:getCookie(search)

        parallel.waitForAny(function() currentPage.init(path,lastCookie) end,function() sleep(funcTimeoutTime) end)

        local repeatLoop = true
        local output, additionalReturnValue, elapsedTime1, elapsedTime2, elapsedTimeDifference, preElapsedTimeDifference

        while repeatLoop do

            parallel.waitForAny(function() output = hud(homeButton,backButton,forwardButton,reloadButton,exitButton,downloadButton) end ,function()
                elapsedTime1 = os.clock()
                output,additionalReturnValue = currentPage.main(path,lastCookie)
                elapsedTime2 = os.clock()
                elapsedTimeDifference = elapsedTime2 - elapsedTime1
                if debugMode and elapsedTimeDifference ~= preElapsedTimeDifference then
                    local timeStr = tostring(elapsedTimeDifference)
                    if #timeStr > (sizeX-21) then
                        timeStr = timeStr:sub(1, sizeX-19) .. ".."
                    end
                    debugText:changeHologramData("TLap:" .. timeStr .. "s",{white = 1})
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
                    forwardPageStack:clear()
                    _G.currentPage = nil
                    unloadLibs()
                    openUILib.clearFrameWork()

                    debugText, homeButton, backButton, forwardButton, reloadButton, exitButton, downloadButton = initHudButtons() -- re add hud buttons

                    backPageStack:push(additionalReturnValue)

                    systemOut:setTextColor(colors.white)
                    systemOut:setBackgroundColor(colors.black)
                    systemOut:clear()

                    downloadLibs(message.libs)

                    local temp = io.open(path.."pages/currentPage.lua","w")
                    temp:write(message.content)
                    temp:close()

                    os.loadAPI(path.."pages/currentPage.lua")
                    parallel.waitForAny(function() currentPage.init(path) end,function() sleep(funcTimeoutTime) end)
                end
            elseif output == 3 then
                rednet.send(serverIP,additionalReturnValue)
                local _,message = receive(2)
                if message.message and message.date then
                    cookies:setCookie(message.message,search,message.date)
                    rednet.send(serverIP,{message= "cookie worked", worked = true})
                    lastCookie = cookies:getCookie(search)
                else
                    rednet.send(serverIP,{message= "cookie failed", worked = false})
                end
            elseif output == "back" or output == -1 then
                printDebug("back",true)
                if backPageStack:size() > 1 then
                    rednet.send(serverIP,{message = backPageStack:peak()})
                    _,message = receive(2)
                    printDebug("received:"..textutils.serialise(message,{compact=true}))
                    if message.content ~= nil then
                        printDebug("success!")
                        _G.currentPage = nil
                        unloadLibs()
                        openUILib.clearFrameWork()

                        debugText, homeButton, backButton, forwardButton, reloadButton, exitButton, downloadButton = initHudButtons()

                        forwardPageStack:push(backPageStack:pop())

                        systemOut:setTextColor(colors.white)
                        systemOut:setBackgroundColor(colors.black)
                        systemOut:clear()

                        downloadLibs(message.libs)

                        local temp = io.open(path.."pages/currentPage.lua","w")
                        temp:write(message.content)
                        temp:close()

                        os.loadAPI(path.."pages/currentPage.lua")
                        parallel.waitForAny(function() currentPage.init(path) end,function() sleep(funcTimeoutTime) end)
                    end
                else
                    repeatLoop = false
                end
            elseif output == "forward" then
                printDebug("forward",true)
                if forwardPageStack:size() > 0 then
                    rednet.send(serverIP,{message= forwardPageStack:peak()})
                    _,message = receive(2)
                    if message.content ~= nil then
                        printDebug("success!")
                        _G.currentPage = nil
                        unloadLibs()
                        openUILib.clearFrameWork()

                        debugText, homeButton, backButton, forwardButton, reloadButton, exitButton, downloadButton = initHudButtons()

                        forwardPageStack:pop()

                        systemOut:setTextColor(colors.white)
                        systemOut:setBackgroundColor(colors.black)
                        systemOut:clear()

                        downloadLibs(message.libs)

                        local temp = io.open(path.."pages/currentPage.lua","w")
                        temp:write(message.content)
                        temp:close()

                        os.loadAPI(path.."pages/currentPage.lua")
                        parallel.waitForAny(function() currentPage.init(path) end,function() sleep(funcTimeoutTime) end)
                    end
                end
            elseif output == "reload" or output == 1 then
                printDebug("reload",true)
                rednet.send(serverIP,{message = backPageStack:peak()})
                _,message = receive(2)
                printDebug("received:"..textutils.serialise(message,{compact=true}))
                if message.content ~= nil then
                    printDebug("success!")
                    _G.currentPage = nil
                    unloadLibs()
                    openUILib.clearFrameWork()

                    debugText, homeButton, backButton, forwardButton, reloadButton, exitButton, downloadButton = initHudButtons()

                    systemOut:setTextColor(colors.white)
                    systemOut:setBackgroundColor(colors.black)
                    systemOut:clear()

                    downloadLibs(message.libs)

                    local temp = io.open(path.."pages/currentPage.lua","w")
                    temp:write(message.content)
                    temp:close()

                    os.loadAPI(path.."pages/currentPage.lua")
                    parallel.waitForAny(function() currentPage.init(path) end,function() sleep(funcTimeoutTime) end)
                end
            elseif output == "download" then
                local temp
                temp = io.open(path.."pages/currentPage.lua",r)
                local content = temp:read("a")
                temp:close()

                fs.delete(path.."pages/"..search..".mnd")
                temp = io.open(path.."pages/"..search..".mnd","w")
                temp:write(content)
                temp:close()

                addToManifest(path..".manifest.json",path.."pages/currentPage.lua")

                if not ((#search+12) > sizeX-6)then
                    debugText:changeHologramData("Downloaded:"..search.."!",{green = 1})
                else
                    debugText:changeHologramData("Downloaded Site!",{green = 1})
                end
                debugText:render()
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
            parallel.waitForAny(function() currentPage.disconnect(path) end,function() sleep(funcTimeoutTime) end)
        end

        unloadLibs()
        _G.currentPage = nil

        fs.delete(path.."pages/currentPage.lua")

        backPageStack:clear()
        forwardPageStack:clear()

        systemOut:setTextColor(colors.white)
        systemOut:setBackgroundColor(colors.black)
        systemOut:clear()

        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)

        openUILib.clearFrameWork()

        startSprite = openUILib.sprite:addSprite(startPageImage,nil,findCenter(nil,22),2)
        searchBar = openUILib.hologram:addHologram("Loading...",{white=1},{gray=1},nil,2,searchBarYPos)
        restore()
    end
end

local function homePageHud(exitButton,downloadButton)
    local output = nil
    while output == nil do
        openUILib.render()
        local _,_,x,y = os.pullEvent("mouse_click")
        if openUILib.isCollidingRaw(x,y,exitButton,true) then
            output = "exit"
        elseif openUILib.isCollidingRaw(x,y,downloadButton,true) then
            output = "downloads"
        end
    end
    return output
end

local segmentedFileList = {{}}
local function listDownloads(offset,page)
    local fileList = fs.list(path.."pages/")

    local i, j ,currentPage =1,1,1
    segmentedFileList = {{}}
    while fileList[i] do
        if j > (2*(sizeY-3)) then
            currentPage = currentPage + 1
            segmentedFileList[currentPage] = {}
            table.insert(segmentedFileList[currentPage],fileList[i])
            j=2
        else
            table.insert(segmentedFileList[currentPage],fileList[i])
            j=j+1
        end
        i=i+1
    end

    if #fileList == 0 or not segmentedFileList[page] then
        downloadScreen:clear()
        downloadScreen.list[1]:changeHologramData("There is nothing here yet")
        downloadScreen.list[1]:render()
    else
        downloadScreen:displayList(segmentedFileList[page],offset,sizeX-1)
    end
end

local function downloadScreenPullEvent()
    while true do
        local eventList = {os.pullEvent()}
        if string.find(eventList[1],"mouse",nil,true) then
            return eventList
        end
    end
end

local function showDownloads(searchBar,scrollBar)

    term.setCursorBlink(false)
    local obj, text, pos, clickedScrollBar
    local offset, page = 0, 1

    local downloads = true
    searchBar:changeHologramData("     page 1/"..#segmentedFileList..string.rep(" ",sizeX-#("     page 1/"..#segmentedFileList)))
    listDownloads(0,1)

    while downloads do
        local eventList = downloadScreenPullEvent()
        if eventList[1] == "mouse_click" and eventList[3] == 1 and eventList[4] > 1 and eventList[4] < sizeY then
            clickedScrollBar = openUILib.isCollidingRaw(1,eventList[4],scrollBar)
            scrollBar:changeSpriteData(nil,nil,eventList[4])
            listDownloads(eventList[4]-2,page)
            offset = eventList[4]-2

            if obj then
                obj:changeHologramData(nil,nil,{lightGray = 1})
                obj = nil
            end

            openUILib.render()
        elseif eventList[1] == "mouse_drag" and eventList[4] > 1 and eventList[4] < sizeY and clickedScrollBar then
            scrollBar:changeSpriteData(nil,nil,eventList[4])
            listDownloads(eventList[4]-2,page)
            offset = eventList[4]-2

            if obj then
                obj:changeHologramData(nil,nil,{lightGray = 1})
                obj = nil
            end

            openUILib.render()
            sleep(0.07)
        elseif eventList[1] == "mouse_scroll" then
            if (offset > 0 and eventList[2] == -1) or (offset < (sizeY-3) and eventList[2] == 1) then
                offset = offset + eventList[2]
            end
            scrollBar:changeSpriteData(nil,nil,offset+2)
            listDownloads(offset,page)

            if obj then
                obj:changeHologramData(nil,nil,{lightGray = 1})
                obj = nil
            end

            openUILib.render()
            sleep(0.07)
        elseif obj and text and eventList[1] == "mouse_click" and #downloadScreen.values[1] > 0 then
            if fs.exists(path.."pages/"..text) then
                if openUILib.isCollidingRaw(eventList[3],eventList[4],obj,true)then
                    return text
                elseif openUILib.isCollidingRaw(eventList[3],eventList[4],playButton,true) then
                    return text
                elseif openUILib.isCollidingRaw(eventList[3],eventList[4],deleteButton,true) then
                    removeFromManifest(path..".manifest.json",path.."pages/"..text)

                    local temp = io.open(path.."pages/"..text,"r")
                    local content = temp:read("a")
                    temp:close()

                    local _,pos1 = string.find(content,"--libs",nil,true)
                    local pos2 = string.find(content,"--/libs",nil,true)
                    if pos1 and pos2 then 
                        local content = string.sub(content,pos1+1,pos2-1)

                        while string.find(content,"--import",nil,true) do
                            local _,pos1 = string.find(content,"--import<",nil,true)
                            local pos2 = string.find(content,">",nil,true)

                            fs.delete(path..content:sub(pos1+1,pos2-1))
                            content = content:sub(pos2+1,#content)
                        end
                    end

                    fs.delete(path.."pages/"..text)

                    listDownloads(offset,page)
                else
                    obj:changeHologramData(nil,nil,{lightGray = 1})
                    obj:render()
                    obj = nil
                end
            end
        elseif eventList[1] == "mouse_click" and openUILib.isCollidingRaw(eventList[3],eventList[4],nextPageButton,true) and downloadScreen.values[page+1] then
            page = page + 1
            offset = 0
            scrollBar:changeSpriteData(nil,nil,2)

            listDownloads(offset,page)
        elseif eventList[1] == "mouse_click" and openUILib.isCollidingRaw(eventList[3],eventList[4],previousPageButton,true) and page > 1 then
            page = page - 1
            offset = 0
            scrollBar:changeSpriteData(nil,nil,2)

            listDownloads(offset,page)
        else
            clickedScrollBar = false
            obj, text, pos = downloadScreen:getSelected(eventList[3],eventList[4])
        end
        searchBar:changeHologramData("     page "..page.."/"..#segmentedFileList..string.rep(" ",sizeX-#("     page "..page.."/"..#segmentedFileList)))
    end
end

local function loadDownloadedLibs(content)
    local _,pos1 = string.find(content,"--libs",nil,true)
    local pos2 = string.find(content,"--/libs",nil,true)
    if not (pos1 and pos2) then return end
    local content = string.sub(content,pos1+1,pos2-1)

    while string.find(content,"--import",nil,true) do
        local _,pos1 = string.find(content,"--import<",nil,true)
        local pos2 = string.find(content,">",nil,true)

        table.insert(activeLibs,path..content:sub(pos1+1,pos2-1))
        content = content:sub(pos2+1,#content)
    end
end

local function useDownload(fileName)

    local debugText, homeButton, backButton, forwardButton, reloadButton, exitButton, output, elapsedTime1, elapsedTime2, elapsedTimeDifference, preElapsedTimeDifference

    useColorValues()
    openUILib.clearFrameWork()
    openUILib.setBackgroundImage({{}})

    local siteName = string.gsub(fileName,".mnd","")

    local temp = io.open(path.."pages/"..fileName,"r")
    local content = temp:read("a")
    temp:close()

    debugText, homeButton, backButton, forwardButton, reloadButton, exitButton = initHudButtons()

    if debugMode then debugText:changeHologramData("Measuring..") end
    loadDownloadedLibs(content)

    fs.move(path.."pages/"..fileName,path.."pages/currentPage.lua")

    os.loadAPI(path.."pages/currentPage.lua")

    if not (currentPage.init or currentPage.main) then
        fs.move(path.."pages/currentPage.lua",path.."pages/"..fileName)
        return
    end

    local repeatLoop = true

    local lastCookie = cookies:getCookie(siteName)

    parallel.waitForAny(function() currentPage.init(path,lastCookie) end, function() sleep(funcTimeoutTime) end)

    while repeatLoop do
        parallel.waitForAny(function() output = hud(homeButton,backButton,forwardButton,reloadButton,exitButton) end ,function()
            elapsedTime1 = os.clock()
            output = currentPage.main(path,lastCookie)
            elapsedTime2 = os.clock()
            elapsedTimeDifference = elapsedTime2 - elapsedTime1
            if debugMode and elapsedTimeDifference ~= preElapsedTimeDifference then
                local timeStr = tostring(elapsedTimeDifference)
                if #timeStr > (sizeX-21) then
                    timeStr = timeStr:sub(1, sizeX-19) .. ".."
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
        if contains({-3,-2,-1,2,"back","exit","home"},output) then
            repeatLoop = false
        end
    end

    if currentPage.disconnect then
        parallel.waitForAny(function() currentPage.disconnect(path) end,function() sleep(funcTimeoutTime) end)
    end

    unloadLibs()

    _G.currentPage = nil

    fs.move(path.."pages/currentPage.lua",path.."pages/"..fileName)

    systemOut:setTextColor(colors.white)
    systemOut:setBackgroundColor(colors.black)
    systemOut:clear()

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)

    openUILib.clearFrameWork()

    startSprite = openUILib.sprite:addSprite(startPageImage,nil,findCenter(nil,22),2)
    searchBar = openUILib.hologram:addHologram("Loading...",{white=1},{gray=1},nil,2,searchBarYPos)
    restore()
end

local function onDownloadedPageError(err)
    printDebug("encountered error whiles trying to use downloaded pages/libs:",true)
    printDebug(err)
    if debugMode then sleep(1) end

    removeFromManifest(path..".manifest.json",path.."pages/currentPage.lua")

    unloadLibs()

    _G.currentPage = nil

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
    searchBar = openUILib.hologram:addHologram("Loading...",{white=1},{gray=1},nil,2,searchBarYPos)
    restore()
end

-- if you are searching start ui initiation then you'll have to go the the openUILib and systemOut init functions
while active and #dnsServers > 0 do
    openUILib.setPaletteColor(colors.black,"#000000")
    openUILib.setPaletteColor(colors.lightGray,"#444444")
    openUILib.setPaletteColor(colors.gray,"#333333")
    openUILib.setPaletteColor(colors.white,"#ffffff")
    openUILib.setPaletteColor(colors.red,"#ff0000")
    openUILib.setPaletteColor(colors.brown,"#884400")
    openUILib.setPaletteColor(colors.green,"#00ff00")
    openUILib.setPaletteColor(colors.lightBlue,"#AAFFFF")

    local serverIP, exitButton, downloadButton
    if not exitButton or not downloadButton or not scrollBar then
        exitButton = openUILib.hologram:addHologram("x",{red=1},{white=1},nil,sizeX,1)
        downloadButton = openUILib.hologram:addHologram("\025",{black=1},{white=1},nil,sizeX-2,1)
        restore()
    end
    if not arg[1] then
        parallel.waitForAny(function() search = searchForAddress() end, function() search = homePageHud(exitButton,downloadButton) term.setTextColor(colors.white) term.setBackgroundColor(colors.black) end)
    else
        search = arg[1]
        arg[1] = nil
    end

    if search:lower() == "exit" then
        active = false
    elseif  search:lower() == "reload" then
        searchBar:changeHologramData("Loading...",nil,nil,findCenter(nil,10))
        openUILib.render()
        dnsServers = {rednet.lookup("DNSServer")}
        searchBar:changeHologramData(nil,nil,nil,2)
    elseif search:lower() == "downloads" then
        local fileName

        searchBar:changeHologramData(nil,nil,nil,1,sizeY)
        startSprite:changeSpriteData({{}})

        scrollBar:changeSpriteData({{colors.lightBlue}})

        deleteButton:changeHologramData("D")
        playButton:changeHologramData("\017")
        nextPageButton:changeHologramData("\026")
        previousPageButton:changeHologramData("\027")

        openUILib.render()

        parallel.waitForAny(function() fileName = showDownloads(searchBar,scrollBar) end,function () homePageHud(exitButton,downloadButton) end)

        deleteButton:changeHologramData("")
        playButton:changeHologramData("")
        nextPageButton:changeHologramData("")
        previousPageButton:changeHologramData("")

        downloadScreen:clear()

        scrollBar:changeSpriteData({{}})

        if fileName then
            local result = xpcall(function()
                useDownload(fileName)
            end,onDownloadedPageError)
        end

        downloadScreen:addDisplay()

        searchBar:changeHologramData(nil,nil,nil,2,searchBarYPos)

        openUILib.render()
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

        downloadScreen:addDisplay()
    end
end

_G.systemOut = nil
_G.Console = nil

rednet.close(modemSide)
openUILib.quit()

_G.openUILib = nil
