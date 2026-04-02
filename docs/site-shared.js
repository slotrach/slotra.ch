(function () {
  function buildMailAddress() {
    var user = String.fromCharCode(121, 97, 110);
    var domain = String.fromCharCode(115, 108, 97, 116, 114, 97, 46, 99, 104);
    return user + String.fromCharCode(64) + domain;
  }

  function bindEmailLinks(selector) {
    var finalSelector = selector || "[data-email-link]";
    var address = buildMailAddress();

    document.querySelectorAll(finalSelector).forEach(function (link) {
      link.addEventListener("click", function (event) {
        event.preventDefault();
        window.location.href = "mailto:" + address;
      });
    });
  }

  window.SiteShared = {
    bindEmailLinks: bindEmailLinks
  };
})();
