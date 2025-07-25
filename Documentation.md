# Disclaimer

this is still work in progress so the documentation is not  done. Thanks! ^^

# Client Functions:

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

<b>Description:</b>
this is the initiating function and is there to create the Consol Object. The function goes as follows:

```lua
_G.Console:init(x: number, y: number, width: number, height: number)
```
<b>Arguments:</b>
<li>x: this is at what X position on screen the origin of your console should be (systemOut: 1)
<li> y: this is at what Y position on screen the origin of your console should be (systemOut: 2)
<li> width: this is how wide you console should be all text wrapping functions will adhere to this (systemOut: screen width)
<li> height: this is how high you console should be meaning how many spaces down is should be  do not that because of the scrolling function there is 1 more buffer space below your given number which is important (systemOut: screen height - 1)
<br><br>
<b>Returns:</b>
<li> consoleObject : metatable ; this is the console  object which you just created

also from now on i will be referencing the object given by this function as `ConsoleOBJ`

#### display

<b>Description:</b>
this function draws the console onto the screen just like a render function

```lua
ConsoleOBJ:display()
```

### _G.systemOut

this is a pre made Console object configured to perfectly fit inside the terminal with the hud on top
this console can be accessed from any website and is created upon launch of the client

it gets all of it functions from `_G.Console` and has none of it's own. So this is kinda for people that don't want or need to make their own output

the only addition is that whenever the openUILib renders it also draws the `systemOut` console
