proto    = require './proto'
utils    = require './utils'
fs       = require 'fs'
path     = require 'path'
basename = path.basename

class Segment
  constructor: ->
    utils.merge @, proto
    @utils = utils
    @stack = []

exports = module.exports = Segment
exports.proto = proto
exports.middleware = middleware = {}

# Auto-load bundled middleware with getters.
fs.readdirSync(__dirname + '/middleware').forEach (filename) ->
  return unless /\.js$/.test filename
  if fs.statSync(__dirname + '/middleware/' + filename).isFile()
    name = basename filename, '.js'
    load = require './middleware/' + name
    exports[name] = load
    middleware[name] = load