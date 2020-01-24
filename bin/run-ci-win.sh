#!/usr/bin/env bash
set -eu

buildWindows() {
  git clone https://github.com/sbt/sbt-launcher-package.git
  pushd sbt-launcher-package
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=true windows:packageBin
  mv target/windows/sbt.msi target/windows/sbt-$SBT_VER.msi
  popd
}

case ${mode:-} in
  build)
    echo Windows build
    buildWindows
    ;;
  *)
    echo no mode is set
    ;;
esac
