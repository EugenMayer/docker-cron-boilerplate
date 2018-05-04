## WAT

This boilerplate should help you understand how to setup cron runs under docker, handle pseudo shells and ENV vars and avoid all the pitfalls with cron in general

a) we want to be able to run cron with other users then our docker-build user (e.g. root)
b) we want to `Dockerfile` / `docker-compose.yml` ENV vars to be present for all our cron users ( see Dockerfile for the detailed info )

### How

See the `Dockerfile` and its comments to see what we handle, why and why we need what. 
