pkgs: pkgs.keeweb.overrideAttrs (old: {
	postFixup = builtins.replaceStrings
		["--add-flags"]
		[''--add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime=true}}" --add-flags'']
		old.postFixup;
})
