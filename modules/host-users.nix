
{ hostname, username, ... }:

#############################################################
#
#  Host & Users configuration
#
#############################################################

{
  networking.hostName = hostname;
  networking.computerName = hostname;

  # No `system.defaults.smb.NetBIOSName` here: nix-darwin writes it on every
  # activation, and on macOS 26 /Library/Preferences/SystemConfiguration is
  # TCC-protected, so `defaults write` fails ("Could not write domain ...")
  # unless the invoking terminal has Full Disk Access. The NetBIOS name is
  # already set correctly on all hosts, and hostName/computerName above cover
  # the names macOS actually shows.

  users.users."${username}"= {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [ username ];
}