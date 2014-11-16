var COMPOUND_SURNAME, FIRST_CHAR_IN_LASTNAME, SECOND_CHAR_IN_LASTNAME, SINGLE_LASTNAME, SURNAME, eql, extend, findOne, fs, loadDict, loadFolder, noop, path, sysDict, unique, _ref, _ref1,
  __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

_ref = require('../utils'), noop = _ref.noop, path = _ref.path, extend = _ref.extend, unique = _ref.unique, findOne = _ref.findOne, eql = _ref.eql;

_ref1 = require('../chn_names/consts'), SURNAME = _ref1.SURNAME, COMPOUND_SURNAME = _ref1.COMPOUND_SURNAME, FIRST_CHAR_IN_LASTNAME = _ref1.FIRST_CHAR_IN_LASTNAME, SECOND_CHAR_IN_LASTNAME = _ref1.SECOND_CHAR_IN_LASTNAME, SINGLE_LASTNAME = _ref1.SINGLE_LASTNAME;

sysDict = null;

loadDict = function(file, dict) {
  var data, lineNo, stats;
  stats = fs.statSync(file);
  if (stats.isSymbolicLink()) {
    file = fs.readlinkSync(file);
  }
  data = fs.readFileSync(file, {
    encoding: 'utf8'
  });
  lineNo = 0;
  data.split(/\r?\n/).forEach(function(jsonWord) {
    var e, key, len, oneWord, _base, _name;
    lineNo++;
    jsonWord = jsonWord.trim();
    if (jsonWord.length > 0) {
      try {
        oneWord = JSON.parse(jsonWord);
      } catch (_error) {
        e = _error;
        throw new Error(("parsing line #" + lineNo + " in file " + file + " errors - ") + e);
      }
      if (oneWord != null) {
        len = oneWord.word.length;
        if (len > 0) {
          key = oneWord.word.toLowerCase();
          dict.byWord[key] = {
            props: oneWord.props,
            freq: oneWord.freq
          };
          if ((_base = dict.byLen)[_name = '' + len] == null) {
            _base[_name] = {};
          }
          return dict.byLen['' + len][key] = dict.byWord[key];
        }
      }
    }
  });
  return dict;
};

loadFolder = function(folder, dict) {
  if (!fs.existsSync(folder)) {
    throw new Error("Dictionary path does not exist - " + folder);
  }
  fs.readdirSync(folder).forEach(function(file) {
    var ext, fullFilePath, stats;
    fullFilePath = path.join(folder, file);
    stats = fs.statSync(fullFilePath);
    if (stats.isDirectory()) {
      return dict = loadFolder(fullFilePath);
    } else if (stats.isFile()) {
      ext = path.extname(file);
      if (ext === '.txt') {
        return dict = loadDict(fullFilePath, dict);
      }
    } else {
      throw new Error(file + 'is a type of file I cannot read');
    }
  });
  return dict;
};

