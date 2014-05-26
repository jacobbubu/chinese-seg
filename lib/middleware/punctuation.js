var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function(options) {
  var extend, fn, hanzenkaku, isToken, latinAlphaPattern, name, noop, path, stopwords, tokenizeSync, unique, _ref, _stopwords;
  hanzenkaku = require('hanzenkaku').HanZenKaku;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, unique = _ref.unique, tokenizeSync = _ref.tokenizeSync;
  options = extend({
    removeToken: false,
    propName: 'punc'
  }, options);
  options.skipProps = unique([options.propName].concat(options.skipProps));
  _stopwords = (function() {
    var chinese, latin;
    latin = '.?!,:;(){}[]"\'';
    chinese = '。。？！，、；：（）［］〔〕【】﹃﹄﹁﹂《》〈〉…“”‘’„‚';
    return latin + chinese;
  })();
  stopwords = (function() {
    var result;
    result = {};
    _stopwords.split('').forEach(function(ch) {
      return result[ch] = true;
    });
    return result;
  })();
  latinAlphaPattern = /[a-zA-Z\xC0-\xD6\xD8-\xF6-\xFE]/;
  isToken = function(text, index) {
    var halfChar, nextChar, oriChar, prevChar, result, _i, _j, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _results, _results1;
    oriChar = text.charAt(index);
    halfChar = oriChar.toHalfwidth().toHalfwidthSpace();
    prevChar = (text.charAt(index - 1)).toHalfwidth().toHalfwidthSpace();
    nextChar = (text.charAt(index + 1)).toHalfwidth().toHalfwidthSpace();
    result = false;
    switch (halfChar) {
      case "'":
        result = !(latinAlphaPattern.test(prevChar) && latinAlphaPattern.test(nextChar));
        break;
      case '.':
        result = !((_ref1 = nextChar.charCodeAt(), __indexOf.call((function() {
          _results = [];
          for (var _i = _ref2 = '0'.charCodeAt(), _ref3 = '9'.charCodeAt(); _ref2 <= _ref3 ? _i <= _ref3 : _i >= _ref3; _ref2 <= _ref3 ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this), _ref1) >= 0) && (_ref4 = prevChar.charCodeAt(), __indexOf.call((function() {
          _results1 = [];
          for (var _j = _ref5 = '0'.charCodeAt(), _ref6 = '9'.charCodeAt(); _ref5 <= _ref6 ? _j <= _ref6 : _j >= _ref6; _ref5 <= _ref6 ? _j++ : _j--){ _results1.push(_j); }
          return _results1;
        }).apply(this), _ref4) >= 0));
        break;
      default:
        result = stopwords[oriChar] != null;
    }
    return result;
  };
  options.isToken = isToken;
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    var result;
    if (next == null) {
      next = noop;
    }
    result = tokenizeSync(words, options);
    return next(null, result);
  };
  return {
    name: name,
    fn: fn
  };
};
