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
      owner = "iwanders";
      repo = "linux-surface-kernel";
      rev = "64b4732bd61e58a16231e057208db954f845fc53";
      sha256 = "sha256-Gfg17jhqfLqsHJ2SkMperTqek0laEdLdeVv7IRoEKs8=";
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
