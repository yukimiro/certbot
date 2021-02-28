#!/bin/sh
echo "Удаление записи из DNS"
sed -i '/^_acme/d' /etc/coredns/test.db
