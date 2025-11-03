let
	keys = {
		# Warning!
		# > Adding a public key to here will
		# > immediately allow access to the servers.
		# > DO NOT ADD ANY UNTRUSTED KEYS HERE.

		"user-nenw-shigureui" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkd7Fk7lI0Sdh5i0U2vI1AUTlQo+pVKghxLW4vJ17/D";
	};
in (
	{ "all" = builtins.attrValues keys; } // keys
)
