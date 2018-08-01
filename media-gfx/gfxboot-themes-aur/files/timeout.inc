%
% include before common.inc
%

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% ( timeout time ) ==> ( )
/Timeout {
  /timeout.time exch def
  /timeout.timeout exch def

  timeout.time 10 mul 150 add 182 div /timeout.seconds exch def

  timeout.seconds timeout.current eq { return } if
  /timeout.current timeout.seconds def
  timeout.hidden { return } if

  timer.color setcolor

  timeout.time.x timeout.time.y moveto -40 0 rmoveto
  currentpoint 40 fontheight image

  timeout.time 0 gt {
    timeout.seconds "%d s" timeout.buf sprintf

    timeout.time.x timeout.time.y moveto timeout.buf showright
  } if
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Initialize timeout indicator.
%
% ( ) ==> ( )
%
/timeout.init {
  /timeout.current    -1 def
  /timeout.buf        64 string def

  /timeout.time.x timer.position.x def
  /timeout.time.y timer.position.y def
} def


/timeout.x { head.x } def
/timeout.y { head.y } def

/timeout.hidden false def
/timeout.hidden.showsplash true def
