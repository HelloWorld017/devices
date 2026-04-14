{
  defineDevice = { inputs, system }:
    let
      self = inputs.self;
      std = inputs.std.lib;
      kind = if std.string.hasSuffix "darwin" system then "darwin" else "nixos";
      base = import "${self}/modules/base";
      repo = import "${self}/modules/packages";
      latestPkgs = import inputs.nixpkgs-latest {
        inherit system;
        config.allowUnfree = true;
      };
      privatePath = fileName: "${self}/private/${fileName}";
      secret = fileName: privatePath "secrets/${fileName}";
      private = fileName:
        let targetPath = privatePath fileName;
        in if builtins.pathExists targetPath
          then { imports = [ targetPath ]; }
          else { warnings = [ "Private module not loaded: ${fileName}" ]; };
    in {
      inherit base private repo system;

      specialArgs = {
        inherit inputs kind latestPkgs private repo secret system std;
      };
    };
}
