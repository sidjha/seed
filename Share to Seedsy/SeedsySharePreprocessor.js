var aShareExt = function() {};

aShareExt.prototype = {
run: function(arguments) {
    arguments.completionFunction({"pageURL": document.URL, "title": document.title});
}
};

var ExtensionPreprocessingJS = new aShareExt;
