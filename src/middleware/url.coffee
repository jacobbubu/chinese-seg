# Matched URL will be marked as 'url: 1' in props.

# Use this regexp to find out shcheme, userinfo and host
urlPattern = /(?:http|https|ftp|sftp|git|ssh):(?:\/\/)(?:[-;:&=\+\$,\w]+@)?(?:(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|(?:['\!\(\)\*\-\w]*\.)*(?:['\!\(\)\*\-\w]*\.)(?:com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2})(?:\:[0-9]{1,5})?)/ig

module.exports = (options) ->
  options = options ? {}
  (words, next) ->
    result = []
    for word in words
      if word.props?.url?
        result.push word
      else
        result = result.concat findURL word
    next null, result

findURL = (word) ->

  # Find out url tail position.
  tailAt = (text, start) ->
    puncs = ['.', ',', ';', '!', '<', '>', '(', ')']
    reachTail = (ch) -> /\s|[\u4e00-\u9FFF]/.test ch
    for index in [start...text.length]
      char = text.charAt index
      break if reachTail char
    if index > 0
      prevChar = text.charAt index - 1
      if prevChar in puncs
        index -= 1
    index

  result = []
  matched = word.w.match urlPattern
  if matched?
    start = word.start
    text = word.w
    for urlHost in matched
      index = text.indexOf urlHost
      tail = tailAt text, index
      # word before url
      if index > 0
        result.push
          w: text.slice 0, index
          start: start
      # url word
      result.push
        w: text.slice index, tail
        start: start + index
        props: { 'url': 1 }
      text = text.slice tail
      start += tail
    if start < word.w.length
      result.push
        w: text
        start: start
  else
    result.push word
  result



