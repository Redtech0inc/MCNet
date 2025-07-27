# Client functions


these functions come preinstalled on the client as part of it's code and is accessible for any website.

## Consoles

in this category there are two things:
`_G.systemOut` which is a pre made console as seen in `www.example.com` and `_G.Console` the class that `systemOut` originates from.

### _G.Console

this is the over all Consol class and consists of all functions available for `_G.systemOut`

<p><b>DO NOT USE PRINT:<br></b>
this is because of the hud which will get pushed out of the screen if the common lua print function is used!
</p>

#### init

<b>Description:</b><br>
this is the initiating function and is there to create the Consol Object. The function goes as follows:

```lua
_G.Console:init(x: number, y: number, width: number, height: number)
```

<b>Arguments:</b>
<li>x: this is at what X position on screen the origin of your console should be (systemOut: 1)
<li> y: this is at what Y position on screen the origin of your console should be (systemOut: 2)
<li> width: this is how wide you console should be all text wrapping functions will adhere to this (systemOut: screen width)
<li> height: this is how high you console should be meaning how many spaces down it should go. Be aware that because of the scrolling function there is 1 more buffer space below your given number which is important (systemOut: screen height - 1)
<br><br>
<b>Returns:</b>
<li> consoleObject : metatable ; this is the console  object which you just created

<br>
also from now on i will be referencing the object given by this function as `ConsoleOBJ`

#### display

<b>Description:</b><br>
this function draws the console onto the screen just like a render function

```lua
ConsoleOBJ:display()
```

#### setCursorPos

<b>Description:</b><br>
this function, just like `term.setCursorPos` , can edit the position at which you ar writing in the console

```lua
ConsoleOBJ:setCursorPos(x: number, y: number)
```

<b>Arguments:</b>
<li> x: this is the X position you will set the cursor to defaults to 1 if not provided.
<li> y: this is the Y position you will set the cursor to defaults to 1 if not provided.

#### getCursorPos

<b>Description:</b><br>
this function returns the X and Y position of the cursor

```lua
ConsoleOBJ:getCursorPos()
```

<b>Returns:</b><br>
<li> x: number ; which is the X coordinate of the cursor
<li> y: number ; which is the Y coordinate of the cursor

#### setTextColor

<b>Description:</b><br>
now unlike `term.setTextColor` this function allows for later color change using X and Y coordinates

```lua
ConsoleOBJ:setTextColor(color: number, posX: number, posY: number)
```

<b>Arguments:</b>
<li> color: this is the color you want to set colum, row or static (static meaning from now on write with this color) to
<li> posX: this is not required but when given will change every position whose X position equals the given one to the given color
<li> posY: this is not required but when given will change every position whose Y position equals the given one to the given color

#### setBackgroundColor

<b>Description:</b><br>
now unlike `term.setBackgroundColor` this function allows for later color change using X and Y coordinates

```lua
ConsoleOBJ:setBackgroundColor(color: number, posX: number, posY: number)
```

<b>Arguments:</b>
<li> color: this is the color you want to set colum, row or static (static meaning from now on write with this color) to
<li> posX: this is not required but when given will change every position whose X position equals the given one to the given color
<li> posY: this is not required but when given will change every position whose Y position equals the given one to the given color

#### getTextColor

<b>Description:</b><br>
this function returns the static (meaning the color that the console will write with. This excludes a change of color using X and Y coordinates) color of the consol object

```lua
ConsoleOBJ:getTextColor()
```

<b>Returns:</b>
<li> color: number ; this is the static text color as a number

#### getBackgroundColor

<b>Description:</b><br>
this function returns the static (meaning the color that the console will write with. This excludes a change of color using X and Y coordinates) color of the consol object

```lua
ConsoleOBJ:getBackgroundColor()
```

<b>Returns:</b>
<li> color: number ; this is the static background color as a number

#### scroll

