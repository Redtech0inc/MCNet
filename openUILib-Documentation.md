# DISCLAIMER
this is the same library as the TDGameLib which was made for 2D game development so the commands are the same but use openUILib. instead of TDGameLib.
this has to do with the fact that i made this library before mcNet and i find it hady to use when making rendered scripts

for all the coding nerds thhe only difference is in the render function where i added one more line of code but that changes nothing about how it's used!

# About the Object based TDGameLib

## Info

### Description


the object oriented TDGameLib is a rewrite of the original TDGameLib
<br><br>
it's a library that takes over the tedious process of rendering and collision made for the CCTweaked minecraft mod

this library works for almost any CCTweaked version

guaranteed to work with ccTweaked mc versions: 1.12.x to 1.20.x

### How to set up

to set up the TDGameLib you can use:
```lua
os.loadAPI(fileDirectory)
```
or
```lua
require(fileName)
```

`fileDirectory` is the directory of the file e.g: `APIs/TDGameLib.lua` <br>
and `fileName` is the name of the file e.g: `TDGameLib.lua`

## Functions

this part of the doc talks about the functions inside of this pack and how you can add your won to the objects

### Framework Based Functions

these are functions that interact with the base frame work

#### Init
```lua
TDGameLib.init(name: any, onErrorCall: function|nil, useMonitor: boolean|nil, allowFallback: boolean|nil, monitorFilter: function|table|nil, pixelSize: number|nil, screenStartX: number|nil, screenStartY: number|nil, screenEndX: number|nil, screenEndY: number|nil)
```

<b>Description:</b><br>
initiates a framework for a 2D game and sets base variables <b>MUST BE CALLED FIRST</b>

<b>Arguments:</b><br>
>name: name of the game given to the game.gameName

>onErrorCall: if supplied is called before the TDGameLib Runs into an error, may not work if the error not called by GameLib it's self!

>useMonitor: if true will make the game render on a connected monitor. defaults to false if not provided

>allowFallback: if true will use the terminal instead of the monitor when no monitor was found (REQUIRES MONITOR)

>monitorFilter: is the name of the monitor that gets picked, will pick names higher up first. can also be a function that filters like the normal peripheral.find (REQUIRES MONITOR)

>pixelSize: is the size of a pixel on a monitor can range from 0.5 to 5 (REQUIRES MONITOR)

>screenStartX:l is the X coordinate at which the render starts, defaults to 1 if not provided

>screenStartY: is the Y coordinate at which the render starts, defaults to 1 if not provided

>screenEndX: is the X coordinate at which the render ends, defaults to output object width if not provided

>screenEndY: is the Y coordinate at which the render ends, defaults to output object height if not provided
<br>

#### Quit
```lua
TDGameLib.quit(restart: boolean|nil, exitMessage: string|nil, exitMessageColor: number|nil)
```
<b>Description:</b><br>
ends the game and removes the framework

<b>Arguments:</b><br>
>restart: if true restarts the computer otherwise just resets the terminal/monitor. If not provided defaults to false

>exitMessage: is a message that get's displayed once this function is called. will only showup if restart is false or nil

>exitMessageColor: is the color of he exit message

<br>

#### Clear Framework
```lua
TDGameLib.clearFrameWork()
```
<b>Description:</b><br>
lets you remove all objects from the render !!!Will delete all object data!!!

<br>

#### Use Data File
```lua
TDGameLib.useDataFile(fileDir: string)
``` 
<b>Description:</b><br>
lets you load in game assets from a .data(.html and .xml mix: tag based) notation file. Will return an error if the .data file has invalid data or something went wrong whilst adding or grouping objects

<b>Arguments:</b><br>
>fileDir: the directory of the file that you want to load

<b>Returns:</b><br>
>objectList: table ;is a table consisting of all object read out from the .data file

<br>

#### Make Data File
```lua
TDGameLib.makeDataFile(fileDir: string, compact: boolean|nil)
```
<b>Description:</b><br>
lets you take all objects & groups and turn them into a .data(.html and .xml mix: tag based) file

<b>Arguments:</b><br>
>fileDir: is the directory where the file will be saved

>compact: if true will compact the content into one line useful for space saving otherwise uses indentation for readability. defaults to false if not provided

<br>

### Image Based Functions

these functions can manipulate or load images

#### Load Image
```lua
TDGameLib.loadImage(imgDir: string)
```
<b>Description:</b><br>
lets you load in a .nfp correctly!

<b>Arguments:</b><br>
>imgDir: is the path that get's loaded as image table

