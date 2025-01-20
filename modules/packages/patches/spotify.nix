super: super.spotify.overrideAttrs(oldAttrs: {
	postFixup = ''
		sed -i 's/%U/--uri %U/' "$out/share/applications/spotify.desktop"
	'';
})
