# Tokenize western characters and numbers
module.exports = (options) ->
  hanzenkaku = require('hanzenkaku').HanZenKaku
  utils = require '../utils'
  options = options ? {}
  isToken = (text, index) ->
    extWesternChars = [ 8361 ] # ₩
    halfChar = text.charAt(index).toHalfwidth().toHalfwidthSpace()
    code = halfChar.charCodeAt()
    code <= 255 or code in extWesternChars

  (words, next) ->
    result = []
    for word in words
      if word.props?
        result.push word
      else
        result = result.concat utils.splitWord word, isToken, 'western'
    next null, result
