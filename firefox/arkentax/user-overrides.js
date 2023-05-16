/* 0404: enable binary checks not in Safe Browsing local lists */
user_pref("browser.safebrowsing.downloads.remote.enabled", true);

/* override recipe: enable session restore ***/
user_pref("browser.startup.page", 3); // 0102
  // user_pref("browser.privatebrowsing.autostart", false); // 0110 required if you had it set as true
  // user_pref("browser.sessionstore.privacy_level", 0); // 1003 optional to restore cookies/formdata
user_pref("privacy.clearOnShutdown.history", false); // 2811
  // user_pref("privacy.cpd.history", false); // 2820 optional to match when you use Ctrl-Shift-Del


/* 0801: enable location bar using search (suggestions are disabled - see 0804) */
user_pref("keyword.enabled", true);


/* 2022: enable all DRM content (EME: Encryption Media Extension) */
user_pref("media.eme.enabled", true);

/* 4520: enable WebGL (Web Graphics Library) */
/* user_pref("webgl.disabled", false); */

/* override recipe: RFP is not for me ***/
user_pref("privacy.resistFingerprinting", false); // 4501
user_pref("privacy.resistFingerprinting.letterboxing", false); // 4504 [pointless if not using RFP]
user_pref("webgl.disabled", false); // 4520 [mostly pointless if not using RFP]
