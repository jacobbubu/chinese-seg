{ test } = require 'tap'
Segment = require '../index'

test 'middleware url runs', (t) ->

  t.test 'test without url inside', (t) ->
    text = 'This paragraph is without url inside.\n The second paragraph are also free to url.'
    new Segment().use(Segment.url()).handle text, (err, result) ->
      t.deepEqual result, [{w: text, start: 0}]
      t.end()

  t.test '1 url inside', (t) ->
    t.test 'pure url', (t) ->
      text = 'http://www.microsoft.com'
      expected = [ { w: 'http://www.microsoft.com', start: 0, props: { url: 1 } } ]
      new Segment().use(Segment.url()).handle text, (err, result) ->
        t.deepEqual result, expected
        t.end()

    t.test 'url in text', (t) ->
      text = '''
        MEAN is a boilerplate that provides a nice starting point for MongoDB(http://www.mongodb.org/)
      '''
      expected = [
        { w: 'MEAN is a boilerplate that provides a nice starting point for MongoDB(', start: 0 }
        { w: 'http://www.mongodb.org/', start: 70, props: url: 1 }
        { w: ')', start: 93 }
      ]
      new Segment().use(Segment.url()).handle text, (err, result) ->
        t.deepEqual result, expected
        t.end()

    t.test 'url in Chinese characters', (t) ->
      text = '''
        访问http://www.nodejs.org可以下载到 NodeJS 最新的文档
      '''
      expected = [
        { w: '访问', start: 0 }
        { w: 'http://www.nodejs.org', start: 2, props: url: 1 }
        { w: '可以下载到 NodeJS 最新的文档', start: 23 }
      ]
      new Segment().use(Segment.url()).handle text, (err, result) ->
        t.deepEqual result, expected
        t.end()

    t.test 'url without protocol', (t) ->
      text = '''
        访问www.nodejs.org可以下载到 NodeJS 最新的文档
      '''
      expected = [
        { w: '访问', start: 0 }
        { w: 'www.nodejs.org', start: 2, props: url: 1 }
        { w: '可以下载到 NodeJS 最新的文档', start: 16 }
      ]
      new Segment().use(Segment.url()).handle text, (err, result) ->
        t.deepEqual result, expected
        t.end()

  t.test 'multi urls in text', (t) ->
    text = '''
      MEAN is a boilerplate that provides a nice starting point for
      MongoDB(http://www.mongodb.org/), Node.js(www.nodejs.org/),
      Express(http://expressjs.com/), and AngularJS(http://angularjs.org/) based applications.
    '''
    expected = [
      { w: 'MEAN is a boilerplate that provides a nice starting point for\nMongoDB(', start: 0 }
      { w: 'http://www.mongodb.org/)', start: 70, props: url: 1 }
      { w: ', Node.js(', start: 94 }
      { w: 'www.nodejs.org/)', start: 104, props: url: 1 }
      { w: ',\nExpress(', start: 120 }
      { w: 'http://expressjs.com/)', start: 130, props: url: 1 }
      { w: ', and AngularJS(', start: 152 }
      { w: 'http://angularjs.org/', start: 168, props: url: 1 }
      { w: ') based applications.', start: 189 }
    ]
    new Segment().use(Segment.url()).handle text, (err, result) ->
      t.deepEqual result, expected
      t.end()