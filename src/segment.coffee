proto    = require './proto'
utils    = require './utils'
fs       = require 'fs'
path     = require 'path'
basename = path.basename

class Segment
  constructor: ->
    utils.merge @, proto
    @stack = []

exports = module.exports = Segment
exports.proto = proto
exports.middleware = {}

# Auto-load bundled middleware with getters.
fs.readdirSync(__dirname + '/middleware').forEach (filename) ->
  return unless /\.js$/.test filename
  if fs.statSync(__dirname + '/middleware/' + filename).isFile()
    name = basename filename, '.js'
    load = -> require './middleware/' + name
    exports.middleware.__defineGetter__ name, load
    exports.__defineGetter__ name, load


