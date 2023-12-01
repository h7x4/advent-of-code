{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    AoCLib = pkgs.callPackage ./lib.nix { };
    packages.${system} = {
      day01 = pkgs.callPackage ./day01 { inherit (self) AoCLib; };
      day02 = pkgs.callPackage ./day02 { inherit (self) AoCLib; };
      day03 = pkgs.callPackage ./day03 { inherit (self) AoCLib; };
      day04 = pkgs.callPackage ./day04 { inherit (self) AoCLib; };
      day05 = pkgs.callPackage ./day05 { inherit (self) AoCLib; };
      day06 = pkgs.callPackage ./day06 { inherit (self) AoCLib; };
      day07 = pkgs.callPackage ./day07 { inherit (self) AoCLib; };
      day08 = pkgs.callPackage ./day08 { inherit (self) AoCLib; };
      day09 = pkgs.callPackage ./day09 { inherit (self) AoCLib; };
      day10 = pkgs.callPackage ./day10 { inherit (self) AoCLib; };
    };
  };
}
