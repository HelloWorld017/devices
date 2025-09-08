{ pkgs, ... }:
let
	profile = "dev-edition-default";
	lock-false = { Value = false; Status = "locked"; };
	lock-true = { Value = true; Status = "locked"; };
in
	{
		imports = [
			((import ./theme.nix) { inherit profile; })
		];

		config = {
			home.programs.firefox = {
				enable = true;
				package = pkgs.firefox-devedition;
				languagePacks = [ "en-US" "ja" "ko" ];
				profiles.${profile} = {
					id = 0;
					name = profile;
					isDefault = true;

					settings = {
						"general.autoScroll" = true;
						"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
					};
				};

				policies = {
					DisableAccounts = true;
					DisableFirefoxAccounts = true;
					DisableFirefoxScreenshots = true;
					DisableFirefoxStudies = true;
					DisablePocket = true;
					DisableTelemetry = true;

					EnableTrackingProtection = {
						Value = true;
						Locked = true;
						Cryptomining = true;
						Fingerprinting = true;
					};

					OverrideFirstRunPage = "";
					OverridePostUpdatePage = "";
					DisplayBookmarksToolbar = "newtab";
					SearchBar = "unified";

					ExtensionSettings = {
						# React Developer Tools
						"@react-devtools" = {
							install_url = "https://addons.mozilla.org/firefox/downloads/latest/react-devtools/latest.xpi";
							installation_mode = "force_installed";
						};

						# Refined GitHub
						"{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
							install_url = "https://addons.mozilla.org/firefox/downloads/latest/refined-github-/latest.xpi";
							installation_mode = "force_installed";
						};

						# Stylus
						"{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
							install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
							installation_mode = "force_installed";
						};

						# uBlock Origin
						"uBlock0@raymondhill.net" = {
							install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
							installation_mode = "force_installed";
						};

						# ViolentMonkey
						"{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
							install_url = "https://addons.mozilla.org/firefox/downloads/latest/violentmonkey/latest.xpi";
							installation_mode = "force_installed";
						};

						# Rainy NewTab
						"rainynewtab@nenw.dev" = {
							install_url = "https://addons.mozilla.org/firefox/downloads/latest/rainy-newtab/latest.xpi";
							installation_mode = "force_installed";
						};
					};

					Preferences = {
						"browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
						"browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
						"browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
						"browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
						"browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
						"browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
						"browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
						"browser.newtabpage.activity-stream.showSponsored" = lock-false;
						"browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
						"browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
						"browser.search.suggest.enabled" = lock-false;
						"browser.search.suggest.enabled.private" = lock-false;
						"browser.topsites.contile.enabled" = lock-false;
						"browser.urlbar.suggest.searches" = lock-false;
						"browser.urlbar.showSearchSuggestionsFirst" = lock-false;
						"extensions.pocket.enabled" = lock-false;
						"extensions.screenshots.disabled" = lock-true;
					};
				};
			};
		};
	}