module.exports = function(options) {
  var DATETIME, byWord, dict, dictFiles, dictPath, filterWord, fn, getChunks, getTops, groupByPos, matchWord, name, optimizer, repetedReg, tokenize;
  options = extend({}, options);
  repetedReg = /([^\s])\1{2,}/;
  if (!sysDict) {
    dictPath = path.resolve(__dirname, '../../dict');
    sysDict = {
      byWord: {},
      byLen: {}
    };
    sysDict = loadFolder(dictPath, sysDict);
  }
  dict = null;
  if (options.files != null) {
    if (typeof options.files === 'string') {
      dictFiles = [options.files];
    } else {
      dictFiles = options.files;
    }
    if (Array.isArray(dictFiles)) {
      dict = {
        byWord: {},
        byLen: {}
      };
      dictFiles.forEach(function(file) {
        return dict = loadDict(file, dict);
      });
    } else {
      throw new TypeError('Unknown options.files type');
    }
  }
  byWord = function(word) {
    var key, result;
    key = word.toLowerCase();
    if (dict != null) {
      result = dict.byWord[key];
    }
    if (result == null) {
      result = sysDict.byWord[key];
    }
    return result;
  };
  DATETIME = (function() {
    var d, result, _DATETIME, _i, _len;
    _DATETIME = ['世纪', '年', '年份', '年度', '月', '月份', '月度', '日', '号', '时', '点', '点钟', '分', '分钟', '秒', '毫秒'];
    result = {};
    for (_i = 0, _len = _DATETIME.length; _i < _len; _i++) {
      d = _DATETIME[_i];
      result[d] = d.length;
    }
    return result;
  })();
  optimizer = function(words, first) {
    var i, isCompatible, j, newWord, props, result, value, w4w, word1, word2, word3, _i, _ref10, _ref11, _ref12, _ref13, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
    if (first == null) {
      first = true;
    }
    isCompatible = function(prop1, prop2) {
      var k;
      if ((prop1 != null) && (prop2 != null)) {
        for (k in prop1) {
          if (prop2[k] != null) {
            return true;
          }
        }
      }
      return false;
    };
    result = [];
    i = 0;
    while (i < words.length) {
      word1 = words[i];
      word2 = words[i + 1];
      if (word2 != null) {
        newWord = word1.w + word2.w;
        if (isCompatible(word1.props, word2.props) && (byWord(newWord) != null)) {
          props = byWord(newWord).props;
          value = {
            w: newWord,
            curr: word1.curr
          };
          if (props != null) {
            value.props = props;
          }
          result.push(value);
          i += 2;
          continue;
        }
        if ((((_ref2 = word1.props) != null ? _ref2['形容词'] : void 0) != null) && (((_ref3 = word2.props) != null ? _ref3['助词'] : void 0) != null)) {
          value = {
            w: newWord,
            curr: word1.curr
          };
          value.props = {};
          value.props['助词'] = 1;
          result.push(value);
          i += 2;
          continue;
        }
        if (((_ref4 = word1.props) != null ? _ref4['数词'] : void 0) != null) {
          if ((((_ref5 = word2.props) != null ? _ref5['数词'] : void 0) != null) || ((_ref6 = word2.w) === '%' || _ref6 === '％')) {
            value = {
              w: newWord,
              curr: word1.curr
            };
            value.props = {};
            value.props['数词'] = 1;
            result.push(value);
            i += 2;
            continue;
          }
          if (((_ref7 = word2.props) != null ? _ref7['量词'] : void 0) != null) {
            value = {
              w: newWord,
              curr: word1.curr
            };
            value.props = {};
            value.props['数量词'] = 1;
            result.push(value);
            i += 2;
            continue;
          }
          word3 = words[i + 2];
          if (word3 != null) {
            if ((((_ref8 = word3.props) != null ? _ref8['数词'] : void 0) != null) && ((_ref9 = word2.w) === '.' || _ref9 === '点' || _ref9 === '分之')) {
              value = {
                w: newWord + word3.w,
                curr: word1.curr
              };
              value.props = {};
              value.props['数词'] = 1;
              result.push(value);
              i += 3;
              continue;
            }
          }
        }
        if ((((_ref10 = word1.props) != null ? _ref10['数量词'] : void 0) != null) && (word1.w.slice(-1) === '点') && (((_ref11 = word2.props) != null ? _ref11['数词'] : void 0) != null)) {
          w4w = '';
          for (j = _i = _ref12 = i + 2, _ref13 = words.length; _ref12 <= _ref13 ? _i < _ref13 : _i > _ref13; j = _ref12 <= _ref13 ? ++_i : --_i) {
            word3 = words[j];
            if ((word3 != null ? word3['数词'] : void 0) != null) {
              w4w += word3.w;
            } else {
              break;
            }
          }
          value = {
            w: newWord + w4w,
            curr: word1.curr
          };
          value.props = {};
          value.props['数量词'] = 1;
          result.push(value);
          i += j - i;
          continue;
        }
        result.push(word1);
      } else {
        result.push(word1);
      }
      i++;
    }
    if (first) {
      return optimizer(result, false);
    } else {
      return result;
    }
  };
  getChunks = function(wordpos, pos, text) {
    var chunk, chunks, len, nextCurr, ret, word, words, _i, _j, _len, _len1;
    ret = [];
    len = text.length;
    while ((wordpos[pos] == null) && pos < len) {
      pos++;
    }
    words = wordpos[pos];
    if (words == null) {
      return ret;
    }
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      nextCurr = word.curr + word.w.length;
      if (nextCurr >= len) {
        ret.push([word]);
      } else {
        chunks = getChunks(wordpos, nextCurr, text);
        for (_j = 0, _len1 = chunks.length; _j < _len1; _j++) {
          chunk = chunks[_j];
          ret.push([word].concat(chunk));
        }
      }
    }
    return ret;
  };
  groupByPos = function(words, text) {
    var ch, i, word, wordpos, _i, _j, _len, _name, _ref2;
    wordpos = {};
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      if (wordpos[_name = word.curr] == null) {
        wordpos[_name] = [];
      }
      wordpos[word.curr].push(word);
    }
    for (i = _j = 0, _ref2 = text.length; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; i = 0 <= _ref2 ? ++_j : --_j) {
      ch = text.charAt(i);
      if (!(wordpos[i] || ch === ' ')) {
        wordpos[i] = [
          {
            w: ch,
            curr: i,
            freq: 0
          }
        ];
      }
    }
    return wordpos;
  };
  getTops = function(scores, chunks) {
    var a, b, i, index, maxIndex, maxs, s, top, tops, _i, _j, _ref2, _ref3;
    top = {
      x: scores[0].x,
      a: scores[0].a,
      b: scores[0].b,
      c: scores[0].c,
      d: scores[0].d
    };
    for (i = _i = 1, _ref2 = scores.length; 1 <= _ref2 ? _i < _ref2 : _i > _ref2; i = 1 <= _ref2 ? ++_i : --_i) {
      s = scores[i];
      if (s.a > top.a) {
        top.a = s.a;
      }
      if (s.b < top.b) {
        top.b = s.b;
      }
      if (s.c > top.c) {
        top.c = s.c;
      }
      if (s.d < top.d) {
        top.d = s.d;
      }
      if (s.x > top.x) {
        top.x = s.x;
      }
    }
    tops = [];
    for (index in scores) {
      s = scores[index];
      i = Number(index);
      tops[i] = 0;
      tops[i] += (top.x - s.x) * 1.5;
      if (s.a >= top.a) {
        tops[i] += 1;
      }
      if (s.b <= top.b) {
        tops[i] += 1;
      }
      tops[i] += top.c - s.c;
      tops[i] += (s.d < 0 ? top.d + s.d : s.d - top.d) * 1;
    }
    maxs = tops[0];
    maxIndex = 0;
    for (i = _j = 1, _ref3 = tops.length; 1 <= _ref3 ? _j < _ref3 : _j > _ref3; i = 1 <= _ref3 ? ++_j : --_j) {
      s = tops[i];
      if (s > maxs) {
        maxIndex = i;
        maxs = s;
      } else if (s === maxs) {
        a = 0;
        b = 0;
        if (scores[i].c < scores[maxIndex].c) {
          a++;
        } else {
          b++;
        }
        if (scores[i].a > scores[maxIndex].a) {
          a++;
        } else {
          b++;
        }
        if (scores[i].x < scores[maxIndex].x) {
          a++;
        } else {
          b++;
        }
        if (a > b) {
          maxIndex = i;
          maxs = s;
        }
      }
    }
    return maxIndex;
  };
  filterWord = function(words, prevParam, text) {
    var avgLengthOfWord, chunk, chunkLength, chunks, currChunk, currProps, hasOne, hasVerb, i, indexInChunk, j, key, nextProps, nextWord, prevProps, prevWord, scores, top, word, wordPos, _ref2, _ref3, _ref4;
    hasOne = function() {
      var n, names, obj, _i, _len;
      obj = arguments[0], names = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (obj == null) {
        return false;
      }
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        n = names[_i];
        if (obj[n] != null) {
          return true;
        }
      }
      return false;
    };
    wordPos = groupByPos(words, text);
    chunks = getChunks(wordPos, 0, text);
    scores = [];
    for (key in chunks) {
      chunk = chunks[key];
      i = Number(key);
      chunkLength = chunk.length;
      scores[i] = {
        x: chunkLength,
        a: 0,
        b: 0,
        c: 0,
        d: 0
      };
      avgLengthOfWord = text.length / chunkLength;
      hasVerb = false;
      if (prevParam != null) {
        prevWord = {
          w: prevParam.w,
          curr: prevParam.curr,
          freq: prevParam.freq
        };
      } else {
        prevWord = null;
      }
      prevProps = null;
      for (j in chunk) {
        word = chunk[j];
        indexInChunk = Number(j);
        if (byWord(word.w) == null) {
          scores[i].c++;
        } else {
          word.props = byWord(word.w).props;
          currProps = word.props;
          scores[i].a += byWord(word.w).freq;
          if (prevWord != null) {
            if (hasOne(prevProps, '数词') && (hasOne(currProps, '量词') || (_ref2 = word.w, __indexOf.call(DATETIME, _ref2) >= 0))) {
              scores[i].d++;
            }
            if (hasOne(currProps, '动词')) {
              hasVerb = true;
              if (hasOne(prevProps, '形容词')) {
                scores[i].d++;
              }
            }
            if ((hasOne(prevProps, '地名', '机构团体', '形容词')) && (hasOne(currProps, '地名', '机构团体', '代词', '名词', '其他专名'))) {
              scores[i].d++;
            }
            if ((hasOne(prevProps, '方位词')) && (hasOne(currProps, '数词', '数量词'))) {
              scores[i].d++;
            }
            if (((SURNAME[prevWord != null ? prevWord.w : void 0] != null) || (COMPOUND_SURNAME[prevWord != null ? prevWord.w : void 0] != null)) && hasOne(currProps, '名词', '其他专名')) {
              scores[i].d += 2;
            }
            nextWord = chunk[indexInChunk + 1];
            if (nextWord != null) {
              nextProps = (_ref3 = byWord(nextWord.w)) != null ? _ref3.props : void 0;
              if ((hasOne(currProps, '连词')) && eql(prevProps, nextProps)) {
                scores[i].d++;
              }
              if (((_ref4 = word.w) === '的' || _ref4 === '之') && (hasOne(nextProps, '名词', '人名', '地名', '机构团体', '其他专名'))) {
                scores[i].d += 1.5;
              }
            }
          }
        }
        scores[i].b += Math.pow(avgLengthOfWord - word.w.length, 2);
        prevWord = word;
        prevProps = prevWord.props;
      }
      if (!hasVerb) {
        scores[i].d -= 0.5;
      }
      scores[i].a = scores[i].a / chunkLength;
      scores[i].b = scores[i].b / chunkLength;
    }
    top = getTops(scores, chunks);
    currChunk = chunks[top];
    return optimizer(currChunk);
  };
  matchWord = function(text, curr, prevWord) {
    var i, index, len, repeatedCharMatched, ret, w, wordList, _ref2, _ref3;
    ret = [];
    repeatedCharMatched = text.match(repetedReg);
    while (repeatedCharMatched != null) {
      index = repeatedCharMatched.index;
      len = repeatedCharMatched[0].length;
      text = text.slice(0, index) + repeatedCharMatched[1] + new Array(len - 1).join(' ') + repeatedCharMatched[1] + text.slice(index + len);
      repeatedCharMatched = text.match(repetedReg);
    }
    if (dict != null) {
      i = curr;
      while (i < text.length) {
        _ref2 = dict.byLen;
        for (len in _ref2) {
          wordList = _ref2[len];
          w = text.substr(i, Number(len));
          if (wordList[w] != null) {
            ret.push({
              w: w,
              curr: i,
              freq: wordList[w].freq
            });
          }
        }
        i++;
      }
    }
    i = curr;
    while (i < text.length) {
      _ref3 = sysDict.byLen;
      for (len in _ref3) {
        wordList = _ref3[len];
        w = text.substr(i, Number(len));
        if (wordList[w] != null) {
          ret.push({
            w: w,
            curr: i,
            freq: wordList[w].freq
          });
        }
      }
      i++;
    }
    return filterWord(ret, prevWord, text);
  };
  tokenize = function(word, prevWord) {
    var lastPos, lastWord, makeValue, props, restPos, result, start, t, temp, _i, _len;
    makeValue = function(w, start, props) {
      var value;
      value = {
        w: w,
        start: start
      };
      if ((props != null) && Object.keys(props).length > 0) {
        value.props = props;
      }
      return value;
    };
    result = [];
    temp = matchWord(word.w, 0, prevWord);
    if (temp.length === 0) {
      result.push(word);
    } else {
      start = word.start, props = word.props;
      lastPos = 0;
      for (_i = 0, _len = temp.length; _i < _len; _i++) {
        t = temp[_i];
        if (t.curr > lastPos) {
          result.push(makeValue(word.w.slice(lastPos, t.curr), start + lastPos));
        }
        result.push(makeValue(t.w, start + t.curr, extend(props, t.props)));
        lastPos = t.curr + t.w.length;
      }
      lastWord = temp[temp.length - 1];
      restPos = lastWord.curr + lastWord.w.length;
      if (restPos < word.w.length) {
        result.push(makeValue(word.w.slice(restPos), start + restPos, props));
      }
    }
    return result;
  };
  name = path.basename(__filename, path.extname(__filename));
  fn = function(words, next) {
    var i, prevWord, result, word, _i, _ref2;
    if (next == null) {
      next = noop;
    }
    result = [];
    for (i = _i = 0, _ref2 = words.length; 0 <= _ref2 ? _i < _ref2 : _i > _ref2; i = 0 <= _ref2 ? ++_i : --_i) {
      word = words[i];
      prevWord = words[i - 1];
      if (word.props != null) {
        result.push(word);
      } else {
        result = result.concat(tokenize(word, prevWord));
      }
    }
    return next(null, result);
  };
  return {
    name: name,
    fn: fn
  };
};
