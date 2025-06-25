--this "libs" comment to gether with the "/libs" comment defines what libraries
--"import" tells the program what libraries exactly
--libs
--import<libs/testLib.lua>
--/libs


--NOTE: no need to add openUILib as library it will have already initiated on the other side!

--[[
return codes:
+------+----------------+--------------------------+
| code | action         | additional requirements  |
+------+----------------+--------------------------+
| -1   | ends page      | None                     |
|  1   | loads new page | must return page message | --the message to give the server to download the page will be  shown in the server.lua file
|      |                |                          |
+-----------------------+--------------------------+
]]

local something,somethingSprite
local sizeX,sizeY = term.getSize()

init = function (path)
    os.loadAPI(path.."libs/testLib.lua")--on receiving computer will find root and then go back one folder to enter apis folder where testLib.lua was downloaded to

    somethingSprite = openUILib.getShapeSprite(colors.blue,"triangle",5,5)
    something = openUILib.sprite:addSprite(somethingSprite,nil,2,2)

    local background = {}
    for i=0,sizeX do
        background[i]={}
        for j=0,sizeY do
            background[i][j] = colors.gray
        end
    end

    openUILib.setBackgroundImage(background)
end

main = function(path)--there are currently 1 argument. this argument is the root path of the mcNet client
    for _=1,20 do
        testLib.test()
        somethingSprite = openUILib.turnSprite(somethingSprite,1)
        something:changeSpriteData(somethingSprite)
        openUILib.render()
        sleep(0.5)
    end
end
