var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function(options) {
  var extWesternChars, extend, findMatchSync, fn, fullToHalf, hanzenkaku, isToken, name, newProps, noop, numberIdentify, path, tokenizeSync, unique, versionIdentify, _ref;
  hanzenkaku = require('hanzenkaku').HanZenKaku;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, unique = _ref.unique, tokenizeSync = _ref.tokenizeSync, findMatchSync = _ref.findMatchSync, newProps = _ref.newProps;
  options = extend({
    removeToken: false,
    propName: 'western'
  }, options);
  extWesternChars = [8361];
  isToken = function(text, index) {
    var code, halfChar;
    halfChar = text.charAt(index).toHalfwidth().toHalfwidthSpace();
    code = halfChar.charCodeAt();
    return code <= 255 || __indexOf.call(extWesternChars, code) >= 0;
  };
  options.isToken = isToken;
  fullToHalf = function(words) {
    var result;
    return result = words.map(function(row) {
      var _ref1;
      if (((_ref1 = row.props) != null ? _ref1[options.propName] : void 0) != null) {
        row.w = row.w.toHalfwidth().toHalfwidthSpace();
        return row;
      } else {
        return row;
      }
    });
  };
  versionIdentify = function(words) {
    var opt, result;
    opt = {
      pattern: /\d+(\.\d+){2,3}/gi,
      propName: 'western.version'
    };
    result = [];
    words.forEach(function(word) {
      var _ref1;
      if (((_ref1 = word.props) != null ? _ref1['western'] : void 0) == null) {
        return result.push(word);
      } else {
        return result = result.concat(findMatchSync(word, opt));
      }
    });
    return result;
  };
  numberIdentify = function(words) {
    var opt, result;
    opt = {
      pattern: /((\d+([\,]\d{3})*)(\.\d+)?)|(\.\d+)/gi,
      propName: 'western.number'
    };
    result = [];
    words.forEach(function(word) {
      var res, _ref1, _ref2, _ref3;
      if (((_ref1 = word.props) != null ? _ref1['western'] : void 0) == null) {
        return result.push(word);
      } else if ((((_ref2 = word.props) != null ? _ref2['western.version'] : void 0) != null) || (((_ref3 = word.props) != null ? _ref3['western.number'] : void 0) != null)) {
        return result.push(word);
      } else {
        res = findMatchSync(word, opt).map(function(row) {
          var _ref4;
          if ((((_ref4 = row.props) != null ? _ref4['western.number'] : void 0) != null) && row.w.indexOf('.') >= 0) {
            row.props['western.number.fraction'] = 1;
          }
          return row;
        });
        return result = result.concat(res);
      }
    });
    return result;
  };
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    var result;
    if (next == null) {
      next = noop;
    }
    result = versionIdentify(fullToHalf(tokenizeSync(words, options)));
    result = numberIdentify(result);
    return next(null, result);
  };
  return {
    name: name,
    fn: fn
  };
};
