// Kill-switch service worker: wipes the old Flutter caches, unregisters itself,
// then reloads open tabs so returning visitors always get the latest deploy.
self.addEventListener('install', function (e) { self.skipWaiting(); });
self.addEventListener('activate', function (e) {
  e.waitUntil((async function () {
    try {
      var keys = await caches.keys();
      await Promise.all(keys.map(function (k) { return caches.delete(k); }));
    } catch (_) {}
    try { await self.registration.unregister(); } catch (_) {}
    try {
      var cs = await self.clients.matchAll({ type: 'window' });
      cs.forEach(function (c) { c.navigate(c.url); });
    } catch (_) {}
  })());
});
