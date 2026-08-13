{
  # Admin users and their SSH public keys.
  #
  # Add a new admin by appending to this list, then rebuild the system
  # on the server with `nixos-rebuild switch --flake .#nixos`.
  admins = [
    {
      username = "minecraft";
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA3e1bjmTPRT/fN+7ubogo2qJU4KOn9TOy+7A6aQVyCN viggokh@framework13"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7R0xrx7mrLnksZTO3Zc8I2i5aTEunWxFcfVeDTL71x viggokh@goonbox-3500"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvVhNbaAGMDhwnTCV1efStVB+KXxP1mgVLKBeh2JAo3 thild@Undercover-Iphone"
      ];
    }
  ];
}
