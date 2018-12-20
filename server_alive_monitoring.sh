TRYCOUNT=3
IPLIST=~/opsfiles/iplist.list 

### PING check
for IP in `cat ${IPLIST}`
do
  ping ${IP} -c ${TRYCOUNT}
  if [ $? -eq 1 ]; then
    if [ -e /tmp/pingfile${IP}.tmp ]; then
      echo "TMP file already exists"
    else
      touch /tmp/pingfile${IP}.tmp
    fi
  else
    rm -f /tmp/pingfile${IP}.tmp
  fi
done

exit 0
