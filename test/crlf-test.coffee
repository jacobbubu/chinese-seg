{ test } = require 'tap'
Segment = require '../index'

test 'middleware crlf runs', (t) ->

  t.test 'no crlf', (t) ->
    text = 'This paragraph is without crlf.'
    expected = [ { w: 'This paragraph is without crlf.', start: 0 } ]
    new Segment().use(Segment.crlf()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test '5 lines', (t) ->
    text = 'line 1\nline 2\n\rline 3\n\rline 4\n\n\nline 5'
    expected = [
      { w: 'line 1', start: 0 }
      { w: 'line 2', start: 7 }
      { w: 'line 3', start: 15 }
      { w: 'line 4', start: 23 }
      { w: 'line 5', start: 32 }
    ]
    new Segment().use(Segment.crlf()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'crlf is in the begin of text', (t) ->
    text = '\n\rline 1\nline 2\r\nline 3'
    expected = [
      { w: 'line 1', start: 2 }
      { w: 'line 2', start: 9 }
      { w: 'line 3', start: 17 }
    ]
    new Segment().use(Segment.crlf()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()
