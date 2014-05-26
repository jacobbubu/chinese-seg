{ test } = require 'tap'
Segment = require '../index'

test 'middleware punctuation runs', (t) ->

  t.test 'Full width western characters in text', (t) ->
    text = 'ASCII的局限在于只能显示26个基本拉丁字母、阿拉伯数目字和英式标点符号，因此只能用于显示现代美国英语（而且在处理英语当中的外来词如naïve、café、élite等等时，所有重音符号都不得不去掉，即使这样做会违反拼写规则）。'
    expected = [
      { w: 'ASCII的局限在于只能显示26个基本拉丁字母', start: 0 }
      { w: '、', start: 23, props: punc: 1 }
      { w: '阿拉伯数目字和英式标点符号', start: 24 }
      { w: '，', start: 37, props: punc: 1 }
      { w: '因此只能用于显示现代美国英语', start: 38 }
      { w: '（', start: 52, props: punc: 1 }
      { w: '而且在处理英语当中的外来词如naïve', start: 53 }
      { w: '、', start: 72, props: punc: 1 }
      { w: 'café', start: 73 }
      { w: '、', start: 77, props: punc: 1 }
      { w: 'élite等等时', start: 78 }
      { w: '，', start: 86, props: punc: 1 }
      { w: '所有重音符号都不得不去掉', start: 87 }
      { w: '，', start: 99, props: punc: 1 }
      { w: '即使这样做会违反拼写规则', start: 100 }
      { w: '）。', start: 112, props: punc: 1 }
    ]
    new Segment().use(Segment.punctuation()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test "Skip has't, didn't", (t) ->
    text = "Didn't he ask, 'What did we do, who preceded you?'"
    expected = [
      { w: 'Didn\'t he ask', start: 0 }
      { w: ',', start: 13, props: punc: 1 }
      { w: ' ', start: 14 }
      { w: '\'', start: 15, props: punc: 1 }
      { w: 'What did we do', start: 16 }
      { w: ',', start: 30, props: punc: 1 }
      { w: ' who preceded you', start: 31 }
      { w: '?\'', start: 48, props: punc: 1 }
    ]
    new Segment().use(Segment.punctuation()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test "Skip decimal point in number", (t) ->
    text = "We've got 12.34 and１２．３４."
    expected = [
      { w: 'We\'ve got 12.34 and１２．３４', start: 0 }
      { w: '.', start: 24, props: punc: 1 }
    ]
    new Segment().use(Segment.punctuation()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test ".1", (t) ->
    text = ".1"
    expected = [
      { w: '.', start: 0, props: { punc: 1 } }
      { w: '1', start: 1 }
    ]
    new Segment().use(Segment.punctuation()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test "1.1", (t) ->
    text = "1.1"
    expected = [ { w: '1.1', start: 0 } ]
    new Segment().use(Segment.punctuation()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()