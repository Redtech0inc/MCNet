-- local variables

local colorTable = {
    colors.white, colors.orange, colors.magenta, colors.lightBlue,
    colors.yellow, colors.lime, colors.pink, colors.gray,
    colors.lightGray, colors.cyan, colors.purple, colors.blue,
    colors.brown, colors.green, colors.red, colors.black,
}

local gameName, errFunc, pixelSize, renderStartX, renderStartY, screenEndX, screenEndY, width, height, monitor

local objects={render={background={},backgroundHolograms = {list={}, listLen=-1, renderList={}}, sprites={list={}, listLen=-1, renderList={}}, holograms={list={}, listLen=-1, renderList={}}}}
local groups = {list={}}
local screen = {}
local colorList={}

-- functions for functions

local function isColorValue(colorValue)
    for color=1,#colorTable do
        if colorTable[color] == colorValue then
            return true
        end
    end
    return false
end

local function toboolean(input)
    if input then
        return true
    end
    return false
end

local function getFileLines(dir)
    if not fs.exists(dir) then error("'"..dir.."' is not an existing file") end
    local file=io.open(dir,"r")
    local output={}
    while true do
        local line=file:read("l")
        if line ~= nil then
            table.insert(output,line)
        else
            return output
        end
    end
end

local function writeToFile(file,text,indents,nextLine,compact)
    if not compact then
        for i=1,indents do
            file:write("    ")
        end
    end
    file:write(tostring(text))
    if nextLine and not compact then
        file:write("\n")
    elseif compact then
        file:write(" ")
    end
end

local function getBiggestIndex(matrix,returnBoth)
    local index1
    local index2 = 0
    for i = 1,#matrix do
        for j = 1,table.maxn(matrix[i]) do
            if j > index2 then
                index2 = j
                index1 = i
            end
        end
    end
    if returnBoth then
        return index1, index2
    end
    return index2
end

local function fromBlit(value)
    if tostring(value) == "0" then return colors.white end
    if tostring(value) == "1" then return colors.orange end
    if tostring(value) == "2" then return colors.magenta end
    if tostring(value) == "3" then return colors.lightBlue end
    if tostring(value) == "4" then return colors.yellow end
    if tostring(value) == "5" then return colors.lime end
    if tostring(value) == "6" then return colors.pink end
    if tostring(value) == "7" then return colors.gray end
    if tostring(value) == "8" then return colors.lightGray end
    if tostring(value) == "9" then return colors.cyan end
    if tostring(value) == "a" then return colors.purple end
    if tostring(value) == "b" then return colors.blue end
    if tostring(value) == "c" then return colors.brown end
    if tostring(value) == "d" then return colors.green end
    if tostring(value) == "e" then return colors.red end
    if tostring(value) == "f" then return colors.black end
end

