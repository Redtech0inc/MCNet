local path = shell.getRunningProgram() --get path
local pathDiv = string.find(path,"/",nil,true) --get the position of a path divider (/)
if not pathDiv then
    path = "" --if there is no '/' then return nothing given path is already root
else
    path = string.sub(path,1,pathDiv) -- if there is a '/' remove everything in front of it to get the root
end

os.loadAPI(path.."libs/serverLib.lua") -- load lib

local server = serverLib.Server:open("www.example.com")

--server program
local function main()
    while true do
        local SenderID, message = server:receive()
        if message.message == "connection test" then
            rednet.send(SenderID,{message="success"}) --anything but nil will do
            sleep(0.1)
            serverLib.sendPage(SenderID,path.."pages/main.lua") --loads main page and sends it to the client (note to self: lib importing!)
        end
    end
end

--[[print(path.."pages/main.lua")

local temp = io.open("pages/main.lua","r")
local content = temp:read("a")
temp:close()
serverLib.sendLibs(4,content)]]
--run server and deactivator
parallel.waitForAny(main,serverLib.deactivator)
server:close()