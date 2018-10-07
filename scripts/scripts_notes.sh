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
