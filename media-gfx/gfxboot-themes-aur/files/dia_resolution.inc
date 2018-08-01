% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Resolution mode selector.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


/resolution.option .undef def

% Custom kernel options.  Feel free to extend as needed.  Keep this in sync
% with MenuInitj

/resolution.auto 0 def

/resolution.alltexts [
  "Auto" "640x480" "800x480" "800x600" "1024x576"
    "1024x600" "1024x768" "1200x800" "1280x720"
    "1280x768" "1280x800" "1280x1024" "1360x768"
    "1366x768" "1368x768" "1400x1050" "1440x900"
    "1600x768" "1600x900" "1600x1200" "1680x945"
    "1680x1050" "1920x1080" "1920x1200" "2048x1152"
    "2560x1440" "2560x1600"
] def

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Initialise resolutionibility menu.
%
% ( ) ==> ( )
%
/resolution.init {
  /xmenu.resolution .xm_size array def
  /xmenu xmenu.resolution def

  xmenu .xm_current resolution.auto put

  xmenu .xm_list [
    resolution.alltexts {
        exec
    } forall
  ] put

  xmenu .xm_title /txt_resolution put
  xmenu .xm_current resolution.auto put

  pmenu.init
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Update accessibility status.
%
% ( ) ==> ( )
%
/resolution.update {
  /xmenu xmenu.resolution def

  /window.action actRedrawPanel def

  pmenu.update
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Show window.
%
% ( ) => ( )
%
/panel.resolution {
  "resolution" help.setcontext

  window.xmenu
  dup .xmenu xmenu.resolution put
  dup .xmenu.update /resolution.update put
  dup window.init
      window.show
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Return width of panel entry.
%
% ( ) => ( width )
%
/panel.resolution.width {
  /xmenu xmenu.resolution def

  pmenu.width
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Redraw panel entry.
%
% ( panel ) => ( )
%
/panel.resolution.update {
  /xmenu xmenu.resolution def

  pmenu.panel.update
} def

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Recalculate panel entry.
%
% ( panel ) => ( )
/panel.resolution.recalculate {
  /xmenu xmenu.resolution def

  panel.text.moveto
  xmenu.sizes
  xmenu .xm_panel_x currentpoint pop xmenu.hspace sub put
  % try to ensure that the menu doesn't overflow the screen
  xmenu .xm_x
    xmenu .xm_panel_x get
    screen.size pop xmenu.columns xmenu.widthupto 10 add sub
    min put
} def
