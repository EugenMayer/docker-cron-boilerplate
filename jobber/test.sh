#!/bin/bash
watch -n2 docker-compose exec cron ls -la /var/log/cronlogs
