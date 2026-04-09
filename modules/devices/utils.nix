{
	defineDevice = { inputs, system }:
		let
			self = inputs.self;
			std = inputs.std.lib;
			kind = if std.string.hasSuffix "darwin" system then "darwin" else "nixos";
			base = (import "${self}/modules/base") kind;
			repo = import "${self}/modules/packages";
			latestPkgs = import inputs.nixpkgs-latest {
				inherit system;
				config.allowUnfree = true;
			};
			secret = fileName: "${self}/private/secrets/${fileName}";
			private = fileName:
				let targetPath = "${self}/private/${fileName}";
				in if builtins.pathExists targetPath
					then { imports = [ targetPath ]; }
					else { warnings = [ "Private module not loaded: ${fileName}" ]; };
		in {
			inherit base private repo secret system;

			specialArgs = {
				inherit inputs latestPkgs private repo secret system std;
			};
		};
}
