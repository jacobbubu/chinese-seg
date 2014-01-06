exports.merge = function(a, b) {
  var key, value;
  if ((a != null) && (b != null)) {
    for (key in b) {
      value = b[key];
      a[key] = value;
    }
  }
  return a;
};

exports.splitWord = function(word, isToken, props, ignoreMatched) {
  var found, index, lastPos, result, start, text, value, _i, _ref;
  if (ignoreMatched == null) {
    ignoreMatched = false;
  }
  result = [];
  text = word.w;
  start = word.start;
  found = false;
  lastPos = 0;
  for (index = _i = 0, _ref = text.length; 0 <= _ref ? _i < _ref : _i > _ref; index = 0 <= _ref ? ++_i : --_i) {
    if (isToken(text, index)) {
      if (!found) {
        if (index > start) {
          result.push({
            w: text.slice(lastPos, index),
            start: start + lastPos
          });
          lastPos = index;
        }
        found = true;
      }
    } else {
      if (found) {
        if (index > lastPos && !ignoreMatched) {
          value = {
            w: text.slice(lastPos, index),
            start: start + lastPos,
            props: {}
          };
          value.props[props] = 1;
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
      value.props = {};
      value.props[props] = 1;
      if (!ignoreMatched) {
        result.push(value);
      }
    } else {
      result.push(value);
    }
  }
  return result;
};
