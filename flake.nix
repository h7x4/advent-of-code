{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      day01 = pkgs.callPackage ./day01 {};
      day02 = pkgs.callPackage ./day02 {};
      day03 = pkgs.callPackage ./day03 {};
    };
  };
}
