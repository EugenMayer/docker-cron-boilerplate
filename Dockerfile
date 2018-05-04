FROM debian:stretch

## i am prefectly aware that i create WAY to much layers splutting the RUN statements
## but this file should be a boilerplate, so copy snippets and parts you need
## thus i split the statements into its components

# just a test value to see if our source env works. We want to ensure that when we run a cron with
# www-data we have this variable present - docker would usually not offer this. ENV vars in here
# and in docker-compose are only present for the user used during build time or more presize "the last user used in the
# dockerfile" - all other users will not have those env vars present which can be tricky for variious reasons like
# services running non-privileged in runtime but during build, a privileged user is used and needed during the entrypoint
# still one wants to have those ENV vars present for the actual service. That is what our cron_runner.sh does for us
ENV FOO=bar

# our helper to expose env vars and start cron in the foreground
COPY cron_runner.sh /usr/local/bin/cron_runner

# that is all you need for cron
RUN apt-get update \
  && apt-get install -y cron

# those are tools since we run with supervisord and use watch to verify its running
RUN apt-get install -y supervisor bash \
  # we use this script to expose our Docker ENV environment to other users (not the "build user")
  && chmod +x /usr/local/bin/cron_runner \
  && mkdir -p /var/log/cronlogs/ \
  && chmod 777 /var/log/cronlogs/

COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf
COPY supervisor_cron.conf /etc/supervisor/conf.d/cron.conf

# root simple cron test
RUN  echo 'not-run-yet' > /var/log/cronlogs/root-simple \
  && printf "* * * * *   root /bin/sh -c 'env >> /var/log/cronlogs/root-simple 2>&1'\n" > /etc/cron.d/root-simple

# root cron test
RUN  echo 'not-run-yet' > /var/log/cronlogs/root \
  && printf "* * * * *   root /bin/sh -c '. /root/envs.sh;env >> /var/log/cronlogs/root 2>&1'\n" > /etc/cron.d/root

# www-data cron test
RUN echo 'not-run-yet' > /var/log/cronlogs/www-data \
  && chown www-data:www-data /var/log/cronlogs/www-data \
  && mkdir -p /home/www-data \
  && printf "* * * * *   www-data /bin/sh -c '. /home/www-data/envs.sh;env >> /var/log/cronlogs/www-data 2>&1'\n" > /etc/cron.d/www-data

################# BROKEN ONES

# this one is broken since the cron file has no newline - this is not allowed
RUN  echo 'not-run-yet' > /var/log/cronlogs/root \
  && printf "* * * * *   root /bin/sh -c '. /root/envs.sh;env >> /var/log/cronlogs/root 2>&1'" > /etc/cron.d/root-no-newline-broken


CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]