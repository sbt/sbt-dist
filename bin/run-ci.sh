#!/usr/bin/env bash
set -eu

buildLinux() {
  pushd sbt
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false clean launcherPackage/Universal/packageBin launcherPackage/Universal/packageZipTarball
  mv launcher-package/target/universal/sbt.zip launcher-package/target/universal/sbt-$SBT_VER.zip
  mv launcher-package/target/universal/sbt.tgz launcher-package/target/universal/sbt-$SBT_VER.tgz
  popd
}

releaseLinux() {
  pushd sbt
  echo "launcherPackage / credentials += Credentials(Path.userHome / \".sbt\" / \"credentials\")" > local.sbt
  mkdir -p $HOME/.sbt/
  echo "realm = Artifactory Realm" >  $HOME/.sbt/credentials
  echo "host = scala.jfrog.io"     >> $HOME/.sbt/credentials
  echo "user = $BINTRAY_USER"      >> $HOME/.sbt/credentials
  echo "password = $BINTRAY_PASS"  >> $HOME/.sbt/credentials
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false -Dsbt.build.includesbtn=false -Dsbt.build.includesbtlaunch=false launcherPackage/Rpm/publish launcherPackage/Debian/packageBin
  rm -f $HOME/.sbt/credentials

  curl -H "X-JFrog-Art-Api:$BINTRAY_PASS" -XPUT "https://scala.jfrog.io/artifactory/debian/sbt-$SBT_VER.deb;deb.distribution=all;deb.component=main;deb.architecture=all" -T "target/sbt_${SBT_VER}_all.deb"

  # https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-CalculateDebianRepositoryMetadata
  curl --user "$BINTRAY_USER:$BINTRAY_PASS" https://scala.jfrog.io/artifactory/api/deb/reindex/debian --data ""
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
