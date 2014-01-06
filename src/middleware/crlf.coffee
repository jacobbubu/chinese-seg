# split text by \r or \n
module.exports = (options) ->
  utils = require '../utils'
  options = options ? {}
  isToken = (text, index) ->
    CRLF = ['\r', '\n']
    text.charAt(index) in CRLF

  (words, next) ->
    result = []
    for word in words
      result = result.concat utils.splitWord word, isToken, 'crlf', true
    next null, result