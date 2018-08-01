% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Panel installation video modes selector.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


/video_modes.selected.append .undef def
/video_modes.selected.replace .undef def
/video_modes.submenu.idx 0 def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Initialise installation video modes menu.
%
% ( ) ==> ( )
%
/video_modes.init {
  /xmenu.video_modes .xm_size array def
  /xmenu xmenu.video_modes def

  xmenu .xm_current 0 put

  /video_modes.gfxconfig listgfxconfig def

  /video_modes.rawlabels [
    video_modes.gfxconfig {
      dup 0 get 6 strndup dup "label " eq exch free { 1 get } { pop } ifelse
    } forall
    /video_modes.submenu.resolution
  ] def
  /video_modes.append [
    video_modes.gfxconfig {
      0 get /video_modes.tmp.key exch def
      video_modes.tmp.key 6 strndup dup "label " eq exch free {
        video_modes.tmp.key 6 add dup length 8 add string /video_modes.tmp.str exch def
        "append %s" video_modes.tmp.str sprintf
        video_modes.tmp.str getgfxconfig
        video_modes.tmp.str free
      } if
    } forall
    .undef
  ] def
  /video_modes.replace [
    video_modes.gfxconfig {
      0 get /video_modes.tmp.key exch def
      video_modes.tmp.key 6 strndup dup "label " eq exch free {
        video_modes.tmp.key 6 add dup length 9 add string /video_modes.tmp.str exch def
        "replace %s" video_modes.tmp.str sprintf
        video_modes.tmp.str getgfxconfig
        video_modes.tmp.str free
      } if
    } forall
    .undef
  ] def
  /video_modes.applies [
    video_modes.gfxconfig {
      0 get /video_modes.tmp.key exch def
      video_modes.tmp.key 6 strndup dup "label " eq exch free {
        video_modes.tmp.key 6 add dup length 9 add string /video_modes.tmp.str exch def
        "applies %s" video_modes.tmp.str sprintf
        video_modes.tmp.str getgfxconfig
        video_modes.tmp.str free
      } if
    } forall
    .undef
  ] def
  
  video_modes.rawlabels length 1 eq {
    /video_modes.rawlabels [ /txt_mode_normal /txt_resolution ] def
    /video_modes.append [ .undef .undef ] def
    /video_modes.replace [ .undef .undef ] def
    /video_modes.applies [ .undef .undef ] def
  } if
  /video_modes.map .undef def

  menu.entry video_modes.filter

  xmenu .xm_title /txt_videodrv put
  resolution.init

} def


/video_modes.submenu.resolution.buf 64 string def
/video_modes.submenu.resolution {
  /txt_resolution exec "\x09%s" video_modes.submenu.resolution.buf sprintf
  video_modes.submenu.resolution.buf
} def

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Update installation modes status.
%
% ( ) ==> ( )
%
/video_modes.update {
  /xmenu xmenu.video_modes def
  xmenu .xm_current get video_modes.submenu.idx eq {
    xmenu 0 xmenu.oldentry put
    panel.resolution
  } {
      video_modes.map xmenu .xm_current get get
      video_modes.append over get /video_modes.selected.append exch def
      video_modes.replace over get /video_modes.selected.replace exch def

      /window.action actRedrawPanel def

      pmenu.update
  } ifelse
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Filter displayed modes when a menu item changes.
%
% ( index ) ==> ( )
%
/video_modes.filter {
  video_modes.rawlabels .undef eq { pop return } if

  menu.labels exch get
  dup length 3 add string /video_modes.tmp.label exch def
  " %s " video_modes.tmp.label sprintf

  xmenu % save
  /xmenu xmenu.video_modes def

  video_modes.map {
    /video_modes.tmp.oldidx video_modes.map xmenu .xm_current get get def
  } {
    /video_modes.tmp.oldidx .undef def
  } ifelse

  video_modes.map free
  % mapping of current menu index to underlying option index
  /video_modes.map [
    0 1 video_modes.rawlabels length 1 sub {
      video_modes.applies over get dup .undef ne {
        dup length 3 add string /video_modes.tmp.applies exch def
        " %s " video_modes.tmp.applies sprintf
        video_modes.tmp.applies video_modes.tmp.label strstr 0 eq { pop } if
        video_modes.tmp.applies free
      } {
        pop
      } ifelse
    } for
  ] def

  video_modes.tmp.label free

  xmenu .xm_list get free
  xmenu .xm_list [
    video_modes.map { video_modes.rawlabels exch get translate } forall
  ] put

  xmenu .xm_current 0 put
  0 1 video_modes.map length 1 sub {
    video_modes.map over get video_modes.tmp.oldidx eq {
      xmenu .xm_current rot put exit
    } {
      pop
    } ifelse
  } for

  xmenu .xm_list get length 1 sub
    /video_modes.submenu.idx exch def

  pmenu.init

  /xmenu exch def % restore
} def

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Show window.
%
% ( ) ==> ( )
%
/panel.video_modes {
  "video_modes" help.setcontext

  window.xmenu
  dup .xmenu xmenu.video_modes put
  dup .xmenu.update /video_modes.update put
  dup window.init
      window.show
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Return width of panel entry.
%
% ( ) => ( width )
%
/panel.video_modes.width {
  /xmenu xmenu.video_modes def

  pmenu.width
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Redraw panel entry.
%
% ( panel ) => ( )
%
/panel.video_modes.update {
  /xmenu xmenu.video_modes def

  dup pmenu.panel.update

  panel.resolution.recalculate
} def
