{ config, lib, ... }:
let
  ports = config.pkgs.server.ports.ports;
in {
  config = {
    pkgs.server = {
      # Service
      ports = {
        ports.mailserver = {
          smtp = 25;
          pop3 = 110;
          imap = 143;
          smtp-starttls = 587;
          imaps = 993;
          pop3s = 995;
          webmail = 20618;
        };
      };

      podman.services.mailserver.enable = true;

      # Ingress
      ingress.rules."webmail.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.mailserver.webmail;
      };

      # Firewall
      firewall.rules.mailserver = {
        from = [ "all" ];
        allowedTCPPorts = lib.attrValues {
          inherit (ports.mailserver) smtp pop3 imap smtp-starttls imaps pop3s;
        };
      };

      # Acme
      acme.reloadedServices = [ "service-mailserver" ];
    };
  };
}
