--HELPER FUNCTIONS
local function getLibs(content)
    local _,pos1 = string.find(content,"--libs",nil,true)
    local pos2 = string.find(content,"--/libs",nil,true)
    if not (pos1 and pos2) then return {{},{}} end
    local content = string.sub(content,pos1+1,pos2-1)

    local libList={}
    libList[1]={}
    libList[2]={}
    while string.find(content,"--import",nil,true) do
        local _,pos1 = string.find(content,"--import<",nil,true)
        local pos2 = string.find(content,">",nil,true)

        table.insert(libList[1],content:sub(pos1+1,pos2-1))
        content = content:sub(pos2+1,#content)
    end

    for i=1,#libList[1] do
        local temp = io.open(libList[1][i],"r")
        local content = temp:read("a")
        table.insert(libList[2],content)
        temp:close()
    end

    return libList
end

local function getEpochTimeDiff(timeTable)
    local ms = 0

    -- Better average constants
    local MS_IN_HOUR = 3600000
    local MS_IN_DAY = 86400000
    local MS_IN_MONTH = 2628000000 -- 1/12 of a year
    local MS_IN_YEAR = 31536000000

    -- Safely add time parts
    if type(timeTable.years) == "number" then
        ms = ms + timeTable.years * MS_IN_YEAR
    end
    if type(timeTable.months) == "number" then
        ms = ms + timeTable.months * MS_IN_MONTH
    end
    if type(timeTable.days) == "number" then
        ms = ms + timeTable.days * MS_IN_DAY
    end
    if type(timeTable.hours) == "number" then
        ms = ms + timeTable.hours * MS_IN_HOUR
    end

    if ms > MS_IN_YEAR then
        ms = MS_IN_YEAR
    end

    return os.epoch("utc") + ms
end

local showExitMessage

--SERVER FUNCTIONS
Server = {}
Server.__index = Server

function Server:open(name)
    if not name then error("argument #1 must be the server web address nil was given") end
    local obj = {}
    obj.side = nil

    peripheral.find("modem",function (name,_)
        if peripheral.call(name,"isWireless") then
            obj.side = name
        end
    end)

    if not obj.side then error("could not find rednet modem!") end

    rednet.open(obj.side)
    obj.dnsServers = {}
    local retries = 0

    local function getDNS()
            while #obj.dnsServers == 0 do
            obj.dnsServers = {rednet.lookup("DNSServer")}
            if #obj.dnsServers == 0 then
                retries = retries + 1
                print("could not find any retrying... (retry:"..retries..")")
            end
        end
    end

    local function exitDNSloop()
        while true do
            _, key, _ = os.pullEvent("key")
            if key == keys.backspace then
                return
            end
        end
    end

    print("searching DNS Server(s)...")
    print("enter backspace to stop search!")
    parallel.waitForAny(getDNS,exitDNSloop)
    print("Found "..#obj.dnsServers.." DNS Server(s)")

    if #obj.dnsServers == 0 then
        print("no DNS server available")
        sleep(0.5)
        print("closing rednet port")
        rednet.close(modemSide)
        sleep(1)
        print("exiting program: returning nil")
        sleep(1)
        return nil
    end

    for i=1,#obj.dnsServers do
        local dnsIp = obj.dnsServers[i]

        rednet.send(dnsIp,{message = "add server", serverName = name })
    end


    term.setTextColor(colors.green)
    term.write("Server now Online at: ")
    print(name)
    term.setTextColor(colors.white)

    setmetatable(obj,self)
    self.__index = self
    showExitMessage = true
    return obj
end

function Server:receive(timeout,times)
    times = times or 1
    times = math.floor(math.abs(times))
    if times < 1 then times = 1 end

    for _=1,times do
        local senderID, message = rednet.receive(timeout)
        if senderID then
            if type(message) ~= "table" then message = {} end
            return senderID, message
        end
    end
end

function Server:close()
    rednet.close(self.side)

    term.setTextColor(colors.red)
    print("Server is now Offline")
    term.setTextColor(colors.white)
    sleep(1)

    setmetatable(self, {
        __index = function()
            return
        end
    })
end


--LOG FUNCTIONS
Log={}
Log.__index = Log

function Log:open(name)
    local obj= {}

    --setting all the variables
    obj.name = tostring(name)
    obj.lines = 1

    if obj.name == nil then
        obj.name=tostring(os.date("%c"))
    end

    --opens log
    obj.log=io.open(obj.name,"w")

    --setmetatable
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Log:write(text,logClass,endLine, includePreInfo)

    --check that logClass isn't nil
    logClass=logClass or "Info"
    logClass = tostring(logClass)
    if endLine == nil then endLine = true end
    if includePreInfo == nil then includePreInfo = true end

    --write in Log
    if includePreInfo then
        self.log:write(os.date("%c").." ["..logClass.."]: ")
    end
    if endLine == true then
        self.log:write(tostring(text),"\n")
        self.lines=self.lines+1
    else
        self.log:write(tostring(text))
    end

    --save written text
    self.log:flush()
end

function Log:space(number)
    if type(number) ~= "number" then
        number = 1
    end
    for i = 1,number do
        self.log:write("\n")
        self.lines=self.lines+1
    end
end

function Log:getLines()
    return self.lines
end

function Log:close()
    self.log:close()
    setmetatable(self, {
        __index = function()
            return function()
                error("\nOBJ-ERROR: This Log is closed and cannot be written to. [Log:close() was called]")
            end
        end
    })
end

--GENERIC FUNCTIONS
sendPage = function(ID,path)
    local file = io.open(path,"r")
    if not file then error("'"..path.."' is not a existing path") end
    local content = file:read("a")
    file:close()

    rednet.send(ID,{content = content, libs = getLibs(content)})
end

sendCookie = function (ID,valueTable,expirationDateTable)
    if type(valueTable) ~= "table" then
        valueTable = {tostring(valueTable)}
    end

    local serializedValueTable = textutils.serialiseJSON(valueTable)

    --{epoch = nil , hours = 60 ,days = 1 , months = 1}
    local time
    if type(expirationDateTable) == "table" then
        time = getEpochTimeDiff(expirationDateTable)
    elseif type(expirationDateTable) == "number" then
        local MS_IN_YEAR = 31536000000
        time = expirationDateTable
        if time > os.epoch("utc") + MS_IN_YEAR then
            time = os.epoch("utc") + MS_IN_YEAR
        elseif time <= os.epoch("utc") then
            time = os.epoch("utc") + 3600000
        end
    else
        time = os.epoch("utc") + 3600000
    end

    if not time then return end

    rednet.send(ID,{message = serializedValueTable, date = time})
end

deactivator = function()
    while not showExitMessage do
        sleep(0.1)
    end
    print("enter backspace to stop server")
    local active = true
    while active do
        _, key, _ = os.pullEvent("key")
        if key == keys.backspace then
            active = false
        end
    end
end
