# Tokenize western characters and numbers
module.exports = (options) ->
  utils = require '../utils'
  options = options ? {}
  isToken = (text, index) ->
    false

  (words, next) ->
    result = []
    for word in words
      if word.props?
        result.push word
      else
        result = result.concat utils.splitWord word, isToken, 'country'
    next null, result
