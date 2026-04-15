{ pkgs, lib, ... }:

###################################################################################
#
#  Tailscale daemon (CLI).
#
#  Installs `tailscale` + `tailscaled` and runs the daemon as a root LaunchDaemon.
#  Run `sudo tailscale up` once per machine to authenticate into the tailnet.
#
###################################################################################

{
  environment.systemPackages = with pkgs; [ tailscale ];

  system.activationScripts.preActivation.text = lib.mkAfter ''
    mkdir -p /var/lib/tailscale
    chmod 700 /var/lib/tailscale
  '';

  launchd.daemons.tailscaled = {
    serviceConfig = {
      Label = "com.tailscale.tailscaled";
      ProgramArguments = [
        "${pkgs.tailscale}/bin/tailscaled"
        "--state=/var/lib/tailscale/tailscaled.state"
        "--socket=/var/run/tailscaled.socket"
        "--port=41641"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/tailscaled.log";
      StandardErrorPath = "/var/log/tailscaled.log";
    };
  };
}
