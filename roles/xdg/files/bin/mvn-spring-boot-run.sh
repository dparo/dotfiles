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
    --debug)
      debug="y"
      shift
      ;;
    --debug-port)
      port="$2"
      shift
      shift
      ;;
    --suspend)
      suspend="y"
      shift
      ;;
    --no-suspend)
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

if test "$USE_MVN_SPRING_BOOT_RUN" -ne 0; then
    goals+=("spring-boot:run")

    jvm_args+=(-Dspring-boot.run.arguments='--debug --spring.profiles.active=local')

    if test "$debug" = "y"; then
        jvm_args+=(-Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=$suspend,address=$port")
    fi
else
    goals+=("package")

    if test "$debug" = "y"; then
        jvm_args+=(-Xdebug "-Xrunjdwp:transport=dt_socket,server=y,suspend=$suspend,address=$port")
    fi
fi


set -x

if test "$USE_MVN_SPRING_BOOT_RUN" -ne 0; then
    mvn -DcheckStyle.skip -DskipTests -Dmaven.test.skip \
        "${goals[@]}" \
        "${jvm_args[@]}" \
        "${OTHER_ARGS[@]}" | tee >(sed -e $'s/\x1b\[[0-9;]*[mGKHF]//g' > "$out_log_file")
else
    jars=( ./target/*.jar )
    jar="${jars[-1]}"

    mvn -DcheckStyle.skip -DskipTests -Dmaven.test.skip "${goals[@]}" && \
        java -Xms512m -Xmx1024m "${jvm_args[@]}" -jar "$jar" --debug --spring.profiles.active=local "${OTHER_ARGS[@]}" \
        | tee >(sed -e $'s/\x1b\[[0-9;]*[mGKHF]//g' > "$out_log_file")
fi
