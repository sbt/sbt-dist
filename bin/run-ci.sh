#!/usr/bin/env bash
set -eu

releaseLinux() {
  git clone https://github.com/sbt/sbt-launcher-package.git
  pushd sbt-launcher-package
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false rpm:publish debian:publish
  popd
}

case ${mode:-} in
  linuxrelease)
    echo linux release
    releaseLinux
    ;;
  *)
    echo no mode is set
    ;;
esac
