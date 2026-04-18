{ lib, ... }: let
  indent = indentSize: line:
    let spaces = lib.concatStrings (lib.genList (_: "  ") indentSize);
    in "${spaces}${line}";

  brackets = indentSize: start: contents: end:
    (indent indentSize start) + "\n" + contents + "\n" + (indent indentSize end);

  bracketsExpr = indentSize: start: contents: end:
    start + "\n" + contents + "\n" + (indent indentSize end);

  isRiverAttrs = value: builtins.isAttrs value && !(value ? "_type");
  isRiverTokenOf = kind: value: builtins.isAttrs value && value ? "_type" && value._type == "river_${kind}";

  render = attrs: "${renderAttrs 0 attrs}\n";
  renderAttrs = indentSize: attrs:
    assert isRiverAttrs attrs;
    lib.trimWith { end = true; } (
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList
          (renderKeyValue indentSize)
          (lib.filterAttrs (k: v: v != null) attrs)
      )
    );

  renderObject = indentSize: attrs:
    assert isRiverAttrs attrs;
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList
        (k: v: (indent indentSize "${k} = ${renderExpr indentSize v}") + ",")
        (lib.filterAttrs (k: v: v != null) attrs)
    );

  renderKeyValue = indentSize: k: v:
    if isRiverTokenOf "blockset" v && builtins.isList v.value then
      # Blockset List
      (lib.concatMapStringsSep "\n\n"
        (item: (brackets indentSize "${k} {" (renderAttrs (indentSize + 1) item) "}"))
        v.value) +
      "\n${indent indentSize ""}"

    else if isRiverTokenOf "blockset" v then
      # Blockset Attrs
      (lib.concatMapStringsSep "\n\n"
        (item: (brackets indentSize 
          "${k} ${builtins.toJSON item.name} {"
          (renderAttrs (indentSize + 1) item.value)
          "}"))
        (lib.attrsToList v.value)) +
      "\n${indent indentSize ""}"

    else if isRiverTokenOf "block" v then
      # Block
      (brackets indentSize "${k} {" (renderAttrs (indentSize + 1) v.value) "}") +
      "\n${indent indentSize ""}"

    else
      # Plain Key - Value
      indent indentSize "${k} = ${renderExpr indentSize v}";

  renderExpr = indentSize: v:
    if isRiverTokenOf "expr" v then
      v.value
    else if builtins.isString v || builtins.isInt v || builtins.isFloat v || builtins.isBool v then
      builtins.toJSON v
    else if builtins.isList v && lib.length v <= 1 then
      "[" + (lib.concatMapStringsSep ", " (v: (renderExpr indentSize v)) v) + "]"
    else if builtins.isList v then
      bracketsExpr indentSize "["
        (lib.concatMapStringsSep "\n"
          (v: (indent (indentSize + 1) (renderExpr (indentSize + 1) v)) + ",") v)
        "]"
    else if isRiverAttrs v then
      bracketsExpr indentSize "{" (renderObject (indentSize + 1) v) "}"
    else abort "Unsupported type in River config: ${builtins.typeOf v}";
in {
  river = {
    inherit render;
    expr = v: { _type = "river_expr"; value = v; };
    block = v: { _type = "river_block"; value = v; };
    blockset = v: { _type = "river_blockset"; value = v; };
  };
}
