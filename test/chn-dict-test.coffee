{ test } = require 'tap'
Segment = require '../index'

test 'middleware chn-dict runs', (t) ->

  chnSeg = new Segment().use(Segment['chn-dict']())

  # t.test 'load dictionary and tokenize', (t) ->
  #   text = '随着智能化住宅小区的普及和宽带接入技术的发展'
  #   expected = [
  #     { w: '随着', start: 0, props: '介词': 1 }
  #     { w: '智能化', start: 2, props: '动词': 1 }
  #     { w: '住宅小区', start: 5, props: '名词': 1 }
  #     { w: '的', start: 9, props: '助词': 1 }
  #     { w: '普及', start: 10, props: '动词': 1 }
  #     { w: '和', start: 12, props: '连词 ': 1 }
  #     { w: '宽带接入', start: 13, props: '名词': 1 }
  #     { w: '技术', start: 17, props: '名词': 1 }
  #     { w: '的', start: 19, props: '助词': 1 }
  #     { w: '发展', start: 20, props: '动词': 1 }
  #   ]
  #   chnSeg.handle text, (err, result) ->
  #     t.deepEqual result, expected
  #     # console.error result
  #     t.end()

  t.test 'mixed in non-chinese characters', (t) ->
    # text = '一次性交一百元'
    text = '一次性交一百元' #, 十五点五八， 十五点三,共有五十分之一'
    expected = [
      { w: '随着', start: 0, props: '介词': 1 }
      { w: '智能化', start: 2, props: '动词': 1 }
      { w: '住宅小区', start: 5, props: '名词': 1 }
      { w: '的', start: 9, props: '助词': 1 }
      { w: '普及', start: 10, props: '动词': 1 }
      { w: '和', start: 12, props: '连词 ': 1 }
      { w: '宽带接入', start: 13, props: '名词': 1 }
      { w: '技术', start: 17, props: '名词': 1 }
      { w: '的', start: 19, props: '助词': 1 }
      { w: '发展', start: 20, props: '动词': 1 }
    ]
    chnSeg.handle text, (err, result) ->
      # t.deepEqual result, expected
      console.error result
      t.end()


