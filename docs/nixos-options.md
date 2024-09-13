## services\.satisfactory\.enable

Whether to enable Satisfactory Dedicated Server\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `



## services\.satisfactory\.package



The satisfactory-server package to use\.



*Type:*
package



*Default:*
` pkgs.satisfactory-server `



## services\.satisfactory\.openFirewall



Whether to open the ports in the firewall\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `



## services\.satisfactory\.port



Override the Game Port the server uses\.
This is the primary port used to communicate game telemetry with the client\.
If it is already in use, the server will step up to the next port until an available one is found\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*
` 7777 `



## services\.satisfactory\.settings



Satisfactory engine \& game settings\.



*Type:*
submodule



*Default:*
` { } `



## services\.satisfactory\.settings\.autosaveNumber



Specifies the number of rotating autosaves to keep\.



*Type:*
positive integer, meaning >0



*Default:*
` 5 `



## services\.satisfactory\.settings\.clientTimeout



Specifies the number of rotating autosaves to keep\.



*Type:*
positive integer, meaning >0



*Default:*
` 5 `



## services\.satisfactory\.settings\.maxObjects



Specifies the maximum object limit for the server\.



*Type:*
positive integer, meaning >0



*Default:*
` 2162688 `



## services\.satisfactory\.settings\.maxPlayers



Specifies the maximum number of players to allow on the server\.



*Type:*
positive integer, meaning >0



*Default:*
` 4 `



## services\.satisfactory\.settings\.maxTickrate



Specifies the maximum tick rate for the server\.



*Type:*
positive integer, meaning >0



*Default:*
` 30 `



## services\.satisfactory\.settings\.seasonalEvents



Whether to enable seasonal events, such as FICSMAS\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## services\.satisfactory\.settings\.streaming



Whether to enable asset streaming\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## services\.satisfactory\.stateDir



Directory to store the server state\.



*Type:*
path



*Default:*
` "/var/lib/satisfactory" `



## services\.satisfactory\.user



User to run the server as\.



*Type:*
string



*Default:*
` "satisfactory" `


