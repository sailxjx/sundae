# Post will be the last decorator of most applications.
# Post hook will be parallel executed after the callback of controller
# You can write your async logic in post functions
# Like broadcast messages, send emails and so on.
post = (req, res, fn, result = {}) ->
  return unless typeof fn is 'function'
  {_ctrl} = req
  if fn.length is 3
    fn.call _ctrl, req, res, result
  else
    fn.call _ctrl, req, result

post.after = true
post.key = post
post.parallel = true

module.exports = post
