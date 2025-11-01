{ config, lib, pkgs, ... }:
{
	options = with lib; with types; {
		pkgs.server.firewall = {
			zones = mkOption {
				type = attrsOf (submodule {
					options = {
						parent = mkOption { type = nullOr str; default = null; };
						interfaces = mkOption { type = listOf str; default = []; };
						ipv4Addresses = mkOption { type = listOf str; default = []; };
						ipv6Addresses = mkOption { type = listOf str; default = []; };
						ingressExpression = mkOption { type = listOf str; default = []; };
						egressExpression = mkOption { type = listOf str; default = []; };
					};
				});
			};

			rules = let
				ports = listOf (either port (submodule {
					options = {
						from = mkOption { type = port; };
						to = mkOption { type = port; };
					};
				}));
			in mkOption {
				type = attrsOf (submodule {
					options = {
						from = mkOption { type = listOf str; default = []; };
						to = mkOption { type = listOf str; default = []; };
						allowedTCPPorts = mkOption { type = ports; default = []; };
						allowedUDPPorts = mkOption { type = ports; default = []; };
						deniedTCPPorts = mkOption { type = ports; default = []; };
						deniedUDPPorts = mkOption { type = ports; default = []; };
						verdict = mkOption { type = nullOr (enum ["accept" "drop" "reject"]); default = null; };
					};
				});
			};
		};
	};

	config = with lib; let
		opts = config.pkgs.server.firewall;
		zones = mapAttrs (name: zone: with zone; {
			name = name;
			ingressExpression = flatten [
				ingressExpression
				(optionals (parent != null) zones.${parent}.ingressExpression)
				(optional (length interfaces >= 1) "iifname { ${concatStringsSep ", " interfaces} }")
				(optional (length ipv6Addresses >= 1) "ip6 saddr { ${concatStringsSep ", " ipv6Addresses} }")
				(optional (length ipv4Addresses >= 1) "ip saddr { ${concatStringsSep ", " ipv4Addresses} }")
			];
			egressExpression = flatten [
				egressExpression
				(optionals (parent != null) zones.${parent}.egressExpression)
				(optional (length interfaces >= 1) "oifname { ${concatStringsSep ", " interfaces} }")
				(optional (length ipv6Addresses >= 1) "ip6 daddr { ${concatStringsSep ", " ipv6Addresses} }")
				(optional (length ipv4Addresses >= 1) "ip daddr { ${concatStringsSep ", " ipv4Addresses} }")
			];
		}) opts.zones;

		toPorts = ports:
			"{ ${concatMapStringsSep ", " (port:
				if isInt port then toString port
				else "${toString port.from}-${toString port.to}"
			) ports} }";

		toZoneExpression = kind: name:
			join " " (zones.${name}."${kind}Expression");

		toZoneIngress = toZoneExpression "ingress";
		toZoneEgress = toZoneExpression "egress";

		toChain = chains:
			concatMapAttrsStringSep "\n"
				(name: group: "chain ${name} {\n${join "\n" (map (chain: chain.rule) group)}\n}")
				(groupBy (chain: chain.name) chains);

		toRuleChains = { chain, prefix }: rule: [
			(optional (length rule.allowedUDPPorts >= 1) {
				name = chain;
				rule = "${prefix} udp dport ${toPorts rule.allowedUDPPorts} accept";
			})

			(optional (length rule.allowedTCPPorts >= 1) {
				name = chain;
				rule = "${prefix} tcp dport ${toPorts rule.allowedTCPPorts} accept";
			})

			(optional (length rule.deniedUDPPorts >= 1) {
				name = chain;
				rule = "${prefix} udp dport ${toPorts rule.allowedUDPPorts} drop";
			})

			(optional (length rule.deniedTCPPorts >= 1) {
				name = chain;
				rule = "${prefix} tcp dport ${toPorts rule.allowedTCPPorts} drop";
			})

			(optional (rule.verdict != null) {
				name = chain;
				rule = "${prefix} ${rule.verdict}";
			})
		];

		inputRules = filterAttrs
			(name: rule: (length rule.from) >= 1 && (length rule.to) == 0)
			opts.rules;

		inputAllowChain = mapAttrsToList
			(name: zone: "${toZoneIngress name} jump input-zone-${name}")
			zones;

		inputZoneChains = flatten (
			(mapAttrsToList
				(name: zone: { name = "input-zone-${name}"; rule = ""; })
				zones
			) ++
			(mapAttrsToList
				(name: rule: (map
					(zone: toRuleChains {
						chain = "input-zone-${zone}";
						prefix = "";
					} rule)
					rule.from
				))
				inputRules
			)
		);

		forwardRules = filterAttrs
			(name: rule: (length rule.from) >= 1 && (length rule.to) >= 1)
			opts.rules;

		forwardAllowChain = flatten (mapAttrsToList
			(name: rule: (map
				(zone: "${toZoneIngress zone} jump forward-rule-${name}")
				rule.from
			))
			forwardRules
		);

		forwardRuleChains = flatten (mapAttrsToList
			(name: rule: (map
				(zone: toRuleChains {
					chain = "forward-rule-${name}";
					prefix = toZoneEgress zone;
				} rule)
				rule.to
			))
			forwardRules
		);
	in {
		environment.systemPackages = with pkgs; [ nftables ];

		networking.firewall.enable = false;
		networking.nftables.enable = true;
		networking.nftables.tables.firewall = {
			family = "inet";
			content = ''
				chain rpfilter {
					type filter hook prerouting priority mangle + 10; policy drop;
					meta nfproto ipv4 udp sport . udp dport { 67 . 68, 68 . 67 } accept comment "accept DHCPv4 client/server"
					fib saddr . mark . iif oif exists accept
				}

				chain input {
					type filter hook input priority filter; policy drop;

					ct state vmap {
						invalid : drop,
						established : accept,
						related : accept,
						new : jump input-allow,
						untracked: jump input-allow,
					}

					tcp flags syn / fin,syn,rst,ack log level info prefix "refused connection: "
				}

				chain input-allow {
					${concatLines inputAllowChain}

					icmp type echo-request limit rate 2/second accept comment "allow ping"
					icmpv6 type != { nd-redirect, 139 } accept comment "accept ICMPv6 messages"
					ip6 daddr fe80::/64 udp dport 546 accept comment "accpe DHCPv6 client"
				}

				${toChain inputZoneChains}

				chain forward {
					type filter hook forward priority filter; policy drop;

					ct state vmap {
						invalid : drop,
						established : accept,
						related : accept,
						new : jump forward-allow,
						untracked : jump forward-allow,
					}
				}

				chain forward-allow {
					${concatLines forwardAllowChain}

					icmpv6 type != { router-renumbering, 139 } accept comment "accept ICMPv6 messages"
					ct status dnat accept comment "allow port forward"
				}

				${toChain forwardRuleChains}
			'';
		};
	};
}
