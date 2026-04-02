/*
  Deployment market switch
  - Default: EU deployment (promote Hainan / China page)
  - Set market to "cn" for China deployment (promote Switzerland journeys)
  - Auto IP detection enabled by default on index page:
    CN IP => cn, others => eu
  - Use forceMarket to bypass IP detection when needed
*/
window.SITE_CONFIG = Object.assign(
  {
    market: "eu",               // fallback market: "eu" | "cn"
    forceMarket: "",            // optional hard override: "eu" | "cn"
    autoDetectMarket: true,     // index: detect by visitor IP country
    geoLookupTimeoutMs: 1400,   // timeout per geo endpoint
    geoApiUrls: [               // customizable geo endpoints
      "https://api.country.is/",
      "https://ipwhois.app/json/"
    ],
    defaultLanguage: ""         // optional: "en" | "zh" | "de" | "fr"
  },
  window.SITE_CONFIG || {}
);
