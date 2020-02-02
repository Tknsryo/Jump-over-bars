# Jump over bars

一个可用于学习机器学习的小游戏。

A little game that could be used for machine learning.

![demo](https://github.com/Tknsryo/Jump-over-bars/blob/v1.0/demo.gif)

## 运行游戏
1. 在根目录("main.m"所在目录)创建名为“detect_zone”的目录；
2. 运行根目录下的"controler.exe"可执行文件，若不存在，自行编译"controler"目录下的源文件并移动至根目录运行；
3. 用支持“classdef”方式的进行面向对象编程的MATLAB(最小安装即可)运行根目录下的"main.m"；
4. 根据提示操作，等待窗口跳出后，切换至"controler.exe"窗口，根据按键提示进行游戏。

## 游戏实现
* MATLAB完成游戏中行为的运算与更新，以及可视化；
* C++完成键盘的输入检测，并通过一套简陋的接口与MATLAB的部分连接，实现实时控制。

## 关于接口
十分简陋的“文件检测接口”

MATLAB部分通过检测某个文件是否存在决定游戏的走向，C++通过创建/删除这些文件实现与游戏MATLAB脚本的通信。

用MATLAB编写的“add.m”与“del.m”也能创建/删除这些文件，游戏MATLAB脚本使用这些函数实现自我调控，开发者也能运用这些函数编写控制游戏行为的脚本，例如下面的语句，让角色每隔两秒跳一次，游戏结束后自动重启游戏：
```
while true
   if detector('eme')
      add('restart');
   end
   pause(2);
   add('jump');
   pause(0.01);
   del('jump');
end
```

更完善的通信接口有待实现