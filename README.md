# MCNet
## about
This is the official [insert website name here] repo for the MCNet Project Lua code for CC-Tweaked

i know this isn't much but i just threw this repo together in like a few second so please don't be mad about that srry

if you have questions feel free to ask on the MCCM Discord you should find my post under creations and then just the name of the repo [Discord LINK](https://discord.gg/minecraft-computer-mods-477910221872824320)

I got this idea from someone else (i can't find the original video :,( ) who made a internet system but i wanted to see if i can do the same

hope you'll enjoy ;) !

## how to set up

tho if you are using the installer from the [pinestore page](https://pinestore.cc/projects/153/mcnet) it should set up the system automatically<br>

First, I recommend making a DNS server, then the client, and then servers can be added to the network!<br>

### setup DNS server

`dnsServer.lua` and <br>
`initDns.lua` ona computer <br>
now execute `initDns.lua` and the rest is done by the system <br>

repo folder [click here](https://github.com/Redtech0inc/MCNet/tree/main/mcNet/dnsServer-Stuff)

#### 📁 File Tree (DNS Server side Example)
computer/<br>
├── dnsServer.lua<br>
└── initDns.lua ← Execute this file to start the system

### setup mcNet-client
so first i would advise you to make a folder on the machine where you are going to install the client on so that the files are in one place tho you don't have to do that<br>
for example `internet` as the folder name <br>
now put the `mcNet-client.lua` file in that and execute it once<br>
it is going to give you an error but thats normal now enter the newly created libs folder (my example `internet/libs`)
and drop the `logo.nfp` and the `openUILib.lua` file in there
then go back and execute `mcNet-client.lua` again now it should work!

repo folder [click here](https://github.com/Redtech0inc/MCNet/tree/main/mcNet/client-stuff)

#### 📁 File Tree (Client Side Example)

internet/  
├── mcNet-client.lua   ← Execute this file first  
├── libs/  
│   ├── logo.nfp  
│   └── openUILib.lua  
└── pages/

### setup server
so to set up a server enter any computer with ender/wireless(not advised) modem<br>
now instal `server.lua` this is your server framework (which you can edit)<br>
you will also have to open a folder to hold all your "pages" and a folder that MUST be named `libs` this is where custom librtaries and the server Library will sit<br>
now as already told put `serverLib.lua` in the libs folder!

repo folders:<br>

- server framework    [click here](https://github.com/Redtech0inc/MCNet/tree/main/mcNet/serverFramework) <br>
- server libraries    [click here](https://github.com/Redtech0inc/MCNet/tree/main/mcNet/serverFramework/libs) <br>
- server exanple page [click here](https://github.com/Redtech0inc/MCNet/tree/main/mcNet/serverFramework/pages) <br>

#### 📁 File Tree (Server Side Example)

server/  
├── server.lua              ← Main server framework (can be edited)  
├── libs/                   ← Contains required and custom libraries  
│   ├── serverLib.lua       ← Required server library  
│   └── yourCustomLib.lua   ← 🔧 Optional custom libraries (not required by server)  
└── pages/                  ← Holds all your "pages"

## coming soon/maybe today

<li> better comments for coders
<li> api documentation
<li> forward arrow button

## disclaimer
this is still in beta so please don't rage or insult for bad / not optimised code
and also i know i used os.loadAPI a LOT but idc bc there a places in this mess where os.loadAPI is the only option if you have a better one then just tell me how to EXACTLY improve it
