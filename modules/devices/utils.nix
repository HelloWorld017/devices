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
		in {
			inherit base repo system;

			specialArgs = {
				inherit inputs system std latestPkgs repo;
			};
		};
}
