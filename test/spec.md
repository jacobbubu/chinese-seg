# Specification #

1. 分词的结果能够显示到原始内容的位置信息
2. 分词组件是插件化的
3. 优化组件也是插件化的
4. 词库的解析和获取由插件来完成。只有插件才知道如何处理词库的格式。
5. 插件可以根据自己的需要来扩展属性定义
6. 一个词可以有多个属性

常用的分词组件：

1. 英文识别
2. URL 识别
3. 新浪 Emotions 识别
4. Sogou 成语词典等等

分词处理结果：

例句：

`本站点 http://www.mysite.com 的地址的正式地址是 http://www.mysite.com`

```
[
  { w: '本站点', start: 0, len: 4 }
  { w: 'http://www.mysite.com', prop: 'url', start: 4, len: 21 }
  { w: ' 的地址的正式地址是 ', start: 25, len: 11 }
  ...
]
```