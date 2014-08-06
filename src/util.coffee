util = module.exports

util._toArray = (obj) ->
  obj = obj.split new RegExp(' +') if toString.call(obj) is '[object String]'
  return if toString.call(obj) is '[object Array]' then obj else []

