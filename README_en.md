# GPU Fan Control Script

This repository contains a bash script for controlling the fan speed of NVIDIA GPUs. The script automatically adjusts the fan speed based on the current temperature of each GPU.

## Features

- Automatically detects all NVIDIA GPUs in the system
- Sets the fan speed for each GPU based on its current temperature
- Logs detailed information about each adjustment, with log filenames including the current date
- Can be set to run at startup, continuously monitoring and adjusting fan speeds

## Usage

1. Clone this repository to your local machine
2. Give the script execution permissions: `chmod +x cool_gpus.sh`
3. Run the script: `./cool_gpus.sh`
4. (Optional) Set the script to run at startup

Note: This script requires the `nvidia-smi` and `nvidia-settings` tools, which are typically included with NVIDIA's official drivers. If these tools are not present on your system, you will need to install NVIDIA's official drivers first.

## Open Source License

This project is licensed under the MIT License.
