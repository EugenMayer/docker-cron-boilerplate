#!/usr/bin/env bash

# we export the ENV vars to ensure we have all the ENV vars we defined in our Dockerfile
env | sed 's/^\(.*\)=\(.*\)$/export \1="\2"/' > /root/envs.sh

# we export the ENV vars to ensure we have all the ENV vars we defined in our Dockerfile for the build user (mostly root)
env | sed 's/^\(.*\)=\(.*\)$/export \1="\2"/' > /home/www-data/envs.sh

# we need to to save it temporarly so we do basically not replace what we write into - empty file is the result
cat /home/www-data/envs.sh | sed 's/^export HOME=.*$//g' > /home/www-data/.envs.sh
mv /home/www-data/.envs.sh /home/www-data/envs.sh
chown www-data:www-data /home/www-data/envs.sh

# finally start cron
exec /usr/libexec/jobbermaster
