{ profile }:
{ pkgs, ... }:
let
	ffultima = builtins.fetchTree {
		type = "github";
		owner = "soulhotel";
		repo = "FF-ULTIMA";
		rev = "f99ca1cbfee282d7d12d155d86c4e85a7c87b91a";
	};
in
	{
		config = {
			home.file.".mozilla/firefox/dev-edition-default/chrome/theme" = {
				source = "${ffultima}/theme";
				recursive = true;
			};

			home.programs.firefox.profiles.${profile} = {
				userChrome = (builtins.readFile "${ffultima}/userChrome.css") + ''
					:root:not([chromehidden~="toolbar"]){
						min-width: 20px !important;
					}
				'';
				userContent = (builtins.readFile "${ffultima}/userContent.css");
				settings = {
					# color schemes 
					"user.theme.fluent" = false;
					"user.theme.kanagawa-wave" = true;
					"user.theme.midnight" = false;
					"user.theme.transparent" = false;

					# titlebar and tabs
					"ultima.disable.alltabs.button" = true;
					"ultima.disable.contextmenu.collapsing" = true;
					"ultima.disable.windowcontrols.button" = false;
					"ultima.disable.verticaltab.bar" = false;
					"ultima.disable.verticaltab.bar.withindicator" = true;
					"ultima.tabs.autohide" = true;
					"ultima.tabs.belowURLbar" = true;
					"ultima.tabs.width.small" = false;
					"ultima.tabs.width.medium" = true;
					"ultima.tabs.width.large" = false;
					"ultima.tabs.width.huge" = false;
					"ultima.spacing.compact.tabs" = false;

					# sidebar
					"ultima.sidebar.autohide" = false;
					"ultima.sidebery.autohide" = true;
					"ultima.sidebar.hidden" = false;
					"ultima.sidebar.longer" = true;

					# extra theming
					"ultima.theme.extensions" = true;
					"ultima.theme.icons" = false;
					"ultima.theme.menubar" = true;
					"ultima.theme.color.swap" = false;

					# url bar
					"ultima.navbar.autohide" = false;
					"ultima.urlbar.suggestions" = true;
					"ultima.urlbar.centered" = true;
					"ultima.urlbar.hidebuttons" = false;
					"ultima.xstyle.urlbar" = false;

					# alternate styles
					"ultima.spacing.compact" = false;
					"ultima.xstyle.tabgroups.i" = true;
					"ultima.xstyle.tabgroups.ii" = false;
					"ultima.xstyle.containertabs.i" = true;
					"ultima.xstyle.containertabs.ii" = false;
					"ultima.xstyle.containertabs.iii" = false;
					"ultima.xstyle.pinnedtabs.i" = false;
					"ultima.xstyle.private" = false;
					"ultima.xstyle.bookmarks.fading" = false;
					"ultima.xstyle.newtab.rounded" = false;

					# other
					"browser.aboutConfig.showWarning" = false;
					"browser.bookmarks.openInTabClosesMenu" = false;
					"browser.newtabpage.activity-stream.feeds.section.topstories" = false;
					"browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar" = false;
					"browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled" = false;
					"browser.tabs.groups.enabled" = true;
					"browser.tabs.hoverPreview.enabled" = true;
					"browser.tabs.insertAfterCurrent" = true;
					"browser.urlbar.suggest.calculator" = false;
					"devtools.debugger.remote-enabled" = true;
					"devtools.chrome.enabled" = true;
					"devtools.debugger.prompt-connection" = false;
					"findbar.highlightAll" = true;
					"full-screen-api.warning.timeout" = 0;
					"layout.css.has-selector.enabled" = true;
					"media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = false;
					"nightly.override" = false;
					"sidebar.revamp" = true;
					"sidebar.verticalTabs" = true;
					"svg.context-properties.content.enabled" = true;
					"toolkit.tabbox.switchByScrolling" = false;
					"widget.gtk.ignore-bogus-leave-notify" = 1;
					"widget.gtk.rounded-bottom-corners.enabled" = true;
					"widget.gtk.native-context-menus" = false;
				};
			};
		};
	}
