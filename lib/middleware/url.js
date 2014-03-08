var urlPattern,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

urlPattern = (function() {
  var auth, domain, finalPart1, finalPart2, host1, host2, ip, ipPart, localhost, port, protocol;
  protocol = "(?:http|https|ftp|sftp|git|ssh):(?://)";
  auth = "(?:[-;:&=\\+\\$,\\w]+@)";
  ipPart = "(?:25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])";
  ip = ipPart + '\\.' + ipPart + '\\.' + ipPart + '\\.' + ipPart;
  localhost = "localhost";
  host1 = "(?:['\\!\\*\\-\\w]*\\.)+";
  host2 = "(?:['\\!\\*\\-\\w]*\\.){2,}";
  domain = "(?:com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2})";
  port = "(?:\\:[0-9]{1,5})";
  finalPart1 = protocol + auth + '?' + '(' + ip + '|' + localhost + '|' + host1 + domain + ')' + port + '?';
  finalPart2 = '(' + ip + '|' + localhost + '|' + host2 + domain + ')' + port + '?';
  return new RegExp("(" + finalPart1 + ")|(" + finalPart2 + ")", 'gi');
})();

module.exports = function(options) {
  var chnRange, extend, fn, matchSync, name, noop, path, puncs, tailAt, tailReg, _ref;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, matchSync = _ref.matchSync, chnRange = _ref.chnRange;
  options = extend({
    propName: 'url'
  }, options);
  tailReg = new RegExp("\\s|[" + chnRange + "]");
  puncs = (function() {
    var chinese, latin;
    latin = '.?!,:;(){}[]"\'';
    chinese = '。。？！，、；：（）［］〔〕【】﹃﹄﹁﹂《》〈〉…“”‘’„‚';
    return (latin + chinese).split('');
  })();
  tailAt = function(text, start) {
    var char, index, prevChar, reachTail, _i, _ref1;
    reachTail = function(ch) {
      return tailReg.test(ch);
    };
    for (index = _i = start, _ref1 = text.length; start <= _ref1 ? _i < _ref1 : _i > _ref1; index = start <= _ref1 ? ++_i : --_i) {
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
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    if (next == null) {
      next = noop;
    }
    options.pattern = urlPattern;
    options.tailAt = tailAt;
    return next(null, matchSync(words, options));
  };
  return {
    name: name,
    fn: fn
  };
};
