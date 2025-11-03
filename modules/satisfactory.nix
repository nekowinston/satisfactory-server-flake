{ self, steam-fetcher }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.satisfactory;

  inherit (lib) mapAttrsToList types;

  iniFromSettings = {
    Engine = {
      "/Script/Engine.Engine" = {
        NetClientTicksPerSecond = cfg.settings.maxTickrate;
      };
      "/Script/Engine.GarbageCollectionSettings" = {
        "gc.MaxObjectsInEditor" = cfg.settings.maxObjects;
      };
      "/Script/FactoryGame.FGSaveSession" = {
        mNumRotatingAutosaves = cfg.settings.autosaveNumber;
      };
      "/Script/OnlineSubsystemUtils.IpNetDriver" = {
        ConnectionTimeout = cfg.settings.clientTimeout;
        InitialConnectTimeout = cfg.settings.clientTimeout;
        LanServerMaxTickRate = cfg.settings.maxTickrate;
        NetServerMaxTickRate = cfg.settings.maxTickrate;
      };
      "ConsoleVariables" = {
        "wp.Runtime.EnableServerStreaming" = if cfg.settings.streaming then "1" else "0";
      };
      "Core.Log" = {
        LogNet = "Error";
        LogNetTraffic = "Warning";
      };
    };
    Game = {
      "/Script/Engine.GameSession" = {
        ConnectionTimeout = cfg.settings.clientTimeout;
        InitialConnectTimeout = cfg.settings.clientTimeout;
        MaxPlayers = cfg.settings.maxPlayers;
      };
    };
    GameUserSettings."/Script/Engine.GameSession" = {
      MaxPlayers = cfg.settings.maxPlayers;
    };
  };

  iniArgs = lib.flatten (
    mapAttrsToList (
      file:
      mapAttrsToList (
        section: mapAttrsToList (key: val: "-ini:${file}:[${section}]:${key}=${toString val}")
      )
    ) (lib.recursiveUpdate iniFromSettings cfg.iniSettings)
  );

  serverArgs = [
    "-Port=${toString cfg.port}"
    "-ReliablePort=${toString cfg.messagingPort}"
    "-ExternalReliablePort=${toString cfg.messagingPort}"
  ]
  ++ lib.optionals (cfg.listenAddr != null) [
    "-multihome=${cfg.listenAddr}"
  ]
  ++ lib.optionals (!cfg.settings.seasonalEvents) [
    "-DisableSeasonalEvents"
  ]
  ++ cfg.extraArgs
  ++ iniArgs;
in
{
  options.services.satisfactory = {
    enable = lib.mkEnableOption "Satisfactory Dedicated Server";

    package = lib.mkPackageOption pkgs "satisfactory-server" { };

    stateDir = lib.mkOption {
      type = types.path;
      default = "/var/lib/satisfactory";
      description = "Directory to store the server state.";
    };

    user = lib.mkOption {
      type = types.str;
      default = "satisfactory";
      description = "User to run the server as.";
    };

    port = lib.mkOption {
      type = types.port;
      default = 7777;
      description = ''
        Override the game port the server uses.
        This is the primary port used to communicate game telemetry with the client.
        If it is already in use, the server will step up to the next port until an available one is found.
      '';
    };

    listenAddr = lib.mkOption {
      type = types.nullOr types.str;
      default = "::";
      description = ''
        Defaults to `::`, which means the server will listen on all interfaces.
        Set to `null` to disable passing in `-multihome`.

        See https://satisfactory.wiki.gg/wiki/Dedicated_servers#Is_the_server_bound_to_the_correct_interface?
      '';
    };

    extraArgs = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Any extra arguments thta should be passed to the Satisfactory server. They will be shell-escaped.
      '';
    };

    messagingPort = lib.mkOption {
      type = types.port;
      default = 8888;
      description = ''
        Override the messaging port the server uses.
      '';
    };

    openFirewall = lib.mkEnableOption "" // {
      description = "Whether to open the ports in the firewall.";
    };

    settings = lib.mkOption {
      description = "Satisfactory engine & game settings.";
      default = { };
      type = types.submodule {
        options = {
          autosaveNumber = lib.mkOption {
            description = "Specifies the number of rotating autosaves to keep.";
            type = types.ints.positive;
            default = 5;
          };
          clientTimeout = lib.mkOption {
            description = "Specifies the number of rotating autosaves to keep.";
            type = types.ints.positive;
            default = 5;
          };
          streaming = lib.mkEnableOption "asset streaming" // {
            default = true;
          };
          maxObjects = lib.mkOption {
            description = "Specifies the maximum object limit for the server.";
            type = types.ints.positive;
            default = 2162688;
          };
          maxTickrate = lib.mkOption {
            description = "Specifies the maximum tick rate for the server.";
            type = types.ints.positive;
            default = 30;
          };
          maxPlayers = lib.mkOption {
            description = "Specifies the maximum number of players to allow on the server.";
            type = types.ints.positive;
            default = 4;
          };
          seasonalEvents = lib.mkEnableOption "seasonal events, such as FICSMAS" // {
            default = true;
          };
        };
      };
    };

    iniSettings = lib.mkOption {
      description = ''
        Freeform type to pass arbitrary `-ini` options to the server.
        See e.g. the [Satisfactory Wiki](https://satisfactory.wiki.gg/wiki/Multiplayer#Engine.ini)
        for recommended config tweaks.
      '';

      type = types.attrsOf (
        types.attrsOf (
          types.attrsOf (
            types.oneOf [
              types.number
              types.str
            ]
          )
        )
      );

      default = { };

      example = {
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
        Game."/Script/Engine.GameNetworkManager" = {
          TotalNetBandwidth = 104857600;
          MaxDynamicBandwidth = 104857600;
          MinDynamicBandwidth = 10485760;
        };
        Scalability."NetworkQuality@3" = {
          TotalNetBandwidth = 104857600;
          MaxDynamicBandwidth = 104857600;
          MinDynamicBandwidth = 10485760;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = lib.mkDefault [
      self.overlays.default
      steam-fetcher.overlay
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

      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        ExecStart = pkgs.writeShellScript "satisfactory-server" /* bash */ ''
          mkdir -p "${cfg.stateDir}/.config/Epic/FactoryGame"
          ${lib.getExe cfg.package} ${lib.escapeShellArgs serverArgs}
        '';
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.port
        cfg.messagingPort
      ];
      allowedUDPPorts = [
        cfg.port
      ];
    };
  };
}
