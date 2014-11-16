fs = require 'fs'
{ noop, path, extend, unique, findOne, eql } = require '../utils'
{ SURNAME, COMPOUND_SURNAME, FIRST_CHAR_IN_LASTNAME, SECOND_CHAR_IN_LASTNAME, SINGLE_LASTNAME } = require '../chn_names/consts'

sysDict = null

loadDict = (file, dict) ->
  stats = fs.statSync file
  file =fs.readlinkSync file if stats.isSymbolicLink()

  data = fs.readFileSync file, { encoding: 'utf8' }
  lineNo = 0

  data.split(/\r?\n/).forEach (jsonWord) ->
    lineNo++
    jsonWord = jsonWord.trim()
    if jsonWord.length > 0
      try
        oneWord = JSON.parse jsonWord
      catch e
        throw new Error "parsing line ##{lineNo} in file #{file} errors - " + e
      if oneWord?
        len = oneWord.word.length
        if len > 0
          key = oneWord.word.toLowerCase()
          dict.byWord[key] = {props: oneWord.props, freq: oneWord.freq}
          dict.byLen[''+len] ?= {}
          dict.byLen[''+len][key] = dict.byWord[key]
  dict

loadFolder = (folder, dict) ->
  throw new Error "Dictionary path does not exist - #{folder}" if not fs.existsSync(folder)

  fs.readdirSync(folder).forEach (file) ->
    fullFilePath = path.join folder, file
    stats = fs.statSync fullFilePath
    if stats.isDirectory()
      dict = loadFolder fullFilePath
    else if stats.isFile()
      ext = path.extname file
      if ext in ['.txt']
        dict = loadDict fullFilePath, dict
    else
      throw new Error file + 'is a type of file I cannot read'
  dict

