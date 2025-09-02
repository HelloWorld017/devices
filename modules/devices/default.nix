{ ... }@inputs: 
	let
		recursiveMerge = with builtins; zipAttrsWith(key: values:
			if tail values == [] then head values
			else if all isAttrs values then recursiveMerge values
			else last values
		);
	in
		recursiveMerge [
			# ((import ./iceflake) inputs)
			# ((import ./seasalt) inputs)
			((import ./akebi) inputs)
			((import ./yanamianna) inputs)
			((import ./shigureui) inputs)
		]
