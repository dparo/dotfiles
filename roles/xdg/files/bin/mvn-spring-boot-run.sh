#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -eou pipefail

OTHER_ARGS=()


goals=()
port="${JDWP_PORT:-5005}"
suspend="${JDWP_SUSPEND:-n}"

while [[ $# -gt 0 ]]; do
  case $1 in
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
set -x
mvn -DcheckStyle.skip -DskipTests -Dmaven.test.skip \
    "${goals[@]}" \
    -Dspring-boot.run.arguments='--debug -Dspring.profiles.active=local' \
    -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=$suspend,address=$port" \
    "${OTHER_ARGS[@]}" | tee >(sed -e $'s/\x1b\[[0-9;]*[mGKHF]//g' > "$out_log_file")
