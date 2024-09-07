{ self, steam-fetcher }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.satisfactory;
in
{
  options.services.satisfactory = {
    enable = lib.mkEnableOption "Satisfactory Dedicated Server";

    package = lib.mkPackageOption pkgs "satisfactory-server" { };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/satisfactory";
      description = "Directory to store the server state.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "satisfactory";
      description = "User to run the server as.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = ''
        Bind the server process to a specific IP address rather than all available interfaces.
      '';
    };

    serverQueryPort = lib.mkOption {
      type = lib.types.port;
      default = 15777;
      description = ''
        Override the Query Port the server uses.
        This is the port specified in the Server Manager in the client UI to establish a server connection.
      '';
    };

    beaconPort = lib.mkOption {
      type = lib.types.port;
      default = 15000;
      description = ''
        Override the Beacon Port the server uses. As of Update 6, this port can be set freely.
        If this port is already in use, the server will step up to the next port until an available one is found.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
      description = ''
        Override the Game Port the server uses.
        This is the primary port used to communicate game telemetry with the client.
        If it is already in use, the server will step up to the next port until an available one is found.	
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the ports in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      self.overlays.default
      steam-fetcher.overlays.default
    ];

    users = {
      groups.${cfg.user} = { };
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.user;
        home = cfg.stateDir;
        createHome = true;
      };
    };

    systemd.services.satisfactory = {
      description = "Satisfactory dedicated server";
      requires = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        mkdir -p ${cfg.stateDir}/.config/Epic/FactoryGame
      '';

      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        ExecStart = lib.strings.concatStringsSep " " [
          "${lib.getExe cfg.package}"
          "-multihome=${cfg.listenAddress}"
          "-QueryPort=${builtins.toString cfg.serverQueryPort}"
          "-BeaconPort=${builtins.toString cfg.beaconPort}"
          "-GamePort=${builtins.toString cfg.port}"
        ];
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [
        cfg.serverQueryPort
        cfg.beaconPort
        cfg.port
      ];
    };
  };
}
