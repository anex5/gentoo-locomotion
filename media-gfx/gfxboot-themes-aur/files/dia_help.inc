% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Panel help entry.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Show help window.
%
% ( ) => ( )
%
/panel.help {
   help.context "opt" eq boot.ed 5 get .undef ne and {
     findbootoption
     help.mapcontext
     dup help.findpage
     "" eq { pop } { help.setcontext } ifelse
   } if
   show_help
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Return width of help entry.
%
% ( ) => ( width )
%
/panel.help.width {
  txt_help strsize pop
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Redraw panel entry.
%
% ( panel ) => ( )
%
/panel.help.update {
  panel.text.moveto

  txt_help show
} def

/panel.tab.update {
  panel.text.moveto
  txt_bootoptions show
} def

/panel.tab.width {
  txt_bootoptions strsize pop
} def

/panel.help {
} def
