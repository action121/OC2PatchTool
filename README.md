# OC2PatchTool

大家做iOS热修复时，大量时间浪费在OC代码翻译成脚本上，给大家提供一个辅助工具，希望能给大家提供便利。

支持的功能：

1、OC代码 一键 批量转换成脚本
支持复制.m内容粘贴，转换
支持单个OC API转换，自动补全
报错提示:根据行号定位到OC代码行

2、将脚本导出Reease包
导出iOS APP可正常解析的包

3、解密Release包
可用于下载线上已发布的包，查看内容；
发版前check

4、提供帮助菜单
路径：菜单->帮助


# 不支持

1. 预编译相关

2. 编译器内置函数以及属性__attribute__等

3. a[x], {x,y,z}, a->x

4. id a = ( identifier )object; 类型转换. 但支持id a = (identifier *)object;

# 热修引擎

[地址](https://github.com/YPLiang19/Mango)

# 感谢

[地址](https://github.com/SilverFruity/oc2mango)

