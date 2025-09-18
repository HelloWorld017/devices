{
	defineDevice = { inputs, system }:
		let
			self = inputs.self;
			std = inputs.std.lib;
			kind = if std.string.hasSuffix "darwin" system then "darwin" else "nixos";
			base = (import "${self}/modules/base") kind;
			repo = import "${self}/modules/packages";
			rollingPkgs = import inputs.nixpkgs-rolling {
				inherit system;
				config.allowUnfree = true;
			};
		in {
			inherit base repo system;

			specialArgs = {
				inherit inputs system std rollingPkgs repo;
			};
		};
}
