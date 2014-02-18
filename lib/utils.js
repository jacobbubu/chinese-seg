var eql, extend, findOne, merge, noop, path, splitWordSync, tokenizeSync, unique;

noop = exports.noop = function() {};

extend = exports.extend = require('xtend');

path = exports.path = require('path');

eql = exports.eql = require('deep-equal');

merge = exports.merge = function(a, b) {
  var key, value;
  if ((a != null) && (b != null)) {
    for (key in b) {
      value = b[key];
      a[key] = value;
    }
  }
  return a;
};

unique = exports.unique = function(arr) {
  var key, output, value, _i, _ref, _results;
  output = {};
  for (key = _i = 0, _ref = arr.length; 0 <= _ref ? _i < _ref : _i > _ref; key = 0 <= _ref ? ++_i : --_i) {
    output[arr[key]] = arr[key];
  }
  _results = [];
  for (key in output) {
    value = output[key];
    _results.push(value);
  }
  return _results;
};

findOne = exports.findOne = function(props, skipProps) {
  var propName, _i, _len;
  if (props != null) {
    for (_i = 0, _len = skipProps.length; _i < _len; _i++) {
      propName = skipProps[_i];
      if (props[propName] != null) {
        return true;
      }
    }
  }
  return false;
};

splitWordSync = exports.splitWordSync = function(word, options) {
  var found, index, isToken, lastPos, propName, removeToken, result, start, text, value, _i, _ref;
  isToken = options.isToken, propName = options.propName, removeToken = options.removeToken;
  result = [];
  text = word.w;
  start = word.start;
  found = false;
  lastPos = 0;
  for (index = _i = 0, _ref = text.length; 0 <= _ref ? _i < _ref : _i > _ref; index = 0 <= _ref ? ++_i : --_i) {
    if (isToken(text, index)) {
      if (!found) {
        if (index > lastPos) {
          value = {
            w: text.slice(lastPos, index),
            start: start + lastPos
          };
          if (word.props != null) {
            value.props = word.props;
          }
          result.push(value);
          lastPos = index;
        }
        found = true;
      }
    } else {
      if (found) {
        if (index > lastPos && !removeToken) {
          value = {
            w: text.slice(lastPos, index),
            start: start + lastPos,
            props: extend({}, word.props)
          };
          value.props[propName] = 1;
          result.push(value);
        }
        lastPos = index;
        found = false;
      }
    }
  }
  if (lastPos < text.length) {
    value = {
      w: text.slice(lastPos),
      start: start + lastPos
    };
    if (found) {
      if (!removeToken) {
        value.props = extend({}, word.props);
        value.props[propName] = 1;
        result.push(value);
      }
    } else {
      result.push(value);
    }
  }
  return result;
};

tokenizeSync = exports.tokenizeSync = function(words, options) {
  var result, word, _i, _len, _ref;
  if (options == null) {
    throw new Error('options required');
  }
  if (options.isToken == null) {
    throw new Error('options.isToken required');
  }
  if (options.propName == null) {
    throw new Error('options.propName required');
  }
  options.skipProps = unique([options.propName].concat((_ref = options.skipProps) != null ? _ref : []));
  if (options.removeToken == null) {
    options.removeToken = false;
  }
  result = [];
  for (_i = 0, _len = words.length; _i < _len; _i++) {
    word = words[_i];
    if (findOne(word.props, options.skipProps)) {
      result.push(word);
    } else {
      result = result.concat(splitWordSync(word, options));
    }
  }
  return result;
};
