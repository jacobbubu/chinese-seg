module.exports = function(options) {
  var DATETIME, extend, fn, name, noop, path, _ref;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend;
  options = extend({}, options);
  DATETIME = (function() {
    var d, result, _DATETIME, _i, _len;
    _DATETIME = ['世纪', '年', '年份', '年度', '月', '月份', '月度', '日', '号', '时', '点', '点钟', '分', '分钟', '秒', '毫秒'];
    result = {};
    for (_i = 0, _len = _DATETIME.length; _i < _len; _i++) {
      d = _DATETIME[_i];
      result[d] = d.length;
    }
    return result;
  })();
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    var i, isNumeral, len, newWord, result, value, w1, w2, word1, word2;
    isNumeral = function(word) {
      if (word.props == null) {
        return false;
      }
      if (word.props['数词'] != null) {
        return true;
      }
      if ((word.props['western.number'] != null) && (word.props['western.number.fraction'] == null)) {
        return true;
      } else {
        return false;
      }
    };
    if (next == null) {
      next = noop;
    }
    result = [];
    i = 0;
    while (i < words.length) {
      word1 = words[i];
      word2 = words[i + 1];
      if (isNumeral(word1)) {
        if ((word2 != null) && (DATETIME[word2.w] != null)) {
          newWord = word1.w + word2.w;
          len = 2;
          while (true) {
            w1 = words[i + len];
            w2 = words[i + len + 1];
            if ((w1 != null) && isNumeral(w1) && (w2 != null) && (DATETIME[w2.w] != null)) {
              len += 2;
              newWord = newWord + w1.w + w2.w;
            } else {
              break;
            }
          }
          value = {
            w: newWord,
            start: word1.start
          };
          value.props = {};
          value.props['时间词'] = 1;
          result.push(value);
          i += len;
          continue;
        }
      }
      result.push(word1);
      i++;
    }
    return next(null, result);
  };
  return {
    name: name,
    fn: fn
  };
};
