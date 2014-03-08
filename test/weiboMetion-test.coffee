{ test } = require 'tap'
Segment = require '../index'

test 'middleware weiboMetion runs', (t) ->

  t.test 'test with multi metions', (t) ->
    text = '如下两位成为幸运儿：@猿飞佐井 @阿多星'
    expected = [
      { w: '如下两位成为幸运儿：', start: 0 }
      { w: '@猿飞佐井', start: 10, props: weiboMention: 1 }
      { w: ' ', start: 15 }
      { w: '@阿多星', start: 16, props: weiboMention: 1 }
    ]
    new Segment().use(Segment.weiboMention()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'include full-width at mark', (t) ->
    text = '＠猿飞佐井@阿多星'
    expected = [
      { w: '＠猿飞佐井', start: 0, props: weiboMention: 1 }
      { w: '@阿多星', start: 5, props: weiboMention: 1 }
    ]
    new Segment().use(Segment.weiboMention()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'include latin characters in screen name', (t) ->
    text = ' @Jacobbubu在行动'
    expected = [
      { w: ' ', start: 0 }
      { w: '@Jacobbubu在行动', start: 1, props: weiboMention: 1 }
    ]
    new Segment().use(Segment.weiboMention()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'include hashtag', (t) ->
    text = '@Jacobbubu#hashtag'
    expected = [
      { w: '@Jacobbubu', start: 0, props: weiboMention: 1 }
      { w: '#hashtag', start: 10 }
    ]
    new Segment().use(Segment.weiboMention()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()
