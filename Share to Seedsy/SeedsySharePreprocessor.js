var aShareExt = function() {};

aShareExt.prototype = {
run: function(arguments) {
    arguments.completionFunction({"pageURL": document.URL, "pageSource": document.documentElement.outerHTML, "title": document.title, "selection": window.getSelection().toString()});
}
};

var ExtensionPreprocessingJS = new aShareExt;
