{
	defineDevice = { inputs, system }:
		let
			base = import "${self}/modules/base";
			repo = import "${self}/modules/packages";
			self = inputs.self;
			std = inputs.std.lib;
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
