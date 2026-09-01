{ ... }:

###################################################################################
#
#  Package overrides that run ahead of nixpkgs.
#
###################################################################################

{
  nixpkgs.overlays = [
    # bun: nixpkgs-unstable trails upstream by a few releases, so point the
    # derivation at the official prebuilt release instead. Upstream's build is
    # just an unpacked zip, which is exactly what the nixpkgs derivation does,
    # so only the version and the per-platform source hashes change.
    #
    # To bump: set the version below, then take the checksums from
    #   https://github.com/oven-sh/bun/releases/download/bun-v<version>/SHASUMS256.txt
    # and convert each with `nix hash convert --hash-algo sha256 --to sri <sha256>`.
    # Remove this override once nixpkgs has caught up.
    (final: prev: {
      bun = prev.bun.overrideAttrs (finalAttrs: prevAttrs: {
        version = "1.4.0";

        # `src` is derived from `passthru.sources.${system}` upstream, so
        # replacing the source set is enough to retarget every platform.
        # mkDerivation cannot see that, and warns about a version bump without
        # a matching `src` unless told the omission is deliberate.
        __intentionallyOverridingVersion = true;
        passthru = prevAttrs.passthru // {
          sources = {
            "aarch64-darwin" = final.fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v${finalAttrs.version}/bun-darwin-aarch64.zip";
              hash = "sha256-xmnpf2Fk4cluBwF0jbmN+ndJKQjL2DlMdVcTSnNd44E=";
            };
            "aarch64-linux" = final.fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v${finalAttrs.version}/bun-linux-aarch64.zip";
              hash = "sha256-SxozLuhhmD65O8/m93D/+U4+MbLDiL2uo8jtNeWO7Q4=";
            };
            "x86_64-darwin" = final.fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v${finalAttrs.version}/bun-darwin-x64-baseline.zip";
              hash = "sha256-2pufG0unZsbymXEfON+qmGI+HtnECJaqU9uAPFLsH6A=";
            };
            "x86_64-linux" = final.fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v${finalAttrs.version}/bun-linux-x64.zip";
              hash = "sha256-LQP7X7g6yLVnrKCigbLOGhoZ1Ij1bClo2Iw/Jekv5FI=";
            };
          };
        };
      });
    })
  ];
}
