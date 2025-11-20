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
/* Disable remote-settings from permissions manager by default but don't lock it
   so corporations can easily turn it back on if there's demand for that */
pref("permissions.manager.remote.enabled", false);

/****************************************************************************
 * SECTION: FASTFOX                                                         *
****************************************************************************/
/** GENERAL ***/
user_pref("content.notify.interval", 100000);

/** GFX ***/
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);

/** DISK CACHE ***/
user_pref("browser.cache.disk.enable", false);

/** MEDIA CACHE ***/
user_pref("media.memory_cache_max_size", 65536);
user_pref("media.cache_readahead_limit", 7200);
user_pref("media.cache_resume_threshold", 3600);

/** IMAGE CACHE ***/
user_pref("image.mem.decode_bytes_at_a_time", 32768);

/** NETWORK ***/
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.pacing.requests.enabled", false);
user_pref("network.dnsCacheExpiration", 3600);
user_pref("network.ssl_tokens_cache_capacity", 10240);

/** SPECULATIVE LOADING ***/
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", false);
user_pref("network.predictor.enable-prefetch", false);

/** EXPERIMENTAL ***/
user_pref("layout.css.grid-template-masonry-value.enabled", true);

/****************************************************************************
 * SECTION: SECUREFOX                                                       *
****************************************************************************/
/** TRACKING PROTECTION ***/
user_pref("browser.contentblocking.category", "strict");
user_pref("urlclassifier.trackingSkipURLs", "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com");
user_pref("urlclassifier.features.socialtracking.skipURLs", "*.instagram.com, *.twitter.com, *.twimg.com");
user_pref("browser.download.start_downloads_in_tmp_dir", true);
user_pref("browser.helperApps.deleteTempFileOnExit", true);
user_pref("browser.uitour.enabled", false);
user_pref("privacy.globalprivacycontrol.enabled", true);

/** OCSP & CERTS / HPKP ***/
user_pref("security.OCSP.enabled", 0);
user_pref("security.remote_settings.crlite_filters.enabled", true);
user_pref("security.pki.crlite_mode", 2);

/** SSL / TLS ***/
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
user_pref("browser.xul.error_pages.expert_bad_cert", true);
user_pref("security.tls.enable_0rtt_data", false);

/** DISK AVOIDANCE ***/
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);
user_pref("browser.sessionstore.interval", 60000);

/** SHUTDOWN & SANITIZING ***/
user_pref("browser.privatebrowsing.resetPBM.enabled", true);
user_pref("privacy.history.custom", true);

/** SEARCH / URL BAR ***/
user_pref("browser.urlbar.trimHttps", true);
user_pref("browser.urlbar.untrimOnUserInteraction.featureGate", true);
user_pref("browser.search.separatePrivateDefault.ui.enabled", true);
user_pref("browser.urlbar.update2.engineAliasRefresh", true);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.groupLabels.enabled", false);
user_pref("browser.formfill.enable", false);
user_pref("security.insecure_connection_text.enabled", true);
user_pref("security.insecure_connection_text.pbmode.enabled", true);
user_pref("network.IDN_show_punycode", true);

/** HTTPS-FIRST POLICY ***/
user_pref("dom.security.https_first", true);

/** PASSWORDS ***/
user_pref("signon.formlessCapture.enabled", false);
user_pref("signon.privateBrowsingCapture.enabled", false);
user_pref("network.auth.subresource-http-auth-allow", 1);
user_pref("editor.truncate_user_pastes", false);

/** MIXED CONTENT + CROSS-SITE ***/
user_pref("security.mixed_content.block_display_content", true);
user_pref("pdfjs.enableScripting", false);

/** EXTENSIONS ***/
user_pref("extensions.enabledScopes", 5);

/** HEADERS / REFERERS ***/
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

/** CONTAINERS ***/
user_pref("privacy.userContext.ui.enabled", true);

/** SAFE BROWSING ***/
user_pref("browser.safebrowsing.downloads.remote.enabled", false);

/** MOZILLA ***/
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("browser.search.update", false);
user_pref("permissions.manager.defaultsUrl", "");

/** TELEMETRY ***/
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);

