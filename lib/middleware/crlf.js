var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function(options) {
  var CRLF, extend, fn, isToken, name, noop, path, tokenizeSync, unique, _ref;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, unique = _ref.unique, tokenizeSync = _ref.tokenizeSync;
  options = extend({
    removeToken: true,
    propName: 'crlf'
  }, options);
  CRLF = ['\r', '\n'];
  isToken = function(text, index) {
    var _ref1;
    return _ref1 = text.charAt(index), __indexOf.call(CRLF, _ref1) >= 0;
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
