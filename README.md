# Jump over bars

一个可用于机器学习的小游戏。

A little game that could be use for machine learning.

## 游戏实现
* MATLAB完成游戏中行为的运算与更新，以及可视化，
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
