var seg, utils;

utils = require('./utils');

seg = module.exports = {};

seg.use = function(fn) {
  this.stack.push({
    handle: fn
  });
  return this;
};

seg.handle = function(text, out) {
  var index, next, stack;
  stack = this.stack;
  index = 0;
  next = function(err, words) {
    var e, layer;
    layer = stack[index++];
    if (layer == null) {
      if (out != null) {
        out(null, words);
      }
      return;
    }
    try {
      return layer.handle(words, function(err, newWords) {
        if (err != null) {
          if (out != null) {
            return out(err, newWords);
          }
        } else {
          return next(null, newWords);
        }
      });
    } catch (_error) {
      e = _error;
      return next(e);
    }
  };
  return next(null, [
    {
      w: text,
      start: 0
    }
  ]);
};
