{ config, secretsPath, ... }:
{
  services.keycloak = {
    enable = true;
    settings = {
      hostname = "keycloak.pine.marco.ooo";
      http-port = 8084;
      https-port = 8444;
    };
    database.passwordFile = "${secretsPath}/keycloak-db-password";
    sslCertificate = "${config.security.acme.certs."pine.marco.ooo".directory}/fullchain.pem";
    sslCertificateKey = "${config.security.acme.certs."pine.marco.ooo".directory}/key.pem";
  };
  services.nginx.virtualHosts."keycloak.pine.marco.ooo" = {
    useACMEHost = "pine.marco.ooo";
    forceSSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }
    ];
    extraConfig = ''
      location / {
        proxy_pass https://localhost:${toString config.services.keycloak.settings.https-port}/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
      }
    '';
  };
}
