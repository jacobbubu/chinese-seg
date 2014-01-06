utils = require './utils'

seg = module.exports = {}

seg.use = (fn) ->
  @stack.push handle: fn
  return @

seg.handle = (text, out) ->
  stack = @stack
  index = 0

  next = (err, words) ->
    layer = stack[index++]

    # all done
    unless layer?
      out null, words if out?
      return

    try
      layer.handle words, (err, newWords) ->
        if err?
          return out err, newWords if out?
        else
          next null, newWords
    catch e
      next e

  next null, [ { w: text, start: 0 } ]
