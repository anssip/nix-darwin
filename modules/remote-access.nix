{ lib, ... }:

###################################################################################
#
#  macOS Remote Login (sshd).
#
#  Pair with modules/tailscale.nix to allow SSH-in over the tailnet.
#
###################################################################################

{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    /usr/sbin/systemsetup -setremotelogin on >/dev/null 2>&1 || \
      echo "warning: could not enable Remote Login (may need Full Disk Access for the terminal)"
  '';
}
