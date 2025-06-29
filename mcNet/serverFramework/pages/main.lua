--this "libs" comment to gether with the "/libs" comment defines the start of library definition
--"import" tells the program what libraries to import exactly
--libs
--import<libs/testLib.lua>
--/libs


--NOTE: no need to add openUILib as library it will have already initiated on the other side!

--[[
return codes:
+------+----------------------+--------------------------+
| code | action               | additional requirements  |
+------+----------------------+--------------------------+
| -3   | Ends net program     | None                     |
| -2   | Ends page            | None                     |
| -1   | Goes back 1 page     | None                     |
|  1   | Reloads current page | None                     |
|  2   | Loads new page       | Must return page message | --the message to give the server to download the page will be  shown in the server.lua file
+-----------------------------+--------------------------+
]]

local something,somethingSprite
local sizeX,sizeY = term.getSize()

--disconnect runs once the client returns to the home page or exits the program (won't run when terminated)
disconnect = function()
    systemOut:print("hello world2")
end

--hudUsed runs when the hud registered a mouse_click event
hubUsed = function()
    systemOut:print("hello world")
end

--init runs once upon startup
init = function (path)
    os.loadAPI(path.."libs/testLib.lua")--on receiving computer will find root and then go back one folder to enter apis folder where testLib.lua was downloaded to

    somethingSprite = openUILib.getShapeSprite(colors.blue,"triangle",5,5)
    something = openUILib.sprite:addSprite(somethingSprite,nil,10,2)

    local background = {}
    for i=0,sizeX do
        background[i]={}
        for j=0,sizeY do
            background[i][j] = colors.gray
        end
    end

    openUILib.setBackgroundImage(background)
end

--main repeatedly runs in a loop together with the hud (if hud is used will stop)
main = function(path)--there are currently 1 argument. this argument is the root path of the mcNet client
    for i=1,math.random(30) do
        testLib.test(i)
        somethingSprite = openUILib.turnSprite(somethingSprite,1)
        something:changeSpriteData(somethingSprite)
        openUILib.render()
        sleep(0.1)
    end
end
