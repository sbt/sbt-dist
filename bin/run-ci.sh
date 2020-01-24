#!/usr/bin/env bash
set -eu

case ${mode:-} in
  linuxrelease)
    echo linux release
    ;;
  *)
    echo no mode is set
    ;;
esac