module.exports = (options) ->
  options = extend {}, options
  repetedReg = /([^\s])\1{2,}/

  if not sysDict
    dictPath = path.resolve __dirname, '../../dict'
    sysDict = { byWord: {}, byLen: {} }
    sysDict = loadFolder dictPath, sysDict

  dict = null
  if options.files?
    if typeof options.files is 'string'
      dictFiles = [options.files]
    else
      dictFiles = options.files

    if Array.isArray dictFiles
      dict = { byWord: {}, byLen: {} }
      dictFiles.forEach (file) ->
        dict = loadDict file, dict
    else
      throw new TypeError 'Unknown options.files type'

  byWord = (word) ->
    key = word.toLowerCase()
    result = dict.byWord[key] if dict?
    result = sysDict.byWord[key] if not result?
    result

  # allProps = {}
  # for k, v of dict.byWord
  #   if v.props?
  #     for propName of v.props
  #       allProps[propName] = 1

  # options.skipProps = unique Object.keys(allProps).concat(options.skipProps ? [])

  DATETIME = do ->
    _DATETIME = [
      '世纪', '年', '年份', '年度', '月', '月份', '月度', '日', '号',
      '时', '点', '点钟', '分', '分钟', '秒', '毫秒'
    ]
    result = {}
    for d in _DATETIME
      result[d] = d.length
    result

  # dateTimeOptimizer = (words) ->
  #   result = []; i = 0
  #   while i < words.length
  #     word1 = words[i]
  #     word2 = words[i + 1]

  #     # 日期时间组合   数字 + 日期单位，如 “2005年", "十二岁时"
  #     if word1.props?['数词']?
  #       if word2? and DATETIME[word2.w]?
  #         newWord = word1.w + word2.w
  #         len = 2
  #         # 继续搜索后面连续的日期时间描述，必须符合  数字 + 日期单位， “2005年10月”
  #         while true
  #           w1 = words[i + len]
  #           w2 = words[i + len + 1]
  #           if w1?.props?['数词']? and w2? and DATETIME[w2.w]?
  #             len += 2
  #             newWord += w1.w + w2.w
  #           else
  #             break
  #         value = { w: newWord, curr: word1.curr }
  #         value.props = {}
  #         value.props['时间词'] = 1
  #         result.push value
  #         i += len
  #         continue
  #     result.push word1
  #     i++
  #   result

  optimizer = (words, first = true) ->

    isCompatible = (prop1, prop2) ->
      if prop1? and prop2?
        for k of prop1
          return true if prop2[k]?
      false

    result = []; i = 0
    while i < words.length
      word1 = words[i]
      word2 = words[i + 1]
      if word2?
        # 能组成一个新词的(词性必须相同/兼容)
        newWord = word1.w + word2.w
        if isCompatible(word1.props, word2.props) and byWord(newWord)?
          props = byWord(newWord).props
          value = { w: newWord, curr: word1.curr }
          value.props = props if props?
          result.push value
          i += 2
          continue

        # 形容词 + 助词 = 形容词，如： 不同 + 的 = 不同的
        if word1.props?['形容词']? and word2.props?['助词']?
          value = { w: newWord, curr: word1.curr }
          value.props = {}
          value.props['助词'] = 1
          result.push value
          i += 2
          continue

        # 数词组合
        if word1.props?['数词']?
          # 百分比数字 如 10%，或者下一个词也是数词，则合并
          if word2.props?['数词']? or (word2.w in ['%', '％'])
            value = { w: newWord, curr: word1.curr }
            value.props = {}
            value.props['数词'] = 1
            result.push value
            i += 2
            continue

          # 数词 + 量词，合并。如： 100个
          if word2.props?['量词']?
            value = { w: newWord, curr: word1.curr }
            value.props = {}
            value.props['数量词'] = 1
            result.push value
            i += 2
            continue

          # 带小数点的数字 ，如 “3.14”，或者 “十五点三”
          # 数词 + "分之" + 数词，如“五十分之一”
          word3 = words[i + 2]
          if word3?
            if word3.props?['数词']? and word2.w in ['.', '点', '分之']
              value = { w: newWord + word3.w, curr: word1.curr }
              value.props = {}
              value.props['数词'] = 1
              result.push value
              i += 3
              continue

        # 修正 “十五点五八”问题
        if word1.props?['数量词']? and (word1.w.slice(-1) is '点') and word2.props?['数词']?
          w4w = ''
          for j in [(i+2)...words.length]
            word3 = words[j]
            if word3?['数词']?
              w4w += word3.w
            else
              break
          value = { w: newWord + w4w, curr: word1.curr }
          value.props = {}
          value.props['数量词'] = 1
          result.push value
          i += j - i
          continue

        result.push word1
      else
        result.push word1
      i++

    # run again to combine new numbers gererated from first running
    if first
      optimizer result, false
    else
      result

  # find out all combinations of words
  getChunks = (wordpos, pos, text) ->
    ret = []
    len = text.length
    while (not wordpos[pos]?) and pos < len
      pos++

    words = wordpos[pos]
    return ret if not words?

    for word in words
      nextCurr = word.curr + word.w.length
      if nextCurr >= len
        ret.push [word]
      else
        chunks = getChunks wordpos, nextCurr, text
        for chunk in chunks
          ret.push [word].concat(chunk)
    ret

  # words group by positions occurred in a line
  groupByPos = (words, text) ->
    wordpos = {}
    # words groupped by starting position in a line
    for word in words
      wordpos[word.curr] ?= []
      wordpos[word.curr].push word

    # filling out the pos gap
    for i in [0...text.length]
      ch = text.charAt i
      wordpos[i] = [ {w: ch, curr: i, freq: 0} ] unless wordpos[i] or ch is ' '
    wordpos

  getTops = (scores, chunks) ->
    # 取各项最大值
    top = { x: scores[0].x, a: scores[0].a, b: scores[0].b, c: scores[0].c, d: scores[0].d }
    for i in [1...scores.length]
      s = scores[i]
      top.a = s.a if s.a > top.a     # 取最大平均词频
      top.b = s.b if s.b < top.b     # 取最小标准差
      top.c = s.c if s.c > top.c     # 取最大未识别词
      top.d = s.d if s.d < top.d     # 取最小语法分数
      top.x = s.x if s.x > top.x     # 取最大单词数量

    # console.log 'top', top
    tops = []
    for index, s of scores
      i = Number index
      tops[i] = 0
      # 词数量，越小越好
      tops[i] += (top.x - s.x) * 1.5
      # 词总频率，越大越好
      tops[i] += 1 if s.a >= top.a
      # 词标准差，越小越好
      tops[i] += 1 if s.b <= top.b
      # 未识别词，越小越好
      tops[i] += top.c - s.c
      # 符合语法结构程度，越大越好
      tops[i] += (if s.d < 0 then top.d + s.d else s.d - top.d) * 1

    # for i in [0...tops.length]
    #   console.log (chunk.w for chunk in chunks[i]), { t: tops[i], x: scores[i].x, a: scores[i].a, b: scores[i].b, c: scores[i].c, d: scores[i].d }

    # 取分数最高的
    maxs = tops[0]; maxIndex = 0
    for i in [1...tops.length]
      s = tops[i]
      if s > maxs
        maxIndex = i
        maxs = s
      else if s is maxs
        # 如果分数相同，则根据词长度、未识别词个数和平均频率来选择
        a = 0; b = 0
        if scores[i].c < scores[maxIndex].c then a++ else b++
        if scores[i].a > scores[maxIndex].a then a++ else b++
        if scores[i].x < scores[maxIndex].x then a++ else b++
        if a > b
          maxIndex = i
          maxs = s

    # x: 该分支中的词汇数量最少越好
    # a: 词平均频率最大
    # b: 每个词长度标准差最小
    # c: counter of unidentified words

    # d: 符合语法结构项：如两个连续的动词减分，数词后面跟量词加分
    maxIndex

  # find best matching phrase
  filterWord = (words, prevParam, text) ->
    hasOne = (obj, names...) ->
      return false unless obj?
      for n in names
        return true if obj[n]?
      false

    wordPos = groupByPos words, text
    # get all combinations of words
    chunks = getChunks wordPos, 0, text
    # evaluation table
    scores = []

    # x: 该分支中的词汇数量最少越好
    # a: 词平均频率最大
    # b: 每个词长度标准差最小
    # c: counter of unidentified words
    # d: 符合语法结构项：如两个连续的动词减分，数词后面跟量词加分

    for key, chunk of chunks
      i = Number key; chunkLength = chunk.length
      scores[i] = { x: chunkLength, a:0, b:0, c:0, d:0 }
      avgLengthOfWord = text.length / chunkLength
      hasVerb = false

      if prevParam?
        prevWord = { w: prevParam.w, curr: prevParam.curr, freq: prevParam.freq }
      else
        prevWord = null
      prevProps = null
      for j, word of chunk
        indexInChunk = Number j
        unless byWord(word.w)?
          # count unidentified words
          scores[i].c++
        else
          word.props = byWord(word.w).props
          currProps = word.props
          scores[i].a += byWord(word.w).freq  # total frequency

          # checking for grammar structure
          if prevWord?
            if hasOne(prevProps, '数词') and (hasOne(currProps, '量词') or word.w in DATETIME)
              scores[i].d++
            if hasOne currProps, '动词'
              hasVerb = true
              # deduction while 2 verbs connected
              # scores[i].d-- if hasOne prevProps, '动词'
              # add while adj. + verb
              scores[i].d++ if hasOne prevProps, '形容词'

            # 如果是地区名、机构名或形容词，后面跟地区、机构、代词、名词等，则加分
            if (hasOne prevProps, '地名', '机构团体', '形容词') and
            (hasOne currProps, '地名', '机构团体', '代词', '名词', '其他专名')
              scores[i].d++
              # console.log '地区名、机构名', prevWord.w, prevProps, word.w, currProps

            # 如果是 方位词 + 数量词，则加分
            if (hasOne prevProps, '方位词') and (hasOne currProps, '数词', '数量词')
              scores[i].d++
              # console.log '方位词 + 数量词', prevWord.w, prevProps, word.w, currProps

            # 如果是 姓 + 名词 || 其他专名，则加分
            if (SURNAME[prevWord?.w]? or COMPOUND_SURNAME[prevWord?.w]?) and hasOne(currProps, '名词', '其他专名')
              scores[i].d += 2

            # detect next word in chunk
            nextWord = chunk[indexInChunk + 1]
            if nextWord?
              nextProps = byWord(nextWord.w)?.props
              # console.log '##########', word.w, nextWord.w, prevProps, currProps, nextProps #, eql(prevProps, nextProps)
              # 如果是连词，前后两个词词性相同则加分
              scores[i].d++ if (hasOne currProps, '连词') and eql(prevProps, nextProps)
              # 如果当前是“的” + 名词，则加分
              scores[i].d += 1.5 if word.w in ['的', '之'] and
                (hasOne nextProps, '名词', '人名', '地名', '机构团体', '其他专名')

        # 标准差
        scores[i].b += Math.pow avgLengthOfWord - word.w.length, 2
        prevWord = word
        prevProps = prevWord.props

      #如果句子中没有动词
      scores[i].d -= 0.5 if not hasVerb
      scores[i].a = scores[i].a / chunkLength
      scores[i].b = scores[i].b / chunkLength

    # 计算排名
    top = getTops scores, chunks
    currChunk = chunks[top]
    optimizer currChunk

    # dateTimeOptimizer ret

    # remove unidentified words
    # currChunk
    # (word for word in currChunk when byWord(word.w)?)

  matchWord = (text, curr, prevWord) ->
    ret = []

    repeatedCharMatched = text.match repetedReg
    while repeatedCharMatched?
      index = repeatedCharMatched.index
      len = repeatedCharMatched[0].length
      text = text[0...index] + repeatedCharMatched[1] + new Array(len-1).join(' ') + repeatedCharMatched[1] + text[index + len..]
      repeatedCharMatched = text.match repetedReg

    # match word by length with current dictionary
    if dict?
      i = curr
      while (i < text.length)
        for len, wordList of dict.byLen
          w = text.substr i, Number(len)
          ret.push { w: w, curr: i, freq: wordList[w].freq} if wordList[w]?
        i++

    # match word by length with system dictionary
    i = curr
    while (i < text.length)
      for len, wordList of sysDict.byLen
        w = text.substr i, Number(len)
        ret.push { w: w, curr: i, freq: wordList[w].freq} if wordList[w]?
      i++

    filterWord ret, prevWord, text

# split text by chinese dictionary

  tokenize = (word, prevWord) ->

    makeValue = (w, start, props) ->
      value = {w, start}
      value.props = props if props? and Object.keys(props).length > 0
      value

    # matchWord word.w, word.start, prevWord
    result = []
    temp = matchWord word.w, 0, prevWord
    # no result here
    if temp.length is 0
      result.push word
    else
      # 分离出已识别的单词
      {start, props} = word; lastPos = 0
      for t in temp
        if t.curr > lastPos
          result.push makeValue(word.w[lastPos...t.curr], start + lastPos)
        result.push makeValue(t.w, start + t.curr, extend(props, t.props))
        lastPos = t.curr + t.w.length

      lastWord = temp[temp.length - 1]; restPos = lastWord.curr + lastWord.w.length
      if restPos < word.w.length
        result.push makeValue(word.w.slice(restPos), start + restPos, props)
    result

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->
    next ?= noop
    result = []
    for i in [0...words.length]
      word = words[i]
      prevWord = words[i-1]
      # if findOne word.props, options.skipProps
      if word.props?
        result.push word
      else
        result = result.concat tokenize(word, prevWord)
    next null, result
  { name, fn }