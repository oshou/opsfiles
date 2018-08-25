#!/bin/sh
# compare dig result (only ANSWER SECTION)


readonly REQ_TIMEOUT=3
readonly DOMAIN_LIST="domain_list1.csv domain_list2.csv"
readonly NAME_SERVERS=(
  "test1.example.com"
  "test2.example.com"
  "test3.example.com"
  "test4.example.com"
  "test5.example.com"
);


cat $DOMAIN_LIST | while read -r domain type _; do
  val=""
  for name_server in ${NAME_SERVERS[@]}
  do
    res=`dig -t $type $domain @$name_server +time=$REQ_TIMEOUT | awk '/ANSWER SECTION/,/(AUTHORITY|ADDITIONAL|Query)/' | head -n -2 | tail -n +2 | awk '{print $1,$3,$4,$5}' | sort`
    # res=`dig -t $type $domain @$name_server +time=$REQ_TIMEOUT | awk '/;; ANSWER|;; AUTHORITY/,/^$/' | head -n -1 | awk '{print $1,$3,$4,$5}' | sort`
    # echo $res;
    if [ -z "$val" ]; then
      val="$res"
    fi
    if [ "$val" != "$res" ]; then
      break;
    fi
  done

  if [ "$val" == "$res" ]; then
    echo -e "\e[32m ${domain}\t${type}\t: OK (compare result is match)"
  else
    echo -e "\e[31m ${domain}\t${type}\t: NG (compare result is unmatch!!)"
  fi

done
