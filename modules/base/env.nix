{ lib, config, ... }:
with lib; {
	options = with types; {
		env = mkOption {
			type = attrsOf (oneOf [ str path (listOf (either str path)) ]);
			apply = mapAttrs (n: v:
				# Handle an array of items separated by `:` e.g. PATH.
				if isList v then
					concatMapStringsSep ":" (x: toString x) v
				else
					(toString v));

			default = {};
			description = "Global environment variables";
		};
	};

	config = {
		env.PATH = ["$PATH"];

		# Writing Environments
		environment.extraInit = concatStringsSep "\n"
			(mapAttrsToList (n: v: ''export ${n}="${v}"'') config.env);
	};
}
