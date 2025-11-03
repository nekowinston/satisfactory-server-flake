{ modules, testers }:
testers.runNixOSTest {
  name = "satisfactory-server";

  nodes.machine = {
    imports = modules;

    services.satisfactory = {
      enable = true;
      openFirewall = true;
    };

    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 7777;
        guest.port = 7777;
        proto = "tcp";
      }
      {
        from = "host";
        host.port = 7777;
        guest.port = 7777;
        proto = "udp";
      }
      {
        from = "host";
        host.port = 8888;
        guest.port = 8888;
        proto = "tcp";
      }
    ];
  };

  # To use, you can run:
  # > nom-build -A packages.x86_64-linux.tests.satisfactory-server.driver
  # > ./result/bin/nixos-test-driver
  testScript = ''
    start_all()
    machine.shell_interact()
  '';
}
