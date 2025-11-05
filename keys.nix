let
	keys = {
		# Warning!
		# > Adding a public key to here will
		# > immediately allow access to the servers.
		# > DO NOT ADD ANY UNTRUSTED KEYS HERE.

		"user-nenw-ajisai" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY/EwgzMYfp/FEUUizTWjw++53LZAxmJ4WgHVA4YiVY";
		"user-nenw-akebi" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWzjPz2+WzZd4IjSoeaSSSvXizSObmCxg+KMp+/V/jG";
		"user-nenw-shigureui" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkd7Fk7lI0Sdh5i0U2vI1AUTlQo+pVKghxLW4vJ17/D";
	};
in (
	{ "all" = builtins.attrValues keys; } // keys
)
