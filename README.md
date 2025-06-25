# MCNet
## about
This is the official repo for the MCNet Project Lua code for CC-Tweaked

i know this isn't much but i just threw this repo together in like a few second so please don't be mad about that srry

if you have questions feel free to ask on the MCCM Discord you should find my post under creations and then just the name of the repo [Discord LINK](https://discord.gg/minecraft-computer-mods-477910221872824320)

I got this idea from someone else (i can't find the original video :,( ) who made a internet system but i wanted to see if i can do the same

hope you'll enjoy ;) !

## how to set up

first i would make a DNS server then the client and then servers can be added to the network!<br>

### setup DNS server

`dnsServer.lua` and <br>
`initDns.lua` ona computer <br>
now execute `initDns.lua` and the rest is done by the system <br>

### setup mcNet-client
so first i would advise you to make a folder on the machine where you are going to install the client on so that the files are in one place tho you don't have to do that<br>
for example `internet` as the folder name <br>
now put the `mcNet-client.lua` file in that and execute it once<br>
it is going to give you an error but thats normal now enter the newly created libs folder (my example `internet/libs`)
and drop the `logo.nfp` and the `openUILib.lua` file in there
then go back and execute `mcNet-cleint.lua` again now it should work!

### setup server
so to set up a server enter any computer with ender/wireless(not advised) modem<br>
now instal `server.lua` this is your server framework (which you can edit)<br>
you will also have to open a folder to hold all your "pages" and a folder thta MUST be named `libs` this is where custom librtaries and the server Library will sit<br>
now as already told put `serverLib.lua` in the libs folder!

## coming soon/maybe today

<list> reload feature
<list> better comments for coders

## disclaimer
this is still in beta so please send don't rage or insult for bad / not optimised code
and also i know i used os.loadAPI a LOT but idc bc there a places in this mess where os.loadAPI is the only option if you have a better one then just tell me how to EXACTLY improve it
