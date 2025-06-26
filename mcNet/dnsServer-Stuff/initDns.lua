local function findCenter(len1,len2)
    local sizeX,_ = term.getSize()
    len1 = len1 or sizeX
    len2 = len2 or 0

    return math.floor((len1-len2)/2)
end

local function loading_bar(x,y,load_len,load_char,max_base,max_deci,done_message,wait_time)
    term.setCursorPos(x,y)
    for _= 1,load_len do
        term.setBackgroundColor(colors.lightGray)
        term.setTextColor(colors.gray)
        term.write(load_char)
    end
    term.setCursorPos(x,y)
    for _= 1,load_len do
        ran_base=math.random(0,max_base)
        ran_deci=math.random(0,max_deci)
        if ran_base == max_base then
            ran=max_base
        else
            ran=ran_base.."."..ran_deci
        end
        sleep(tonumber(ran))
        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.pink)
        term.write(load_char)
    end
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.green)
    term.setCursorPos(findCenter(nil,#done_message),(y+1))
    print(done_message)
    sleep(wait_time)
    term.setTextColor(colors.white)
end

local function getFileName()
    if not string.find(arg[0],".lua",nil,true) then
        return arg[0]..".lua"
    end
    return arg[0]
end

if not (getFileName() == "startup.lua") then fs.delete("startup.lua") fs.move(getFileName(),"startup.lua") end
if multishell.getCount() > 1 then
    os.reboot()
end

local _,sizeY = term.getSize()
term.clear()
term.setCursorPos(findCenter(nil,19),findCenter(sizeY,2))

term.setTextColor(colors.blue)
print("Starting DNS Server")
term.setTextColor(colors.white)
loading_bar(findCenter(nil,19),findCenter(sizeY),19," ",0,5,"Done Loading DNS Server!",2)

local dnsTabID = multishell.launch(_ENV,"dnsServer.lua")
multishell.setTitle(dnsTabID,"DNS Server")
multishell.setFocus(dnsTabID)

term.clear()
term.setCursorPos(1,1)
