{ test } = require 'tap'
Segment = require '../index'

test 'middleware weiboMetion runs', (t) ->

  t.test 'test with single hashtag', (t) ->
    text = '#古城秀湖奇山#在瑞吉山山顶远眺'
    expected = [
      { w: '#古城秀湖奇山#', start: 0, props: weiboHashtag: 1 }
      { w: '在瑞吉山山顶远眺', start: 8 }
    ]
    new Segment().use(Segment.weiboHashtag()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'test with single open hashtag', (t) ->
    text = '#古城秀湖奇山'
    expected = [ { w: '#古城秀湖奇山', start: 0 } ]
    new Segment().use(Segment.weiboHashtag()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'mixed latin and chinese characters in one hashtag', (t) ->
    text = '#ABC - 古城秀湖奇山#'
    expected = [ { w: '#ABC - 古城秀湖奇山#', start: 0, props: { weiboHashtag: 1 } } ]
    new Segment().use(Segment.weiboHashtag()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'test with multi hashtags', (t) ->
    text = '#琉森##古城秀湖奇山#在瑞吉山山顶远眺'
    expected = [
      { w: '#琉森#', start: 0, props: weiboHashtag: 1 }
      { w: '#古城秀湖奇山#', start: 4, props: weiboHashtag: 1 }
      { w: '在瑞吉山山顶远眺', start: 12 }
    ]
    new Segment().use(Segment.weiboHashtag()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()