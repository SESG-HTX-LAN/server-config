{ inputs, config, pkgs, lib, ... }:

let
  keys = (import ./admins.nix).keys;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  system.stateVersion = "26.05";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  # Enable networking.
  networking.networkmanager.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 21 22 25565 ];
    allowedUDPPorts = [ 24454 ];
  };

  networking.interfaces.enp2s0.ipv4.addresses = [
    {
      address = "10.34.144.50";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway.address = "10.34.144.1";
  networking.nameservers = [ "8.8.8.8" ];

  # Time zone.
  time.timeZone = "Europe/Copenhagen";

  # Internationalisation.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Keymap.
  services.xserver.xkb = {
    layout = "dk";
    variant = "winkeys";
  };
  console.keyMap = "dk-latin1";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # The Minecraft server jar is marked unfree.
  nixpkgs.config.allowUnfree = true;

  # ---- Admin account (see admins.nix) -----------------------------------------
  users.users.minecraft = {
    isNormalUser = true;
    description = "noname";
    extraGroups = [ "networkmanager" "wheel" "minecraft-server" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = keys;
  };

  users.groups.minecraft-server = { };

  # Packages installed in the system profile.
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    screen
    git
    jdk21_headless
    kitty
  ];

  # ---- SSH -------------------------------------------------------------------
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      AllowUsers = null;
      UseDns = true;
    };
  };

  # ---- Minecraft -------------------------------------------------------------
  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/srv/minecraft";
    
    # For modpack from Modrinth
    servers.polymania = {
      enable = true;
      autoStart = true;
      
      # This pulls Polymania 26.1.2
      modrinth-modpack = {
        projectId = "polymania";
        versionId = "26.1.2";
      };
      
      plugins = [{
        source = "https://cdn.modrinth.com/data/...";
      }];
      
      jvmOpts = "-Xms4G -Xmx16G";
      serverProperties = {
        server-port = 25565;
        difficulty = "normal";
        gamemode = "survival";
        max-players = 20;
        # Voice chat uses port 24454 UDP by default
      };

      symlinks.mods = pkgs.linkFarmFromDrvs "mods" ( builtins.attrValues {
      	Voice-chat = pkgs.fetchurl {
	  url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/Z8DASI8B/voicechat-fabric-2.6.22%2B26.1.2.jar?mr_download_reason=standalone&mr_game_version=26.1.2&mr_loader=fabric";
	  sha256 = "07ammfj3dlzigwby2kcljqwrwv1i77c07b6kz9gr74fciq80ff96";
	};
      });
      symlinks.config = pkgs.linkFarmFromDrvs "config" ( builtins.attrValues {                 
        "polydex.json" = pkgs.writeTextFile {
          name = "polydex.json";
          text = ''
 {
  "enable_search": true,
  "enable_language_support_in_search": true,
  "enable_hover_display": false,
  "hover_display_update_rate": 4,
  "hover_display_entity_absorption": false,
  "default_hover_settings": {
    "display_type": "polydex:bossbar",
    "display_mode": "TARGET",
    "visible_components": {
      "polydex:fuel": "NEVER",
      "polyfactory:debug_data": "NEVER",
      "polydex:input": "NEVER",
      "polydex:progress": "ALWAYS",
      "polydex:name": "ALWAYS",
      "polyfactory:filled_amount": "ALWAYS",
      "polydex:mod_source": "NEVER",
      "polydex:armor": "ALWAYS",
      "polydex:raw_id": "NEVER",
      "polyfactory:machine_state": "ALWAYS",
      "polydex:effects": "ALWAYS",
      "polydex:output": "NEVER",
      "polydex:health": "ALWAYS"
    }
  },
  "disabled_hover_information": [],
  "display_can_show_requirement": {
    "type": "has_player"
  },
  "displayCantMine": true,
  "displayModSource": true,
  "displayAdditional": true,
  "displayMiningProgress": true,
  "displayEntity": true,
  "displayEntityHealth": true
}           
          '';
        };
      });
    };
  };
}