local function wrapHologramText(text, x)
    local text = tostring(text)
    local textTable = {}
    local line = ""

    local width = width- (x - 1)

    -- Split into lines at \n first
    for rawLine in text:gmatch("([^\n]*)\n?") do
        local words = {}
        for word in rawLine:gmatch("%S+") do
            table.insert(words, word)
        end

        local i = 1
        while i <= #words do
            local word = words[i]

            if #word > width then
                if #line > 0 then
                    table.insert(textTable, line)
                    line = ""
                end
                -- Split long word
                while #word > width do
                    table.insert(textTable, word:sub(1, width))
                    word = word:sub(width + 1)
                end
                line = word
            elseif #line + #word + (line == "" and 0 or 1) > width then
                table.insert(textTable, line)
                line = word
            else
                line = (#line > 0) and (line .. " " .. word) or word
            end

            i = i + 1
        end

        -- End of manual line → flush current line
        if #line > 0 then
            table.insert(textTable, line)
            line = ""
        end
    end

    -- Just in case something is still in `line` (shouldn't happen)
    if #line > 0 then
        table.insert(textTable, line)
    end

    -- Calculate max line width
    local maxWidth = 0
    for i = 1, #textTable do
        if #textTable[i] > maxWidth then
            maxWidth = #textTable[i]
        end
    end

    return textTable, maxWidth
end

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

local function drawPixel(x, y, color)
    if monitor then

        monitor.setCursorPos(x, y)
        monitor.setBackgroundColor(color)
        monitor.write(" ")
    else

        term.setCursorPos(x, y)
        term.setBackgroundColor(color)
        term.write(" ")
    end
end

-- object functions for functions

sprite = {}
sprite.__index = sprite

hologram = {}
hologram.__index = hologram

group = {}
group.__index = group

function sprite:clone(parentObject,priority,x,y,screenBound,group)
    local spriteData = {}

    if type(priority) ~= "number" then
        priority=#objects.render.sprites.list+1
    end
    if type(x) ~= "number" then
        x=1
    end
    if type(y) ~= "number" then
        y=1
    end
    if (x < 1-#img or x > width) and parentObject.screenBound then
        x=1
    end
    if (y < 1-table.maxn(img[1]) or y > height) and parentObject.screenBound then
        y=1
    end

    spriteData.x = math.floor(x)
    spriteData.y = math.floor(y)
    spriteData.type = "spriteClone"
    spriteData.sprite = parentObject
    spriteData.priority = priority
    spriteData.group = group
    spriteData.screenBound = toboolean(screenBound)

    setmetatable(spriteData,self)
    self.__index= self

    table.insert(objects.render.sprites.list,{spriteData,priority})

    if group then
        group:addObjectsToGroup({spriteData})
    end

    return spriteData
end

function hologram:clone(parentObject,priority,x,y,screenBound,group,wrapped)
    local hologramData= {}

    if not priority then
        if parentObject.dynamic then
            priority = #objects.render.holograms.list+1
        else
            priority = #objects.render.backgroundHolograms.list+1
        end
    end

    local textMaxWidth, correctionsCycles
    if wrapped then correctionsCycles=3 else correctionsCycles = 1 end

    for _=1,correctionsCycles do
        if wrapped then
            _, textMaxWidth = wrapHologramText(parentObject.text,hologramData.x)
        else
            textMaxWidth = #parentObject.text
        end

        if (x < 1-textMaxWidth or x > width) and screenBound then
            x=1
        end
        if (y < 1 or y > height) and screenBound then
            y=1
        end
    end

    hologramData.x = math.floor(x)
    hologramData.y = math.floor(y)
    hologramData.text = parentObject
    hologramData.priority = priority
    hologramData.textMaxWidth = textMaxWidth
    hologramData.type = "hologramClone"
    hologramData.group = group
    hologramData.wrapped = toboolean(wrapped)
    hologramData.screenBound = toboolean(screenBound)

    setmetatable(hologramData,self)
    self.__index = self

    if parentObject.dynamic then
        table.insert(objects.render.holograms.list,{hologramData,priority})
    else
        table.insert(objects.render.backgroundHolograms.list,{hologramData,priority})
    end

    if group then
        group:addObjectsToGroup({hologramData})
    end

    return hologramData
end

function sprite:changeSpriteCloneData(x,y,screenBound)

    if self.type == "sprite" then return end
    if screenBound ~= nil then self.screenBound = toboolean(screenBound) end

    if self.sprite.sprite then
        if type(x) == "number" then
            if not (x < 2-#self.sprite.sprite) and not (x > width) then
                self.x = math.floor(x)
            elseif not self.screenBound then
                self.x = math.floor(x)
            end
        end
        if type(y) == "number" then
            if not (y < 2-table.maxn(self.sprite.sprite[1])) and not (y > height) then
                self.y = math.floor(y)
            elseif not self.screenBound then
                self.y = math.floor(y)
            end
        end
    end
end

function hologram:changeHologramCloneData(x,y,screenBound,wrapped)

    if self.type == "hologram" then return end
    if wrapped ~= nil then self.wrapped = toboolean(wrapped) end
    if screenBound ~= nil then self.screenBound = toboolean(screenBound) end


    local correctionsCycles
    if wrapped then correctionsCycles=3 else correctionsCycles = 1 end

    for _=1,correctionsCycles do
        if self.text.text ~= nil then
            if type(x) == "number" then
                if not (x < 2-self.text.textMaxWidth) and not (x > width) then
                    self.x = math.floor(x)
                elseif not self.screenBound then
                    self.x = math.floor(x)
                end
            end
            if type(y) == "number" then
                if not (y < 1) and not (y > height) then
                    self.y = math.floor(y)
                elseif not self.screenBound then
                    self.y = math.floor(y)
                end
            end
        end
    end
end

-- framework based functions

---initiates a framework for a 2D game and sets base variables
---@param name any name of the game given to the game.gameName
---@param onErrorCall function|nil if supplied is called before the TDGameLib Runs into an error, may not work if the error not called by GameLib it's self!
---@param useMonitor boolean|nil if true will make the game render on a connected monitor. defaults to false if not provided
---@param allowFallback boolean|nil if true will use the terminal instead of the monitor when no monitor was found (REQUIRES MONITOR)
---@param monitorFilter table|function|nil is the name of the monitor that gets picked, will pick names higher up first. can also be a function that filters like the normal peripheral.find (REQUIRES MONITOR)
---@param pixelSize number|nil is the size of a pixel on a monitor can range from 0.5 to 5 (REQUIRES MONITOR)
---@param screenStartX number|nil is the X coordinate at which the render starts, defaults to 1 if not provided
---@param screenStartY number|nil is the Y coordinate at which the render starts, defaults to 1 if not provided
---@param screenEndX number|nil is the X coordinate at which the render ends, defaults to output object width if not provided
---@param screenEndY number|nil is the Y coordinate at which the render ends, defaults to output object height if not provided
init = function(name,onErrorCall,useMonitor,allowFallback,monitorFilter,pixelSize,screenStartX,screenStartY,screenWidth,screenHeight)
    gatherColorValues()

    local sizeX,sizeY = term.getSize()

    screenWidth = screenWidth or sizeX+1
    screenHeight = screenHeight or sizeY+1

    renderStartX = screenStartX or 1
    renderStartY = screenStartY or 1

    renderStartX = renderStartX - 1
    renderStartY = renderStartY - 1

    screenEndX = renderStartX + (screenWidth - 1)
    screenEndY = renderStartY + (screenHeight - 1)

    name = name or "Game"
    gameName = tostring(name)

    if not onErrorCall then errFunc = function() return end end

    if useMonitor then
        if type(monitorFilter) == "table" then
            monitor = peripheral.find("monitor",function(name)
                if monitorFilter then 
                    for i =1,#monitorFilter do
                        if name == monitorFilter[i] then
                            return true
                        end
                    end
                    return false
                end
                return true
            end)
        elseif type(monitorFilter) == "function" then
            monitor = peripheral.find("monitor",function(name, monitor)
                return monitorFilter(name, monitor)
            end)
        end

        if not monitor and not allowFallback then
            if monitorFilter then
                errFunc()
                if type(monitorFilter) == "function" then
                    error("could not find monitor, make sure that a monitor that get's accepted by the function is attached or disable the useMonitor variable")
                else
                    error("could not find monitor, make sure that a monitor named:"..textutils.serialise(monitorFilter,{compact=true}).." is attached or disable the useMonitor variable")
                end
                else
                errFunc()
                error("could not find monitor, make sure that a monitor is attached or disable the useMonitor variable")
            end
        end

        if type(pixelSize) == "number" and monitor then
            if pixelSize >= 0.5 and pixelSize <= 5 then 
                monitor.setTextScale(pixelSize) 
            else
                errFunc()
                error("Screen size must be in range of 0.5 to 5")
            end
        end
        if monitor then
            width, height = monitor.getSize()
        elseif not monitor and allowFallback then
            width, height = term.getSize()
        end
    else
        width, height = term.getSize()
    end

    screenEndX = screenEndX or width
    screenEndY = screenEndY or height

    if not onErrorCall then errFunc = function() useColorValues() end end

    width = screenEndX-renderStartX
    height = screenEndY-renderStartY


    for i = 1,width do
        objects.render.background[i] = {}
        for j = 1,height do
            --set black as default background
            objects.render.background[i][j] = colors.black
        end
    end
end

---ends the game and removes the framework
---@param restart boolean|nil if true restarts the computer otherwise just resets the terminal/monitor. If not provided defaults to false
---@param exitMessage string|nil is a message that get's displayed once this function is called. will only showup if restart is false or nil
---@param exitMessageColor number|nil is the color of he exit message
quit = function(restart,exitMessage,exitMessageColor)

    clearFrameWork()
    if type(restart) ~= "boolean" then
        restart=false
    end

    if not isColorValue(exitMessageColor) then
        exitMessageColor = colors.white
    end

    if monitor then
        monitor.setTextScale(1)
        monitor.clear()
        monitor.setCursorPos(1,1)
    end
    term.clear()
    term.setCursorPos(1,1)

    useColorValues(colorList)

    if not restart then
        if exitMessage then
            local currentTextColor= term.getTextColor()
            term.write(gameName..": ")
            term.setTextColor(exitMessageColor)
            print(exitMessage)
            term.setTextColor(currentTextColor)
        end
        sleep(0.2)
    else
        os.reboot()
    end

    gameName, errFunc, pixelSize, renderStartX, renderStartY, screenEndX, screenEndY, width, height, monitor = nil, nil ,nil, nil, nil, nil, nil, nil, nil, nil
end

---lets you remove all objects from the render !!!Will delete all object data!!!
clearFrameWork = function()
    objects.render.backgroundHolograms.list = {}
    objects.render.sprites.list = {}
    objects.render.holograms.list = {}
    objects.render.backgroundHolograms.listLen = -1
    objects.render.sprites.listLen = -1
    objects.render.holograms.listLen = -1
    groups.list = {}

    sprite = {}
    sprite.__index = sprite

    hologram = {}
    hologram.__index = hologram

    group = {}
    group.__index = group
end

---lets you load in game assets from a .data(.html and .xml mix: tag based) notation file. Will return an error if the .data file has invalid data or something went wrong whilst adding or grouping objects
---@param fileDir string the directory of the file that you want to load
---@return table objectTable is a table consisting of all object read out from the .data file
useDataFile=function(fileDir)

    if not fs.exists(fileDir) then errFunc() error("'"..tostring(fileDir).."' is not an existing File") return end

    local index={data={"<body>","</body>" , "<background>","</background>","<sprites>","</sprites>","<holograms>","</holograms>","<groups>","</groups>" , "<object>","</object>","<image>","</image>","<br>"}, lua={"{","}" , "background={","},","sprites={","},","holograms={","},","groups={","}," , "{","},","{{","}}","},{"}}
    local output = ""
    local fileOver = false
    local returnTable={sprites={}, holograms={}, groups={}}

    for line in io.lines(fileDir) do
        if not fileOver then
            for i=1,#index.data do
                if string.find(line,"</body>",nil,true) then
                    fileOver=true
                end
            line = string.gsub(line,index.data[i],index.lua[i])
            end

            while string.find(line,"<",nil,true) do
                local startTag=string.find(line,"<",nil,true) or 1
                local stopTag =string.find(line,">",nil,true) or #line

                line = string.gsub(line, string.sub(line,startTag,stopTag), "")
            end

        else
            line=""
        end

        output = output .. line
    end

    if textutils.unserialise(output) then
        output = textutils.unserialise(output)
    else
        errFunc()
        error("'"..tostring(fileDir).."' doesn't contain valid Data!")
    end

    if output.background then
        setBackgroundImage(output.background[1])
    end
    if output.sprites then
        for i=1,#output.sprites do
            table.insert(returnTable.sprites,
                sprite:addSprite(output.sprites[i][1],output.sprites[i][2],output.sprites[i][3],output.sprites[i][4],output.sprites[i][5])
            )
        end
    end
    if output.holograms then
        for i=1,#output.holograms do
            table.insert(returnTable.holograms,
                hologram:addHologram(output.holograms[i][1],output.holograms[i][2],output.holograms[i][3],output.holograms[i][4],output.holograms[i][5],output.holograms[i][6],output.holograms[i][7],output.holograms[i][8],output.holograms[i][9])
            )
        end
    end
    if output.groups then
        for i=1,#output.groups do
            table.insert(returnTable.groups,
                group:groupObjects(output.groups[i][2])
            )
        end
    end

    return returnTable
end

---lets you take all objects & groups and turn them into a .data(.html and .xml mix: tag based) file
---@param fileDir string is the directory where the file will be saved
---@param compact boolean|nil if true will compact the content into one line useful for space saving otherwise uses indentation for readability. defaults to false if not provided
makeDataFile=function(fileDir,compact)

    --phase 1: fetch data and compile list!

    local data = {}

    if objects.render.background then

        data.background={}

        for i=1,#objects.render.background do
            data.background[i]={}
            for j=1,table.maxn(objects.render.background[i]) do
                data.background[i][j] = objects.render.background[i][j]
            end
        end
    end

    if #objects.render.sprites.list > 0 then

        data.sprites={}

        local list = objects.render.sprites.list

        for i=1,#objects.render.sprites.list do

            local obj = objects.render.sprites.list[i][1]
            if obj.type == "sprite" then
                table.insert(data.sprites, {obj.sprite, list[i][2], obj.x, obj.y, obj.screenBound})
            end
        end
    end

    if #objects.render.holograms.list > 0 then

        data.holograms={}
        local list = objects.render.holograms.list

        for i=1,#objects.render.holograms.list do


            local obj = objects.render.holograms.list[i][1]
            local textOut

            if obj.type == "hologram" then
                for j=1, #obj.text do

                    if j ~= 1 then
                        textOut = textOut .. obj.text[j]
                    else
                        textOut = obj.text[j]
                    end


                end

                table.insert(data.holograms, {textOut, obj.textColor, obj.textBackgroundColor, list[i][2], obj.x, obj.y, nil, obj.wrapped, obj.screenBound})
            end
        end
    end

    if #objects.render.backgroundHolograms.list > 0 then

        if not data.holograms then
            data.holograms={}
        end
        local list = objects.render.backgroundHolograms.list

        for i=1,#objects.render.backgroundHolograms.list do

            local obj = objects.render.backgroundHolograms.list[i][1]
            local textOut

            if obj.type == "hologram" then
                for j=1, #obj.text do

                    if j ~= 1 then
                        textOut = textOut .. " " .. obj.text[j]
                    else
                        textOut = obj.text[j]
                    end

                end

                table.insert(data.holograms, {textOut, obj.textColor, obj.textBackgroundColor, list[i][2], obj.x, obj.y, false, obj.wrapped, obj.screenBound})
            end
        end
    end

    if #groups.list > 0 then
        data.groups = {}
        local list = groups.list

        for i=1,#groups.list do

            local obj = groups.list[i]

            if obj then
                table.insert(data.groups, {obj.lvlTable})
            end
        end
    end

    --phase 2: compile and write the .data(xml like) file

    local file=io.open(fileDir,"w")

    writeToFile(file,"<body>",0,true,compact)

    if data.background then

        local backgroundString=textutils.serialise(data.background,{compact=true})

        writeToFile(file,"<background>",1,true,compact)

        backgroundString = string.gsub(backgroundString, "{{","<image>")

        while string.find(backgroundString,"},{",nil,true) do
            backgroundString=string.gsub(backgroundString,"},{","<br>")
        end

        backgroundString = string.gsub(backgroundString, "},}","</image>")

        writeToFile(file,backgroundString,2,true,compact)
        writeToFile(file,"</background>",1,true,compact)
    end

    if data.sprites then
        writeToFile(file,"<sprites>",1,true,compact)
        for i=1,#data.sprites do
            writeToFile(file,"<object>",2,true,compact)
            if not compact then
                file:write("            ")
            end

            for j=1,6 do

                if type(data.sprites[i][j]) == "string" then

                    file:write("\""..tostring(data.sprites[i][j]).."\", ")
                elseif type(data.sprites[i][j]) == "table" then

                    local imageString=textutils.serialise(data.sprites[i][j],{compact=true})

                    imageString = string.gsub(imageString, "{{","<image>")

                    while string.find(imageString,"},{",nil,true) do
                        imageString=string.gsub(imageString,"},{","<br>")
                    end

                    imageString = string.gsub(imageString, "},}","</image>")
                    file:write(imageString..", ")
                else

                    file:write(tostring(data.sprites[i][j])..", ")
                end
            end
            if not compact then
                file:write("\n")
            end
            writeToFile(file,"</object>",2,true,compact)
        end
        writeToFile(file,"</sprites>",1,true,compact)
    end

    if data.holograms then
        writeToFile(file,"<holograms>",1,true,compact)

        for i=1,#data.holograms do

            writeToFile(file,"<object>",2,true,compact)
            if not compact then
                file:write("            ")
            end

            for j=1,10 do

                if type(data.holograms[i][j]) == "string" then

                    file:write("\""..data.holograms[i][j].."\", ")
                elseif type(data.holograms[i][j]) == "table" then

                    file:write(textutils.serialise(data.holograms[i][j],{compact=true})..", ")
                else

                    file:write(tostring(data.holograms[i][j])..", ")
                end
            end
            writeToFile(file,"",0,true,compact)
            writeToFile(file,"</object>",2,true,compact)
        end
        writeToFile(file,"</holograms>",1,true,compact)
    end

    if data.groups then
        writeToFile(file,"<groups>",1,true,compact)

        for i=1,#data.groups do

            writeToFile(file,"<object>",2,true,compact)
            if not compact then
                file:write("            ")
            end

            for j=1,2 do

                if type(data.groups[i][j]) == "table" then
                    file:write("<object> ")
                    for k=1,#data.groups[i][j] do
                        file:write("\""..tostring(data.groups[i][j][k]).."\", ")
                    end
                    writeToFile(file,"</object>",0,true,compact)
                end
            end

            writeToFile(file,"</object>",2,true,compact)
        end

        writeToFile(file,"</groups>",1,true,compact)
    end

    writeToFile(file,"</body>",0,false,compact)
    --file:write("\n\n",textutils.serialise(data,{compact=true})) --used for debugging purposes
    file:close()
end

-- image based functions

---lets you load in a .nfp correctly!
---@param imgDir string is the path that get's loaded as image table
---@return table image the image as Matrix made of color values
loadImage = function(imgDir)
    if not fs.exists(imgDir) then errFunc() error("'"..tostring(imgDir).."' is not an existing File") return end

    --make a matrix out of the imageFile's Content
    local img={}
    local fileLines = getFileLines(imgDir)
    for i=1,#fileLines do
        if img[i] == nil then
            img[i]={}
        end
        for j=1,#fileLines[i] do
            if type(fileLines[i]) == "string" then
                table.insert(img[i],string.sub(fileLines[i],j,j))
            end
        end
    end

    --convert from '0123456789abcdef' to colorValue
    local newImg={}
    for i=1,#img do
        for j=1,table.maxn(img[i]) do
            if newImg[j] == nil then
                newImg[j]={}
            end
            newImg[j][i]=fromBlit(img[i][j])
        end
    end

    --return image Matrix
    return newImg
end

---this function is like term.setPalletColor but this accepts hex too and works for both terminal and monitor depending on output object
---@param color number the color you want to change
---@param hex string|number can be supplied a string like "#ff0000" or "0xff0000" or a number like 20 in which case it becomes the red amount
---@param g number|nil is the green amount if hex was give a number then this must be a number as well
---@param b number|nil is the blue amount if hex was give a number then this must be a number as well
setPaletteColor = function(color,hex,g,b)
    if not color or not hex then errFunc() error("no color and/or hex given!") return end
    local r
    if not g and not b then
        if string.find(hex,"#",1,true) then
            hex = string.gsub(hex,"#","0x",1)
            if not tonumber(hex) then errFunc() error("hex argument was not acceptable may have been incorrectly formatted") end
            hex = tonumber(string.format("0x%X", hex))
        elseif type(hex) ~= "number" then
            hex=tonumber(hex)
        end
        if not hex then errFunc() error("hex argument was not acceptable may have been incorrectly formatted") end
        r,g,b=colors.unpackRGB(hex)
    else
        r=hex
        if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
            errFunc() error("hex,g and b argument must be number")
        end
    end
    if monitor then
        monitor.setPaletteColor(color,r,g,b)
    else
        term.setPaletteColor(color,r,g,b)
    end
end

---generates a sprite of geometric shapes
---@param color number is the color of the shape
---@param shape string|nil is the geometric shape which you want ot generate a sprite for e.g: "circle","triangle","square"
---@param width number|nil is the width/radius(if it's a circle) of the shape must be provided for shapes: "square" & "circle"
---@param height number|nil is the height of the shape must be provided for shapes: "square" & "triangle"
---@param rightAngled boolean|nil will make a triangle right angled. Will default to false if not provided
---@param side string|nil will determine if the upper or lower half of the right angled triangle is given. Will default to "lower" if not provided
---@return table img is the image matrix of the shape
getShapeSprite=function(color,shape,width,height,rightAngled,side)
    local shapeSprite = {}

    if shape == "circle" then
        local center = width + 1

        for i= 1, 2*width + 1 do
            shapeSprite[i]={}
            for j= 1, 2*width+1 do
                local dx = j - center
                local dy = i - center
                if dx * dx + dy * dy <= width * width then
                    shapeSprite[i][j] = color
                end
            end
        end
    elseif shape == "triangle" then
        if rightAngled then

            for i = 1, height do
                shapeSprite[i] = {}
                for j = 1, height do
                    if j <= i and (not side) or side == "upper" then
                        shapeSprite[i][j] = color
                    elseif j >= i and side then
                        shapeSprite[i][j] = color
                    end
                end
            end
        else
            shapeSprite = {}
            local centerX = height

            for i = 1,height do
                for j = 1,height * 2 do
                    if not shapeSprite[j] then
                        shapeSprite[j] = {}
                    end
                    if j >= centerX - (i-1) and j<= centerX + (i-1) then
                        shapeSprite[j][i] = color
                    end
                end
            end
        end
    else
        for i=1,width do
            shapeSprite[i]={}
            for j=1,height do
                shapeSprite[i][j]=color
            end
        end
    end

    return shapeSprite
end

---lets you turn the given sprite in increments of 90 Degrees by the number of times you inputted
---@param sprite table is the sprite that gets turned
---@param times number is the amount of times it will iterate of rotations of 90 degrees
---@return table sprite is the rotated matrix of the sprite
turnSprite=function(sprite, times)
    if not sprite then errFunc() error("the sprite variable has to be a 2D Image(Matrix)") end
    if type(times) ~= "number" then times = 0 end

    times = times % 4 -- Only need 0 to 3 turns

    for _ = 1, times do
        local rotated = {}
        local rows = #sprite
        local maxCol = 0
        for i = 1, #sprite do
            maxCol = math.max(maxCol, #sprite[i])
        end

        for x = 1, maxCol do
            rotated[x] = {}
            for y = rows, 1, -1 do
            rotated[x][rows - y + 1] = sprite[y][x] or nil
            end
        end

        sprite={}
        for i=1,#rotated do
            sprite[i]={}
            for j=1,table.maxn(rotated[i]) do
                sprite[i][j] = rotated[i][j]
            end
        end
    end

    return sprite
end

---lets you set a background via TDGameLib.loadImage advised to be the length & width of the output object
---@param img table matrix give by TDGameLib.loadImage
setBackgroundImage=function(img)
    objects.render.background=img
end

-- object based functions

---adds a Sprite object to the render and returns the new object
---@param img table is the sprite of the game as matrix can be loaded using TDGameLib.loadImage
---@param priority number|nil level of priority when rendering will default to the highest when nil higher priority gets rendered over lower
---@param x number|nil X position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided
---@param y number|nil Y position of the sprite (will start rendering at that y pos). defaults to 1 if not provided
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. defaults to true if not provided
---@return table spriteObject is the created sprite object
function sprite:addSprite(img,priority,x,y,screenBound)
    local spriteData = {}

    if type(x) ~= "number" then x = 1 end
    if type(y) ~= "number" then y = 1 end

    if screenBound == nil then screenBound = true end
    spriteData.screenBound = toboolean(screenBound)

    if type(img) ~= "table" then errFunc() error("image has to be a table ('"..type(img).."' was supplied)") end

    if type(priority) ~= "number" then
        priority=#objects.render.sprites.list+1
    end
    if type(x) ~= "number" then
        x=1
    end
    if type(y) ~= "number" then
        y=1
    end
    if (x < 1-#img or x > width) and spriteData.screenBound then
        x=1
    end
    if (y < 1-table.maxn(img[1]) or y > height) and spriteData.screenBound then
        y=1
    end

    spriteData.x = math.floor(x)
    spriteData.y = math.floor(y)
    spriteData.type = "sprite"
    spriteData.sprite = img
    spriteData.priority = priority

    setmetatable(spriteData,self)
    self.__index= self

    table.insert(objects.render.sprites.list,{spriteData,priority})

    return spriteData
end

---adds a Hologram/Text object to the render and returns the new object
---@param text string is the text that is going to be displayed
---@param textColor table|nil is the text color of the displayed Text. If nil defaults to colors.white
---@param textBackgroundColor table|nil is the background color of the displayed Text. If not supplied will render with background Color of background
---@param priority number|nil level of priority when rendering will default to the highest when nil higher priority gets rendered over lower
---@param x number|nil X position of the Hologram (will print at that x pos). defaults to 1 if not provided
---@param y number|nil Y position of the Hologram (will print at that y pos). defaults to 1 if not provided
---@param dynamic boolean|nil if false will render it behind every sprite but it can not adjust to the sprite background colors. doesn't change the way it collides! will default to true if not provided
---@param wrapped boolean|nil if false won't wrap the text when to big (smart wrapping: wraps at last space if there is one in the current line otherwise wraps to screen size). will default to true if not provided
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. defaults to true if not provided
---@return table hologramObject is the created hologram object
function hologram:addHologram(text,textColor,textBackgroundColor,priority,x,y,dynamic,wrapped,screenBound)
    local hologramData= {}

    if type(x) ~= "number" then x = 1 end
    if type(y) ~= "number" then y = 1 end

    if dynamic == nil then dynamic = true end

    hologramData.dynamic = toboolean(dynamic)
    hologramData.wrapped = toboolean(wrapped)
    hologramData.screenBound = toboolean(screenBound)

    hologramData.textColor = textColor
    hologramData.textBackgroundColor = textBackgroundColor

    if not priority then
        if hologramData.dynamic then
            priority = #objects.render.holograms.list+1
        else
            priority = #objects.render.backgroundHolograms.list+1
        end
    end

    local textOut, textMaxWidth, correctionsCycles
    if hologramData.wrapped then correctionsCycles=3 else correctionsCycles = 1 end

    for _=1,correctionsCycles do
        if wrapped then
            textOut, textMaxWidth = wrapHologramText(hologramData.text,hologramData.x)
        else
            textOut = {text}
            textMaxWidth = #text
        end

        if (x < 1-textMaxWidth or x > width) and screenBound then
            x=1
        end
        if (y < 1 or y > height) and screenBound then
            y=1
        end
    end

    hologramData.x = math.floor(x)
    hologramData.y = math.floor(y)
    hologramData.text = textOut
    hologramData.priority = priority
    hologramData.textMaxWidth = textMaxWidth
    hologramData.type = "hologram"

    setmetatable(hologramData,self)
    self.__index = self

    if hologramData.dynamic then
        table.insert(objects.render.holograms.list,{hologramData,priority})
    else
        table.insert(objects.render.backgroundHolograms.list,{hologramData,priority})
    end

    return hologramData
end


function group:groupObjects(objects)
    local groupData = {}

    if type(objects) == "table" and not (objects.x or objects.lvlTable) then
        groupData.lvlTable = objects
    else
        groupData.lvlTable = {}
    end

    groupData.type = "group"

    setmetatable(groupData,self)
    self.__index = self

    table.insert(groups.list,groupData)

    return groupData
end

---lets you remove this object
function hologram:remove()
    if self.dynamic then
        for i=1,#objects.render.holograms.list do
            if self == objects.render.holograms.list[i][1] then
                objects.render.holograms.list[i] = nil
            end
        end
        objects.render.holograms.listLen = -1
    else
        for i=1,#objects.render.backgroundHolograms.list do
            if self == objects.render.backgroundHolograms.list[i][1] then
                objects.render.backgroundHolograms.list[i] = nil
            end
        end
        objects.render.backgroundHolograms.listLen = -1
    end


    setmetatable(self, {
        __index = function()
            return function()
                errFunc()
                error("ERROR: Can't use a removed hologram")
            end
        end
    })
end

---lets you remove this object
function sprite:remove()
    for i=1,#objects.render.sprites.list do
        if self == objects.render.sprites.list[i][1] then
            objects.render.sprites.list[i] = nil
        end
    end

    setmetatable(self, {
        __index = function()
            return function()
                errFunc()
                error("ERROR: Can't use a removed sprite")
            end
        end
    })

    objects.render.sprites.listLen = -1
end

---lets you remove this object
function group:remove()
    for i=1,#groups.list do
        if self == groups.list[i] then
            groups.list[i] = nil
        end
    end

    setmetatable(self, {
        __index = function()
            return function()
                errFunc()
                error("ERROR: Can't use a removed group")
            end
        end
    })
end

---lets you manipulate all data of a Sprite
---@param img table|nil is the sprite that will be displayed can be loaded from .nfp file through TDGameLib.loadImage won't change if not supplied
---@param x number|nil X position on screen that it starts to be rendered at. Won't change if not supplied
---@param y number|nil Y position on screen that it starts to be rendered at. Won't change if not supplied
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. defaults to true if not provided
function sprite:changeSpriteData(img,x,y,screenBound)

    if self.type == "spriteClone" then self:changeSpriteCloneData(x, y, screenBound) return end
    if screenBound ~= nil then self.screenBound = toboolean(screenBound) end

    if self.sprite then
        if type(x) == "number" then
            if not (x < 2-#self.sprite) and not (x > width) then
                self.x = math.floor(x)
            elseif not self.screenBound then
                self.x = math.floor(x)
            end
        end
        if type(y) == "number" then
            if not (y < 2-table.maxn(self.sprite[1])) and not (y > height) then
                self.y = math.floor(y)
            elseif not self.screenBound then
                self.y = math.floor(y)
            end
        end
    end
    if type(img) =="table" and self.sprite then
        self.sprite = img
    end
end

--lets you manipulate all data of a Hologram
---@param text string|nil is the text that is being displayed. Won't change if not supplied
---@param textColor table|nil is the color of the displayed text won't change if not supplied
---@param textBackgroundColor table|nil is the background color of the text that is being displayed. Won't change if not supplied
---@param x number|nil X position on screen that it gets written at. Won't change if not supplied
---@param y number|nil Y position on screen that it gets written at. Won't change if not supplied
---@param wrapped boolean|nil if false won't wrap the text when to big (smart wrapping: wraps at last space if there is one in the current line otherwise wraps to screen size). won't change if not provided
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. won't change if not provided
function hologram:changeHologramData(text,textColor,textBackgroundColor,x,y,wrapped,screenBound)

    if self.type == "hologramClone" then self:changeHologramCloneData(x, y,screenBound,wrapped) return end
    if wrapped ~= nil then self.wrapped = toboolean(wrapped) end
    if screenBound ~= nil then self.screenBound = toboolean(screenBound) end

    -- Traverse the table, creating sub-tables as needed

    local correctionsCycles
    if wrapped then correctionsCycles=3 else correctionsCycles = 1 end

    for _=1,correctionsCycles do
        if self.text ~= nil then
            if type(x) == "number" then
                if not (x < 2-self.textMaxWidth) and not (x > width) then
                    self.x = math.floor(x)
                elseif not self.screenBound then
                    self.x = math.floor(x)
                end
            end
            if type(y) == "number" then
                if not (y < 1) and not (y > height) then
                    self.y = math.floor(y)
                elseif not self.screenBound then
                    self.y = math.floor(y)
                end
            end
        end

        if text then
            if wrapped then
                self.text, self.textMaxWidth = wrapHologramText(text,self.x)
            else
                self.text = {text}
                self.textMaxWidth = #text
            end
        end
    end

    if type(textColor) == "table" then
        self.textColor = textColor
    end
    if type(textBackgroundColor) == "table" then
        self.textBackgroundColor = textBackgroundColor
    end
end

function group:addObjectsToGroup(objects)
    if type(objects) ~= "table" then
        errFunc() error("this function was not give a tables made of objects")
    end
    if objects.x or objects.lvlTable then
        error("this is a object")
    end

    for i=1,#objects do
        table.insert(self.lvlTable,objects[i])
    end
end

function group:removeObjectFromGroup(object)
    for i = 1,#self.lvlTable do
        if object == self.lvlTable[i] then
            table.remove(self.lvlTable,i)
        end
    end
end

function group:changeGroupData(x,y,screenBound)
    for i = 1,#self.lvlTable do
        local object = self.lvlTable[i]
        if type(x) == "number" then
            object.x = object.x + math.floor(x)
        end
        if type(y) == "number" then
            object.y = object.y + math.floor(y)
        end
        if not screenBound == nil then
            object.screenBound = toboolean(screenBound)
        end
    end
end

---allows you to make a clone of an object this wll create a object that gets some data from its parent object
---@param object table is the object that will get cloned
---@param priority number|nil level of priority when rendering will default to the highest when nil higher priority gets rendered over lower. can not be the priority of thr original sprite
---@param x number|nil X position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided
---@param y number|nil Y position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided
---@param group table|nil if group object is supplied will add cloned object to a group
---@return table object is the clone of the original object
cloneObject=function(object,priority,x,y,group,wrapped,screenBound)
    if object.type == "sprite" then
        return sprite:clone(object,priority,x,y,group)
    elseif object.type == "hologram" then 
        return hologram:clone(object,priority,x,y,group)
    end
end

---lets you check if an object (including groups) is on top of an other object (including groups) returns true if it is, otherwise it returns false uses bounding boxes. Waring may fail if supplied, a group containing more groups (due to lua function stacking prevention)!
---@param obj1 table is a string that gives it the hierarchy of the first object (including groups) to check e.g: "test.string"
---@param obj2 table is a string that gives it the hierarchy of the second object (including groups) to check e.g: "test.number"
---@param isTransparent boolean|nil if true an empty space colliding counts as a collision. Defaults to false if not supplied
---@returns boolean
isColliding=function(obj1, obj2, isTransparent)
    --add fails save for must be objects

    if isTransparent == nil then
        isTransparent = false
    end

    if not obj1 or not obj2 or not obj1.type or not obj2.type then return false end

    if obj1.type == "group" and obj2.type == "group" then
        local groupList1=obj1.lvlTable
        local groupList2=obj2.lvlTable

        if type(groupList1) ~= "table" or type(groupList2) ~= "table" then return false end

        for i=1,table.maxn(groupList1) do

            for j=1,table.maxn(groupList2) do

                if isColliding(groupList1[i], groupList2[j], isTransparent) then
                    return true
                end
            end
        end

        return false
    elseif obj1.type == "group" and obj2.type ~= "group" then
        local groupList=obj1.lvlTable

        if type(groupList) ~= "table" then return false end

        for i=1,table.maxn(groupList) do

            if isColliding(groupList[i], lvl2, isTransparent) then
                return true
            end
        end

        return false
    elseif obj1.type ~= "group" and obj2.type == "group" then
        local groupList=obj2.lvlTable

        if type(groupList) ~= "table" then return false end

        for i=1,table.maxn(groupList) do

            if isColliding(groupList[i], lvl, isTransparent) then
                return true
            end
        end

        return false
    end

    if not (obj1.x and obj1.y and obj2.x and obj2.y) then return false end

    local x1, y1 = obj1.x + renderStartX, obj1.y + renderStartY
    local x2, y2 = obj2.x + renderStartX, obj2.y + renderStartY
    local w1, h1, w2, h2 = 0, 0, 0, 0

    -- Get width and height for each object type
    if obj1.type == "sprite" or obj1.type == "spriteClone" then

        if not obj1.sprite then return false end

        if obj1.type == "spriteClone" then
            if not obj1.sprite.sprite then return false end

            w1, h1 = #obj1.sprite.sprite, getBiggestIndex(obj1.sprite.sprite)
        else

            w1, h1 = #obj1.sprite, getBiggestIndex(obj1.sprite) 
        end
    elseif obj1.type == "hologram" or obj1.type == "hologramClone" then

        if not obj1.text then return false end
        local text

        if obj1.type == "hologramClone" then
            if not obj1.text.text then return false end
            text = obj1.text.text
        else
            text = obj1.text.text
        end

        for i=1,#text do
            if w1 < #tostring(text[i]) then
                w1 = #tostring(text[i])
            end
        end

        h1 = #text
    end

    if obj2.type == "sprite" or obj2.type == "spriteClone" then

        if not obj2.sprite then return false end

        if obj2.type == "spriteClone" then
            if not obj2.sprite.sprite then return false end

            w2, h2 = #obj2.sprite.sprite, getBiggestIndex(obj2.sprite.sprite)
        else

            w2, h2 = #obj2.sprite, getBiggestIndex(obj2.sprite)
        end
    elseif obj2.type == "hologram" or obj2.type == "hologramClone" then

        if not obj2.text then return false end
        local text

        if obj2.type == "hologramClone" then
            if not obj2.text.text then return false end
            text = obj2.text.text
        else
            text = obj2.text
        end

        for i=1,#text do
            if w2 < #tostring(text[i]) then
                w2 = #tostring(text[i])
            end
        end

        h2 = #text
    end

    -- Refined Bounding box check (avoid false positives where they just touch)
    if x1 + w1 <= x2 or x1 >= x2 + w2 or y1 + h1 <= y2 or y1 >= y2 + h2 then
        return false
    end

    -- Sprite vs Sprite (Pixel-perfect collision)
    if (obj1.type == "sprite" or obj1.type == "spriteClone") and (obj2.type == "sprite" or obj2.type == "spriteClone") then
        local sprite1, sprite2 = obj1.sprite, obj2.sprite

        if obj1.type=="spriteClone" then
            sprite1 = obj1.sprite.sprite
        end
        if obj2.type=="spriteClone" then
            sprite2 = obj2.sprite.sprite
        end
        if not (sprite1 and sprite2) then return false end

        for i = 1, #sprite1 do
            for j = 1, table.maxn(sprite1[i]) do
                local px1, py1 = x1 + i - 1, y1 + j - 1
                local relX, relY = px1 - x2 + 1, py1 - y2 + 1
                if relX > 0 and relY > 0 and sprite2[relX] and sprite2[relX][relY] then
                    if (not isTransparent) and (isColorValue(sprite1[i][j]) and isColorValue(sprite2[relX][relY])) then
                        return true
                    elseif isTransparent then
                        return true
                    end
                end
            end
        end
    end

    -- Sprite vs Hologram
    if (obj1.type == "sprite" or obj1.type == "spriteClone") and (obj2.type == "hologram" or obj2.type == "hologramClone") then
        local sprite = obj1.sprite
        if obj1.type=="spriteClone" then
            sprite = obj1.sprite.sprite
        end

        local text = obj2.text
        if obj2.type == "hologramClone" then
            text = obj2.text.text
        end

        if not sprite then return false end

        for i = 1, #sprite do
            for j = 1, table.maxn(sprite[i]) do
                local px, py = x1 + i - 1, y1 + j - 1 -- Actual world position of pixel
                local relY = py - y2 + 1 -- Adjust to hologram text coordinates

                -- Ensure relY is within obj2's text bounds
                if relY >= 1 and relY <= #text then
                    local textLine = text[relY]
                    local startX = x2 + (text[relY]:find("%S") or 1) - 1 -- First non-space X in obj2

                    local relX = px - startX + 1 -- Adjusted X position in text

                    -- Ensure relX is within obj2's text bounds
                    if relX >= 1 and relX <= #textLine then
                        local textChar = textLine:sub(relX, relX)

                        -- If the sprite pixel is not transparent and the textChar is not a space, collision detected
                        if sprite[i][j] and textChar ~= " " and not isTransparent then
                            return true
                        elseif isTransparent then
                            return true
                        end
                    end
                end
            end
        end
    end

    -- Hologram vs Sprite (flipped case)
    if obj1.type == "hologram" and (obj2.type == "sprite" or obj2.type == "spriteClone") then
        return isColliding(obj2, obj, isTransparent)
    end

    -- Hologram vs Hologram
    if (obj1.type == "hologram" or obj1.type == "hologramClone") and (obj2.type == "hologram" or obj2.type == "hologramClone") then
        local text1, text2 = obj1.text, obj2.text

        if obj1.type == "hologramClone" then
            text1 = obj1.text.text
        end
        if obj2.type == "hologramClone" then
            text2 = obj2.text.text
        end
        for i = 1, #text1 do
            local relY = y1 + (i - 1) - y2 + 1 -- Adjust vertical alignment

            -- Ensure relY is within obj2's text bounds
            if relY >= 1 and relY <= #text2 then
                local textLine1 = text1[i]
                local textLine2 = text2[relY]

                local startX1 = x1 + (text1[i]:find("%S") or 1) - 1 -- First non-space X in obj1
                local startX2 = x2 + (text2[relY]:find("%S") or 1) - 1 -- First non-space X in obj2

                for j = 1, #textLine1 do
                    local relX = startX1 + (j - 1) - startX2 + 1 -- Adjusted X position

                    -- Ensure relX is within obj2's text bounds
                    if relX >= 1 and relX <= #textLine2 then
                        local char1 = textLine1:sub(j, j)
                        local char2 = textLine2:sub(relX, relX)

                        -- If both characters are non-space, collision detected
                        if char1 ~= " " and char2 ~= " " and not isTransparent then
                            return true
                        elseif isTransparent then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

---lets you check if a object (including groups) is rendered at certain X,Y Coordinates. Waring may fail if supplied, a group containing more groups (due to lua function stacking prevention)!
---@param xIn number is the X coordinate for the collision check
---@param yIn number is the Y coordinate for the collision check
---@param obj string is a string that gives it the hierarchy of the object to check e.g: "test.string"
---@param isTransparent boolean|nil if true an empty space colliding counts as a collision. Defaults to false if not supplied
---@returns boolean
isCollidingRaw=function(xIn, yIn, obj, isTransparent)
    --add fails save for must be object

    if type(xIn) ~="number" or type(yIn) ~= "number" then
        errFunc()
        error("argument 1 and 2 must be numbers")
    end

    if isTransparent == nil then
        isTransparent = false
    end

    if not obj or not obj.type then return false end

    if obj.type == "group" then
        local groupList=obj.lvlTable

        if type(groupList) ~= "table" then return false end

        for i=1,#groupList do

            if isCollidingRaw(xIn, yIn, groupList[i], isTransparent) then

                return true
            end
        end

        return false
    end

    if not (obj.x and obj.y) then return false end

    local x, y = obj.x + renderStartX, obj.y + renderStartY
    local w, h = 0, 0

    -- Get width and height for each object type
    if obj.type == "sprite" or obj.type == "spriteClone" then
        if not obj.sprite then return false end
        if obj.type == "spriteClone" then
            if not obj.sprite.sprite then return false end

            w, h = #obj.sprite.sprite , getBiggestIndex(obj.sprite.sprite )
        else
            w, h = #obj.sprite, getBiggestIndex(obj.sprite)
        end
    elseif obj.type == "hologram" or obj.type == "hologramClone" then
        if not obj.text then return false end
        local text 
        if obj.type == "hologramClone" then
            text = obj.text.text
        else
            text = obj.text
        end

        for i=1,#text do
            if w < #tostring(text[i]) then
                w = #tostring(text[i])
            end
        end

        h = #text
    end

    -- Bounding box check
    if xIn < x or xIn >= x + w or yIn < y or yIn >= y + h then
        return false
    end

    -- Pixel-perfect check (for sprites only)
    if obj.type == "sprite" or obj.type == "spriteClone" then
        local sprite
        if obj.type == "spriteClone" then
            sprite=obj.sprite.sprite
        else
            sprite = obj.sprite
        end

        if not sprite then return false end

        local spriteX = xIn - x + 1
        local spriteY = yIn - y + 1
        local pixel = sprite[spriteX] and sprite[spriteX][spriteY]

        -- Check if the pixel is actually "solid"
        if not isColorValue(pixel) and not isTransparent then
            return false
        end
    end

    if obj.type == "hologram" or obj.type == "hologramClone" then
        local text
        if obj.type == "hologramClone" then
            text = obj.text.text
        else
            text = obj.text
        end

        local textX = xIn - x + 1
        local textY = yIn - y + 1
        local line = text[textY]

        if line then
            local char = line:sub(textX, textX)

            if char == " " and not isTransparent then
                return false
            end
        else

            return false
        end
    end

    return true
end

---this function is like the read() function except it is like a window to write in
---@param width number is width of the window to write in note that the cursor also takes up 1 space so the amount of characters shown are width-1
---@param character string|nil if supplied replaces every input with this character like read(character)
---@param preFix string|nil if supplied is put in front of the typing space (will attach to the read window)
---@param onChar function|nil if provided can determine behavior of function when a character(e.g:'c') was entered
---@param onKey function|nil if provided can determine behavior of function when a key(e.g:'backspace') was entered
---@return string userInput is the input from the user as a string
function hologram:read(width, preFix, character, onChar, onKey)
    if monitor then printError("ERRORecp: TDGameLib.read should not be used when rendering on a screen!") end

    if not (self.text and self.y and self.x) then errFunc() error("Invalid hologram object") end
    if type(width) ~= "number" then errFunc() error("width must be a number") end

    if self.type == "hologramClone" then errFunc() error("1 argument can't be a clone") end

    preFix = preFix or ""
    preFix = tostring(preFix)
    local currentBackgroundColor = term.getBackgroundColor()
    local currentTextColor = term.getTextColor()

    local preWrapped = self.wrapped
    local readOut, cursorPos = "", 0
    local displayText = ""
    local event, key
    local y = self.y
    local startX = self.x
    self.wrapped = false

    if type(onChar) ~= "function" then 
        onChar = function(key, readOut, cursorPos)
            readOut = readOut:sub(1, cursorPos) .. key .. readOut:sub(cursorPos + 1)
            cursorPos = cursorPos + 1

            return readOut, cursorPos
        end
    end

    if type(onKey) ~= "function" then
        onKey = function(key, readOut, cursorPos)
            if key == keys.backspace and cursorPos > 0 then
                readOut = readOut:sub(1, cursorPos - 1) .. readOut:sub(cursorPos + 1)
                cursorPos = cursorPos - 1

            elseif key == keys.left and cursorPos > 0 then
                cursorPos = cursorPos - 1

            elseif key == keys.right and cursorPos < #readOut then
                cursorPos = cursorPos + 1
            end

            return readOut, cursorPos
        end
    end

    while key ~= keys.enter do
        term.setCursorBlink(true)

        -- Calculate which slice of text to display
        local displayStart = math.max(1, cursorPos - width + 2)
        local displayEnd = displayStart + width - 1
        local rawDisplay = readOut:sub(displayStart, displayEnd)

        if character then
            displayText = string.rep(character, #rawDisplay)
        else
            displayText = rawDisplay
        end

        -- Pad with spaces to keep width exact
        if #displayText < width then
            displayText =displayText .. string.rep(" ", width - #displayText)
        end

        displayText = preFix .. displayText

        -- Draw field
        self.text = {displayText}
        term.setCursorBlink(false)
        self:render()
        term.setCursorBlink(true)

        -- Determine visual cursor X position
        local relativeCursor = cursorPos - displayStart + 2 -- +2: +1 for Lua indexing, +1 to be "in front"
        local cursorX = #preFix + startX + math.min(math.max(0, relativeCursor - 1), width)
        term.setCursorPos(cursorX, y) -- add 1 to position it *after* the visible character

        -- Handle input
        event, key = os.pullEvent() 

        if event == "char" then
            readOut, cursorPos = onChar(key, readOut, cursorPos)
        elseif event == "key" then
            readOut, cursorPos = onKey(key, readOut, cursorPos)
        end
        if type(cursorPos) ~= "number" then errFunc() error("ERROR: onKey or onChar returned invalid cursorPos (returned type: '"..type(cursorPos).."') should have been type: 'number'") end
        if type(readOut) ~= "string" then errFunc() error("ERROR: onKey or onChar did not return a string (returned type: '"..type(readOut).."') should have been type: 'string'") end
        cursorPos = math.floor(cursorPos)
    end
    self.wrapped = preWrapped

    term.setCursorBlink(false)
    term.setCursorPos(1, y + 1)
    term.setTextColor(currentTextColor)
    term.setBackgroundColor(currentBackgroundColor)
    return readOut
end

--rendering based functions

---lets you render just this object (does not include background)
function sprite:render()
    if monitor then
        monitor.setCursorPos(1,1)
    else
        term.setCursorPos(1,1)
    end

    -- get values from the given Sprite path
    local renderSprite = self.sprite or {}
    if self.type == "spriteClone" then
        renderSprite = self.sprite.sprite or {}
    end

    local renderX = self.x or 1
    local renderY = self.y or 1
    renderX = renderX - 1
    renderY = renderY -1

    for i = 1, #renderSprite do
        for j = 1, table.maxn(renderSprite[i]) do
            if isColorValue(renderSprite[i][j]) then
                drawPixel(i + renderX + renderStartX, j + renderY + renderStartY, renderSprite[i][j])
                if screen[i + renderX] then
                    if screen[i + renderX][j + renderY] and isColorValue(renderSprite[i][j]) then
                        screen[i + renderX][j + renderY] = renderSprite[i][j]
                    end
                end
            end
        end
    end
end

---lets you render just this object (does not include background)
function hologram:render()
    -- get values from the given Hologram path
    if self.dynamic then
        local renderText = self.text
        local renderTextColor = self.textColor
        local renderTextBackgroundColor = self.textBackgroundColor
        if self.type == "hologramClone" then
            renderText = self.text.text
            renderTextColor = self.textColor.textColor
            renderTextBackgroundColor = self.textBackgroundColor.textBackgroundColor
        end

        if monitor then
            monitor.setTextColor(colors.white)
        else
            term.setTextColor(colors.white)
        end

        local renderX = self.x or 1
        local renderY = self.y or 1

        local textColorTable = {}
        if type(renderTextColor) == "table" then
            for color, textPos in pairs(renderTextColor) do
                textColorTable[textPos] = colors[color]
            end
        end

        local textBackgroundColorTable = {}
        if type(renderTextBackgroundColor) == "table" then
            for color, textPos in pairs(renderTextBackgroundColor) do
                textBackgroundColorTable[textPos] = colors[color]
            end
        end   

        local textBackgroundColorSet = false
        local textColorPos = 0
        local textOut = ""
        for i =1, #renderText do

            if monitor then
                monitor.setCursorPos(renderX + renderStartX, renderY + renderStartY + (i - 1))
            else
                term.setCursorPos(renderX + renderStartX, renderY + renderStartY + (i - 1))
            end

            textOut = tostring(renderText[i])

            for j = 1, #renderText[i] do
                if isColorValue(textColorTable[j+textColorPos]) then
                    if monitor then
                        monitor.setTextColor(textColorTable[j+textColorPos])
                    else
                        term.setTextColor(textColorTable[j+textColorPos])
                    end
                end
                if isColorValue(textBackgroundColorTable[j+textColorPos]) then
                    if monitor then
                        monitor.setBackgroundColor(textBackgroundColorTable[j+textColorPos])
                    else
                        term.setBackgroundColor(textBackgroundColorTable[j+textColorPos])
                    end
                    textBackgroundColorSet = true
                elseif screen[renderX + (j - 1)] then
                    if isColorValue(screen[renderX + (j - 1)][renderY + (i - 1)]) and not textBackgroundColorSet then
                        if monitor then
                            monitor.setBackgroundColor(screen[renderX + (j - 1)][renderY + (i - 1)])
                        else
                            term.setBackgroundColor(screen[renderX + (j - 1)][renderY + (i - 1)])
                        end
                    end
                end
                if monitor then
                    monitor.write(string.sub(textOut, j, j))
                else
                    term.write(string.sub(textOut, j, j))
                end
            end
            textColorPos = textColorPos + #textOut
        end
    else
        -- get values from the given Hologram path
        local renderText = self.text
        local renderTextColor = self.textColor
        local renderTextBackgroundColor = self.textBackgroundColor
        if self.type == "hologramClone" then
            renderText = self.text.text
            renderTextColor = self.text.textColor
            renderTextBackgroundColor = self.text.textBackgroundColor
        end

        local renderX = self.x or 1
        local renderY = self.y or 1

        local textColorTable = {}
        if type(renderTextColor) == "table" then
            for color, textPos in pairs(renderTextColor) do
                textColorTable[textPos] = colors[color]
            end
        end

        local textBackgroundColorTable = {}
        if type(renderTextBackgroundColor) == "table" then
            for color, textPos in pairs(renderTextBackgroundColor) do
                textBackgroundColorTable[textPos] = colors[color]
            end
        end

        local textBackgroundColorSet = false
        local textColorPos = 0
        local textOut = ""
        for i =1, #renderText do

            if monitor then
                monitor.setCursorPos(renderX + renderStartX, renderY + renderStartY + (i - 1))
                monitor.setTextColor(colors.white)
            else
                term.setCursorPos(renderX + renderStartX, renderY + renderStartY + (i - 1))
                term.setTextColor(colors.white)
            end

            textOut = tostring(renderText[i])

            for j = 1, #renderText[i] do
                if isColorValue(textColorTable[j]) then
                    if monitor then
                        monitor.setTextColor(textColorTable[j+textColorPos])
                    else
                        term.setTextColor(textColorTable[j+textColorPos])
                    end
                end
                if isColorValue(textBackgroundColorTable[j+textColorPos]) then
                    if monitor then
                        monitor.setBackgroundColor(textBackgroundColorTable[j+textColorPos])
                    else
                        term.setBackgroundColor(textBackgroundColorTable[j+textColorPos])
                    end
                    textBackgroundColorSet = true
                elseif screen[renderX + (j - 1)] then
                    if isColorValue(screen[renderX + (j - 1)][renderY + (i - 1)]) and not textBackgroundColorSet then
                        if monitor then
                            monitor.setBackgroundColor(screen[renderX + (j - 1)][renderY + (i - 1)])
                        else
                            term.setBackgroundColor(screen[renderX + (j - 1)][renderY + (i - 1)])
                        end
                    end
                end
                if monitor then
                    monitor.write(string.sub(textOut, j, j))
                else
                    term.write(string.sub(textOut, j, j))
                end
            end
            textColorPos = textColorPos + #textOut
        end
    end
end

---lets you render just the background (does not include objects)
renderBackground = function()
    for i = 1, width do
        for j = 1, height do
            if objects.render.background[i] then
                if isColorValue(objects.render.background[i][j]) then
                    drawPixel(i + renderStartX, j + renderStartY, objects.render.background[i][j])
                    if not screen[i] then
                        screen[i] = {}
                    end
                    screen[i][j] = objects.render.background[i][j]
                end
            end
        end
    end
end

---lets you render all objects and background
render=function()
    --[[for i=1,#self.gameMEM.dataFileCache.clones do
        if self.gameMEM.dataFileCache.clones[i] then
            if self:cloneObject(self.gameMEM.dataFileCache.clones[i][1],self.gameMEM.dataFileCache.clones[i][2],self.gameMEM.dataFileCache.clones[i][3],self.gameMEM.dataFileCache.clones[i][4],self.gameMEM.dataFileCache.clones[i][5],self.gameMEM.dataFileCache.clones[i][6]) then
                table.remove(self.gameMEM.dataFileCache.clones,i)
            end
        end
    end]]

    objects.render.subTasks = {}
    local CurX, CurY
    local currentBackgroundColor
    local currentTextColor

    if monitor then
        CurX, CurY = monitor.getCursorPos()
        currentBackgroundColor = monitor.getBackgroundColor()
        currentTextColor = monitor.getTextColor()
    else
        CurX, CurY = term.getCursorPos()
        currentBackgroundColor = term.getBackgroundColor()
        currentTextColor = term.getTextColor()
    end

    --Rendering background (threaded)
    table.insert(objects.render.subTasks,function() 
        for i = 1, width do
            for j = 1, height do
                if objects.render.background[i] then
                    if isColorValue(objects.render.background[i][j]) then
                        drawPixel(i + renderStartX, j + renderStartY, objects.render.background[i][j])
                        if not screen[i] then
                            screen[i] = {}
                        end
                        screen[i][j] = objects.render.background[i][j]
                    end
                end
            end
        end
    end)

    --create renderList for backgroundHolograms
    if objects.render.backgroundHolograms.listLen ~= #objects.render.backgroundHolograms.list then
        objects.render.backgroundHolograms.renderList = {}
        for i = 1, #objects.render.backgroundHolograms.list do
            if objects.render.backgroundHolograms.list[i] ~= nil then
                objects.render.backgroundHolograms.renderList[objects.render.backgroundHolograms.list[i][2]] = objects.render.backgroundHolograms.list[i][1]
                objects.render.backgroundHolograms.listLen = #objects.render.backgroundHolograms.list
            end
        end
    end

    --crate renderList for sprites
    if objects.render.sprites.listLen ~= #objects.render.sprites.list then
        objects.render.sprites.renderList = {}
        for i = 1, #objects.render.sprites.list do
            if objects.render.sprites.list[i] ~= nil then
                objects.render.sprites.renderList[objects.render.sprites.list[i][2]] = objects.render.sprites.list[i][1]
                objects.render.sprites.listLen = #objects.render.sprites.list
            end
        end
    end

    --crate renderList for holograms (dynamic)
    if objects.render.holograms.listLen ~= #objects.render.holograms.list then
        objects.render.holograms.renderList = {}
        for i = 1, #objects.render.holograms.list do
            if objects.render.holograms.list[i] ~= nil then
                objects.render.holograms.renderList[objects.render.holograms.list[i][2]] = objects.render.holograms.list[i][1]
                objects.render.holograms.listLen = #objects.render.holograms.list
            end
        end
    end

    --Rendering backgroundHolograms (threaded)
    for i = 1,table.maxn(objects.render.backgroundHolograms.renderList) do
        if type(objects.render.backgroundHolograms.renderList[i]) == "table" then
            table.insert(objects.render.subTasks,function ()
                objects.render.backgroundHolograms.renderList[i]:render()
            end)
        end
    end

    --Rendering sprites (threaded)
    for i = 1, table.maxn(objects.render.sprites.renderList) do
        if type(objects.render.sprites.renderList[i]) == "table" then
            table.insert(objects.render.subTasks,function ()
                objects.render.sprites.renderList[i]:render()
            end)
        end
    end

    --Rendering holograms (dynamic) (threaded)
    for i = 1,table.maxn(objects.render.holograms.renderList) do
        if type(objects.render.holograms.renderList[i]) == "table" then
            table.insert(objects.render.subTasks,function ()
                objects.render.holograms.renderList[i]:render()
            end)
        end
    end

    --[[for i =1,#self.gameMEM.objects.render.subTasks do
        parallel.waitForAny(self.gameMEM.objects.render.subTasks[i])
    end]]
    parallel.waitForAll(table.unpack(objects.render.subTasks))

    if monitor then
        monitor.setTextColor(currentTextColor)
        monitor.setBackgroundColor(currentBackgroundColor)
        monitor.setCursorPos(CurX, CurY)
    else
        term.setTextColor(currentTextColor)
        term.setBackgroundColor(currentBackgroundColor)
        term.setCursorPos(CurX, CurY)
    end

    if systemOut then
        systemOut:display()
    end
end
