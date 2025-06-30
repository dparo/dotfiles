#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -eou pipefail

OTHER_ARGS=()

USE_MVN_SPRING_BOOT_RUN=0

goals=()
port="${JDWP_PORT:-5005}"
suspend="${JDWP_SUSPEND:-n}"
debug="n"

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool-debug)
      debug="y"
      shift
      ;;
    --tool-debug-port)
      port="$2"
      shift
      shift
      ;;
    --tool-suspend)
      suspend="y"
      shift
      ;;
    --tool-no-suspend)
      suspend="n"
      shift
      ;;
    --clean)
      goals+=("clean")
      shift
      ;;
    -*|--*)
      OTHER_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
    *)
      OTHER_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done


mkdir -p logs
out_log_file=logs/"$(date --iso-8601=seconds).log"

jvm_args=()
jvm_args+=('-Dspring.devtools.restart.enabled=true')

if test "$USE_MVN_SPRING_BOOT_RUN" -ne 0; then
    goals+=("spring-boot:run")

    jvm_args+=(-Dspring-boot.run.arguments='--debug')

    if test "$debug" = "y"; then
        jvm_args+=(-Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=$suspend,address=$port")
    fi
else
    goals+=("package")

    if test "$debug" = "y"; then
        # Enable JMX Monitoring: JMX is Java's way to inspect and control the JVM at runtime. It’s a powerful tool for debugging memory usage hotspots
        #  It has dynatrace support:
        #
        #    https://docs.dynatrace.com/docs/ingest-from/extend-dynatrace/extend-metrics/ingestion-methods/jmx-extensions
        #
        jvm_args+=( -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9010 -Dcom.sun.management.jmxremote.rmi.port=9010 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=127.0.0.1 )
        jvm_args+=( -Dspring.jmx.enabled=true )
        jvm_args+=( -Xdebug "-Xrunjdwp:transport=dt_socket,server=y,suspend=$suspend,address=$port" )
    fi
fi


set -x

if test "$USE_MVN_SPRING_BOOT_RUN" -ne 0; then
    mvn -DcheckStyle.skip -DskipTests -Dmaven.test.skip -Dmaven.compiler.useIncrementalCompilation=false \
        "${goals[@]}" \
        "${jvm_args[@]}" \
        "${OTHER_ARGS[@]}" | tee >(sed -e $'s/\x1b\[[0-9;]*[mGKHF]//g' > "$out_log_file")
else

    # -Xmx512m
    # -XX:MaxRAM=2g -XX:MaxRAMPercentage=50.0

    mvn -DcheckStyle.skip -DskipTests -Dmaven.test.skip -Dmaven.compiler.useIncrementalCompilation=false \
        "${goals[@]}" && \
        java -Xms64m -XX:MaxRAM=1g -XX:MaxRAMPercentage=50.0 -XX:MaxMetaspaceSize=180m "${jvm_args[@]}" \
            -jar "$(find ./target -type f -name "*.jar" | sort | head -n 1)" \
            "${OTHER_ARGS[@]}" \
        | tee >(sed -e $'s/\x1b\[[0-9;]*[mGKHF]//g' > "$out_log_file")
fi
