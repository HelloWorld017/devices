{ profile }:
{ pkgs, ... }:
let
	ffultima = builtins.fetchTree {
		type = "github";
		owner = "soulhotel";
		repo = "FF-ULTIMA";
		rev = "f5f2a98de607e1f6c75854e72aa08b4d767c8e81";
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
					"user.theme.dark.a" = true;
					"user.theme.light.a" = true;
					"user.theme.adaptive" = false;
					"user.theme.dark.catppuccin" = false;
					"user.theme.dark.catppuccin-frappe" = true;
					"user.theme.dark.catppuccin-mocha" = false;
					"user.theme.dark.gruvbox" = false;
					"user.theme.light.gruvbox" = false;
					"user.theme.dark.midnight" = false;

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

					# override wallpapers
					"user.theme.wallpaper.catppuccin" = false;
					"user.theme.wallpaper.catppuccin-mocha" = false;
					"user.theme.wallpaper.catppuccin-frappe" = true;
					"user.theme.wallpaper.dusky" = false;
					"user.theme.wallpaper.fullmoon" = false;
					"user.theme.wallpaper.green" = false;
					"user.theme.wallpaper.gruvbox" = false;
					"user.theme.wallpaper.gruvbox.flowers" = false;
					"user.theme.wallpaper.gruvbox.light" = false;
					"user.theme.wallpaper.midnight" = false;
					"user.theme.wallpaper.midnight2" = false;
					"user.theme.wallpaper.seasonal" = false;
					"user.theme.wallpaper.seasonal2" = false;

					# other
					"nightly.override" = false;
					"browser.aboutConfig.showWarning" = false;
					"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
					"devtools.debugger.remote-enabled" = true;
					"devtools.chrome.enabled" = true;
					"devtools.debugger.prompt-connection" = false;
					"svg.context-properties.content.enabled" = true;
					"layout.css.has-selector.enabled" = true;
					"toolkit.tabbox.switchByScrolling" = false;
					"widget.gtk.ignore-bogus-leave-notify" = 1;
					"widget.gtk.rounded-bottom-corners.enabled" = true;
					"widget.gtk.native-context-menus" = false;
					"sidebar.revamp" = true;
					"sidebar.verticalTabs" = true;
					"browser.tabs.groups.enabled" = true;
					"browser.tabs.hoverPreview.enabled" = true;
					"browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled" = false;
					"media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = false;
					"browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar" = false;

					# accessibility
					"findbar.highlightAll" = true;
					"browser.tabs.insertAfterCurrent" = true;
					"browser.bookmarks.openInTabClosesMenu" = false;
					"full-screen-api.transition-duration.enter" = "0 0";
					"full-screen-api.transition-duration.leave" = "0 0";
					"full-screen-api.warning.timeout" = 0;
					"browser.newtabpage.activity-stream.feeds.section.topstories" = false;
					"network.http.max-connections" = 300;
					"browser.urlbar.suggest.calculator" = false;
					"apz.overscroll.enabled" = true;
					"general.smoothScroll" = true;
					"general.smoothScroll.msdPhysics.enabled" = true;

					# privacy
					"browser.send_pings" = false;
					"dom.battery.enabled" = false;
					"extensions.pocket.enabled" = false;
					"datareporting.healthreport.uploadEnabled" = false;
				};
			};
		};
	}
