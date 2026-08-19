{ inputs, config, pkgs, lib, ... }:

let
  keys = (import ./admins.nix).keys;
in
{
  imports = [
    ./hardware-configuration.nix
    ./minecraft.nix
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
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "services.minecraft-server"
      "minecraft"
    ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = keys;
  };

  users.groups.minecraft-server = { };

  # Packages installed in the system profile.
  environment.systemPackages = with pkgs; [
    neovim
    vim
    wget
    curl
    screen
    git
    jdk21_headless
    kitty
    ripgrep
    lazygit
    bottom
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
}
