# Tokenize western characters and numbers
module.exports = (options) ->
  hanzenkaku = require('hanzenkaku').HanZenKaku
  { noop, path, extend, unique, tokenizeSync, findMatchSync, newProps } = require '../utils'
  options = extend { removeToken: false, propName: 'western' }, options
  extWesternChars = [ 8361 ] # ₩

  isToken = (text, index) ->
    halfChar = text.charAt(index).toHalfwidth().toHalfwidthSpace()
    code = halfChar.charCodeAt()
    code <= 255 or code in extWesternChars
  options.isToken = isToken

  fullToHalf = (words) ->
    result = words.map (row) ->
      if row.props?[options.propName]?
        row.w = row.w.toHalfwidth().toHalfwidthSpace()
        row
      else
        row

  versionIdentify = (words) ->
    opt =
      # 3.0.0 or 3.1.2.1 will be recognized as a version number
      # 2.0 will be left as a number
      pattern: /\d+(\.\d+){2,3}/gi
      propName: 'western.version'
    result = []
    words.forEach (word) ->
      if not word.props?['western']?
        result.push word
      else
        result = result.concat findMatchSync(word, opt)
    result

  numberIdentify = (words)->
    opt =
      pattern: /((\d+([\,]\d{3})*)(\.\d+)?)|(\.\d+)/gi
      propName: 'western.number'
    result = []
    words.forEach (word) ->
      if not word.props?['western']?
        result.push word
      else if word.props?['western.version']? or word.props?['western.number']?
        result.push word
      else
        res = findMatchSync(word, opt).map (row) ->
          if row.props?['western.number']? and row.w.indexOf('.') >= 0
            row.props['western.number.fraction'] = 1
          row
        result = result.concat res
    result

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->
    next ?= noop
    result = versionIdentify fullToHalf(tokenizeSync words, options)
    result = numberIdentify result
    next null, result
  { name, fn }