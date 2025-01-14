{
	defineDevice = { inputs, system }:
		let
			base = import "${self}/modules/base";
			repo = import "${self}/modules/packages";
			self = inputs.self;
			std = inputs.std.lib;
			rollingPkgs = inputs.nixpkgs-rolling.legacyPackages.${system};
		in {
			inherit base repo system;

			specialArgs = {
				inherit inputs system std rollingPkgs repo;
			};
		};
}
