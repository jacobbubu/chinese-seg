{ test } = require 'tap'
Segment = require '../index'

test 'construct', (t) ->
  seg = new Segment()
  t.ok seg?, 'Segment object should be created'
  t.ok Segment['url']? and Segment.middleware['url']?, "Default middleware 'url' should load"
  t.end()