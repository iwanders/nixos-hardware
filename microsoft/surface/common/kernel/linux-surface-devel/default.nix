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
      rev = "3f6f5d59423e89576283e110fa03b950c707d5c7";
      sha256 = "sha256-7FatBC7MJBA37vVF2DwpckbPVj3vVJdS1IM+UeiplK0=";
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
