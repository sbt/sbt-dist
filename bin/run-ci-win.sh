#!/usr/bin/env bash
set -eu

buildWindows() {
  git clone https://github.com/sbt/sbt.git
  pushd sbt
  cd launcher-package
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false clean windows:packageBin
  ls target
  ls target/windows/
  mv target/windows/sbt.msi target/windows/sbt-$SBT_VER.msi
  popd
}

case ${mode:-} in
  build)
    echo Windows build
    buildWindows
    ls sbt/launcher-package/target/windows
    ;;
  *)
    echo no mode is set
    ;;
esac
