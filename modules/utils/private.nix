{ self, ... }:
let
  privatePath = fileName: "${self}/private/${fileName}";
in {
  secret = fileName: privatePath "secrets/${fileName}";
  private = fileName:
    let targetPath = privatePath fileName;
    in if builtins.pathExists targetPath
      then { imports = [ targetPath ]; }
      else { warnings = [ "Private module not loaded: ${fileName}" ]; };
}
