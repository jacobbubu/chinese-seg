var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function(options) {
  var extWesternChars, extend, fn, hanzenkaku, isToken, name, noop, path, tokenizeSync, unique, _ref;
  hanzenkaku = require('hanzenkaku').HanZenKaku;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, unique = _ref.unique, tokenizeSync = _ref.tokenizeSync;
  options = extend({
    removeToken: false,
    propName: 'western',
    fullToHalf: false
  }, options);
  extWesternChars = [8361];
  isToken = function(text, index) {
    var code, halfChar;
    halfChar = text.charAt(index).toHalfwidth().toHalfwidthSpace();
    code = halfChar.charCodeAt();
    return code <= 255 || __indexOf.call(extWesternChars, code) >= 0;
  };
  options.isToken = isToken;
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    var result;
    if (next == null) {
      next = noop;
    }
    result = tokenizeSync(words, options);
    if (options.fullToHalf) {
      result = result.map(function(row) {
        var _ref1;
        if (((_ref1 = row.props) != null ? _ref1[options.propName] : void 0) != null) {
          row.w = row.w.toHalfwidth().toHalfwidthSpace();
          return row;
        } else {
          return row;
        }
      });
    }
    return next(null, result);
  };
  return {
    name: name,
    fn: fn
  };
};
