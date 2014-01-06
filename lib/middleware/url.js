var findURL, urlPattern,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

urlPattern = /(?:http|https|ftp|sftp|git|ssh):(?:\/\/)(?:[-;:&=\+\$,\w]+@)?(?:(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|(?:['\!\(\)\*\-\w]*\.)*(?:['\!\(\)\*\-\w]*\.)(?:com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2})(?:\:[0-9]{1,5})?)/ig;

module.exports = function(options) {
  options = options != null ? options : {};
  return function(words, next) {
    var result, word, _i, _len, _ref;
    result = [];
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      if (((_ref = word.props) != null ? _ref.url : void 0) != null) {
        result.push(word);
      } else {
        result = result.concat(findURL(word));
      }
    }
    return next(null, result);
  };
};

findURL = function(word) {
  var index, matched, result, start, tail, tailAt, text, urlHost, _i, _len;
  tailAt = function(text, start) {
    var char, index, prevChar, puncs, reachTail, _i, _ref;
    puncs = ['.', ',', ';', '!', '<', '>', '(', ')'];
    reachTail = function(ch) {
      return /\s|[\u4e00-\u9FFF]/.test(ch);
    };
    for (index = _i = start, _ref = text.length; start <= _ref ? _i < _ref : _i > _ref; index = start <= _ref ? ++_i : --_i) {
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
        result.push({
          w: text.slice(0, index),
          start: start
        });
      }
      result.push({
        w: text.slice(index, tail),
        start: start + index,
        props: {
          'url': 1
        }
      });
      text = text.slice(tail);
      start += tail;
    }
    if (start < word.w.length) {
      result.push({
        w: text,
        start: start
      });
    }
  } else {
    result.push(word);
  }
  return result;
};
