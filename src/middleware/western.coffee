# Tokenize western characters and numbers
module.exports = (options) ->
  hanzenkaku = require('hanzenkaku').HanZenKaku
  { noop, path, extend, unique, tokenizeSync } = require '../utils'
  options = extend { removeToken: false, propName: 'western', fullToHalf: false }, options
  extWesternChars = [ 8361 ] # ₩
  isToken = (text, index) ->
    halfChar = text.charAt(index).toHalfwidth().toHalfwidthSpace()
    code = halfChar.charCodeAt()
    code <= 255 or code in extWesternChars
  options.isToken = isToken

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->
    next ?= noop
    result = (tokenizeSync words, options)
    if options.fullToHalf
      result = result.map (row) ->
        if row.props?[options.propName]?
          row.w = row.w.toHalfwidth().toHalfwidthSpace()
          row
        else
          row
    next null, result
  { name, fn }