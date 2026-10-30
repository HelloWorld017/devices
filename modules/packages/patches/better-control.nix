super: super.better-control.overrideAttrs(finalAttrs: oldAttrs: let
  inherit (super) lib;
in {
  patches = (oldAttrs.patches or [ ]) ++ [
    (super.writeText "better-control-early-size.patch" ''
      diff --git a/src/ui/main_window.py b/src/ui/main_window.py
      --- a/src/ui/main_window.py
      +++ b/src/ui/main_window.py
      @@ -57,6 +57,16 @@
                   try:
                       # Initialize GTK window
                       super().__init__(title="Better Control")
      +                # Configure size before the first show_all()
      +                if arg_parser.find_arg(("-s", "--size")):
      +                    size = arg_parser.option_arg(("-s", "--size"))
      +                    try:
      +                        width, height = map(int, size.split("x"))
      +                    except (AttributeError, ValueError) as e:
      +                        raise ValueError("Invalid window size") from e
      +                else:
      +                    width, height = 900, 600
      +                self.set_default_size(width, height)
                       self._initialized = True
                       # Show window immediately for faster perceived startup
                       self.show_all()
      @@ -67,3 +77,2 @@
               self.logging = logging
      -        self.set_default_size(600, 400)
               self.logging.log(LogLevel.Info, "Initializing application")
      diff --git a/src/better_control.py b/src/better_control.py
      --- a/src/better_control.py
      +++ b/src/better_control.py
      @@ -3,7 +3,6 @@
       import os
       import subprocess
      -from typing import Any
       import gi  # type: ignore
       import sys
       from setproctitle import setproctitle
       import signal
      @@ -159,17 +158,4 @@
           GLib.idle_add(run_audio_operation)
       
      -    option: Any = []
      -    if arg_parser.find_arg(("-s", "--size")):
      -        optarg = arg_parser.option_arg(("-s", "--size"))
      -        if optarg is None or 'x' not in optarg:
      -            logger.log(LogLevel.Error, "Invalid window size")
      -            sys.exit(1)
      -        else:
      -            option = optarg.split('x')
      -    else:
      -        option = [900, 600]
      -
      -    win.set_default_size(int(option[0]), int(option[1]))
      -    win.resize(int(option[0]), int(option[1]))
           win.connect("destroy", Gtk.main_quit)
           win.show_all()
      @@ -315,17 +301,4 @@
           GLib.idle_add(run_audio_operation)
       
      -    option: Any = []
      -    if arg_parser.find_arg(("-s", "--size")):
      -        optarg = arg_parser.option_arg(("-s", "--size"))
      -        if optarg is None or 'x' not in optarg:
      -            logger.log(LogLevel.Error, "Invalid window size")
      -            sys.exit(1)
      -        else:
      -            option = optarg.split('x')
      -    else:
      -        option = [900, 600]
      -
      -    win.set_default_size(int(option[0]), int(option[1]))
      -    win.resize(int(option[0]), int(option[1]))
           win.connect("destroy", Gtk.main_quit)
           win.show_all()
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
