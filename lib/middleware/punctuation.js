module.exports = function(options) {
  var isToken, stopwords, utils, _stopwords;
  utils = require('../utils');
  options = options != null ? options : {};
  _stopwords = '\u3000 ,.;+-|/\\\'":?<>[]{}=!@#$%^&*()~`' + '。，、＇：∶；?‘’“”〝〞ˆˇ﹕︰﹔﹖﹑·¨….¸;！´？！～—ˉ｜‖＂〃｀@﹫¡¿﹏﹋﹌︴々﹟#﹩$﹠&﹪%*﹡﹢﹦' + '﹤‐￣¯―﹨ˆ˜﹍﹎+=<­＿_-\ˇ~﹉﹊（）〈〉‹›﹛﹜『』〖〗［］《》〔〕{}「」【】︵︷︿︹︽_﹁﹃︻︶︸' + '﹀︺︾ˉ﹂﹄︼＋－×÷﹢﹣±／＝≈≡≠∧∨∑∏∪∩∈⊙⌒⊥∥∠∽≌＜＞≤≥≮≯∧∨√﹙﹚[]﹛﹜∫∮∝∞⊙∏' + '┌┬┐┏┳┓╒╤╕─│├┼┤┣╋┫╞╪╡━┃└┴┘┗┻┛╘╧╛┄┆┅┇╭─╮┏━┓╔╦╗┈┊│╳│┃┃╠╬╣┉┋╰─╯┗━┛' + '╚╩╝╲╱┞┟┠┡┢┦┧┨┩┪╉╊┭┮┯┰┱┲┵┶┷┸╇╈┹┺┽┾┿╀╁╂╃╄╅╆' + '○◇□△▽☆●◆■▲▼★♠♥♦♣☼☺◘♀√☻◙♂×▁▂▃▄▅▆▇█⊙◎۞卍卐╱╲▁▏↖↗↑←↔◤◥╲╱▔▕↙↘↓→↕◣◢∷▒░℡™';
  stopwords = (function() {
    var result;
    result = {};
    _stopwords.split('').forEach(function(ch) {
      return result[ch] = true;
    });
    return result;
  })();
  isToken = function(text, index) {
    return stopwords[text.charAt(index)] != null;
  };
  return function(words, next) {
    var result, word, _i, _len;
    result = [];
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      if (word.props != null) {
        result.push(word);
      } else {
        result = result.concat(utils.splitWord(word, isToken, 'punc'));
      }
    }
    return next(null, result);
  };
};
