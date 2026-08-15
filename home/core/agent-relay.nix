{ pkgs, ... }:
let
  npiperelay = "/mnt/c/Users/Zhang/AppData/Local/npiperelay/npiperelay.exe";
in
{
  home.packages = [
    pkgs.gnupg
    pkgs.openssh
  ];

  # Keep Windows as the GPG agent owner.  GnuPG connects to the socket below
  # instead of spawning a local gpg-agent.
  programs.gpg = {
    enable = true;
    settings = {
      no-autostart = true;
    };
  };

  # A systemd user runtime directory is per-user, so %t avoids depending on
  # ming's current numeric UID.
  systemd.user.sockets = {
    ssh-agent = {
      Unit.Description = "Windows OpenSSH agent relay socket";
      Socket = {
        ListenStream = "%t/ssh-agent.socket";
        SocketMode = "0600";
        Accept = true;
        Service = "ssh-agent@.service";
      };
      Install.WantedBy = [ "sockets.target" ];
    };

    gpg-agent-relay = {
      Unit.Description = "Windows GPG agent relay socket";
      Socket = {
        ListenStream = "%t/gnupg/S.gpg-agent";
        SocketMode = "0600";
        DirectoryMode = "0700";
        Accept = true;
        Service = "gpg-agent-relay@.service";
      };
      Install.WantedBy = [ "sockets.target" ];
    };
  };

  systemd.user.services = {
    "ssh-agent@" = {
      Unit.Description = "Windows OpenSSH agent relay connection";
      Service = {
        ExecStart = "/init ${npiperelay} -ep -ei -s //./pipe/openssh-ssh-agent";
        StandardInput = "socket";
        StandardOutput = "socket";
      };
    };

    "gpg-agent-relay@" = {
      Unit.Description = "Windows GPG agent relay connection";
      Service = {
        ExecStart = "/init ${npiperelay} -ep -ei -s -a C:/Users/Zhang/AppData/Local/gnupg/S.gpg-agent.extra";
        StandardInput = "socket";
        StandardOutput = "socket";
      };
    };
  };

  programs.nushell.extraEnv = ''
    $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"
  '';
}
