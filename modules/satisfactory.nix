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

    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
      description = ''
        Override the Game Port the server uses.
        This is the primary port used to communicate game telemetry with the client.
        If it is already in use, the server will step up to the next port until an available one is found.	
      '';
    };

    openFirewall = lib.mkEnableOption "" // {
      description = "Whether to open the ports in the firewall.";
    };

    settings = lib.mkOption {
      description = "Satisfactory engine & game settings.";
      default = { };
      type = lib.types.submodule {
        options = {
          autosaveNumber = lib.mkOption {
            description = "Specifies the number of rotating autosaves to keep.";
            type = lib.types.ints.positive;
            default = 5;
          };
          clientTimeout = lib.mkOption {
            description = "Specifies the number of rotating autosaves to keep.";
            type = lib.types.ints.positive;
            default = 5;
          };
          streaming = lib.mkEnableOption "asset streaming" // {
            default = true;
          };
          maxObjects = lib.mkOption {
            description = "Specifies the maximum object limit for the server.";
            type = lib.types.ints.positive;
            default = 2162688;
          };
          maxTickrate = lib.mkOption {
            description = "Specifies the maximum tick rate for the server.";
            type = lib.types.ints.positive;
            default = 30;
          };
          maxPlayers = lib.mkOption {
            description = "Specifies the maximum number of players to allow on the server.";
            type = lib.types.ints.positive;
            default = 4;
          };
          seasonalEvents = lib.mkEnableOption "seasonal events, such as FICSMAS" // {
            default = true;
          };
        };
      };
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
        createHome = lib.mkDefault true;
        group = cfg.user;
        home = cfg.stateDir;
        isSystemUser = lib.mkDefault true;
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
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "-ini:Engine:[/Script/Engine.Engine]:NetClientTicksPerSecond=${toString cfg.settings.maxTickrate}"
            "-ini:Engine:[/Script/Engine.GarbageCollectionSettings]:gc.MaxObjectsInEditor=${toString cfg.settings.maxObjects}"
            "-ini:Engine:[/Script/FactoryGame.FGSaveSession]:mNumRotatingAutosaves=${toString cfg.settings.autosaveNumber}"
            "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:ConnectionTimeout=${toString cfg.settings.clientTimeout}"
            "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:InitialConnectTimeout=${toString cfg.settings.clientTimeout}"
            "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:LanServerMaxTickRate=${toString cfg.settings.maxTickrate}"
            "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:NetServerMaxTickRate=${toString cfg.settings.maxTickrate}"
            "-ini:Engine:[ConsoleVariables]:wp.Runtime.EnableServerStreaming=${
              if cfg.settings.streaming then "1" else "0"
            }"
            "-ini:Engine:[Core.Log]:LogNet=Error"
            "-ini:Engine:[Core.Log]:LogNetTraffic=Warning"
            "-ini:Game:[/Script/Engine.GameSession]:ConnectionTimeout=${toString cfg.settings.clientTimeout}"
            "-ini:Game:[/Script/Engine.GameSession]:InitialConnectTimeout=${toString cfg.settings.clientTimeout}"
            "-ini:Game:[/Script/Engine.GameSession]:MaxPlayers=${toString cfg.settings.maxPlayers}"
            "-ini:GameUserSettings:[/Script/Engine.GameSession]:MaxPlayers=${toString cfg.settings.maxPlayers}"
            "-Port=${builtins.toString cfg.port}"
            "-DisablePacketRouting"
          ]
          ++ lib.optionals (!cfg.settings.seasonalEvents) [ "-DisableSeasonalEvents" ]
        );
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
