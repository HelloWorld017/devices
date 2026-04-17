{ self, inputs, ... }:
{
  defineDevice = { system }:
    let
      std = inputs.std.lib;
      kind = if std.string.hasSuffix "darwin" system then "darwin" else "nixos";
      base = import "${self}/modules/base";
      repo = import "${self}/modules/packages";
      latestPkgs = import inputs.nixpkgs-latest {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      inherit base repo system;

      specialArgs = {
        inherit inputs kind latestPkgs repo system std self;
      };
    };
}
