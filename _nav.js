// _nav.js — floating "back to launcher" pill, injected into every subpage by publish.sh.
// Edit styling/behavior here; no need to touch individual pages.
(function () {
  // Don't render on the launcher itself.
  var path = window.location.pathname;
  if (/(?:^|\/)index\.html?$/i.test(path) || /\/$/.test(path)) return;

  function inject() {
    if (document.getElementById('__htmlapps_nav__')) return;

    var a = document.createElement('a');
    a.id = '__htmlapps_nav__';
    a.href = './index.html';
    a.textContent = '← Apps';
    a.setAttribute('aria-label', 'Back to HTMLApps launcher');

    var s = a.style;
    s.position = 'fixed';
    s.top = 'calc(12px + env(safe-area-inset-top, 0px))';
    s.left = 'calc(12px + env(safe-area-inset-left, 0px))';
    s.zIndex = '2147483647';
    s.padding = '6px 12px 7px';
    s.background = 'rgba(20, 20, 25, 0.78)';
    s.color = '#ffffff';
    s.fontFamily = '-apple-system, BlinkMacSystemFont, "SF Pro Text", system-ui, sans-serif';
    s.fontSize = '12px';
    s.fontWeight = '600';
    s.letterSpacing = '0.02em';
    s.lineHeight = '1';
    s.textDecoration = 'none';
    s.borderRadius = '999px';
    s.border = '1px solid rgba(255, 255, 255, 0.08)';
    s.backdropFilter = 'blur(8px) saturate(140%)';
    s.webkitBackdropFilter = 'blur(8px) saturate(140%)';
    s.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.18)';
    s.transition = 'transform 0.15s ease, background 0.15s ease, box-shadow 0.15s ease';
    s.userSelect = 'none';
    s.cursor = 'pointer';

    a.addEventListener('mouseenter', function () {
      s.background = 'rgba(20, 20, 25, 0.92)';
      s.transform = 'translateY(-1px)';
      s.boxShadow = '0 4px 14px rgba(0, 0, 0, 0.22)';
    });
    a.addEventListener('mouseleave', function () {
      s.background = 'rgba(20, 20, 25, 0.78)';
      s.transform = 'none';
      s.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.18)';
    });

    document.body.appendChild(a);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', inject);
  } else {
    inject();
  }
})();
