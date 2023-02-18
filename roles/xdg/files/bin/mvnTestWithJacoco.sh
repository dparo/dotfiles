#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# This approach to Jacoco instrumentation is called OFFLINE instrumetnation
# It is deprecated. The preferred approach is to use agent-instrumentation

mvn clean compile org.jacoco:jacoco-maven-plugin:instrument \
    && mvn test \
    && mvn org.jacoco:jacoco-maven-plugin:restore-instrumented-classes org.jacoco:jacoco-maven-plugin:report surefire-report:report-only
