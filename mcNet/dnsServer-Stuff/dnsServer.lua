local hostName

local function isNumber(str)
    return string.match(str, "^%d+$") ~= nil 
end

server = {}
server.__index = server

function server:openPort(protocol,port)
    local obj = {}
    obj.side = nil
    obj.port = tostring(port)
    obj.protocol = protocol or "unknownHost"

    peripheral.find("modem",function (name,_)
        if peripheral.call(name,"isWireless") then
            obj.side = name
        end
    end)

    if not obj.side then error("could not find rednet modem!") end

    rednet.open(obj.side)

    rednet.host(obj.protocol,obj.port)

    term.setTextColor(colors.green)
    term.write("Server now Online on port(Host Name): ")
    term.setTextColor(colors.blue)
    print(obj.port)
    term.setTextColor(colors.white)

    setmetatable(obj,self)
    self.__index = self
    return obj
end

function server:receive(timeout,times)
    times = times or 1
    times = math.floor(times)
    if times < 1 then times = 1 end

    for _=1,times do
        local senderID, message = rednet.receive(timeout)
        if senderID then
            if type(message) ~= "table" then message = {} end
            return senderID, message
        end
    end
end

function server:closePort()
    rednet.unhost(self.protocol,self.port)
    rednet.close(self.side)

    term.setTextColor(colors.red)
    print("Server is now Offline")
    term.setTextColor(colors.white)

    setmetatable(self, {
        __index = function()
            return
        end
    })
end

Log={}
Log.__index = Log

function Log:open(name)
    local obj= {}

    --setting all the variables
    obj.name = tostring(name)
    obj.lines = 1

    if obj.name == nil then
        obj.name=os.date("%c")
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

local function getHostName()
    local dnsServerList = rednet.lookup("DNSServer")
    if dnsServerList then
        return "DNSServer" .. tostring((#dnsServerList)+1)
    else
        return "DNSServer1"
    end
end

local function setupDNSServer()
    local temp
    temp = io.open("DNSServerInfo.txt","w")
    temp:write("name="..getHostName()..";")
    temp:close()
    temp = io.open("serverIPs.txt","w")
    temp:write("empty")
    temp:close()
end

local function readDNSServerInfo()
    local temp = io.open("DNSServerInfo.txt","r")
    local infoFileContent = temp:read("a")
    local pos1, pos2, lastLineEnd
    _, pos1 = string.find(infoFileContent,"name=",nil,true)
    pos2 = string.find(infoFileContent,";")
    lastLineEnd = pos2
    hostName = string.sub(infoFileContent,pos1+1,pos2-1)
end

local function makeServerIDFile(IDList)
    local temp = io.open("serverIPs.txt","w")
    if #IDList == 0 then
        temp:write("empty")
    end
    for i=1,#IDList do
        temp:write(IDList[i][1].."=>"..IDList[i][2])
        if not (i==#IDList) then
            temp:write("\n")
        end
    end
    temp:close()
end

local function readServerIPs()
    local serverIps={}
    local i=1
    for line in io.lines("serverIPs.txt") do
        if line == "empty" then
            return serverIps
        end
        if not serverIps[i] then
            serverIps[i] = {}
        end
        local pos = string.find(line,"=>",nil,true)
        serverIps[i][1] = string.sub(line,1,pos-1)
        serverIps[i][2] = tonumber(string.sub(line,pos+2,#line))
        i=i+1
    end
    return serverIps
end

local function getServerByName(serverIPs,serverName)
    for i=1,#serverIPs do
        if serverIPs[i][1] == serverName then
            return serverIPs[i][2]
        end
    end
end

local function contains(list,j,item)
    if j then
        for i=1,#list do
            if list[i][j] == item then
                return true
            end
        end
    else
        for i=1,#list do
            if list[i] == item then
                return true
            end
        end
    end
    return false
end

--START OF DNS SERVER
local dnsServer, dnsLog, modemSide, serverIPs
local showExitMessage = false
local function run()
    peripheral.find("modem",function (name,_)
        if peripheral.call(name,"isWireless") then
            modemSide = name
        end
    end)

    rednet.open(modemSide)

    if not fs.exists("DNSServerInfo.txt") then
        setupDNSServer()
    end

    if not fs.exists("serverIPs.txt") then
        local temp = io.open("serverIPs.txt","w")
        temp:write("empty")
        temp:close()
    end

    readDNSServerInfo()

    serverIPs = readServerIPs()

    dnsLog = Log:open("logs/Dns-Server-Console.log")
    dnsServer = server:openPort("DNSServer",hostName)
    print("enter backspace to stop server")
    showExitMessage = true
    dnsLog:write("Server is now Online")

    while true do
        dnsLog:space()
        print()

        local senderID, message = dnsServer:receive()
        --if not message.message then message.message="A" end
        message.message = string.lower(tostring(message.message))

        print("received message fom computer: "..senderID)
        term.write("asked for: ")
        dnsLog:write("asked for: ", nil, false)

        if message.message == "get server ip" then
            if serverIPs then
                print("getting server by name")
                dnsLog:write("getting server by name", nil, nil, false)
                print()
                dnsLog:space()

                print("Server name: "..message.serverName)
                dnsLog:write("Server name: "..message.serverName)
                term.write("Server IP(ID): ")
                dnsLog:write("Server IP(ID): ", nil, false)

                local IP = getServerByName(serverIPs,message.serverName)
                if IP then
                    print(IP)
                    dnsLog:write(IP, nil, nil, false)
                    rednet.send(senderID,{message=IP})
                else
                    print("ERR server not found")
                    dnsLog:write("ERR server not found", nil, nil, false)
                    rednet.send(senderID,{message="server is not registered"})
                end
            end
        elseif message.message == "add server" then
            print("add server ip")
            dnsLog:write("add server ip", nil, nil, false)
            print()
            dnsLog:space()

            print("Server name: "..message.serverName)
            dnsLog:write("Server name: "..message.serverName)
            print("Server IP(ID): "..senderID)
            dnsLog:write("Server IP(ID): "..senderID)

            if message.serverName then
                if contains(serverIPs,2,senderID) then
                    print("CMD_ERR: server ip already registered")
                    dnsLog:write("server ip already registered","CMD_ERR")
                    rednet.send(senderID,"server ip already registered")
                elseif contains(serverIPs,1,message.serverName) then
                    print("CMD_ERR: server name already exists")
                    dnsLog:write("server name already exists","CMD_ERR")
                    rednet.send(senderID,"server name already exists")
                else
                    local IpLen = #serverIPs
                    serverIPs[IpLen+1] = {}
                    serverIPs[IpLen+1][1] = message.serverName
                    serverIPs[IpLen+1][2] = senderID
                    print("server successfully registered")
                    dnsLog:write("server successfully registered")
                    makeServerIDFile(serverIPs)
                end
            end
        end
    end
end

local function deactivator()
    while not showExitMessage do
        sleep(0.1)
    end
    local active = true
    while active do
        _, key, _ = os.pullEvent("key")
        if key == keys.backspace then
            active = false
        end
    end
end

parallel.waitForAny(run,deactivator)
dnsServer:closePort()
rednet.close(modemSide)

makeServerIDFile(serverIPs)

dnsLog:write("Server is now Offline")
dnsLog:close()

sleep(1)