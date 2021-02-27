#!/bin/bash
#Проверяем, установлен ли compose
if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

#Запускаем DNS
docker-compose run -d --rm -p 192.168.0.53:53:53/udp coredns -conf /etc/coredns/Corefile

domains=(*.testcertbot1.tk)
rsa_key_size=4096
data_path="./data/certbot"
email="" # Почта по желанию
staging=1 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Сертификат уже существует. Заменить? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

#Скачивание рекомендуемых настроек
if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### #Скачивание рекомендуемых настроек ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Запрос сертификата Let's Encrypt для $domains ..."
#Добавление доменов в аргументы -d
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

#Проверка почты
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Проверка режима staging
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "certbot certonly $staging_arg $email_arg --rsa-key-size $rsa_key_size --agree-tos --break-my-certs --manual --preferred-challenges dns --manual-auth-hook /etc/letsencrypt/auth-hook.sh --manual-cleanup-hook /etc/letsencrypt/cleanup-hook.sh $domain_args" certbot 
# работает docker-compose run --rm --entrypoint "sh /etc/letsencrypt/auth-hook.sh" certbot 
docker-compose run --rm --entrypoint "cat /etc/coredns/test.db" certbot

echo

#docker-compose run --rm --entrypoint "certbot certonly --webroot -w /var/www/certbot --agree-tos" certbot
echo "Запуск nginx"
#docker-compose exec nginx nginx -s reload
docker-compose up -d nginx
