{ config, lib, pkgs, ... }: {

  options.modules.services.immich.enable =
    lib.mkEnableOption "Enable Immich image viewer";

  config = lib.mkIf config.modules.services.immich.enable {
    systemd.services.init-immich-network-bridge = {
      description = "Create Immich network bridge.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect immich-net > /dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create immich-net
      '';
    };

    systemd.tmpfiles.settings = {
      "immich" = {
        "/var/lib/immich/" = { d.mode = "0777"; };
        "/var/lib/immich/machine-learning" = { d.mode = "0777"; };
        "/var/lib/immich/postgres" = { d.mode = "0777"; };
      };
    };

    virtualisation.oci-containers = { backend = "docker"; };
    virtualisation.containers.enable = true;
    virtualisation = {
      docker = {
        enable = true;
        autoPrune.enable = true;
      };
    };
    boot.kernel.sysctl = { "vm.overcommit_memory" = 1; };

    virtualisation.oci-containers.containers = let
      immich-version = "v1.120.2";
      environment = {
        DB_HOSTNAME = "immich-postgres";
        REDIS_HOSTNAME = "immich-redis";
        DB_DATA_LOCATION = "/var/lib/immich/postgres";

        DB_DATABASE_NAME = "immich";
        DB_USERNAME = "postgres";
        DB_PASSWORD = "postgres";
        IMMICH_METRICS = "true";
        PUID = "1000";
        PGID = "100";
        TZ = config.time.timeZone;
        IMMICH_IGNORE_MOUNT_CHECK_ERRORS = "true";
      };
    in {
      immich-server = {
        autoStart = true;
        image = "ghcr.io/immich-app/immich-server:${immich-version}";
        volumes = [
          "/mnt/nas/images/immich/:/usr/src/app/upload"
          "/mnt/nas/images/artwork:/mnt/nas/images/artwork:ro"
          "/mnt/nas/images/purpose-based:/mnt/nas/images/purpose-based:ro"
        ];
        ports = [ "8090:2283" ];
        inherit environment;
        extraOptions = [ "--network=immich-net" ];
        dependsOn = [ "immich-redis" "immich-postgres" ];
      };

      immich-machine-learning = {
        autoStart = true;
        image = "ghcr.io/immich-app/immich-machine-learning:${immich-version}";
        volumes = [
          "/mnt/nas/images/immich:/usr/src/app/upload"
          "/var/lib/immich/machine-learning:/cache"
        ];
        inherit environment;
        extraOptions = [ "--network=immich-net" ];
      };

      immich-redis = {
        autoStart = true;
        image =
          "registry.hub.docker.com/library/redis:6.2-alpine@sha256:e3b17ba9479deec4b7d1eeec1548a253acc5374d68d3b27937fcfe4df8d18c7e";
        ports = [ "6379:6379" ];
        extraOptions = [
          "--network=immich-net"
          "--health-cmd=redis-cli ping || exit 1"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-start-period=30s"
        ];
      };

      immich-postgres = {
        autoStart = true;
        image =
          "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
        ports = [ "5432:5432" ];
        volumes = [ "/var/lib/immich/postgres:/var/lib/postgresql/data" ];
        environment = {
          POSTGRES_PASSWORD = environment.DB_PASSWORD;
          POSTGRES_USER = environment.DB_USERNAME;
          POSTGRES_DB = environment.DB_DATABASE_NAME;
          POSTGRES_INITDB_ARGS = "--data-checksums";
        };
        cmd = [
          "postgres"
          "-c"
          "shared_preload_libraries=vectors.so"
          "-c"
          ''search_path="$$user", public, vectors''
          "-c"
          "logging_collector=on"
          "-c"
          "max_wal_size=2GB"
          "-c"
          "shared_buffers=512MB"
          "-c"
          "wal_compression=on"
        ];
        extraOptions = [ "--network=immich-net" ];
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."_" = {
        locations."/immich" = {
          proxyPass = "http://127.0.0.1:8090";
          recommendedProxySettings = true;
        };
      };
    };

    fileSystems."/mnt/nas/images" = {
      device = "//172.19.20.10/images";
      fsType = "cifs";
      options = [
        "credentials=/etc/nixos/smb-secrets"
        "vers=3.0"
        "x-systemd.automount"
        "x-systemd.requires=network-online.target"
        "x-systemd.after=network-online.target"
        "uid=1000"
        "gid=100"
        "file_mode=0770"
        "dir_mode=0770"
      ];
    };
  };
}
