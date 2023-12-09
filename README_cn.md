#  rp_autostartscript

这是一个为Rosenpass而编写的第三方启动脚本， 用于开机自启。


## 安装教程
```shell
git clone https://github.com/jinnang233/rp_autostartscript
cd rp_autostartscript
make install
make install_service
```

## 配置

安装后， 在安装路径下， 将会有两个文件夹：clients, clients_ip。目录路径可在config中自定义自定义。 

> 如果需要自定义路径， 那么在之后需要手动执行makedirs.sh来创建脚本和密钥文件。

clients文件夹用于存放由官方rp脚本生成的客户端**公钥文件夹**， 而clients_ip用于存放客户端指定AllowedIPs的纯文本文件。 clients_ip文件夹下的文件内容对应Wireguard节点AllowedIps。

例:
> 192.168.4.2/32

clients_ip目录下的文件也可通过touch_ipfiles.sh脚本生成。
```shell
cd /usr/local/rosenpass # 脚本安装的路径
./touch_ipfiles.sh
```

ddns.sh的内容可自定义，用户可自行编写DDNS脚本以配置IPv6动态域名。

在config文件里设置参数以满足不同的需要。

配置完毕后， 请重启服务来应用。
```shell
systemctl restart rp_assignip
systemctl restart rosenpass
```

## 限制和注意事项

本脚本并非由Rosenpass官方编写。我的代码水平不好， 请自行评估使用风险。

代码如有不妥， 请多多指教。

欢迎fork。
