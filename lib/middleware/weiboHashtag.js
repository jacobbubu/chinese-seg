module.exports = function(options) {
  var chnRange, extend, fn, hashtagPattern, matchSync, name, noop, path, _ref;
  _ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, matchSync = _ref.matchSync, chnRange = _ref.chnRange;
  hashtagPattern = (function() {
    var hashSigns, validHashtag;
    hashSigns = "[#＃]";
    validHashtag = ("(" + hashSigns + ")") + ("(?:[\x20-\x7e\xa0-\xff" + chnRange + "]{1,138}?)") + ("(" + hashSigns + ")");
    return new RegExp(validHashtag, 'gi');
  })();
  options = extend({
    propName: 'weiboHashtag'
  }, options);
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    var result;
    if (next == null) {
      next = noop;
    }
    options.pattern = hashtagPattern;
    result = matchSync(words, options);
    return next(null, result);
  };
  return {
    name: name,
    fn: fn
  };
};
