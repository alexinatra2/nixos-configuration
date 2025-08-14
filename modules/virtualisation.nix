{
  pkgs,
  ...
}:
{
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    # podman = {
    #   enable = true;

    #   # Create a `docker` alias for podman, to use it as a drop-in replacement
    #   dockerCompat = true;

    #   # Required for containers under podman-compose to be able to talk to each other.
    #   defaultNetwork.settings.dns_enabled = true;
    # };
    docker = {
      enable = true;
      package = pkgs.docker_25;
    };

    oci-containers = {
      backend = "docker";
      containers.neo4j = {
        image = "neo4j:4.4";
        ports = [
          "7474:7474"
          "7687:7687"
        ];
        environment = {
          NEO4J_AUTH = "neo4j:some-password";
        };
        extraOptions = [
          "--restart=unless-stopped"
        ];
      };
    };
  };

  # Useful container development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
  ];
}
