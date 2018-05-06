## WAT

This boilerplate will show you how to run cron or better alternatives under docker


## Cron
This boilerplate should help you understand how to setup cron runs under docker, handle pseudo shells and ENV vars and avoid all the pitfalls with cron in general

a) we want to be able to run cron with other users then our docker-build user (e.g. root)
b) we want to `Dockerfile` / `docker-compose.yml` ENV vars to be present for all our cron users ( see Dockerfile for the detailed info )


## Jobber

[Jobber](https://github.com/dshearer/jobber) is a  far better alternative to cron. Far better logging, status report, syntax and general debug-ability and therefor reliability.
Especially the build in tools to create random time offsets for jobs so your infra does not run `something` at the very same second with a huge peek, is very handy.
Error handler, notifications, run histories, `jobber test` to see how it will run and what stdout/err looks like just makes your life a lot easier.
You can also run as often as every second, not only every minute.

Downside is, the most then "echoing one line".

## Why

1. we use supervisor

   Since it is in the nature that you will run cron for a specific service you also run in this docker-container most probably.
   So cron is just something in addition, and will most probably need you app-interpreter to be present. Maybe you run `rake`/`thor`/`drush`
   cleanup tasks or some python related cleanup jobs. Means you will have like `fpm` and `cron` and this will always require you to use
   `supervisor` - thats why we include it here out of the box, eventhough for our boilerplate, we would not need it ( since cron runs alone )

2. why the envs.sh

   See the Dockerfile for `FOO=bar` - it explains it pretty well

3. why `printf` and not `echo`

   [Do not use echo for this](https://unix.stackexchange.com/questions/65803/why-is-printf-better-than-echo?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa)
   
   
     