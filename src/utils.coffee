exports.merge = (a, b) ->
  if a? and b?
    a[key] = value for key, value of b
  a

exports.splitWord = (word, isToken, props, ignoreMatched = false) ->
  result = []; text = word.w; start = word.start; found = false

  lastPos = 0
  for index in [0...text.length]
    if isToken text, index
      if not found
        if index > start
          result.push
            w: text.slice lastPos, index
            start: start + lastPos
          lastPos = index
        found = true
    else
      if found
        if index > lastPos and not ignoreMatched
          value =
            w: text.slice lastPos, index
            start: start + lastPos
            props: {}
          value.props[props] = 1
          result.push value
        lastPos = index
        found = false

  if lastPos < text.length
    value =
      w: text.slice lastPos
      start: start + lastPos
    if found
      value.props = {}
      value.props[props] = 1
      result.push value if not ignoreMatched
    else
      result.push value
  result