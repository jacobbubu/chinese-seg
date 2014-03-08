module.exports = function(options) {
  var chnRange, extend, fn, matchSync, mentionPattern, name, noop, path, _ref;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, matchSync = _ref.matchSync, chnRange = _ref.chnRange;
  mentionPattern = (function() {
    var atSigns, validMention;
    atSigns = "[@＠]";
    validMention = ("(" + atSigns + ")") + ("([a-zA-Z0-9_" + chnRange + "]{1,30})");
    return new RegExp(validMention, 'gi');
  })();
  options = extend({
    propName: 'weiboMention'
  }, options);
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    var result;
    if (next == null) {
      next = noop;
    }
    options.pattern = mentionPattern;
    result = matchSync(words, options);
    return next(null, result);
  };
  return {
    name: name,
    fn: fn
  };
};
