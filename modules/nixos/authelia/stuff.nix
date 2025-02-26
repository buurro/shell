{
  nginx.enableVhost = builtins.readFile ./authelia-location.conf;
  nginx.enableLocation = (builtins.readFile ./proxy.conf) + (builtins.readFile ./authelia-authrequest.conf);
}
