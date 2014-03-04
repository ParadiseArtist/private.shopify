exports.singularize = (namespace)->
  ies  = /y$/
  ches = /ch$/
  s    = /s$/
  return namespace.replace(ies, 'y') if ies.test namespace  
  return namespace.replace(ches, 'ch') if ches.test namespace
  return namespace.replace(s, '') if s.test namespace
  namespace

exports.pluralize = (namespace)->
  y = /y$/
  ch = /ch$/
  return namespace.replace(y, 'ies') if y.test namespace  
  return namespace.replace(ch, 'ches') if ch.test namespace
  "#{namespace}s"

exports.nest = (method)-> method.split(/(?=[A-Z])/).toLowerCase().map exports.pluralize