/** EXPERIMENTS ***/
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");

/** CRASH REPORTS ***/
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);

/** DETECTION ***/
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false);
user_pref("network.connectivity-service.enabled", false);

/****************************************************************************
 * SECTION: PESKYFOX                                                        *
****************************************************************************/
/** MOZILLA UI ***/
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.profiles.enabled", true);

/** THEME ADJUSTMENTS ***/
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.compactmode.show", true);
user_pref("browser.privateWindowSeparation.enabled", false); // WINDOWS

/** COOKIE BANNER HANDLING ***/
user_pref("cookiebanners.service.mode", 1);
user_pref("cookiebanners.service.mode.privateBrowsing", 1);

/** FULLSCREEN NOTICE ***/
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.warning.timeout", 0);

/** URL BAR ***/
user_pref("browser.urlbar.suggest.calculator", true);
user_pref("browser.urlbar.unitConversion.enabled", true);
user_pref("browser.urlbar.trending.featureGate", false);

/** NEW TAB PAGE ***/
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showWeather", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);

/** POCKET ***/
user_pref("extensions.pocket.enabled", false);

/** DOWNLOADS ***/
user_pref("browser.download.manager.addToRecentDocs", false);

/** PDF ***/
user_pref("browser.download.open_pdf_attachments_inline", true);

/** TAB BEHAVIOR ***/
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.menu.showViewImageInfo", true);
user_pref("findbar.highlightAll", true);
user_pref("layout.word_select.eat_space_to_next_word", false);

/****************************************************************************
* START: MY OVERRIDES                                                      *
****************************************************************************/

