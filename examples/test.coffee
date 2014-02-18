Segment = require '../index'
chnSeg = new Segment().use(Segment['chn-dict']())

# text = '否则会导致分词时间成倍增加'
# text = '本模块以盘古分词组件中的词库为基础'
# text = '长春市长春药店'
# text = '她十二岁时是班花'
# text = '二零零五年十二月'
text = "张亚东为其量身打造"
chnSeg.handle text, (err, result) ->
  if err?
    console.error err
  else
    console.log result