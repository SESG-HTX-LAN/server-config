{ inputs, config, pkgs, lib, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/SESG-HTX-LAN/server-modpack/refs/heads/master/pack.toml";
    packHash = "sha256-17haizlskq9spgn46d1k2rgs2zx00hgmwhnvz217v3gjkays6jy7";
  };
in
{
  services.minecraft-servers.servers.minecraft = {
    enable = true;
    autoStart = true;
    
    jvmOpts = "-Xms4G -Xmx20G";
    serverProperties = {
      server-port = 25565;
      difficulty = "normal";
      gamemode = "survival";
      max-players = 20;
    };
    package = pkgs.fabricServers.fabric-26_1_2;
    symlinks = {
      "mods" = "${modpack}/mods";
    };
    files = {
      "config" = "${modpack}/config";
    };
  };
}