<b>Returns:</b><br>
>image: table ;the image as Matrix made of color values

<br>

#### Set Palette Color
```lua
TDGameLib.setPaletteColor(color: number, hex: string|number, g: number|nil, b: number|nil)
```
<b>Description:</b><br>
this function is like term.setPalletColor but this accepts hex too and works for both terminal and monitor depending on output object

<b>Arguments:</b><br>
>color: the color you want to change

>hex: can be supplied a string like "#ff0000" or "0xff0000" or a number like 20 in which case it becomes the red amount

>g: is the green amount if hex was give a number then this must be a number as well

>b: is the blue amount if hex was give a number then this must be a number as well

<br>

#### Get Shape Sprite
```lua
TDGameLib.getShapeSprite(color: number, shape: string|nil, width: number|nil, height: number|nil, rightAngled: boolean|nil, side: string|nil)
```
<b>Description:</b><br>
generates a sprite of geometric shapes

<b>Arguments:</b><br>
>color: is the color of the shape

>shape: is the geometric shape which you want ot generate a sprite for e.g: "circle","triangle","square"

>width: is the width/radius(if it's a circle) of the shape must be provided for shapes: "square" & "circle"

>height: is the height of the shape must be provided for shapes: "square" & "triangle"

>rightAngled: will make a triangle right angled. Will default to false if not provided

>side: will determine if the upper or lower half of the right angled triangle is given. Will default to "lower" if not provided

<b>Returns:</b><br>
>img: table ;is the image matrix of the shape

<br>

#### Turn Sprite
```lua
TDGameLib.turnSprite(sprite: table, times: number)
```
<b>Description:</b><br>
lets you turn the given sprite in increments of 90 Degrees by the number of times you inputted

<b>Arguments:</b><br>
>sprite: is the sprite that gets turned

>times: is the amount of times it will iterate of rotations of 90 degrees

<b>Returns:</b><br>
>sprite: table ;is the rotated matrix of the sprite

<br>

#### Set Background Image
```lua
TDGameLib.setBackgroundImage(img: table)
```
<b>Description:</b><br>
lets you set a background via TDGameLib.loadImage advised to be the length & width of the output object

<b>Arguments:</b><br>
>img: matrix give by TDGameLib.loadImage

<br>

### Object Based Functions

this part of the doc talks about Object the most important Thing in this library
it'll teach you how to create objects,what different object types exist and how to add your own functions to objects including object private variables

#### Important To Know

here are different existing class types:

<li>Sprite
<li>Hologram
<li>Group

<br>
each object has certain functions it can and can't execute like normal classes in lua

#### Sprite Object
this object is capable of rendering images to the screen
now i'll tell you all about their functions and private variable and how you can add your own functions to their class

##### Add Sprite
```lua
TDGameLib.sprite:addSprite(img: table, priority: number|nil, x: number|nil, y: number|nil, screenBound: boolean|nil)
```
<b>Description:</b><br>
adds a Sprite object to the render and returns the new object

<b>Arguments:</b><br>
>img: is the sprite of the game as matrix can be loaded using TDGameLib.loadImage

>priority: level of priority when rendering will default to the highest when nil higher priority gets rendered over lower

>x: X position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided

>y: Y position of the sprite (will start rendering at that y pos). defaults to 1 if not provided

>screenBound: if false the object can go as far off screen as it wants. defaults to true if not provided

<b>Returns:</b><br>
>spriteObject: table ;is the created sprite object

note: from now on I will reference the object obtained from this function as `spriteOBJ`

<br>

##### Remove Sprite
```lua
spriteOBJ:remove()
```
<b>Description:</b><br>
lets you remove this object

<br>

##### Change Sprite Data
```lua
spriteOBJ:changeSpriteData(img: table|nil, x: number|nil, y: number|nil, screenBound: boolean|nil)
```
<b>Description:</b><br>
lets you manipulate all data of a Sprite

<b>Arguments:</b><br>
>img: is the sprite that will be displayed can be loaded from .nfp file through TDGameLib.loadImage won't change if not supplied

>x: X position on screen that it starts to be rendered at. Won't change if not supplied

>y: Y position on screen that it starts to be rendered at. Won't change if not supplied

>screenBound: if false the object can go as far off screen as it wants. defaults to true if not provided

<br>

##### Render Sprite
```lua
spriteOBJ:render()
```
<b>Description:</b><br>
lets you render just this object (does not include background)

<br>

##### Private Variables Sprite
these are private variables of a sprite object

###### type
```lua
spriteOBJ.type
```
<b>Returns:</b><br>
```lua
"sprite"
```
or
```lua
"spriteClone"
```
if this sprite is a clone of an other Sprite

<br>

###### sprite
```lua
spriteOBJ.sprite
```
<b>Returns:</b><br>
a ```table``` which is it's image matrix or in the case of a clone it's parent object<br>
(to get the actual sprite just call: 
```lua
spriteOBJ.sprite.sprite
```
)

<br>

###### x
```lua
spriteOBJ.x
```
<b>Returns:</b><br>
a number that is the X position of the sprite

<br>

###### y
```lua
spriteOBJ.y
```
<b>Returns:</b><br>
a number that is the Y position of the sprite

<br>

##### Custom Functions Sprite
I'ts very easy to add custom functions to any object
but here it's show for a sprite

```lua
function TDGameLib.sprite:myFunction()
    if self.type ~= "sprite" then return end
    for i=1,#self.sprite do
        print(textutils.serialize(self.sprite[i],{compact=true}))
    end
end
```
this custom function called `myFunction` is a function every sprite object can do and if `self.type` = `"sprite"` then it'll print out every color value inside of `self.sprite`

in a function you can call any of the Private Variables just replace `spriteOBJ` with `self`

<br>

#### Hologram Object
this object is capable of rendering text to the screen
now i'll tell you all about their functions and private variable and how you can add your own functions to their class

##### Add Hologram
```lua
TDGameLib.hologram:addHologram(text: string, textColor: table|nil, textBackgroundColor: table|nil, priority: number|nil, x: number|nil, y: number|nil, dynamic: boolean|nil, wrapped: boolean|nil, screenBound: boolean|nil)
```
<b>Description:</b><br>
adds a Hologram/Text object to the render and returns the new object

<b>Arguments:</b><br>
>text: is the text that is going to be displayed

>textColor: is the text color of the displayed Text. If nil defaults to colors.white

>textBackgroundColor: is the background color of the displayed Text. If not supplied will render with background Color of background

>priority: level of priority when rendering will default to the highest when nil higher priority gets rendered over lower

>x: X position of the Hologram (will print at that x pos). defaults to 1 if not provided

>y Y position of the Hologram (will print at that y pos). defaults to 1 if not provided

>dynamic: if false will render it behind every sprite but it can not adjust to the sprite background colors. doesn't change the way it collides! will default to true if not provided

>wrapped: if false won't wrap the text when to big (smart wrapping: wraps at last space if there is one in the current line otherwise wraps to screen size). will default to true if not provided

>screenBound: if false the object can go as far off screen as it wants. defaults to true if not provided

<b>Returns:</b><br>
>hologramObject: table ;is the created hologram object

note: from now on I will reference the object obtained from this function as `hologramOBJ`

<br>

##### Remove Hologram
```lua
hologramOBJ:remove()
```
<b>Description:</b><br>
lets you remove this object

<br>

##### Change Hologram Data
```lua
hologramOBJ:changeHologramData(text: string|nil, textColor: table|nil, textBackgroundColor: table|nil, x: number|nil, y: number|nil, wrapped: boolean|nil, screenBound: boolean|nil)
```
<b>Description:</b><br>
lets you manipulate all data of a Hologram

<b>Arguments:</b><br>
>text: is the text that is being displayed. Won't change if not supplied

>textColor: is the color of the displayed text won't change if not supplied

>textBackgroundColor: is the background color of the text that is being displayed. Won't change if not supplied

>x: X position on screen that it gets written at. Won't change if not supplied

>y: Y position on screen that it gets written at. Won't change if not supplied

>wrapped: if false won't wrap the text when to big (smart wrapping: wraps at last space if there is one in the current line otherwise wraps to screen size). won't change if not provided

>screenBound: if false the object can go as far off screen as it wants. won't change if not provided

<br>

##### Render Hologram
```lua
hologramOBJ:render()
```
<b>Description:</b><br>
lets you render just this object (does not include background)

<br>

##### read
```lua
hologramOBJ:read(width: number, preFix: string|nil, character: string|nil, onChar: function|nil, onKey: function|nil)
```
<b>Description:</b><br>
this function is like the read() function except it is like a window to write in

<b>Arguments:</b><br>
>width number is width of the window to write in note that the cursor also takes up 1 space so the amount of characters shown are width-1

>character: if supplied replaces every input with this character like read(character)

>preFix: if supplied is put in front of the typing space (will attach to the read window)

>onChar: if provided can determine behavior of function when a character(e.g:'c') was entered

>onKey: if provided can determine behavior of function when a key(e.g:'backspace') was entered

<b>Returns:</b><br>
>userInput: string ;is the input from the user as a string

###### Preset Functions For HologramOBJ:Read()
<b>onChar:</b><br>

```lua
function onChar(key, readOut, cursorPos)
    readOut = readOut:sub(1, cursorPos) .. key .. readOut:sub(cursorPos + 1)
    cursorPos = cursorPos + 1

    return readOut, cursorPos
end
```

<b>onKey:</b><br>

```lua
function onKey(key, readOut, cursorPos)
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
```

<br>

##### Private Variables Holograms
these are private variables of a hologram object

###### type
```lua
hologramOBJ.type
```
<b>Returns:</b><br>
```lua
"hologram"
```
or
```lua
"hologramClone"
```
if this hologram is a clone of an other Hologram

<br>

###### text
```lua
hologramOBJ.text
```
<b>Returns:</b><br>
a table containing all lines as string or in case of a hologram clone is the parent object

<br>

###### text color format
```lua
hologramOBJ.textColor
```
<b>Returns:</b><br>
a table that is the text color formatting
how the formatting works:<br>
{ `color` = `textPos` }<br>
replace `color` with the name of a color inside of the colors api
and replace `textPos` with the position in the text at which it should start coloring
good to know is that this format also works for wrapped text it just assumes the text is a continuos string

to get the color formatting of a hologram clone use:<br>
```lua
hologramOBJ.text.textColor
```

<br>

###### text background color format
```lua
hologramOBJ.textBackgroundColor
```
<b>Returns:</b><br>
a table that is the background color formatting
how the formatting works:<br>
{ `color` = `textPos` }<br>
replace `color` with the name of a color inside of the colors api
and replace `textPos` with the position in the text at which it should start coloring
good to know is that this format also works for wrapped text it just assumes the text is a continuos string

<br>

###### x
```lua
HologramOBJ.x
```
<b>Returns:</b><br>
a number that is the X position of the hologram

<br>

###### y
```lua
hologramOBJ.y
```
<b>Returns:</b><br>
a number that is the Y position of the hologram

<br>

##### Custom Functions Hologram
I'ts very easy to add custom functions to any object
but here it's show for a hologram

```lua
function TDGameLib.hologram:myFunction()
    if self.type ~= "hologram" then return end
    local textOut = ""
    for i=1,#self.text do
        if i == 1 then
            textOut = self.text
        else
            textOut = textOut .. " " .. self.text[i]
        end
    end
end
```
this custom function called `myFunction` is a function every hologram object can do and if `self.type` = `"hologram"` then it'll print out the text inside of `self.text` as one string

in a function you can call any of the Private Variables just replace `hologramOBJ` with `self`

#### General Object Functions
these are functions that take in a object as a argument to then use them

##### Clone Object
```lua
TDGameLib.cloneObject(object: table, priority: number|nil, x: number|nil, y: number|nil, group: table|nil)
```
<b>Description:</b><br>
allows you to make a clone of an object this wll create a object that gets some data from its parent object

<b>Arguments:</b><br>
>object: is the object that will get cloned

>priority: level of priority when rendering will default to the highest when nil higher priority gets rendered over lower. can not be the priority of thr original sprite

>x: X position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided

>y: Y position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided

>group: if group object is supplied will add cloned object to a group

<b>Returns:</b><br>
>object: table ;is the clone of the original object

<br>

##### Is Colliding
```lua
TDGameLib.isColliding(obj1: table, obj2: table, isTransparent: boolean|nil)
```
<b>Description:</b><br>
lets you check if an object (including groups) is on top of an other object (including groups) returns true if it is, otherwise it returns false uses bounding boxes. Waring may fail if supplied, a group containing more groups (due to lua function stacking prevention)!

<b>Arguments:</b><br>
>obj1 table is a string that gives it the hierarchy of the first object (including groups) to check e.g: "test.string"

>obj2 table is a string that gives it the hierarchy of the second object (including groups) to check e.g: "test.number"

>isTransparent boolean|nil if true an empty space colliding counts as a collision. Defaults to false if not supplied

<b>Returns:</b><br>
>output: boolean ;is true if the objects touched otherwise false

<br>

##### Is Colliding Raw
```lua
TDGameLib.isCollidingRaw(xIn: number, yIn: number, obj: string, isTransparent: boolean|nil)
```
<b>Description:</b><br>
lets you check if a object (including groups) is rendered at certain X,Y Coordinates. Waring may fail if supplied, a group containing more groups (due to lua function stacking prevention)!

<b>Arguments:</b><br>
>xIn number is the X coordinate for the collision check

>yIn number is the Y coordinate for the collision check

>obj string is a string that gives it the hierarchy of the object to check e.g: "test.string"

>isTransparent boolean|nil if true an empty space colliding counts as a collision. Defaults to false if not supplied

<b>Returns:</b><br>
>output: boolean ;is true if the coordinate is on the object

<br>

### Rendering Based Functions
these are functions that render objects

#### Render
```lua
TDGameLib.render()
```
<b>Description:</b><br>
lets you render all objects and background

<br>

## .data file syntax
<p>
the ability to pre define objects via a file is a feature since TDGameLib V1.0 in the form of .data file<br>
this can be used to make a game level with pre defined objects for example.
<br>(i have put one in the repo: https://github.com/Redtech0inc/TDGameLib/blob/main/doc.data)<br>
in this "chapter" i tell you about the syntax of .data files
</p>
<b>What happens during Data => lua conversion</b>
<p>
when i made the .data syntax my goals were:
<li>readability
<li>easy to understand
<li>easy to transcript

<br>to achieve this i made it so that every tag(`<...>`) is equal to a string in lua e.g:<br>
```xml
<sprites>
    ...
</sprites>
```
transcripts to
```lua
sprites = {
    ...
}
```
(this tag is the start of a list containing all sprite objects)
</p><br>

### body tag
```xml
<body>
    ... 
</body>
```
this transcripts to
```lua
{
    ...
}
```
`<body>` is the entry point for the data to lua transcription<br>
`</body>` therefor counts as exit point.<br>
keep in mind that everything after `</body>` won't be decrypted!<br>
p.s.: can be useful to put own tags after `</body>`

<br>

### image tag
```xml
<image>...<br>...</image>
```
this transcripts to
```lua
{
    {
        ...
    },{
        ...
    }
}
```
or compacted: `{{...},{...}}`<br>

this, as you may have already noticed, is a matrix more specific an image matrix
it is important to note that each subList in the matrix is from left to right a column from top to bottom. so<br>
`image[1][2] => "a"` and `image[2][1] => "b"` is `{{nil,a},{b,nil}}`!<br>
<br>
`<image>` is equal to `{{` and `</image>` transcripts to `}}`
so does `<br>` equal to `},{`

<br>

### object tag
```xml
<object> ... </object>
```
transcripts to:
```lua
{...},
```
on it's own this tag can't do anything it's just there to put all data of an object inside of it so it's mostly used with object  describing tags like for example: `<sprites> ... </sprites>` 

<br>

### background tag
```xml
<background>
    <image> ... </image>
</background>
```
transcripts to:
```lua
background = {
    {{ ... }}
}
```
this tells the library the background as an image matrix.<br>
so you have to put `<image>` inside of `<background>`

<br>

### sprite tag
```xml
<sprites>
    <object>
        <image>512,512</image>, nil, 5, 5, false
    </object>
    <object>
        ...
    </object>
    ...
</sprites>
```
transcripts to:
```lua
sprites={
    {
        {{512,512}}, nil, 5, 5, false
    },
    {
        ...
    },
    ...
}
```
now as you may have already noticed, all theses values are arguments, that can be parsed on to gameLib:addSprite.<br>
That is exactly what happens when transcribing it.

<br>

### hologram tag
```xml
<holograms>
    <object>
        "text goes here", {blue=1, red=5}, {yellow=2, green=6}, nil, 10, 13, true, nil, true
    </object>
    <object>
        ...
    </object>
    ...
</holograms>
```
transcripts to:
```lua
holograms= {
    {
        "text goes here", {blue=1, red=5}, {yellow=2, green=6}, nil, 10, 13, true, nil, true
    },
    {
        ...
    },
    ...
}
```
as you may have already noticed, all theses values are arguments, that can be parsed on to gameLib:addHologram.<br>
That is exactly what happens when transcribing it.<br>
this also transcribes for non dynamic as well as dynamic holograms (argument8 = dynamic: boolean|nil).

<br>

### group tag
```xml
<groups>
    <object>
        <object> "test.sprite1", "test.sprite", "test.hologram </object>
    </object>
    <object>
        ...
    </object>
    ...
</groups>
```
transcripts to:
```lua
groups = {
    {
        {"test.sprite1", "test.sprite", "test.hologram"}
    },
    {
        ...
    },
    ...
}
```
this describes a group and as you see `<object>` is used two times here,<br>
once to describe the group object and the other time to describe all objects inside of the group
