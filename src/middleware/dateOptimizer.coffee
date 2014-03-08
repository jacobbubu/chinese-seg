module.exports = (options) ->
  { noop, path, extend } = require '../utils'
  options = extend {}, options

  DATETIME = do ->
    _DATETIME = [
      '世纪', '年', '年份', '年度', '月', '月份', '月度', '日', '号',
      '时', '点', '点钟', '分', '分钟', '秒', '毫秒'
    ]
    result = {}
    result[d] = d.length for d in _DATETIME
    result

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->

    isNumeral = (word) ->
      return false if not word.props?
      return true if word.props['数词']?
      if word.props['western.number']? and (not word.props['western.number.fraction']?)
        true
      else
        false

    next ?= noop
    result = []; i = 0
    while i < words.length
      word1 = words[i]
      word2 = words[i + 1]

      # 日期时间组合   数字 + 日期单位，如 “2005年", "十二岁时"
      if isNumeral word1
        if word2? and DATETIME[word2.w]?
          newWord = word1.w + word2.w
          len = 2
          # 继续搜索后面连续的日期时间描述，必须符合  数字 + 日期单位， “2005年10月”
          while true
            w1 = words[i + len]
            w2 = words[i + len + 1]
            if isNumeral(w1) and w2? and DATETIME[w2.w]?
              len += 2
              newWord = newWord + w1.w + w2.w
            else
              break
          value = { w: newWord, start: word1.start }
          value.props = {}
          value.props['时间词'] = 1
          result.push value
          i += len
          continue
      result.push word1
      i++
    next null, result
  { name, fn }