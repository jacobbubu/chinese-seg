# split text by \r or \n
module.exports = (options) ->
  { noop, path, extend, unique, tokenizeSync } = require '../utils'
  options = extend { removeToken: true, propName: 'crlf' }, options
  CRLF = ['\r', '\n']
  isToken = (text, index) ->
    text.charAt(index) in CRLF
  options.isToken = isToken

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->
    next ?= noop
    result = tokenizeSync words, options
    next null, result

  { name, fn }