#!/bin/sh
echo "_acme-challenge.testcertbot.tk. 3600    IN  TXT  $CERTBOT_VALIDATION" >> /etc/coredns/test.db
#echo "_acme-challenge.testcertbot.tk. 3600    IN  TXT  AABBCC" >> /etc/coredns/test.db

#Увеличить serial на 1

#out=($(cat /etc/coredns/test.db))  -  не работает в шелле контейнера
#old_serial=${out[5]}
#new_serial=$((${out[5]}+1))

out=$(cat /etc/coredns/test.db)
k=0
for i in $out
do
  k=$(($k+1))
  if [ $k -eq "6" ]
  then
    old_serial=$i
    break
  fi
done

new_serial=$(($old_serial+1))

#Заменить SOA запись

replace="testcertbot.tk. IN  SOA dns.testcertbot.tk. email.testcertbot.tk. $new_serial 7200 3600 1209600 3600" >> /etc/coredns/test.db
sed -i '1d' /etc/coredns/test.db
sed -i "1i $replace" /etc/coredns/test.db
