#!/bin/bash

# chamge apt source to tsinghua

# ---
# test information
#
# ---

sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g'  /etc/apt/sources.list