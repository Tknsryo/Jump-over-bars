# Jump over bars

一个可用于学习机器学习的小游戏

A little game that could be used for machine learning.

![demo](imgs/demo.gif?raw=true)

## 运行游戏
* 通过源码运行，用matlab（实测最小安装的R2018b及以上版本运行正常）运行脚本“start.m”；
* 通过编译过的[可执行文件](https://github.com/Tknsryo/Jump-over-bars/releases/tag/v2.0)运行；

## 项目组成
* 游戏本体（[Jump-over-bars](.)）
* 后台服务器（[Job-Background-Server](https://github.com/Tknsryo/JoB-Background-Server)）
* matlab包client（[Jump-over-bars/+client](./+client)）

这三部分可以运行在同一主机上，也可以各自运行在不同的主机上，他们通过TCP连接交换数据。三者能正常交换数据的前提是[游戏端](.)与使用了[client包](./+client)的matlab进程连接到同一个运行中的[后台服务器](https://github.com/Tknsryo/JoB-Background-Server)。有关数据传输的控制接口在[client包](./+client)中提供。

![structure](imgs/structure.png?raw=true)
## GUI
本项目GUI采用matlab的图形对象实现，各组件如下：

![panel](imgs/gui.png?raw=true)
### 菜单
菜单中提供了与游戏交互的组件。

![menu](imgs/menu.png?raw=true)
### 设置
目前设置中只提供了修改FPS与仿真频率的接口。

![setting](imgs/setting.png?raw=true)

操作演示：
![settingDemo](imgs/settingDemo.gif?raw=true)

## 按键
* J: 起跳；
* K: 下蹲，须持续按下；
* L: 暂停游戏，相当于点击一次菜单中的“PAUSE”；
* R: 重开游戏，相当于点击一次菜单中的“RESTART”。
## 连接
连接部分允许您建立游戏到一个运行中的[后台服务器](https://github.com/Tknsryo/JoB-Background-Server)的连接。

![connecting](imgs/connection.png?raw=true)
