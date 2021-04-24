#!/usr/bin/env bash
set -eu

buildLinux() {
  git clone https://github.com/sbt/sbt.git
  pushd sbt
  cd launcher-package
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false clean universal:packageBin universal:packageZipTarball
  mv target/universal/sbt.zip target/universal/sbt-$SBT_VER.zip
  mv target/universal/sbt.tgz target/universal/sbt-$SBT_VER.tgz
  popd
}

releaseLinux() {
  git clone https://github.com/sbt/sbt.git
  pushd sbt
  cd launcher-package
  echo "credentials += Credentials(Path.userHome / \".sbt\" / \"credentials\")" > local.sbt
  echo "realm = Artifactory Realm" >  $HOME/.sbt/credentials
  echo "host = scala.jfrog.io"     >> $HOME/.sbt/credentials
  echo "user = $BINTRAY_USER"      >> $HOME/.sbt/credentials
  echo "password = $BINTRAY_PASS"  >> $HOME/.sbt/credentials
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false -Dsbt.build.includesbtn=false -Dsbt.build.includesbtlauncher=false rpm:publish debian:publish
  rm -f $HOME/.sbt/credentials
  # curl --user "$BINTRAY_USER:$BINTRAY_PASS" --data "" https://bintray.com/api/v1/calc_metadata/sbt/rpm
  # curl --user "$BINTRAY_USER:$BINTRAY_PASS" --data "" https://bintray.com/api/v1/calc_metadata/sbt/debian
  popd
}

case ${mode:-} in
  build)
    echo Linux build
    buildLinux
    ;;
  linuxrelease)
    echo Linux release
    releaseLinux
    ;;
  *)
    echo no mode is set
    ;;
esac
