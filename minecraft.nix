{ inputs, config, pkgs, lib, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/SESG-HTX-LAN/server-modpack/c7bfc2397e9d5151a6e7c42a8362d7fb329fcfe7/pack.toml";
    packHash = "sha256-LKRBDHmSQ/cvRM1BS9VQKw6yseGLijzgpCYmQdQsFVs=";
    #dontVerifyIndexHash = true;
  };

  bedwars = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/SESG-HTX-LAN/bedwars-server/f6aa2f19d2afdcfdf146ab7e7fbb8d65a21af2ff/pack.toml";
    packHash = "sha256-xw72z8BgbTXcaKffJyIVYR52bKgf16wIM9oFon8+COY=";
    #dontVerifyIndexHash = true;
  };

  spigotJar = pkgs.fetchurl {
    url = "https://cdn.getbukkit.org/spigot/spigot-1.12.2.jar";
    hash = "sha256-RIa3gV7WyF6LLmr54vV5/wluWliL7BpEcBWZP9UhOPE=";
  };

  spigot = pkgs.vanillaServers.vanilla-1_12_2.overrideAttrs ( oldAttrs: {
    src = spigotJar;
    jre_headless = pkgs.openjdk17_headless;
  });
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

    servers.bedwars = {
      enable = true;
      openFirewall = true;
      enableReload = true;

      package = spigot;

      jvmOpts = "-javaagent:slimeworldmanager-classmodifier-2.2.1.jar -Xms1024M -Xmx6144M -Dfile.encoding=UTF-8";

      serverProperties = {
	server-port = 23343;
	motd = "Bedwars HTX";
	max-players = 30;
      };

      extraReload = ''
      	cp -rn ${bedwars}/* /srv/minecraft/bedwars
	chown -R minecraft:minecraft /srv/minecraft/bedwars/
      '';
    };
  };
}
