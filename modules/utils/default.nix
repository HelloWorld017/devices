inputs: let
  inherit (builtins) all head isAttrs last tail zipAttrsWith;

  recursiveMerge = zipAttrsWith(key: values:
    if tail values == [] then head values
    else if all isAttrs values then recursiveMerge values
    else last values
  );

  args = {
    inherit inputs;
    self = inputs.self;
    lib = inputs.nixpkgs-base.lib;
  };
in {
  lib = recursiveMerge [
    { inherit recursiveMerge; }
    (import ./device.nix args)
    (import ./private.nix args)
    (import ./river.nix args)
  ];
}
