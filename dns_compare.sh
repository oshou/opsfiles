#!/bin/sh
# dns compare script

readonly DIG_TIMEOUT=3

readonly NAME_SERVERS=(
  "dns01.jword.jp"
  "dns02.jword.jp"
  "ns-a1.cloud.z.com"
  "ns-a2.cloud.z.com"
  "ns-a3.cloud.z.com"
);

# readonly NAME_SERVERS=(
#   "dns01.jword.jp"
#   "dns02.jword.jp"
# );

cat domain_list.csv | while read -r domain type _; do
  val=""
  for name_server in ${NAME_SERVERS[@]}
  do
    # res=`dig -t $type $domain @$name_server +time=$DIG_TIMEOUT | grep -e "ANSWER SECTION" -e "AUTHORITY SECTION" -A2 | grep -v "ANSWER SECTION"`
    res=`dig -t $type $domain @$name_server +time=$DIG_TIMEOUT | grep -e "ANSWER SECTION" -A2 | grep -v "ANSWER SECTION"`
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
