{ config, lib, pkgs, ... }:

{
  environment.etc."hosts" = {
    text = ''
      127.0.0.1 localhost
      127.0.0.1 elasticsearch.snowfox.local
      ::1 localhost
    '';
  };
}
