% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% audio selection dialog.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Some global vars.
%
/audio.use false def
/audio.default 0 def
/audio.changed false def

/audio.values [
    "pulseaudio"
    "alsa"
] def

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Build menu list.
%
% ( ) ==> ( )
%
/audio.init {
  /xmenu.audio .xm_size array def

  /xmenu xmenu.audio def

  xmenu .xm_list [
    "PulseAudio"
    "ALSA"
  ] put

  xmenu .xm_current 0 put
  xmenu .xm_title /txt_audio put

  pmenu.init
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Update audio selection menu.
%
% ( ) ==> ( )
%
/audio.update {
  /xmenu xmenu.audio def

  /window.action actRedrawPanel def

  pmenu.update
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Show audio selection menu.
%
% ( ) => ( )
%
/panel.audio {
  "audio" help.setcontext

  window.xmenu
  dup .xmenu xmenu.audio put
  dup .xmenu.update /audio.update put
  dup window.init
      window.show
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Return width of panel entry.
%
% ( ) => ( width )
%
/panel.audio.width {
  /xmenu xmenu.audio def

  pmenu.width
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Redraw panel entry.
%
% ( panel ) => ( )
%
/panel.audio.update {
  /xmenu xmenu.audio def

  pmenu.panel.update
} def


