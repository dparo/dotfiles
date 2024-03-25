#!/usr/bin/env bash
# -*- coding: utf-8 -*-


set -x

JDWP_PORT=0         # USE 0 for dynamically determining a free port

mvn -DcheckStyle.skip -DskipTests -Dmaven.test.skip \
    clean spring-boot:run \
    -Dspring-boot.run.arguments='--debug -Dspring.profiles.active=local' \
    -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=$JDWP_PORT" \
    "$@"
