module.exports = (options) ->
  { noop, path, extend, matchSync, chnRange } = require '../utils'

  mentionPattern = do ->
    atSigns = "[@＠]"
    validMention =
      "(#{atSigns})" +                     # $1: At mark
      "([a-zA-Z0-9_\\-#{chnRange}]{1,30})"  # $2: Screen name
    new RegExp validMention, 'gi'

  options = extend { propName: 'weiboMention' }, options

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->
    next ?= noop
    options.pattern = mentionPattern
    result = matchSync words, options
    next null, result

  { name, fn }