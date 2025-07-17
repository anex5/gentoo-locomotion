pref("app.update.autoInstallEnabled",      false);
pref("browser.display.use_system_colors",  true);
pref("browser.link.open_external",         3);
pref("general.smoothScroll",               true);
pref("general.autoScroll",                 false);
pref("browser.tabs.tabMinWidth",           15);
pref("browser.backspace_action",           0);
pref("browser.urlbar.hideGoButton",        true);
pref("browser.shell.checkDefaultBrowser",  false);
pref("browser.EULA.override",              true);
pref("general.useragent.locale",           "chrome://global/locale/intl.properties");
pref("accessibility.typeaheadfind",        true);
pref("intl.locale.requested",              "");
pref("layout.css.dpi",                     0);
/* Disable DoH by default */
pref("network.trr.mode",                   5);
/* Disable use of Mozilla Normandy service by default */
pref("app.normandy.enabled",               false);
/* Disable remote-settings from permissions manager by default but don't lock it
   so corporations can easily turn it back on if there's demand for that */
pref("permissions.manager.remote.enabled", false);
