#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -eou pipefail

OTHER_ARGS=()


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

goals+=("spring-boot:run")
spring_boot_args=(-Dspring-boot.run.arguments='--debug -Dspring.profiles.active=local')

if test "$debug" = "y"; then
    spring_boot_args+=(-Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=$suspend,address=$port")
fi

set -x
mvn -DcheckStyle.skip -DskipTests -Dmaven.test.skip \
    "${goals[@]}" \
    "${spring_boot_args[@]}" \
    "${OTHER_ARGS[@]}" | tee >(sed -e $'s/\x1b\[[0-9;]*[mGKHF]//g' > "$out_log_file")
