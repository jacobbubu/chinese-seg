{ test } = require 'tap'
Segment  = require '../index'

test 'middleware western runs', (t) ->

  t.test 'simple western text', (t) ->
    text = "For node < v0.6, use 'npm install WNdb@3.0.0'"
    expected = [
      { w: 'For node < v', start: 0, props: { western: 1 } }
      { w: '0.6', start: 12, props: { western: 1, 'western.number': 1, 'western.number.fraction' : 1 } }
      { w: ', use \'npm install WNdb@', start: 15, props: western: 1 }
      { w: '3.0.0', start: 39, props: { western: 1, 'western.version': 1 } }
      { w: '\'', start: 44, props: western: 1 }
    ]
    new Segment().use(Segment.western()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'Complicated numbers', (t) ->
    text = "778,619 of its 2005-2007, G5, 1,000.11, +0.22, .33"
    expected = [
      { w: '778,619', start: 0, props: { western: 1, 'western.number': 1 } }
      { w: ' of its ', start: 7, props: western: 1 }
      { w: '2005', start: 15, props: { western: 1, 'western.number': 1 } }
      { w: '-', start: 19, props: western: 1 }
      { w: '2007', start: 20, props: { western: 1, 'western.number': 1 } }
      { w: ', G', start: 24, props: western: 1 }
      { w: '5', start: 27, props: { western: 1, 'western.number': 1 } }
      { w: ', ', start: 28, props: western: 1 }
      { w: '1,000.11', start: 30, props: { western: 1, 'western.number': 1, 'western.number.fraction': 1 } }
      { w: ', +', start: 38, props: western: 1 }
      { w: '0.22', start: 41, props: { western: 1, 'western.number': 1, 'western.number.fraction': 1 } }
      { w: ', ', start: 45, props: western: 1 }
      { w: '.33', start: 47, props: { western: 1, 'western.number': 1, 'western.number.fraction': 1 } }
    ]
    new Segment().use(Segment.western()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'Chinese charaters mixed in the text', (t) ->
    text = '中文 Node.JS 社区的活跃，也带动了 CoffeeScript 的普及'
    expected = [
      { w: '中文', start: 0 }
      { w: ' Node.JS ', start: 2, props: western: 1 }
      { w: '社区的活跃', start: 11 }
      { w: ',', start: 16, props: western: 1 }
      { w: '也带动了', start: 17 }
      { w: ' CoffeeScript ', start: 21, props: western: 1 }
      { w: '的普及', start: 35 }
    ]
    new Segment().use(Segment.western()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'Convert full width text to half width', (t) ->
    text = '在２０１３年ＭｏｎｇｏＤＢ，Ｅｘｐｒｅｓｓ．ＪＳ，ＡｎｇｕｌａｒＪＳ　ａｎｄ　ＮＯＤＥ．ＪＳ统称为ＭＥＡＮ'
    expected = [
      { w: '在', start: 0 }
      { w: '2013', start: 1, props: { western: 1, 'western.number': 1 } }
      { w: '年', start: 5 }
      { w: 'MongoDB,Express.JS,AngularJS and NODE.JS', start: 6, props: western: 1 }
      { w: '统称为', start: 46 }
      { w: 'MEAN', start: 49, props: western: 1 }
    ]
    new Segment().use(Segment.western()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test 'Combine punctuation and western', (t) ->
    text = 'ASCII的局限在于只能显示26个基本拉丁字母、阿拉伯数目字和英式标点符号，因此只能用于显示现代美国英语（而且在处理英语当中的外来词如naïve、café、élite等等时，所有重音符号都不得不去掉，即使这样做会违反拼写规则）。而EASCII虽然解决了部分西欧语言的显示问题，但对更多其他语言依然无能为力。因此现在的软件系统大多采用Unicode。'
    expected = [
      { w: 'ASCII', start: 0, props: western: 1 }
      { w: '的局限在于只能显示', start: 5 }
      { w: '26', start: 14, props: { western: 1, 'western.number': 1 } }
      { w: '个基本拉丁字母', start: 16 }
      { w: '、', start: 23, props: punc: 1 }
      { w: '阿拉伯数目字和英式标点符号', start: 24 }
      { w: '，', start: 37, props: punc: 1 }
      { w: '因此只能用于显示现代美国英语', start: 38 }
      { w: '（', start: 52, props: punc: 1 }
      { w: '而且在处理英语当中的外来词如', start: 53 }
      { w: 'naïve', start: 67, props: western: 1 }
      { w: '、', start: 72, props: punc: 1 }
      { w: 'café', start: 73, props: western: 1 }
      { w: '、', start: 77, props: punc: 1 }
      { w: 'élite', start: 78, props: western: 1 }
      { w: '等等时', start: 83 }
      { w: '，', start: 86, props: punc: 1 }
      { w: '所有重音符号都不得不去掉', start: 87 }
      { w: '，', start: 99, props: punc: 1 }
      { w: '即使这样做会违反拼写规则', start: 100 }
      { w: '）。', start: 112, props: punc: 1 }
      { w: '而', start: 114 }
      { w: 'EASCII', start: 115, props: western: 1 }
      { w: '虽然解决了部分西欧语言的显示问题', start: 121 }
      { w: '，', start: 137, props: punc: 1 }
      { w: '但对更多其他语言依然无能为力', start: 138 }
      { w: '。', start: 152, props: punc: 1 }
      { w: '因此现在的软件系统大多采用', start: 153 }
      { w: 'Unicode', start: 166, props: western: 1 }
      { w: '。', start: 173, props: punc: 1 }
    ]
    new Segment().use(Segment.punctuation()).use(Segment.western()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()