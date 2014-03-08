Segment = require '../index'
chnSeg = new Segment()
.use Segment.crlf()
.use Segment.weiboMention()
.use Segment.weiboHashtag()
.use Segment.punctuation()
.use Segment.western()
.use Segment['chn']()

# text = '否则会导致分词时间成倍增加'
# text = '本模块以盘古分词组件中的词库为基础'
# text = '长春市长春药店'
# text = '她十二岁时是班花'
# text = '二零零五年十二月'
# text = "张亚东为其量身打造"
text = "作为世界上巧克力消费最大的国家之一，超过百年历史的巧克力厂商也颇有一些呢。127年前Chocolat Frey还是个家庭小作坊，现在是瑞士最大的巧克力制造商。如下五位成为幸运儿：@猿飞佐井 @阿多星 @怡宁怡宁 @100鲜橙汁 @向海小屋 这个情人节更甜蜜哟！其他同学的热情也已感受，咱们下周继续不见不散。"
chnSeg.handle text, (err, result) ->
  if err?
    console.error err
  else
    console.log result