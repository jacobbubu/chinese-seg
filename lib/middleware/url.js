var urlPattern,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

urlPattern = /(?:http|https|ftp|sftp|git|ssh):(?:\/\/)(?:[-;:&=\+\$,\w]+@)?(?:(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|(?:['\!\(\)\*\-\w]*\.)*(?:['\!\(\)\*\-\w]*\.)(?:com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2})(?:\:[0-9]{1,5})?)/ig;

module.exports = function(options) {
  var extend, findOne, findURL, fn, name, noop, path, unique, _ref, _ref1;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, findOne = _ref.findOne, unique = _ref.unique;
  options = extend({
    removeToken: false,
    propName: 'url'
  }, options);
  options.skipProps = unique([options.propName].concat((_ref1 = options.skipProps) != null ? _ref1 : []));
  findURL = function(word) {
    var index, matched, result, start, tail, tailAt, text, urlHost, value, _i, _len, _ref2;
    tailAt = function(text, start) {
      var char, index, prevChar, puncs, reachTail, _i, _ref2;
      puncs = ['.', ',', ';', '!', '<', '>', '(', ')'];
      reachTail = function(ch) {
        return /\s|[\u4e00-\u9FFF]/.test(ch);
      };
      for (index = _i = start, _ref2 = text.length; start <= _ref2 ? _i < _ref2 : _i > _ref2; index = start <= _ref2 ? ++_i : --_i) {
        char = text.charAt(index);
        if (reachTail(char)) {
          break;
        }
      }
      if (index > 0) {
        prevChar = text.charAt(index - 1);
        if (__indexOf.call(puncs, prevChar) >= 0) {
          index -= 1;
        }
      }
      return index;
    };
    result = [];
    matched = word.w.match(urlPattern);
    if (matched != null) {
      start = word.start;
      text = word.w;
      for (_i = 0, _len = matched.length; _i < _len; _i++) {
        urlHost = matched[_i];
        index = text.indexOf(urlHost);
        tail = tailAt(text, index);
        if (index > 0) {
          value = {
            w: text.slice(0, index),
            start: start
          };
          if (word.props != null) {
            value.props = word.props;
          }
          result.push(value);
        }
        value = {
          w: text.slice(index, tail),
          start: start + index,
          props: (_ref2 = word.props) != null ? _ref2 : {}
        };
        value.props[options.propName] = 1;
        result.push(value);
        text = text.slice(tail);
        start += tail;
      }
      if (start < word.w.length) {
        value = {
          w: text,
          start: start
        };
        if (word.props != null) {
          value.props = word.props;
        }
        result.push(value);
      }
    } else {
      result.push(word);
    }
    return result;
  };
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    var result, word, _i, _len;
    if (next == null) {
      next = noop;
    }
    result = [];
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      if (findOne(word.props, options.skipProps)) {
        result.push(word);
      } else {
        result = result.concat(findURL(word));
      }
    }
    return next(null, result);
  };
  return {
    name: name,
    fn: fn
  };
};
