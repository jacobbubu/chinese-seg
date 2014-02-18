# split text by punctuation (support full and half width)
module.exports = (options) ->
  hanzenkaku = require('hanzenkaku').HanZenKaku
  { noop, path, extend, unique, tokenizeSync } = require '../utils'
  options = extend { removeToken: false, propName: 'punc' }, options
  options.skipProps = unique [options.propName].concat options.skipProps
  _stopwords = '\u3000 ,.;+-|/\\\'":?<>[]{}=!@#$%^&*()~`' +
              '。，、＇：∶；?‘’“”〝〞ˆˇ﹕︰﹔﹖﹑·¨….¸;！´？！～—ˉ｜‖＂〃｀@﹫¡¿﹏﹋﹌︴々﹟#﹩$﹠&﹪%*﹡﹢﹦' +
              '﹤‐￣¯―﹨ˆ˜﹍﹎+=<­＿_-\ˇ~﹉﹊（）〈〉‹›﹛﹜『』〖〗［］《》〔〕{}「」【】︵︷︿︹︽_﹁﹃︻︶︸' +
              '﹀︺︾ˉ﹂﹄︼＋－×÷﹢﹣±／＝≈≡≠∧∨∑∏∪∩∈⊙⌒⊥∥∠∽≌＜＞≤≥≮≯∧∨√﹙﹚[]﹛﹜∫∮∝∞⊙∏' +
              '┌┬┐┏┳┓╒╤╕─│├┼┤┣╋┫╞╪╡━┃└┴┘┗┻┛╘╧╛┄┆┅┇╭─╮┏━┓╔╦╗┈┊│╳│┃┃╠╬╣┉┋╰─╯┗━┛' +
              '╚╩╝╲╱┞┟┠┡┢┦┧┨┩┪╉╊┭┮┯┰┱┲┵┶┷┸╇╈┹┺┽┾┿╀╁╂╃╄╅╆' +
              '○◇□△▽☆●◆■▲▼★♠♥♦♣☼☺◘♀√☻◙♂×▁▂▃▄▅▆▇█⊙◎۞卍卐╱╲▁▏↖↗↑←↔◤◥╲╱▔▕↙↘↓→↕◣◢∷▒░℡™'
  stopwords = do ->
    result = {}
    _stopwords.split('').forEach (ch) -> result[ch] = true
    result

  isToken = (text, index) ->
    oriChar = text.charAt index; halfChar = oriChar.toHalfwidth().toHalfwidthSpace()
    prevChar = (text.charAt index - 1).toHalfwidth().toHalfwidthSpace()
    nextChar = (text.charAt index + 1).toHalfwidth().toHalfwidthSpace()

    result = false
    switch halfChar
      # skip sinngle quote in "doen't, hasn't, didn't, etc."
      when "'"
        result = stopwords[prevChar]? or stopwords[nextChar]?
      # 12.3, .01
      when "."
        result = not (nextChar.charCodeAt() in ['0'.charCodeAt()..'9'.charCodeAt()])
      # -12
      when "-"
        result = not (nextChar.charCodeAt() in ['0'.charCodeAt()..'9'.charCodeAt()])
      # +12
      when "+"
        result = not (nextChar.charCodeAt() in ['0'.charCodeAt()..'9'.charCodeAt()])
      else
        result= stopwords[oriChar]?
    result
  options.isToken = isToken

  name = path.basename __filename, path.extname(__filename)
  fn = (words, next) ->
    next ?= noop
    result = tokenizeSync words, options
    next null, result
  { name, fn }