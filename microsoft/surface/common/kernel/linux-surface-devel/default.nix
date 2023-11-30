{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption types;
  inherit (pkgs) fetchurl;

  inherit (pkgs.callPackage ../linux-package.nix { }) linuxPackage repos;

  cfg = config.microsoft-surface;

  version = "6.5.3";
  extraMeta.branch = "surface-devel";

  #patchDir = repos.linux-surface + "/patches/${extraMeta.branch}";
  kernelPatches = pkgs.callPackage ./patches.nix {
    inherit (lib) kernel;
    inherit version;
  };


  kernelPackages = linuxPackage {
    inherit version extraMeta kernelPatches;
    src = pkgs.fetchFromGitHub {
      owner = "linux-surface";
      repo = "kernel";
      rev = "df0bd8ffbea23a1819920da1a95ab55d12d4c5bf";
      sha256 = "sha256-iUVvpPhDy7oc5/kEH4eXpPL7kTFaFARpjQXo0GEqT/o=";
    };
  };


in {
  options.microsoft-surface.kernelVersion = mkOption {
    type = types.enum [ "surface-devel" ];
  };

  config = mkIf (cfg.kernelVersion == "surface-devel") {
    boot = {
      inherit kernelPackages;
    };
  };
}
