noop = exports.noop = ->
extend = exports.extend = require 'xtend'
path = exports.path = require 'path'
eql = exports.eql = require 'deep-equal'

merge = exports.merge = (a, b) ->
  if a? and b?
    a[key] = value for key, value of b
  a

unique = exports.unique = (arr) ->
  output = {}
  output[arr[key]] = arr[key] for key in [0...arr.length]
  value for key, value of output

findOne = exports.findOne = (props, skipProps) ->
  if props?
    for propName in skipProps
      if props[propName]?
        return true
  false

splitWordSync = exports.splitWordSync = (word, options) ->
  { isToken, propName, removeToken } = options
  result = []; text = word.w; start = word.start; found = false

  lastPos = 0
  for index in [0...text.length]
    if isToken text, index
      if not found
        if index > lastPos
          value =
            w: text.slice lastPos, index
            start: start + lastPos
          value.props = word.props if word.props?
          result.push value
          lastPos = index
        found = true
    else
      if found
        if index > lastPos and not removeToken
          value =
            w: text.slice lastPos, index
            start: start + lastPos
            props: extend {}, word.props
          value.props[propName] = 1
          result.push value
        lastPos = index
        found = false

  if lastPos < text.length
    value =
      w: text.slice lastPos
      start: start + lastPos
    if found
      if not removeToken
        value.props = extend {}, word.props
        value.props[propName] = 1
        result.push value
    else
      result.push value
  result

# options =
#   isToken: "func for identifying token, (text, index, next) ->"
#   skipPros: 'words that has props to skip parsing'
#   propName: 'current prop name'
#   removeToken: false
tokenizeSync = exports.tokenizeSync = (words, options) ->
  throw new Error 'options required' unless options?
  throw new Error 'options.isToken required' unless options.isToken?
  throw new Error 'options.propName required' unless options.propName?
  options.skipProps = unique [options.propName].concat (options.skipProps ? [])
  options.removeToken ?= false
  result = []
  for word in words
    if findOne word.props, options.skipProps
      result.push word
    else
      result = result.concat splitWordSync word, options
  result
