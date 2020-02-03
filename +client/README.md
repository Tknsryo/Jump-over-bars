# MATLAB Package: client

通过client包，您可以：
* 采集游戏数据；
* 远程控制游戏；
* 远程设置游戏或后台服务器行为。

## 快速上手

要使用本包，您需要将“+client”文件夹拷贝至您的matlab脚本所在目录，在脚本中通过以下命令导入。
```
import client.Client;
```
### 创建Client对象
导入后，您可以轻松创建一个Client对象与后台服务器交互。
```
c = Client(address, port);
```
* address: 后台服务器地址，如 'localhost' 指明为本地地址；
* port: 后台服务器开放给client的端口，如 9999 为默认开放端口；

### 重新指定后台服务器
要改变到另一个后台服务器，您无需重新创建一个Client对象。
```
c.setServer(new_address,new_port);
```
### 设置数据扫描间隔
与后台服务器建立连接后，Client将持续检查是否有来自后台服务器的新数据，每次检查的时间间隔可以如下设定。
```
c.recvInterval = 0.01;
```
这样便将时间间隔设定为0.01秒，这也是默认值。
注：每次设定将在下一次连接中生效。
### 连接至后台服务器
```
c.connect();
```
连接成功后，您将会收到提示以及来自服务器的回应。
```
》c.connect();
connecting
connect successfully
*message from the server:
You have successfully connected to the server.
*
```

### 断开连接
建立连接后，您可以随时断开连接。
```
c.disconnect();
```

### <span id='play'>游戏操作接口</span>
通过建立好连接的Client对象，您可以轻松操作已与后台服务器建立连接的游戏端。
与后台服务器建立连接后，您可以查询是否有与后台服务器建立连接的游戏端。
```
c.gameIsRunning();
```
您将会收到服务器的回应。
```
》c.gameIsRunning();
》*message from the server:
Game is not running
*
```
#### <span id='jump'>跳跃</span>
```
c.jump(value);
```
* value: 1或0，分别相当于按下起跳键与松开起跳键。

#### 下蹲
```
c.squat(value);
```
* value: 1或0，分别相当于按下蹲下键与松开蹲下键。
  
#### 暂停游戏
```
c.pause();
```

#### 重开游戏
```
c.reset();
```

### 配置后台服务器或游戏端
所有的配置都通过Client对象的“configure”函数完成。
```
c.configure(key,value);
```
* key: 指定配置项；
* value: 配置值。

#### 可用配置项
对于取值为1，0的配置项，1为是，0为否。
* 'reqDataFromGame': 1, 0; 是否让游戏端将游戏数据发送到后台服务器；
* 'reqDataFromBg': 1, 0; 是否让后台服务器将游戏数据发送到本地；
* 'fps': 10~60; 游戏端的FPS（HZ）；
* 'simulRate': 10~120; 游戏端的仿真频率（HZ）；
* 'recvRate'： 1~60; 游戏端发送游戏数据的频率（HZ）；
* 'autoRestart': 1, 0; 是否游戏结束后重开游戏，'reqDataFromGame'为1时生效；
* 'dispInBg': 1,0; 是否在后台服务器显示接受到的游戏数据。
  
注：每次配置'recvRate'后，游戏端将暂停将游戏数据发送到后台服务器
，重新发送须手动配置'reqDataFromGame'为1。
### 处理游戏数据
要在服务器处理数据，需要将'reqDataFromGame'配置为1。
要运用Client处理数据，需要同时将'reqDataFromGame'及'reqDataFromBg'配置为1。
在后台服务器，目前仅支持保存数据到文件。
#### 在后台服务器保存数据
开始记录数据：
```
c.toDisk(path,openMode);
```
* path: 保存文件路径，不支持中文，长度要在255个字节以内；
* openMode: 'w'或'a'，分布代表覆盖文件和追加到文件末尾。 

注：path应是服务器主机上的有效路径，支持绝对路径与相对路径，相对路径为相对后台服务器程序的路径。

停止记录数据并保存：
```
c.save();
```

数据将按csv格式保存，各字段同下文的["gameData"成员](#data)，除命名略有不同。

#### 在Client端处理数据
将'reqDataFromGame'及'reqDataFromBg'配置为1后，Client的"gameData"成员会积累接收到的数据，
它是一个结构体数组，新数据会追加到它的末尾，您可以限制它的长度。
```
c.maxLen = len;
```
len为您想设置的值，默认为0，代表无限制。

注：当"gameData"成员长度被限制时，若接受新数据后长度超出上限，Client会采取先进先出的策略剔除多出的数据。

<span id='data'>"gameData"成员的元素为结构体，它包含以下成员。</span>
* time: 当前得分；
* stat: 当前状态，0代表游戏进行中，1代表游戏结束；
* jump: 跳跃状态，其取值与函数[c.jump(value)](#jump)中的value有相同解释；
* squat: 下蹲状态，类似“jump”；
* dis: 离玩家最近的前三个障碍的位移信息，1x3数组；
* len: 离玩家最近的前三个障碍的高度信息，1x3数组；

通过访问"gameData"成员，您可以对游戏状况做出判断，据此得出游戏策略，并通过[游戏操作接口](#play)执行您的策略