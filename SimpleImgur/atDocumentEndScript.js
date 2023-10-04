//
//  This gets loaded and run AFTER anything else in the DOM.
//
console.log("Running atDocumentEndScript.js...");



// This block does 90% of the heavy lifting from the user perspective.
// However, the site is still loading ads and using bandwidth for no reason...
let el = document.createElement("style");
el.innerText = "div.AdTop, div.BannerAd-cont, div.Ad-adhesive, a.get-app-block { display: none !important; }";
document.head.appendChild(el);







console.log("Completed atDocumentEndScript.js");