<b>Description:</b><br>
This function is useful if you want to shift all printed lines by `n` places upwards tho I'am afraid that it can't yet shift lines by `n` places down :,(

```lua
ConsoleOBJ:scroll(n: number)
```

<b>Arguments:</b>
<li> n: this is the amount of position you want to shift all lines up by

#### write

<b>Description:</b><br>
this is the common `term.write` command for the Console object

```lua
ConsoleOBJ:write(str: any)
```

<b>Arguments:</b>
<li> str: this is what will be written on to the Console

#### print

<b>Description:</b><br>
this is the common `print` command for the Console
unlike `ConsoleOBJ:write` this uses smart text wrapping meaning it wraps the text to the Console size and tries to wrap at the latest space.

```lua
ConsoleOBJ:print(str: any)
```

<b>Arguments:</b>
<li> str: this is what will be printed no to the Console

### _G.systemOut

this is a pre made Console object configured to perfectly fit inside the terminal with the hud on top
this console can be accessed from any website and is created upon launch of the client

it gets all of it functions from `_G.Console` and has none of it's own. So this is kinda for people that don't want or need to make their own output

the only addition is that whenever the openUILib renders it also draws the `systemOut` console

## openUILib

This is the built in graphics library that allows you to make a GUI in no time<br>
<br>
this is a port of my `TDGameLib` which was made for 2D Game Development but i often use it for GUIs because of it's easy way of making 2D interfaces.<br>

#### OpenUILib Documentation (TDGameLib Documentation)
you can find the full documentation of the TDGameLib/OpenUILib
[here](https://github.com/Redtech0inc/MCNet/blob/main/openUILib-Documentation.md)
<br><br><br>

# Server Library

## Server Object

### open

<b>Description:</b><br>
this function is here to create a server object which will handle all requests and register it's self at at all available DNS server

```lua
serverLib.Server:open(name: any)
```

<b>Arguments:</b>
<li> name: this is what the server will tell the DNS Server as it's address <b>(NOTE: currently there is no option to change this once a server has told the DNS it's name the server can't delete or change it only the DNS Server owner can manually)</b>
<br><br>
<b>Returns:</b>
<li> serverObject: metatable ; this is the server object you've just created

<br>
also from now on i will be referencing the object given by this function as `ServerOBJ`

### receive

<b>Description:</b><br>
this function allows to listen and retrieve requests using a wireless modem<br>
<b>NOTE: This is a bit better than rednet.receive so I advise to use this instead</b>

```lua
ServerOBJ:receive(timeout: number, times: number)
```

<b>Arguments:</b>
<li> timeout: this is how long it waits for a answer before returning or trying again, if not given waits forever
<li> times: this is how many times it tries to receive an answer, if not given defaults to 1
<br><br>
<b>Returns:</b>
<li> message : table ; this is a table containing the request/answer of a client, if nothing was received or the request/answer was not a table returns an empty table

### close

<b>Description:</b><br>
when this function is called the server goes offline by closing the rednet port <b>this should always be called last</b>

```lua
ServerOBJ:close()
```

## Log Object

### open

<b>Description:</b><br>
This function allows you to open and write to a log that may help in the case of an error to clarify things for debugging

```lua
serverLib.Log:open(name: any)
```

<b>Arguments:</b>
<li> name: this is the name of the file, if not provided will use the time and date from os.date("%c")

<br>

also from now on i will be referencing the object given by this function as `LogOBJ`

### write

<b>Description:</b><br>
this allows you to write inside of the log file you created by using:

```lua
LogOBJ:write(text: any, logClass: any, endLine: boolean, includePreInfo: boolean)
```
<b>Arguments:</b>
<li> text: this is what will be put inside of the file!
<li> logClass: this is under what this classifies e.g: "INFO" or "ERROR", defaults to "Info" if not provided
<li> endLine: if false won't end the line, defaults to true if not provided
<li> includePreInfo: if false won't include logClass and time + date

### space

<b>Description:</b><br>
this function allows for quick spacing in your logs it utilizes `\n`

```lua
LogOBJ:space(number: number)
```
<b>Arguments:</b>
<li>number: this is the amount of empty lines you want to generate

### getLines

<b>Description:</b><br>
this function returns how many lines have been printed so far

```lua
LogOBJ:getLines()
```
<b>Returns:</b>
<li> lines: number ; this is how many lines have been printed so far

### close

<b>Description:</b><br>
this closes the log and wipes the object

```lua
LogOBJ:close()
```

## Generic Functions

### sendPage

<b>Description:</b><br>
this function is used to send pages to the client

```lua
serverLib.sendPage(ID: number, path: string)
```
<b>Arguments:</b>
<li>ID: this is the computer ID you want to send the page to
<li>path: this is the path of the page you want to send

### sendCookie

<b>Description:</b><br>
this is the function used to send a cookie to the client

```lua
serverLib.sendCookie(ID: number, valueTable: table, expirationDateTable: table|number)
```
<b>Arguments:</b>
<li>ID: this is the computer ID you want tro send the page to
<li> valueTable: this is the table containing you cookie values
<li> expirationDateTable: this is a table describing how long the cookie  will stay for
<br><br>
<b>expirationDateTable explanation</b><br>
<p>
the expirationDateTable describes how long a cookie will last in UTC Epoch this means that it is a bit inaccurate but it gets as close as it can
</p>
structure if given a table:<br>

```lua
{
    years,
    months,
    days,
    hours,
}
```
<li> years: this describes how many years the cookie will last (1 year max)
<li> months: this is how many months the cookie will last (~12 months max)
<li> days: this how many days the cookie will last (~365 days max)
<li> hours: this is how many hours the cookie will last (~8760 hours max)
<br><br>
<b>Usage of Epoch num</b>
<p>
now if you want to get more precise than hours you are going to have to enter a exact epoch you can do this via
</p>

```lua
os.epoch("utc")+yourTime
```
`yourTime` in this example is the time in milliseconds you want to add on

<b>NOTE: this epoch has to be bigger than `os.epoch("utc")` or else it will default to `os.epoch("utc")+3600000` which is about 1 hour from current UTC</b>

p.s: for people that are interested, a expired cookie will only get deleted if a cookie gets set or a cookie gets fetched

### deactivator

<b>Description:</b><br>
this is a function you want to run parallel to you server setup. It ensures that if you press enter the server thread will stop!

```lua
serverLib.deactivator()
```
 you can run it parallel using the `parallel.waitForAny` function built into CCTweaked

 as shown in this example which can be found in the [server.lua file](https://github.com/Redtech0inc/MCNet/blob/main/mcNet/serverFramework/server.lua)
 ```lua
 parallel.waitForAny(main,serverLib.deactivator)
 ```
<br><br><br>

# Website Scripts

web scripts are the way the client and the server communicate this is what get's send to the client using `serverLib.sendPage` to execute this targeted the client calls certain function names

## init

<b>Description:</b><br>
this function is run when the page initiates so it only runs once at the start of the script

```lua
init = function (path)
    os.loadAPI(path.."libs/testLib.lua")--on receiving computer will find root and then enter libs folder where testLib.lua was downloaded to

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
```
<b>Given Arguments:</b>
<li>path: this is the root path of the client

### main

<b>Description:</b><br>
this function is called repeatably each time the function exits it is called again

```lua
main = function(path,lastCookie)--there are currently 2 argument. the 1st argument is the root path of the mcNet client, the 2nd argument is the pages cookie nil if it doesn't exist
    if not lastCookie then
        return 3, {message = "getCookie"}
    end
    for i=1,math.random(30) do
        testLib.test(i)
        somethingSprite = openUILib.turnSprite(somethingSprite,1)
        something:changeSpriteData(somethingSprite)
        openUILib.render()
        sleep(0.1)
    end
end
```
<b>Given Arguments:</b>
<li>path: this is the root path of the client
<li>lastCookie: this is the cookie under this page name, is nil if there is no cookie

### disconnect

<b>Description:</b><br>
this function is called when the client disconnects

```lua
disconnect = function(path)
    rednet.send(serverIP,{message = "disconnect"})
end
```

<b>Given Arguments:</b>
<li>path: this is the root path of the client

### hudEvent

<b>Description:</b><br>

```lua
hubEvent = function(path)
    systemOut:print("hello world")
end
```
<b>Given Arguments:</b>
<li>path: this is the root path of the client

### Return Codes

these are codes that when returned by the main function, can trigger certain actions<br><br>

return codes:
```
+------+-----------------------+----------------------------+
| code | action                | additional requirements    |
+------+-----------------------+----------------------------+
| -3   | Ends net program      | None                       |
| -2   | Ends page             | None                       |
| -1   | Goes back 1 page      | None                       |
|  1   | Reloads current page  | None                       |
|  2   | Loads new page        | Must return page message   | --the message to give the server to download the page will be  shown in the server.lua file
|  3   | set cookie val of page| Must return cookie message | --the message which when given to the server will return the cookie value and expiration date
+------------------------------+----------------------------+
```
