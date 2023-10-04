//
//  This gets loaded and run BEFORE anything else in the DOM.
//
//  NOTE: document.body and .head are null while this script executes.
//

console.log("Running atDocumentStartScript.js...");

// Any iframes are assuredly ads, so lets not allow them to even be created.
document._createElement = document.createElement;

document.createElement = (e) => {
    if (e.toLowerCase() == "iframe") {
        e = "img";
   //     console.log("IFRAME");
    }
    /*
    if (e.toLowerCase() == "script") {
        e = "noscript";
        console.log("SCRIPT");
    }
     */
   // e = e.toLowerCase() == "script" ? "noscript" : e;
    
    return document._createElement(e);
}


// imgur makes TONS of xhr... what if it did not do that???
_XMLHttpRequest = XMLHttpRequest;

XMLHttpRequest = function () {
    var x = new _XMLHttpRequest();

    var _open = x.open;
    x.open = function() {
        if (!(arguments[1].includes("imgur.com/") || arguments[1].includes("imgur.io/"))) {
      //      console.log("XHR Attempt", arguments)
            arguments[1] = "//0.0.0.0";
        }
        return _open.apply(this, arguments);
    }

    return x;
};


// Maybe this works to keep scripts from getting attached?
Element.prototype._appendChild = Element.prototype.appendChild;

Element.prototype.appendChild = function (el) {
    if (el.tagName) {
        if (el.tagName.toLowerCase() == "img") {
            if (!el.src.includes("imgur.")){
                el.src = "";
            }
        }
        
        if (el.tagName.toLowerCase() == "script") {
           //     el.src = "";
           //     el.textContent = "";
                console.log("APPENDING ", el.src)
            }
        }
    }
    
    return Element.prototype._appendChild.apply(this, arguments);
};

function stripScripts() {
    document.scripts.forEach((s) => {
        console.log("--" + s.src);
        if (s.src.includes("imgur.com/")) { return; }
        if (s.src.includes("imgur.io/")) { return; }
        if (s.src.startsWith("/") && !s.src.startsWith("//")) { return; }
        
        s.src = "";
        s.textContent = "";
        s.remove();
        console.log("REMOVED");
    });
}

document.addEventListener("DOMContentLoaded", stripScripts)


console.log("Completed atDocumentStartScript.js");