user_pref("accessibility.force_disabled", 1);
user_pref("accessibility.typeaheadfind.flashBar", 0);
user_pref("alerts.showFavicons", true);
user_pref("keyword.enabled", true);
user_pref("app.update.doorhanger", false);
user_pref("app.update.langpack.enabled", false);
user_pref("app.update.staging.enabled", false);
user_pref("apz.allow_double_tap_zooming", false);
user_pref("apz.android.chrome_fling_physics.enabled", false);
user_pref("apz.drag.touch.enabled", false);
user_pref("apz.gtk.kinetic_scroll.enabled", false);
user_pref("apz.peek_messages.enabled", false);
user_pref("apz.prefer_jank_minimal_displayports", false);
user_pref("apz.windows.force_disable_direct_manipulation", true);
user_pref("apz.windows.use_direct_manipulation", false);
user_pref("beacon.enabled", false);
user_pref("browser.bookmarks.editDialog.confirmationHintShowCount", 3);
user_pref("browser.bookmarks.restore_default_bookmarks", false);
user_pref("browser.cache.disk.parent_directory", "~/.cache");
user_pref("browser.cache.memory.max_entry_size", 32768);
user_pref("browser.cache.offline.enable", true);
user_pref("browser.cache.offline.storage.enable", true);
user_pref("browser.cache.disk.enable", true);
user_pref("browser.compactmode.show", true);
user_pref("browser.urlbar.decodeURLsOnCopy", true);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr", false);
user_pref("identity.fxaccounts.enabled", false);
user_pref("browser.zoom.siteSpecific", false);
user_pref("browser.contentblocking.category", "custom");
user_pref("browser.contentblocking.report.lockwise.enabled", false);
user_pref("browser.download.animateNotifications", false);
user_pref("browser.download.enable_spam_prevention", false);
user_pref("browser.download.improvements_to_download_panel", false);
user_pref("browser.download.panel.shown", true);
user_pref("browser.download.save_converter_index", 0);
user_pref("browser.download.viewableInternally.typeWasRegistered.avif", true);
user_pref("browser.download.viewableInternally.typeWasRegistered.jxl", true);
user_pref("browser.download.viewableInternally.typeWasRegistered.webp", true);
user_pref("browser.engagement.ctrlTab.has-used", true);
user_pref("browser.engagement.downloads-button.has-used", true);
user_pref("browser.history_swipe_animation.disabled", true);
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", true);
user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.topSitesRows", 4);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", true);
user_pref("browser.newtabpage.storageVersion", 1);
user_pref("browser.pagethumbnails.storage_version", 3);
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.policies.applied", true);
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false);
user_pref("browser.preferences.search", false);
user_pref("browser.proton.enabled", true);
user_pref("browser.proton.places-tooltip.enabled", true);
user_pref("browser.proton.toolbar.version", 3);
user_pref("browser.safebrowsing.allowOverride", false);
user_pref("browser.safebrowsing.blockedURIs.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.block_dangerous", false);
user_pref("browser.safebrowsing.downloads.remote.block_dangerous_host", false);
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.search.openintab", true);
user_pref("browser.search.suggest.enabled", true);
user_pref("browser.startup.homepage.abouthome_cache.enabled", false);
user_pref("browser.startup.page", 3);
user_pref("browser.startup.upgradeDialog.enabled", false);
user_pref("browser.tabs.allowTabDetach", false);
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.touchmode.auto", false);
user_pref("browser.translation.ui.show", true);
user_pref("browser.translations.enable", true);
user_pref("browser.uidensity", 1);
user_pref("browser.uitour.enabled", false);
user_pref("browser.urlbar.decodeURLsOnCopy", true);
user_pref("browser.urlbar.richSuggestions.tail", false);
user_pref("browser.urlbar.suggest.calculator", true);
user_pref("browser.urlbar.tabToSearch.onboard.interactionsLeft", 0);
user_pref("browser.urlbar.tipShownCount.searchTip_onboard", 4);
user_pref("browser.urlbar.trimURLs", false);
user_pref("browser.urlbar.update", 1);
user_pref("browser.zoom.full", false);
user_pref("browser.zoom.siteSpecific", false);
user_pref("canvas.capturestream.enabled", false);
user_pref("content.interrupt.parsing", true);
user_pref("content.notify.backoffcount", 5);
user_pref("content.sink.pending_event_mode", 1);
user_pref("corroborator.enabled", false);
user_pref("devtools.aboutdebugging.collapsibilities.otherWorker", true);
user_pref("devtools.aboutdebugging.collapsibilities.processes", false);
user_pref("devtools.aboutdebugging.collapsibilities.serviceWorker", true);
user_pref("devtools.aboutdebugging.collapsibilities.sharedWorker", true);
user_pref("devtools.aboutdebugging.showHiddenAddons", true);
user_pref("devtools.browserconsole.filter.css", true);
user_pref("devtools.browserconsole.filter.error", false);
user_pref("devtools.browserconsole.filter.net", true);
user_pref("devtools.browserconsole.filter.netxhr", true);
user_pref("devtools.browserconsole.filter.warn", false);
user_pref("devtools.cache.disabled", true);
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.debugger.prefs-schema-version", 11);
user_pref("devtools.debugger.remote-enabled", true);
user_pref("devtools.dom.enabled", true);
user_pref("devtools.everOpened", true);
user_pref("devtools.inspector.showUserAgentStyles", true);
user_pref("devtools.performance.new-panel-onboarding", false);
user_pref("devtools.performance.ui.show-platform-data", true);
user_pref("devtools.responsive.reloadNotification.enabled", false);
user_pref("devtools.screenshot.audio.enabled", false);
user_pref("devtools.source-map.client-service.enabled", false);
user_pref("devtools.toolbox.splitconsoleEnabled", true);
user_pref("devtools.webconsole.filter.css", true);
user_pref("devtools.webconsole.input.editorOnboarding", false);
user_pref("devtools.webextensions.siddhartha@ooogle.it.enabled", true);
user_pref("devtools.whatsnew.enabled", false);
user_pref("devtools.whatsnew.feature-enabled", false);
user_pref("distribution.gentoo.bookmarksProcessed", true);
user_pref("distribution.iniFile.exists.value", true);
user_pref("doh-rollout.balrog-migration-done", true);
user_pref("dom.IntersectionObserver.enabled", true);
user_pref("dom.abort_script_on_child_shutdown", true);
user_pref("dom.animations.mainthread-synchronization-with-geometric-animations", false);
user_pref("dom.block_download_insecure", false);
user_pref("dom.events.asyncClipboard.clipboardItem", true);
user_pref("dom.events.asyncClipboard.dataTransfer", true);
user_pref("dom.events.asyncClipboard.readText", true);
user_pref("dom.events.compress.touchmove", false);
user_pref("dom.events.dataTransfer.mozFile.enabled", true);
user_pref("dom.events.testing.asyncClipboard", true);
user_pref("dom.forms.autocomplete.formautofill", true);
user_pref("dom.gamepad.enabled", false);
user_pref("dom.gamepad.extensions.enabled", false);
user_pref("dom.image-lazy-loading.enabled", false);
user_pref("dom.indexedDB.experimental", true);
user_pref("dom.indexedDB.logging.details", false);
user_pref("dom.indexedDB.logging.enabled", false);
user_pref("dom.ipc.plugins.asyncdrawing.enabled", false);
user_pref("dom.ipc.plugins.flash.disable-protected-mode", true);
user_pref("dom.ipc.processCount.file", 8);
user_pref("dom.ipc.processHangMonitor", false);
user_pref("dom.ipc.reportProcessHangs", false);
user_pref("dom.keyboardevent.dispatch_during_composition", false);
user_pref("dom.manifest.enabled", false);
user_pref("dom.maxHardwareConcurrency", 4);
user_pref("dom.push.enabled", true);
user_pref("dom.security.https_only_mode_ever_enabled", true);
user_pref("dom.security.https_only_mode_ever_enabled_pbm", true);
user_pref("dom.security.https_only_mode_pbm", true);
user_pref("dom.security.unexpected_system_load_telemetry_enabled", false);
user_pref("dom.serviceWorkers.enabled", false);
user_pref("dom.storage.shadow_writes", true);
user_pref("dom.vibrator.enabled", false);
user_pref("dom.w3c_touch_events.enabled", 0);
user_pref("dom.webdriver.enabled", false);
user_pref("dom.webnotifications.enabled", true);
user_pref("dom.webnotifications.serviceworker.enabled", true);
user_pref("editor.use_css", true);
user_pref("extensions.abuseReport.amWebAPI.enabled", false);
user_pref("extensions.abuseReport.enabled", false);
user_pref("extensions.blocklist.pingCountVersion", -1);
user_pref("extensions.content_script_csp.report_only", false);
user_pref("extensions.formautofill.creditCards.enabled", false);
user_pref("extensions.formautofill.reauth.enabled", true);
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("extensions.incognito.migrated", true);
user_pref("extensions.pendingOperations", false);
user_pref("extensions.pictureinpicture.enable_picture_in_picture_overrides", true);
user_pref("extensions.postDownloadThirdPartyPrompt", false);
user_pref("extensions.screenshots.upload-disabled", true);
user_pref("extensions.startupScanScopes", 5);
user_pref("extensions.ui.dictionary.hidden", true);
user_pref("extensions.ui.extension.hidden", false);
user_pref("extensions.ui.locale.hidden", false);
user_pref("extensions.ui.sitepermission.hidden", true);
user_pref("extensions.update.autoUpdateDefault", false);
user_pref("extensions.update.enabled", true);
user_pref("extensions.webcompat.enable_shims", true);
user_pref("extensions.webcompat.perform_injections", true);
user_pref("extensions.webcompat.perform_ua_overrides", true);
user_pref("fission.autostart", false);
user_pref("fission.experiment.max-origins.qualified", true);
user_pref("findbar.highlightAll", true);
user_pref("font.internaluseonly.changed", false);
user_pref("full-screen-api.warning.timeout", 0);
user_pref("general.autoScroll", true);
user_pref("gestures.enable_single_finger_input", false);
user_pref("gfx.core-animation.tint-opaque", true);
user_pref("gfx.downloadable_fonts.keep_color_bitmaps", true);
user_pref("gfx.e10s.font-list.shared", false);
user_pref("gfx.filter.nearest.force-enabled", true);
user_pref("gfx.text.subpixel-position.force-enabled", true);
user_pref("gfx.use_text_smoothing_setting", true);
user_pref("gfx.vsync.compositor.unobserve-count", 0);
user_pref("gfx.vsync.force-disable-waitforvblank", true);
user_pref("gfx.webgpu.ignore-blocklist", true);
//user_pref("gfx.webrender.compositor", true);
//user_pref("gfx.webrender.compositor.force-enabled", true);
//user_pref("gfx.webrender.enabled", true);
//user_pref("gfx.webrender.fallback.software", false);
user_pref("gfx.webrender.precache-shaders", true);
user_pref("gfx.ycbcr.accurate-conversion", true);
user_pref("gl.ignore-dx-interop2-blacklist", true);
user_pref("image.avif.compliance_strictness", 0);
user_pref("image.decode-immediately.enabled", true);
user_pref("image.http.accept", "*/*");
user_pref("image.jxl.enabled", true);
user_pref("intl.menuitems.insertseparatorbeforeaccesskeys", "false");
user_pref("intl.multilingual.enabled", false);
user_pref("intl.regional_prefs.use_os_locales", true);
user_pref("intl.uidirection", 0);
user_pref("javascript.options.asyncstack", false);
user_pref("javascript.options.asyncstack_capture_debuggee_only", false);
user_pref("javascript.options.spectre.disable_for_isolated_content", true);
user_pref("javascript.options.spectre.index_masking", false);
user_pref("javascript.options.spectre.jit_to_C++_calls", false);
user_pref("javascript.options.spectre.jit_to_cxx_calls", false);
user_pref("javascript.options.spectre.object_mitigations", false);
user_pref("javascript.options.spectre.object_mitigations.barriers", false);
user_pref("javascript.options.spectre.object_mitigations.misc", false);
user_pref("javascript.options.spectre.string_mitigations", false);
user_pref("javascript.options.spectre.value_masking", false);
user_pref("javascript.use_us_english_locale", true);
user_pref("layers.enable-tiles", true);
user_pref("layers.force-active", true);
user_pref("layers.max-active", 8);
user_pref("layers.offmainthreadcomposition.enabled", true);
user_pref("layers.offmainthreadcomposition.testing.enabled", false);
user_pref("layout.css.accent-color.enabled", false);
user_pref("layout.css.allow-mixed-page-sizes", true);
user_pref("layout.css.backdrop-filter.force-enabled", true);
user_pref("layout.css.conic-gradient.enabled", true);
user_pref("layout.css.content-visibility.enabled", true);
user_pref("layout.css.cross-fade.enabled", true);
user_pref("layout.css.element-content-none.enabled", true);
user_pref("layout.css.exp.enabled", true);
user_pref("layout.css.fit-content-function.enabled", true);
user_pref("layout.css.font-variant-emoji.enabled", true);
user_pref("layout.css.getBoxQuads.enabled", true);
user_pref("layout.css.grid-template-subgrid-value.enabled", true);
user_pref("layout.css.initial-letter.enabled", true);
user_pref("layout.css.moz-document.content.enabled", true);
user_pref("layout.css.nesting.enabled", true);
user_pref("layout.css.page-orientation.enabled", true);
user_pref("layout.css.page-size.enabled", false);
user_pref("layout.css.prefers-color-scheme.content-override", 0);
user_pref("layout.css.properties-and-values.enabled", true);
user_pref("layout.css.report_errors", false);
user_pref("layout.css.round.enabled", true);
user_pref("layout.css.touch_action.enabled", false);
user_pref("layout.css.zoom-transform-hack.enabled", true);
user_pref("layout.dynamic-reflow-roots.enabled", true);
user_pref("media.cache_readahead_limit", 240);
user_pref("media.cache_resume_threshold", 6000);
user_pref("media.devices.enumerate.legacy.enabled", false);
user_pref("media.devices.insecure.enabled", true);
user_pref("media.getusermedia.screensharing.enabled", false);
user_pref("media.gmp.storage.version.observed", 1);
user_pref("media.hls.enabled", true);
user_pref("media.mediasource.experimental.enabled", true);
user_pref("media.navigator.enabled", false);
user_pref("media.ondevicechange.enabled", false);
user_pref("media.peerconnection.enabled", false);
user_pref("media.setsinkid.enabled", true);
user_pref("media.videocontrols.picture-in-picture.respect-disablePictureInPicture", true);
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
user_pref("mozilla.widget.use-argb-visuals", true);
user_pref("narrate.enabled", false);
user_pref("network.connectivity-service.nat64-check", false);
user_pref("network.cookie.cookieBehavior", 5);
user_pref("network.cookie.sameSite.laxByDefault", true);
user_pref("network.cookie.sameSite.noneRequiresSecure", true);
user_pref("network.cookie.sameSite.schemeful", true);
user_pref("network.notify.changed", false);
user_pref("network.predictor.enabled", false);
user_pref("network.protocol-handler.expose.magnet", false);
user_pref("network.protocol-handler.external.mailto", false);
user_pref("network.protocol-handler.external.news", false);
user_pref("network.protocol-handler.external.nntp", false);
user_pref("network.protocol-handler.external.snews", false);
user_pref("network.protocol-handler.external.viewtube", true);
user_pref("network.protocol-handler.external.vlc", true);
user_pref("network.tcp.tcp_fastopen_enable", true);
user_pref("network.traffic_analyzer.enabled", false);
user_pref("network.trr.blocklist_cleanup_done", true);
user_pref("network.trr.confirmation_telemetry_enabled", false);
user_pref("network.wifi.scanning_period", 0);
user_pref("pdfjs.enableWebGL", true);
user_pref("pdfjs.enabledCache.state", true);
user_pref("pdfjs.migrationVersion", 2);
user_pref("plugin.persistentPermissionAlways.intervalInDays", 0);
user_pref("pref.downloads.disable_button.edit_actions", false);
user_pref("privacy.firstparty.isolate", false);
user_pref("privacy.partition.network_state", false);
user_pref("privacy.purge_trackers.date_in_cookie_database", "0");
user_pref("privacy.resistFingerprinting.block_mozAddonManager", true);
//user_pref("privacy.spoof_english", 1);
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);
user_pref("privacy.webrtc.hideGlobalIndicator", true);
user_pref("reader.color_scheme", "light");
user_pref("security.cert_pinning.enforcement_level", 0);
user_pref("security.enterprise_roots.enabled", true);
user_pref("security.mixed_content.block_active_content", false);
user_pref("security.mixed_content.upgrade_display_content", true);
user_pref("security.sandbox.content.level", 0);
user_pref("security.sandbox.socket.process.level", 0);
user_pref("security.ssl3.ecdhe_ecdsa_aes_128_sha", false);
user_pref("security.ssl3.ecdhe_ecdsa_aes_256_sha", false);
user_pref("security.ssl3.ecdhe_rsa_aes_128_sha", false);
user_pref("security.ssl3.ecdhe_rsa_aes_256_sha", false);
user_pref("security.ssl3.rsa_aes_128_sha", false);
user_pref("security.ssl3.rsa_aes_256_sha", false);
user_pref("security.xfocsp.errorReporting.enabled", false);
user_pref("services.sync.engine.addresses.available", true);
user_pref("security.xfocsp.errorReporting.enabled", false);
user_pref("services.sync.prefs.sync.app.shield.optoutstudies.enabled", false);
user_pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsored", false);
user_pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("services.sync.prefs.sync.browser.search.update", false);
user_pref("services.sync.prefs.sync.network.cookie.thirdparty.sessionOnly", false);
user_pref("services.sync.prefs.sync.signon.generation.enabled", false);
user_pref("services.sync.prefs.sync.signon.management.page.breach-alerts.enabled", false);
user_pref("signon.generation.available", false);
user_pref("signon.generation.enabled", false);
user_pref("signon.management.page.breach-alerts.enabled", false);
user_pref("signon.rememberSignons", false);
user_pref("svg.context-properties.content.enabled", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("toolkit.telemetry.pioneer-new-studies-available", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("trailhead.firstrun.didSeeAboutWelcome", true);
user_pref("ui.key.menuAccessKey", 0);
user_pref("ui.prefersReducedMotion", 0);
# Transparency
user_pref("browser.tabs.allow_transparent_browser", true);
user_pref("zen.widget.linux.transparency", true);

