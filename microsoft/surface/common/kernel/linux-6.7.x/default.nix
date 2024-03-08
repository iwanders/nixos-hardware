{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption;

  inherit (pkgs.callPackage ../linux-package.nix { }) linuxPackage surfacePatches isVersionOf versionsOfEnum;

  cfg = config.microsoft-surface;

  version = "6.7.6";
  kernelPatches = surfacePatches {
    inherit version;
    patchFn = ./patches.nix;
  };
  kernelPackages = linuxPackage {
    inherit version kernelPatches;
    sha256 = "sha256-5InsDhNw0Im0RtVlre16aYCT0rfEEioY8h7bbvk9N9M=";
    ignoreConfigErrors=true;
  };

in {
  options.microsoft-surface.kernelVersion = mkOption {
    type = versionsOfEnum version;
  };

  config = mkIf (isVersionOf cfg.kernelVersion version) {
    boot = {
      inherit kernelPackages;
    };
  };
}
