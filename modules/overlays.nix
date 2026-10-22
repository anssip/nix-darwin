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

    # laravel-cloud-cli: the `cloud` command (https://cloud.laravel.com). Not
    # in nixpkgs or Homebrew, so wrap the prebuilt phar upstream attaches to
    # each GitHub release. The phar bundles all PHP dependencies but needs a
    # PHP runtime: composer.json says ^8.3, but the shipped phar's platform
    # check demands >= 8.4.1, hence php84 below.
    #
    # To bump: set the version below, then take the `digest` (sha256) of the
    # `cloud` asset from
    #   https://api.github.com/repos/laravel/cloud-cli/releases
    # and convert it with `nix hash convert --hash-algo sha256 --to sri <sha256>`.
    # (`cloud self-update` can't write into the nix store, so bumps happen here.)
    (final: prev: {
      laravel-cloud-cli = prev.stdenv.mkDerivation (finalAttrs: {
        pname = "laravel-cloud-cli";
        version = "0.7.0";

        src = final.fetchurl {
          url = "https://github.com/laravel/cloud-cli/releases/download/v${finalAttrs.version}/cloud";
          hash = "sha256-G29ibk5oY2dL0+kJI6DNUcbXVud7nUt+EDglWhHLfvs=";
        };

        dontUnpack = true;

        nativeBuildInputs = [ final.makeWrapper ];

        installPhase = ''
          runHook preInstall
          install -Dm555 "$src" "$out/share/laravel-cloud-cli/cloud.phar"
          makeWrapper "${final.php84}/bin/php" "$out/bin/cloud" \
            --add-flags "$out/share/laravel-cloud-cli/cloud.phar"
          runHook postInstall
        '';

        meta = {
          description = "CLI to interact with Laravel Cloud";
          homepage = "https://github.com/laravel/cloud-cli";
          license = prev.lib.licenses.mit;
          mainProgram = "cloud";
          platforms = prev.lib.platforms.unix;
        };
      });
    })
  ];
}
