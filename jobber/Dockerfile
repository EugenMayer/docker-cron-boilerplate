FROM debian:stretch

ARG JOBBER_VERSION=1.3.2
## i am prefectly aware that i create WAY to much layers splitting the RUN statements
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

# that is all you need for jobber
RUN apt-get update \
  && apt-get install -y curl \
  && curl -sS --location --retry 3 https://github.com/dshearer/jobber/releases/download/v${JOBBER_VERSION}/jobber_${JOBBER_VERSION}-1_amd64_deb9.deb -o jobber.deb \
  && dpkg -i jobber.deb && rm jobber.deb


# those are tools since we run with supervisord and use watch to verify its running
RUN apt-get install -y supervisor bash watch \
  # we use this script to expose our Docker ENV environment to other users (not the "build user")
  && chmod +x /usr/local/bin/cron_runner \
  && mkdir -p /var/log/cronlogs/ \
  && chmod 777 /var/log/cronlogs/

COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf
COPY supervisor_cron.conf /etc/supervisor/conf.d/cron.conf

## CRONS: root
RUN  echo 'not-run-yet' > /var/log/cronlogs/root
COPY crons/root.yml /root/.jobber

## CRONS: www-data cron test
RUN echo 'not-run-yet' > /var/log/cronlogs/www-data \
  && chown www-data:www-data /var/log/cronlogs/www-data \
  && usermod -m -d /home/www-data www-data

COPY crons/www-data.yml /home/www-data/.jobber
RUN chown -R www-data:www-data /home/www-data


CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]