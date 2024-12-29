{ lib, pkgs, config, ... }:
{
	options = with lib.types; {
		yanamianna = {
			podmanServices = lib.mkOption {
				type = attrsOf (submodule ({ name, ... }: {
					options = {
						enable = lib.mkOption {
							type = bool;
						};

						path = lib.mkOption {
							type = str;
							description = "path of the directory containing podman-compose.yml";
							default = "/srv/${name}";
						};
					};
				}));
				default = {};
				description = "systemd services for podman";
			};
		};
	};

	config = {
		systemd.services = lib.mapAttrs (name: value: {
			enable = value.enable;
			after = [ "network-online.target" "podman.service" ];
			wants = [ "network-online.target" "podman.service" ];
			wantedBy = [ "multi-user.target" ];
			description = "Podman container service: ${name}";
			path = with pkgs; [podman podman-compose];
			serviceConfig = {
				Type = "oneshot";
				RemainAfterExit = "yes";
				WorkingDirectory = value.path;
				ExecStartPre = ''${pkgs.coreutils}/bin/sleep 1'';
				ExecStart = ''/bin/sh -c "podman compose up -d"'';
				ExecStop = ''/bin/sh -c "podman compose down"'';
			};
		}) config.yanamianna.podmanServices;

		virtualisation.podman = {
			enable = true;

			# Prune unused images periodically
			autoPrune = {
				enable = true;
				dates = "weekly";
				flags = ["--all"];
			};

			defaultNetwork.settings = {
				dns_enabled = true;
			};
		};
	};
}
