{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.networking.vpn;
in
{
  options = {
    networking.vpn = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      wgConfigFile = mkOption {
        type = types.path;
        default = "/var/lib/secrets/wg0.conf";
      };
      portForwards = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            localPort = mkOption {
              type = types.int;
            };
            namespacePort = mkOption {
              type = types.int;
            };
          };
        });
        default = { };
      };
      services = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };
  config = mkIf cfg.enable
    {
      # services.resolved.enable = true;
      systemd.services = {
        wg = {
          description = "wg network interface";
          requires = [ "network-online.target" ];
          after = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = with pkgs; writers.writeBash "wg-up" ''
              set -e

              ${iproute2}/bin/ip netns add wg
              ${iproute2}/bin/ip netns exec wg ${iproute2}/bin/ip link set dev lo up
              mkdir -p /etc/netns/wg
              echo "nameserver 1.1.1.1" > /etc/netns/wg/resolv.conf

              ${iproute2}/bin/ip link add wg0 type wireguard
              ${iproute2}/bin/ip link set wg0 netns wg
              ${iproute2}/bin/ip -n wg address add 10.197.52.6/24 dev wg0
              ${iproute2}/bin/ip netns exec wg ${wireguard-tools}/bin/wg setconf wg0 ${cfg.wgConfigFile}
              ${iproute2}/bin/ip -n wg link set wg0 up
              ${iproute2}/bin/ip -n wg route add default dev wg0
            '';
            ExecStop = with pkgs; writers.writeBash "wg-down" ''
              set -e

              ${iproute2}/bin/ip -n wg route del default dev wg0
              ${iproute2}/bin/ip -n wg link del wg0

              ${iproute2}/bin/ip netns del wg
              rm /etc/netns/wg/resolv.conf
              rmdir /etc/netns/wg
            '';
          };
        };
      }
      // mapAttrs # todo: generate service name
        (portName: portConfig: {
          wantedBy = [ "multi-user.target" ];
          after = [ "wg.service" ];
          requires = [ "wg.service" ];
          # wantedBy = [ "network.target" ];
          serviceConfig = {
            ExecStart = with pkgs; ''
              ${socat}/bin/socat tcp-listen:${ toString portConfig.localPort},fork,reuseaddr exec:'${iproute2}/bin/ip netns exec wg ${socat}/bin/socat STDIO "tcp-connect:127.0.0.1:${toString portConfig.namespacePort}"',nofork
            '';
          };
        })
        cfg.portForwards
      // listToAttrs (map
        (serviceName: {
          name = serviceName;
          value = {
            after = [ "wg.service" ];
            requires = [ "wg.service" ];
            serviceConfig = {
              NetworkNamespacePath = "/var/run/netns/wg";
              BindReadOnlyPaths = [ "/etc/netns/wg/resolv.conf:/etc/resolv.conf:norbind" ];
            };
          };
        })
        cfg.services);
    };
}
