{ inputs, config, pkgs, lib, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/SESG-HTX-LAN/server-modpack/c7bfc2397e9d5151a6e7c42a8362d7fb329fcfe7/pack.toml";
    packHash = "sha256-LKRBDHmSQ/cvRM1BS9VQKw6yseGLijzgpCYmQdQsFVs=";
    #dontVerifyIndexHash = true;
  };
in
{
  environment.systemPackages = with pkgs; [
    tmux
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    user = "minecraft";
    group = "minecraft";

    managementSystem.tmux.enable = true;

    servers.htx = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      enableReload = true;
      
      jvmOpts = "-Xms2G -Xmx20G";
      serverProperties = {
        server-port = 25565;
        difficulty = "normal";
        gamemode = "survival";
	motd = "HTX Minecraft server! Installer simple voice chat for ingame proxi chat";
        max-players = 20;
	level-name = "world.2627";
      };
      package = pkgs.fabricServers.fabric-26_1_2.override {
        jre_headless = pkgs.openjdk25_headless;
      };
      symlinks = {
        mods = "${modpack}/mods";
      };
      files = {
        config = "${modpack}/config";
      };
    };
  };
}
