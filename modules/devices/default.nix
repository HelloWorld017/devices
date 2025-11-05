{ ... }@inputs:
	let
		recursiveMerge = with builtins; zipAttrsWith(key: values:
			if tail values == [] then head values
			else if all isAttrs values then recursiveMerge values
			else last values
		);
	in
		recursiveMerge [
			((import ./ajisai) inputs)
			((import ./akebi) inputs)
			((import ./shigureui) inputs)
			((import ./yanamianna) inputs)
		]
