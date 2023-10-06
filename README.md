# SimpleImgur

Basic ad-blocking client for Imgur.

Everything a lurker would use works, but I have not exercised all of the features that a logged in user might try.

---

Most of the blocking is done with WebKit's `WKContentRuleList`, but a bit of CSS and JS are injected.  

All of the superfluous connections to ad networks and other vendors are blocked.  Should reduce network and battery consumption.

---

The only remaining thing I want to do is follow up on the event listener in `main.js` that fires a ridiculous number of times on every scroll event.   Seriously, throwing `window.scrollBy(0,1)` into the console spews over a dozen errors as it repeatedly tries to load the next ad.
