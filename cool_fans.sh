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
