utils = require './utils'

seg = module.exports = {}

seg.use = (plugin) ->
  @stack.push plugin
  return @

seg.handle = (text, out) ->
  stack = @stack
  index = 0
  self = @

  next = (err, words) ->
    layer = stack[index++]

    # all done
    unless layer?
      out null, words if out?
      return

    layer.fn.call self, words, (err, newWords) ->
      if err?
        next err
      else
        next null, newWords

  next null, [ { w: text, start: 0 } ]
