module.exports = (options) ->
  { noop, path, extend, matchSync, chnRange } = require '../utils'

  hashtagPattern = do ->
    hashSigns = "[#＃]"
    validHashtag =
      "(#{hashSigns})" +                                # $1: Begin mark
      "(?:[\x20-\x7e\xa0-\xff#{chnRange}]{1,138}?)" +   # $2: Content
      "(#{hashSigns})"                                  # $3: End mark
    new RegExp validHashtag, 'gi'

  options = extend { propName: 'weiboHashtag' }, options

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->
    next ?= noop
    options.pattern = hashtagPattern
    result = matchSync words, options
    next null, result

  { name, fn }