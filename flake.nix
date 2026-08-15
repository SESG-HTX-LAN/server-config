{
  description = "NixOS Minecraft server configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-minecraft,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          nix-minecraft.nixosModules.minecraft-servers
          {
            nixpkgs.overlays = [ nix-minecraft.overlays.default ];
          }
        ];
	specialArgs = { inherit inputs; };
      };
    };
}
