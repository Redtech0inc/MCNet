local path = shell.getRunningProgram() --get path
local pathDiv = string.find(path,"/",nil,true) --get the position of a path divider (/)
if not pathDiv then
    path = "" --if there is no '/' then return nothing given path is already root
else
    path = string.sub(path,1,pathDiv) -- if there is a '/' remove everything in front of it to get the root
end

os.loadAPI(path.."libs/serverLib.lua")

local server = serverLib.Server:open("www.example.com")

--server program
local function main()
    while true do
        local SenderID, message = server:receive()
        print("received message: "..tostring(message.message))
        if message.message == "connection test" then
            serverLib.sendPage(SenderID,path.."pages/main.lua") --loads main page and sends it to the client (note to self: lib importing!)
        end
    end
end

parallel.waitForAny(main,serverLib.deactivator)
server:close()
