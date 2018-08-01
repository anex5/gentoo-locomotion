
/.tz.language 0 def
/.tz.name     1 def

/timezones [
  [ "be_BY" "Europe/Minsk" ]
  [ "bg_BG" "Europe/Sofia" ]
  [ "bs_BA" "Europe/Sarajevo" ]
  [ "cs_CZ" "Europe/Prague" ]
  [ "da_DK" "Europe/Copenhagen" ]
  [ "de_DE" "Europe/Berlin" ]
  [ "en_AU" "Australia/Canberra" ]
  [ "en_GB" "Europe/London" ]
  [ "en_US" "America/New_York" ]
  [ "es_ES" "Europe/Madrid" ]
  [ "es_UY" "America/Montevideo" ]
  [ "es_VE" "America/Caracas" ]
  [ "et_EE" "Europe/Tallinn" ]
  [ "fi_FI" "Europe/Helsinki" ]
  [ "fr_BE" "Europe/Brussels" ]
  [ "fr_CA" "Canada/Pacific" ]
  [ "fr_FR" "Europe/Paris" ]
  [ "hr_HR" "Europe/Zagreb" ]
  [ "hu_HU" "Europe/Budapest" ]
  [ "is_IS" "Atlantic/Reykjavik" ]
  [ "it_IT" "Europe/Rome" ]
  [ "kk_KZ" "Asia/Almaty" ]
  [ "lt_LT" "Europe/Vilnius" ]
  [ "lv_LV" "Europe/Riga" ]
  [ "nl_BE" "Europe/Brussels" ]
  [ "nl_NL" "Europe/Amsterdam" ]
  [ "nn_NO" "Europe/Oslo" ]
  [ "pl_PL" "Europe/Warsaw" ]
  [ "pt_BR" "Brazil/East" ]
  [ "pt_PT" "Europe/Lisbon" ]
  [ "ro_RO" "Europe/Bucharest" ]
  [ "ru_RU" "Europe/Moscow" ]
  [ "sk_SK" "Europe/Bratislava" ]
  [ "sl_SI" "Europe/Ljubljana" ]
  [ "sq_AL" "Europe/Tirane" ]
  [ "sr_RS" "Europe/Belgrade" ]
  [ "sv_SE" "Europe/Stockholm" ]
  [ "uk_UA" "Europe/Kiev" ]
] def

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Get timezone (timezone).
%
% Returns timezone for lang
%
% ( locale ) ==> ( EEEE/MMMM )
%
/lang.gettimezone {
  timezones {
    dup .tz.language get 2 index eq { .tz.name get exch pop exit } { pop } ifelse
  } forall
} def
