var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function(options) {
  var hanzenkaku, isToken, utils;
  hanzenkaku = require('hanzenkaku').HanZenKaku;
  utils = require('../utils');
  options = options != null ? options : {};
  isToken = function(text, index) {
    var code, extWesternChars, halfChar;
    extWesternChars = [8361];
    halfChar = text.charAt(index).toHalfwidth().toHalfwidthSpace();
    code = halfChar.charCodeAt();
    return code <= 255 || __indexOf.call(extWesternChars, code) >= 0;
  };
  return function(words, next) {
    var result, word, _i, _len;
    result = [];
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      if (word.props != null) {
        result.push(word);
      } else {
        result = result.concat(utils.splitWord(word, isToken, 'western'));
      }
    }
    return next(null, result);
  };
};
