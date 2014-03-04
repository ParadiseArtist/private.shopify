(function() {

  exports.singularize = function(namespace) {
    var ches, ies, s;
    ies = /y$/;
    ches = /ch$/;
    s = /s$/;
    if (ies.test(namespace)) return namespace.replace(ies, 'y');
    if (ches.test(namespace)) return namespace.replace(ches, 'ch');
    if (s.test(namespace)) return namespace.replace(s, '');
    return namespace;
  };

  exports.pluralize = function(namespace) {
    var ch, y;
    y = /y$/;
    ch = /ch$/;
    if (y.test(namespace)) return namespace.replace(y, 'ies');
    if (ch.test(namespace)) return namespace.replace(ch, 'ches');
    return "" + namespace + "s";
  };

  exports.nest = function(method) {
    return method.split(/(?=[A-Z])/).toLowerCase().map(exports.pluralize);
  };

}).call(this);
