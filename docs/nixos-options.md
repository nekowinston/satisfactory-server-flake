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



## services\.satisfactory\.beaconPort

Override the Beacon Port the server uses\. As of Update 6, this port can be set freely\.
If this port is already in use, the server will step up to the next port until an available one is found\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*
` 15000 `



## services\.satisfactory\.listenAddress



Bind the server process to a specific IP address rather than all available interfaces\.



*Type:*
string



*Default:*
` "0.0.0.0" `



## services\.satisfactory\.openFirewall



Whether to open the ports in the firewall\.



*Type:*
boolean



*Default:*
` false `



## services\.satisfactory\.port



Override the Game Port the server uses\.
This is the primary port used to communicate game telemetry with the client\.
If it is already in use, the server will step up to the next port until an available one is found\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*
` 7777 `



## services\.satisfactory\.serverQueryPort



Override the Query Port the server uses\.
This is the port specified in the Server Manager in the client UI to establish a server connection\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*
` 15777 `



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


