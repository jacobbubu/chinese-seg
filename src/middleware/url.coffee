# Matched URL will be marked as 'url: 1' in props.

# Use this regexp to find out shcheme, userinfo and host
urlPattern = do ->
  protocol = "(?:http|https|ftp|sftp|git|ssh):(?://)"
  auth = "(?:[-;:&=\\+\\$,\\w]+@)"
  ipPart = "(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])"
  ip = ipPart + '\\.' + ipPart + '\\.' + ipPart + '\\.' + ipPart
  localhost = "localhost"
  # host1 = "(?:['\\!\\*\\-\\w]*\\.)*(?:['\\!\\*\\-\\w]*\.)"
  host1 = "(?:['\\!\\*\\-\\w]*\\.)+"
  host2 = "(?:['\\!\\*\\-\\w]*\\.){2,}"
  domain = "(?:com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2})"
  port = "(?:\\:[0-9]{1,5})"
  finalPart1 = protocol + auth + '?' + '(' + ip + '|' + localhost + '|' + host1 + domain + ')' + port + '?'
  finalPart2 = '(' + ip + '|' + localhost + '|' +  host2 + domain + ')' + port + '?'
  new RegExp "(#{finalPart1})|(#{finalPart2})" , 'gi'

# urlPattern = /(?:http|https|ftp|sftp|git|ssh):(?:\/\/)(?:[-;:&=\+\$,\w]+@)?(?:(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|(?:['\!\(\)\*\-\w]*\.)*(?:['\!\(\)\*\-\w]*\.)(?:com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2})(?:\:[0-9]{1,5})?)/ig

module.exports = (options) ->
  { noop, path, extend, matchSync, chnRange } = require '../utils'
  options = extend { propName: 'url' }, options

  tailReg = new RegExp "\\s|[#{chnRange}]"

  puncs = do ->
    latin = '.?!,:;(){}[]"\''
    chinese = '。。？！，、；：（）［］〔〕【】﹃﹄﹁﹂《》〈〉…“”‘’„‚'
    (latin + chinese).split ''

  # Find out url tail position.
  tailAt = (text, start) ->
    reachTail = (ch) -> tailReg.test ch
    for index in [start...text.length]
      char = text.charAt index
      break if reachTail char
    if index > 0
      prevChar = text.charAt index - 1
      if prevChar in puncs
        index -= 1
    index

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->
    next ?= noop
    options.pattern = urlPattern
    options.tailAt = tailAt
    next null, matchSync(words, options)

  { name, fn }