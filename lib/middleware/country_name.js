module.exports = function(options) {
  var isToken, utils;
  utils = require('../utils');
  options = options != null ? options : {};
  isToken = function(text, index) {
    return false;
  };
  return function(words, next) {
    var result, word, _i, _len;
    result = [];
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      if (word.props != null) {
        result.push(word);
      } else {
        result = result.concat(utils.splitWord(word, isToken, 'country'));
      }
    }
    return next(null, result);
  };
};
