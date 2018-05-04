FROM debian:stretch

## i am prefectly aware that i create WAY to much layers splutting the RUN statements
## but this file should be a boilerplate, so copy snippets and parts you need
## thus i split the statements into its components
ENV FOO=bar
ENV TERM=xterm

COPY cron_runner.sh /usr/local/bin/cron_runner

# that is all you need for cron
RUN apt-get update \
  && apt-get install -y cron

# those are tools since we run with supervisord and use watch to verify its running
RUN apt-get install -y supervisor bash watch \
  # we use this script to expose our Docker ENV environment to other users (not the "build user")
  && chmod +x /usr/local/bin/cron_runner \
  && mkdir -p /var/log/cronlogs/ \
  && chmod 777 /var/log/cronlogs/

COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf
COPY supervisor_cron.conf /etc/supervisor/conf.d/cron.conf
# our helper to watch for the cron runs to be executed and stream its output into the docker-compose logs
COPY supervisor_watch.conf /etc/supervisor/conf.d/watch.conf

# root simple cron test
RUN  echo 'no-run-yet' > /var/log/cronlogs/root-simple \
  && printf "* * * * *   root env >> /var/log/cronlogs/root-simple 2>&1'\n\n" > /etc/cron.d/root-simple

# root cron test
RUN  echo 'no-run-yet' > /var/log/cronlogs/root \
  && printf "* * * * *   root /bin/sh -c '. /root/env.sh;env >> /var/log/cronlogs/root 2>&1'\n\n" > /etc/cron.d/root

# www-data cron test
RUN echo 'no-run-yet' > /var/log/cronlogs/www-data \
  && chown www-data:www-data /var/log/cronlogs/www-data \
  && mkdir -p /home/www-data \
  && printf "* * * * *   www-data /bin/sh -c '. /home/www-data/envs.sh;env >> /var/log/cronlogs/www-data 2>&1'\n\n" > /etc/cron.d/www-data

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]