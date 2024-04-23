# cool_gpu_fans 
[English](README.md), [Chinese](README_zh.md)
> linux 服务器因为没有安装桌面，gpu 风扇转速控制一直失败，搞了几天终于成功了，记录一下。
> 

这个仓库包含一个用于控制NVIDIA GPU风扇速度的bash脚本。脚本会根据GPU的当前温度自动调整风扇的速度。

## 功能

- 自动检测系统中所有的NVIDIA GPU
- 根据每个GPU的当前温度设置风扇速度
- 将每次调整的详细信息记录到日志文件中，日志文件名包含当前日期
- 可以设置为开机自启动，持续监控和调整风扇速度

## 使用方法

1. 克隆这个仓库到你的本地机器
2. 给脚本添加执行权限：`chmod +x cool_gpus.sh`
3. 运行脚本：`./cool_gpus.sh`
4. （可选）设置脚本为开机自启动

注意：这个脚本需要`nvidia-smi`和`nvidia-settings`工具，这两个工具通常在NVIDIA的官方驱动中包含。如果你的系统中没有这两个工具，你需要先安装NVIDIA的官方驱动。

## 开源许可

这个项目使用MIT许可证。



## 1、使用 nvidia-settings  需要开启一个 X server 才能使用
```bash
#开启一个X server
X :1 &\

# 要关闭的话,用ps查找id, 手动kill

ps -fC Xorg
sudo kill pid
```
## 2、 然后更改 GPU 状态和风扇转速
```bash
nvidia-settings --display :1.0 -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=60"
#或者
nvidia-settings --display :1.0 -a "[gpu:1]/GPUFanControlState=1" -a "[fan:1]/GPUTargetFanSpeed=60"

```
修改之前
![image.png](https://cdn.nlark.com/yuque/0/2024/png/27633416/1713854943198-0df737eb-fbfd-43f1-9cb2-1c2153fc3e67.png#averageHue=%23465d3c&clientId=u067946bc-1b26-4&from=paste&height=57&id=u728d0878&originHeight=113&originWidth=669&originalType=binary&ratio=2&rotation=0&showTitle=false&size=31967&status=done&style=none&taskId=u4b1b96a1-603d-43f3-a497-11c8d756c95&title=&width=334.5)

修改后
![image.png](https://cdn.nlark.com/yuque/0/2024/png/27633416/1713854987316-4cfbd35d-5191-43dd-b090-d1b89a1b801c.png#averageHue=%2341593d&clientId=u067946bc-1b26-4&from=paste&height=59&id=u466b7315&originHeight=117&originWidth=674&originalType=binary&ratio=2&rotation=0&showTitle=false&size=31798&status=done&style=none&taskId=ub3024065-84e9-47e7-b637-a170b37d39d&title=&width=337)
## 3、写一个自动控制的脚本时刻监测温度，并修改风扇转速
```bash
sudo mkdir /opt/cool_gpus/
sudo vim /opt/cool_gpus/cool_gpus.sh
```
```bash
#!/bin/bash
cd $(dirname $0)
X :1 &\
# 检查是否有无限运行的参数
run_forever=1


# 设置日期格式
date_format="+%Y-%m-%d %H:%M:%S"

# 定义日志文件，文件名包含当前日期
log_file="gpu_fan_log_$(date "+%Y%m%d").txt"

# 循环直到脚本被告知停止
while : ; do
    # 获取所有NVIDIA GPU的数量
    gpu_count=$(nvidia-smi -L | wc -l)

    # 为每个GPU设置风扇速度
    for (( gpuid=0; gpuid<gpu_count; gpuid++ )); do
        # 获取当前GPU的温度
        temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits -i ${gpuid})

        # 根据温度确定目标风扇速度
        if [ "$temp" -lt 30 ]; then
            target=20
        elif [ "$temp" -lt 40 ]; then
            target=30
        elif [ "$temp" -lt 50 ]; then
            target=40
        elif [ "$temp" -lt 60 ]; then
            target=50
        elif [ "$temp" -lt 70 ]; then
            target=60
        elif [ "$temp" -lt 75 ]; then
            target=70
        elif [ "$temp" -lt 80 ]; then
            target=80
        elif [ "$temp" -lt 85 ]; then
            target=95
        else
            target=99
        fi

        # 输出当前温度和目标风扇速度，并将输出重定向到日志文件
        echo "$(date "$date_format") - GPU ${gpuid}: Current temperature is ${temp} C. Setting fan speed to ${target}%." >> $log_file

        # 设置当前GPU的风扇速度
        nvidia-settings --display :1.0 -a "[gpu:${gpuid}]/GPUFanControlState=1" -a "[fan-${gpuid}]/GPUTargetFanSpeed=${target}"
    done
    # 检查是否设置为无限运行
    if [ "${run_forever}" -ne 1 ]; then
        break
    fi

    # 等待一定时间再次检查
    sleep 15
done
```
## 4、 添加权限
```bash
sudo chmod +x /opt/cool_gpus/cool_gpus.sh
```
## 5、设置开机自启
首先，创建一个新的systemd服务文件。这个文件通常位于/etc/systemd/system目录下，文件名以.service结尾。我们创建一个名为gpu_fan_control.service的文件：
```bash
sudo vim /etc/systemd/system/gpu_fan_control.service
```
输入下面的内容
```bash
[Unit]
Description=GPU Fan Control Script

[Service]
ExecStart=/opt/cool_gpus/cool_gpus.sh

[Install]
WantedBy=multi-user.target
```
保存后关闭文件，加在配置文件
```bash
sudo systemctl daemon-reload
```
开机启动
```bash
sudo systemctl enable gpu_fan_control
```
立即启动
```bash
sudo systemctl start gpu_fan_control
```
检查状态
```bash
sudo systemctl status gpu_fan_control
```
