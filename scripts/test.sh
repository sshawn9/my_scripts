tmp(){
file="testfile"
if [ -f "$file"* ]; then
  echo "fuck1"
  echo "$file"
  echo "$file"*
else
  echo "fuck2"
fi


#awk '{printf $1 + $2}'
echo "test bash end"
}

echo "alias clion=/usr/local/clion*/bin/clion.sh" >> ~/.bashrc
