var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function(options) {
  var isToken, utils;
  utils = require('../utils');
  options = options != null ? options : {};
  isToken = function(text, index) {
    var CRLF, _ref;
    CRLF = ['\r', '\n'];
    return _ref = text.charAt(index), __indexOf.call(CRLF, _ref) >= 0;
  };
  return function(words, next) {
    var result, word, _i, _len;
    result = [];
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      result = result.concat(utils.splitWord(word, isToken, 'crlf', true));
    }
    return next(null, result);
  };
};
