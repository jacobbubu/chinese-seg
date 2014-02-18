var seg, utils;

utils = require('./utils');

seg = module.exports = {};

seg.use = function(plugin) {
  this.stack.push(plugin);
  return this;
};

seg.handle = function(text, out) {
  var index, next, self, stack;
  stack = this.stack;
  index = 0;
  self = this;
  next = function(err, words) {
    var layer;
    layer = stack[index++];
    if (layer == null) {
      if (out != null) {
        out(null, words);
      }
      return;
    }
    return layer.fn.call(self, words, function(err, newWords) {
      if (err != null) {
        return next(err);
      } else {
        return next(null, newWords);
      }
    });
  };
  return next(null, [
    {
      w: text,
      start: 0
    }
  ]);
};
