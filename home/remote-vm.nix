{ pkgs, lib, config, ... }:

###################################################################################
#
#  Remote windowed-app access for a Windows client, via a Linux VM on the mini.
#
#  macOS can't give a Windows client an independent, concurrent second-user GUI
#  session (Apple's Screen Sharing "virtual display" is Mac/iPad-client-only).
#  So we run a headless Ubuntu+XFCE VM under Lima that exposes a desktop over RDP.
#  The Windows side uses its built-in Remote Desktop Connection; the browser runs
#  in the guest, alongside (concurrent with) the `anssi` macOS console session.
#
#  Guest definition: modules/lima/win-desktop.yaml
#
#  ── One-time bootstrap on the mini ──────────────────────────────────────────
#    1. Create the VM (downloads the image, runs provisioning — takes a while):
#         limactl start --name=win-desktop \
#           ~/nix-darwin-config/modules/lima/win-desktop.yaml
#    2. Change the guest login password from the placeholder in the template:
#         limactl shell win-desktop -- sudo passwd "$(whoami)"
#    3. Expose RDP to the tailnet only (not the LAN):
#         tailscale serve --bg --tcp 3389 tcp://localhost:3389
#  From Windows (joined to the tailnet): Remote Desktop Connection ->
#    anssis-macmini.tailcb0f0e.ts.net:3389
#
#  After the one-time create, the launchd agent below restarts the VM on login.
#
###################################################################################

let
  vmName = "win-desktop";

  # Restart the already-created VM on login. (Initial creation is the one-time
  # bootstrap above — it needs the template and a network download, so we don't
  # do it from the agent.) `vz` virtualization needs the user's GUI session, so
  # this runs as a LaunchAgent rather than a system daemon.
  startScript = pkgs.writeShellScript "lima-${vmName}-start" ''
    set -eu
    export PATH=${lib.makeBinPath [ pkgs.lima ]}:/usr/bin:/bin
    if limactl list --format '{{.Name}}' | grep -qx ${vmName}; then
      exec limactl start --tty=false ${vmName}
    fi
    echo "lima instance '${vmName}' not found — run the one-time bootstrap (see home/remote-vm.nix)" >&2
    exit 0
  '';
in
{
  home.packages = [ pkgs.lima ];

  launchd.agents."lima-${vmName}" = {
    enable = true;
    config = {
      ProgramArguments = [ "${startScript}" ];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/lima-${vmName}.out.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/lima-${vmName}.err.log";
    };
  };
}
