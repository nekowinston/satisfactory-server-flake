{ modules, testers }:
testers.runNixOSTest {
  name = "satisfactory-server";

  nodes.machine =
    { config, ... }:
    let
      cfg = config.services.satisfactory;
    in
    {
      imports = modules;

      services.satisfactory = {
        enable = true;
        openFirewall = true;

        iniSettings.Engine = {
          # allow the tests to skip authentication.
          SystemSettings."FG.DedicatedServer.AllowInsecureLocalAccess" = 1;
        };
      };

      # needs to be bumped to host a game session
      virtualisation.memorySize = 4096;

      virtualisation.forwardPorts = [
        {
          host.port = cfg.port;
          guest.port = cfg.port;
        }
        {
          host.port = cfg.port;
          guest.port = cfg.port;
          proto = "udp";
        }
        {
          host.port = cfg.messagingPort;
          guest.port = cfg.messagingPort;
        }
      ];
    };

  extraPythonPackages = ps: [
    ps.requests
    ps.types-requests
  ];

  # To use, you can run:
  # > nix build .#tests.satisfactory-server
  testScript =
    { nodes, ... }:
    let
      cfg = nodes.machine.services.satisfactory;
    in
    /* py */ ''
      import requests

      machine.wait_for_unit("satisfactory")
      machine.wait_for_open_port(${toString cfg.port})

      with subtest("Check that the server is healthy"):
          response = requests.post("https://localhost:${toString cfg.port}/api/v1", verify=False, json={
              "function": "HealthCheck",
              "data": { "clientCustomData": "" }
          })
          print(f"Response code: {response.status_code}")
          print("Response: %r" % response.content)

          assert response.json()["data"]["health"] == "healthy"

      machine.shell_interact()
    '';
}
