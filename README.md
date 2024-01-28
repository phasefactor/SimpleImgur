# SimpleImgur

Basic ad-blocking client for Imgur.

Everything a lurker would use works, but I have not tested all of the features that a logged in user might try.

It is just the Imgur website on a diet.

---

Most of the blocking is done with WebKit's `WKContentRuleList`, but a bit of CSS and JS are injected.

The single CSS rule gets rid of the empty ad containers, and the JS script tries to upgrade the resolution of any .webp images.  

All of the superfluous connections to ad networks and other vendors are blocked.  Also blocked Imgur's internal analytics tracker.  Should reduce network and battery consumption.
