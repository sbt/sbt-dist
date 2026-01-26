#!/usr/bin/env bash
set -eu

buildWindows() {
  pushd sbt
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false clean launcherPackage/Windows/packageBin
  ls launcher-package/target
  ls launcher-package/target/windows/
  mv launcher-package/target/windows/sbt.msi launcher-package/target/windows/sbt-$SBT_VER.msi
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
