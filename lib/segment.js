var Segment, basename, exports, fs, middleware, path, proto, utils;

proto = require('./proto');

utils = require('./utils');

fs = require('fs');

path = require('path');

basename = path.basename;

Segment = (function() {
  function Segment() {
    utils.merge(this, proto);
    this.utils = utils;
    this.stack = [];
  }

  return Segment;

})();

exports = module.exports = Segment;

exports.proto = proto;

exports.middleware = middleware = {};

fs.readdirSync(__dirname + '/middleware').forEach(function(filename) {
  var load, name;
  if (!/\.js$/.test(filename)) {
    return;
  }
  if (fs.statSync(__dirname + '/middleware/' + filename).isFile()) {
    name = basename(filename, '.js');
    load = require('./middleware/' + name);
    exports[name] = load;
    return middleware[name] = load;
  }
});
