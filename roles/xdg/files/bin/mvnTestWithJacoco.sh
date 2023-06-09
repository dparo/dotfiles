#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# This approach to Jacoco instrumentation is called OFFLINE instrumetnation
# It is deprecated. The preferred approach is to use agent-instrumentation

mvn compile org.jacoco:jacoco-maven-plugin:instrument \
    && mvn -DtrimStackTrace=false test

status="$?"

if test "$status" -neq 0; then
    mvn org.jacoco:jacoco-maven-plugin:restore-instrumented-classes
    exit "$status"
fi

mvn org.jacoco:jacoco-maven-plugin:restore-instrumented-classes org.jacoco:jacoco-maven-plugin:report surefire-report:report-only
status="$?"

xdg-open target/site/jacoco/index.html

exit "$status"
