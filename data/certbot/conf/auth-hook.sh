#!/bin/sh
echo "_acme-challenge.testcertbot.tk. 3600    IN  TXT  $CERTBOT_VALIDATION" >> /etc/coredns/test.db
