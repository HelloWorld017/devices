super: super.better-control.overrideAttrs(finalAttrs: oldAttrs: let
  inherit (super) lib;
in {
  patches = (oldAttrs.patches or [ ]) ++ [
    (super.writeText "better-control-defer-show.patch" ''
      diff --git a/src/ui/main_window.py b/src/ui/main_window.py
      --- a/src/ui/main_window.py
      +++ b/src/ui/main_window.py
      @@ -58,8 +58,6 @@
                       # Initialize GTK window
                       super().__init__(title="Better Control")
                       self._initialized = True
      -                # Show window immediately for faster perceived startup
      -                self.show_all()
                   except Exception as e:
                       logging.log(LogLevel.Error, f"Window initialization failed: {e}")
                       raise
      @@ -426,8 +424,6 @@
               # Start the delayed loading process
               GLib.idle_add(delayed_preload)
       
      -        # Show all widgets
      -        self.show_all()
       
           def get_cache_file(self, tab_name):
               """Get cache file path for a tab"""
    '')
  ];

  # TODO(nixpkgs/better-control): Remove following backported patches
  preFixup = (oldAttrs.preFixup or "") + ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath finalAttrs.runtimeDeps)
  ];
})
