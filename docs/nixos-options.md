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



## services\.satisfactory\.iniSettings



Freeform type to pass arbitrary ` -ini ` options to the server\.
See e\.g\. the [Satisfactory Wiki](https://satisfactory\.wiki\.gg/wiki/Multiplayer\#Engine\.ini)
for recommended config tweaks\.



*Type:*
submodule



*Default:*
` { } `



*Example:*

```
{
  Engine = {
    "/Script/Engine.Player" = {
      ConfiguredInternetSpeed = 104857600;
      ConfiguredLanSpeed = 104857600;
    };
    "/Script/OnlineSubsystemUtils.IpNetDriver" = {
      MaxClientRate = 104857600;
      MaxInternetClientRate = 104857600;
    };
    "/Script/SocketSubsystemEpic.EpicNetDriver" = {
      MaxClientRate = 104857600;
      MaxInternetClientRate = 104857600;
    };
  };
  Game = {
    "/Script/Engine.GameNetworkManager" = {
      MaxDynamicBandwidth = 104857600;
      MinDynamicBandwidth = 10485760;
      TotalNetBandwidth = 104857600;
    };
  };
  Scalability = {
    "NetworkQuality@3" = {
      MaxDynamicBandwidth = 104857600;
      MinDynamicBandwidth = 10485760;
      TotalNetBandwidth = 104857600;
    };
  };
}
```



## services\.satisfactory\.listenAddr



See https://satisfactory\.wiki\.gg/wiki/Dedicated_servers\#Is_the_server_bound_to_the_correct_interface?
Defaults to ` :: `, which means the server will listen on all interfaces\.



*Type:*
string



*Default:*
` "::" `



## services\.satisfactory\.messagingPort



Override the messaging port the server uses\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*
` 8888 `



## services\.satisfactory\.openFirewall



Whether to open the ports in the firewall\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `



## services\.satisfactory\.port



Override the game port the server uses\.
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
absolute path



*Default:*
` "/var/lib/satisfactory" `



## services\.satisfactory\.user



User to run the server as\.



*Type:*
string



*Default:*
` "satisfactory" `


