noop = exports.noop = ->
extend = exports.extend = require 'xtend'
path = exports.path = require 'path'
eql = exports.eql = require 'deep-equal'
chnRange = exports.chnRange = '\\u2E80-\\uFE4F'

merge = exports.merge = (a, b) ->
  if a? and b?
    a[key] = value for key, value of b
  a

clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date(obj.getTime())

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global?
    flags += 'i' if obj.ignoreCase?
    flags += 'm' if obj.multiline?
    flags += 'y' if obj.sticky?
    return new RegExp(obj.source, flags)

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance

newProps = exports.newProps = (a, propName) ->
  return a if not propName?
  c = clone a
  c = {} if not c?
  c[propName] = 1
  c

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
            props: newProps word.props, propName
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
        value.props[propName] = 1 if propName?
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
  # options.skipProps = unique [options.propName].concat (options.skipProps ? [])
  options.removeToken ?= false
  result = []
  for word in words
    # if findOne word.props, options.skipProps
    if word.props?
      result.push word
    else
      result = result.concat splitWordSync word, options
  result

findMatchSync = exports.findMatchSync= (word, options) ->
  result = []
  allMatched = word.w.match options.pattern
  removeSplitter = options.removeSplitter ? false
  if allMatched?
    start = word.start
    text = word.w
    for oneMatched in allMatched
      index = text.indexOf oneMatched
      if options.tailAt?
        tail = options.tailAt text, index
      else
        tail = index + oneMatched.length
      # word before matched
      if not removeSplitter and index > 0
        value =
          w: text.slice 0, index
          start: start
        value.props = word.props if word.props?
        result.push value
      # matched part
      value =
        w: text.slice index, tail
        start: start + index
        props: newProps word.props, options.propName
      result.push value

      text = text.slice tail
      start += tail
    if not removeSplitter and start < word.w.length
      value =
        w: text
        start: start
      value.props = word.props if word.props?
      result.push value
  else
    result.push word
  result

matchSync = exports.matchSync = (words, options) ->
  throw new Error 'options required' unless options?
  throw new Error 'options.pattern required' unless options.pattern?
  throw new Error 'options.propName required' unless options.propName?
  # options.skipProps = unique [options.propName].concat (options.skipProps ? [])
  result = []
  for word in words
    # if findOne word.props, options.skipProps
    if word.props?
      result.push word
    else
      result = result.concat findMatchSync word, options
  result
