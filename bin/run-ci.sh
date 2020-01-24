#!/usr/bin/env bash
set -eu

releaseLinux() {
  git clone https://github.com/sbt/sbt-launcher-package.git
  pushd sbt-launcher-package
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false rpm:publish rpm:bintrayReleaseAllStaged debian:publish debian:bintrayReleaseAllStaged
  curl --user "$BINTRAY_USER:$BINTRAY_PASS" --data "" https://bintray.com/api/v1/calc_metadata/sbt/rpm
  curl --user "$BINTRAY_USER:$BINTRAY_PASS" --data "" https://bintray.com/api/v1/calc_metadata/sbt/debian
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
