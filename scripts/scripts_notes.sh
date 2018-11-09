## embedded expect in bash
#!/bin/bash
expect <(cat <<'EOD'
spawn python
expect ">>>"
send "\n"
send "hhh\r"
interact
EOD
)



乱七八糟
pwd
echo dirname
SCRIPT_DIR="$( cd "$( dirname " ${BASH_SOURCE[0]}" )" && pwd )"
echo $SCRIPT_DIR
echo ${BASH_SOURCE[0]}
echo ${BASH_SOURCE}



sudo tar -zxf software_package/CLion*.tar.gz -C .
