var chnRange, clone, eql, extend, findMatchSync, findOne, matchSync, merge, newProps, noop, path, splitWordSync, tokenizeSync, unique;

noop = exports.noop = function() {};

extend = exports.extend = require('xtend');

path = exports.path = require('path');

eql = exports.eql = require('deep-equal');

chnRange = exports.chnRange = '\\u2E80-\\uFE4F';

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

clone = function(obj) {
  var flags, key, newInstance;
  if ((obj == null) || typeof obj !== 'object') {
    return obj;
  }
  if (obj instanceof Date) {
    return new Date(obj.getTime());
  }
  if (obj instanceof RegExp) {
    flags = '';
    if (obj.global != null) {
      flags += 'g';
    }
    if (obj.ignoreCase != null) {
      flags += 'i';
    }
    if (obj.multiline != null) {
      flags += 'm';
    }
    if (obj.sticky != null) {
      flags += 'y';
    }
    return new RegExp(obj.source, flags);
  }
  newInstance = new obj.constructor();
  for (key in obj) {
    newInstance[key] = clone(obj[key]);
  }
  return newInstance;
};

newProps = exports.newProps = function(a, propName) {
  var c;
  if (propName == null) {
    return a;
  }
  c = clone(a);
  if (c == null) {
    c = {};
  }
  c[propName] = 1;
  return c;
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
            props: newProps(word.props, propName)
          };
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
        if (propName != null) {
          value.props[propName] = 1;
        }
        result.push(value);
      }
    } else {
      result.push(value);
    }
  }
  return result;
};

tokenizeSync = exports.tokenizeSync = function(words, options) {
  var result, word, _i, _len;
  if (options == null) {
    throw new Error('options required');
  }
  if (options.isToken == null) {
    throw new Error('options.isToken required');
  }
  if (options.propName == null) {
    throw new Error('options.propName required');
  }
  if (options.removeToken == null) {
    options.removeToken = false;
  }
  result = [];
  for (_i = 0, _len = words.length; _i < _len; _i++) {
    word = words[_i];
    if (word.props != null) {
      result.push(word);
    } else {
      result = result.concat(splitWordSync(word, options));
    }
  }
  return result;
};

findMatchSync = exports.findMatchSync = function(word, options) {
  var allMatched, index, oneMatched, removeSplitter, result, start, tail, text, value, _i, _len, _ref;
  result = [];
  allMatched = word.w.match(options.pattern);
  removeSplitter = (_ref = options.removeSplitter) != null ? _ref : false;
  if (allMatched != null) {
    start = word.start;
    text = word.w;
    for (_i = 0, _len = allMatched.length; _i < _len; _i++) {
      oneMatched = allMatched[_i];
      index = text.indexOf(oneMatched);
      if (options.tailAt != null) {
        tail = options.tailAt(text, index);
      } else {
        tail = index + oneMatched.length;
      }
      if (!removeSplitter && index > 0) {
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
        props: newProps(word.props, options.propName)
      };
      result.push(value);
      text = text.slice(tail);
      start += tail;
    }
    if (!removeSplitter && start < word.w.length) {
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

matchSync = exports.matchSync = function(words, options) {
  var result, word, _i, _len;
  if (options == null) {
    throw new Error('options required');
  }
  if (options.pattern == null) {
    throw new Error('options.pattern required');
  }
  if (options.propName == null) {
    throw new Error('options.propName required');
  }
  result = [];
  for (_i = 0, _len = words.length; _i < _len; _i++) {
    word = words[_i];
    if (word.props != null) {
      result.push(word);
    } else {
      result = result.concat(findMatchSync(word, options));
    }
  }
  return result;
};
