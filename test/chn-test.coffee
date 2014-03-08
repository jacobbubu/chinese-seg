{ test } = require 'tap'
Segment = require '../index'

test 'middleware chn runs', (t) ->

  chnSeg = new Segment()
  .use(Segment.crlf())
  .use(Segment.western())
  .use(Segment.chn())
  .use(Segment['dateOptimizer']())

  t.test '一次性交一百元', (t) ->
    text = '一次性交一百元' #, 十五点五八， 十五点三,共有五十分之一'
    expected = [
      { w: '一次性', start: 0, props: { '区别词': 1, '数词': 1 } }
      { w: '交', start: 3, props: '动词': 1}
      { w: '一百元', start: 4, props: '数词': 1 }
    ]
    chnSeg.handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test '永和服装饰品有限公司', (t) ->
    text = '永和服装饰品有限公司'
    expected = [
      { w: '永和', start: 0, props: { '名词': 1 } },
      { w: '服装', start: 2, props: { '名词': 1 } },
      { w: '饰品有限公司', start: 4, props: { '名词': 1 } }
    ]
    chnSeg.handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test '研究生命起源', (t) ->
    text = '研究生命起源'
    expected = [
      { w: '研究', start: 0, props: '动词': 1 }
      { w: '生命', start: 2, props: '名词': 1 }
      { w: '起源', start: 4, props: '名词': 1 }
    ]
    chnSeg.handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test '本科班学生', (t) ->
    text = '本科班学生'
    expected = [
      { w: '本科', start: 0, props: '名词': 1 }
      { w: '班', start: 2, props: { '量词': 1, '机构团体': 1 } }
      { w: '学生', start: 3, props: '名词': 1 }
    ]
    chnSeg.handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test '杭州市长春药店', (t) ->
    text = '杭州市长春药店'
    expected = [
      { w: '杭州市', start: 0, props: '地名': 1 }
      { w: '长春', start: 3, props: '地名': 1 }
      { w: '药店', start: 5, props: '名词': 1 }
    ]
    chnSeg.handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  t.test '1989年12月景甜出生于西安市。', (t) ->
    text = '1989年12月景甜出生于西安市。'
    expected = [
      { w: '1989年12月', start: 0, props: '时间词': 1 }
      { w: '景甜', start: 8, props: '人名': 1 }
      { w: '出生', start: 10, props: '动词': 1 }
      { w: '于', start: 12, props: '介词': 1 }
      { w: '西安市', start: 13, props: '地名': 1 }
      { w: '。', start: 16 }
    ]
    chnSeg.handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()

  # t.test '前几天王老头刚收到小孩寄来的照片', (t) ->
  #   text = '前几天王老头刚收到小孩寄来的照片'
  #   expected = [
  #     { w: '永和', start: 0, props: { '名词': 1 } },
  #     { w: '服装', start: 2, props: { '名词': 1 } },
  #     { w: '饰品有限公司', start: 4, props: { '名词': 1 } }
  #   ]
  #   chnSeg.handle text, (err, result) ->
  #     # t.deepEqual result, expected
  #     console.error '没有做人名优化'
  #     console.error result
  #     t.end()
