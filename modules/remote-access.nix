{ pkgs, lib, ... }:

###################################################################################
#
#  macOS Remote Login (sshd).
#
#  Pair with modules/tailscale.nix to allow SSH-in over the tailnet.
#
###################################################################################

{
  # Install terminfo for clients that set exotic TERM values when SSHing in
  # (Ghostty sets TERM=xterm-ghostty). We use ghostty-bin (the prebuilt binary
  # distribution) rather than ghostty, because ghostty is marked broken on
  # aarch64-darwin and building it from source fails.
  environment.systemPackages = [ pkgs.ghostty-bin.terminfo ];

  system.activationScripts.postActivation.text = lib.mkAfter ''
    /usr/sbin/systemsetup -setremotelogin on >/dev/null 2>&1 || \
      echo "warning: could not enable Remote Login (may need Full Disk Access for the terminal)"
  '';
}
