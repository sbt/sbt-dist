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
  echo "LocalProject(\"launcherPackage\") / credentials += Credentials(Path.userHome / \".sbt\" / \"credentials\")" > local.sbt
  mkdir -p $HOME/.sbt/
  echo "realm = Artifactory Realm" >  $HOME/.sbt/credentials
  echo "host = scala.jfrog.io"     >> $HOME/.sbt/credentials
  echo "user = $BINTRAY_USER"      >> $HOME/.sbt/credentials
  echo "password = $BINTRAY_PASS"  >> $HOME/.sbt/credentials
  sbt -Dsbt.build.version=$SBT_VER -Dsbt.build.offline=false -Dsbt.build.includesbtn=false -Dsbt.build.includesbtlaunch=false launcherPackage/Rpm/publish launcherPackage/Debian/packageBin
  rm -f $HOME/.sbt/credentials

  curl -H "X-JFrog-Art-Api:$BINTRAY_PASS" -XPUT "https://scala.jfrog.io/artifactory/debian/sbt-$SBT_VER.deb;deb.distribution=all;deb.component=main;deb.architecture=all" -T "launcher-package/target/sbt_${SBT_VER}_all.deb"

  # https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-CalculateDebianRepositoryMetadata
  curl --user "$BINTRAY_USER:$BINTRAY_PASS" https://scala.jfrog.io/artifactory/api/deb/reindex/debian --data ""
  popd
}

installGpgkey() {
  gpg --version
  echo "$PGP_SECRET" | base64 --decode | gpg --batch --import
}

releaseNightly() {
  pushd sbt

  installGpgkey
  BASE_VERSION="2.1.0"
  DATE_STR="$(date -u +%Y%m%d)"
  if ! GIT_SHA_FULL="$(git rev-parse HEAD 2>/dev/null)"; then
    echo "Error: not a valid git repository" >&2
    exit 1
  fi
  GIT_SHA_SHORT="${GIT_SHA_FULL:0:7}"
  NIGHTLY_VERSION="${BASE_VERSION}-bin-${DATE_STR}-${GIT_SHA_SHORT}-NIGHTLY"

  echo "credentials += Credentials(Path.userHome / \".sbt\" / \"credentials\")" > local.sbt
  echo "ThisBuild / version := \"$NIGHTLY_VERSION\"" >> local.sbt
  echo "ThisBuild / publishTo := Some(\"local-maven-nightlies\" at \"https://scala.jfrog.io/artifactory/local-maven-nightlies\")" >> local.sbt

  mkdir -p $HOME/.sbt/
  echo "realm = Artifactory Realm" >  $HOME/.sbt/credentials
  echo "host = scala.jfrog.io"     >> $HOME/.sbt/credentials
  echo "user = $BINTRAY_USER"      >> $HOME/.sbt/credentials
  echo "password = $BINTRAY_PASS"  >> $HOME/.sbt/credentials

  sbt --server releaseLowerUtils release

  rm -f $HOME/.sbt/credentials
  popd
}

releaseSonatype() {
  pushd sbt

  installGpgkey

  echo "credentials += Credentials(Path.userHome / \".sbt\" / \"credentials\")" > local.sbt
  echo "ThisBuild / version := \"$SBT_VER\"" >> local.sbt

  mkdir -p $HOME/.sbt/
  echo "host = central.sonatype.com"   > $HOME/.sbt/credentials
  echo "user = $SONATYPE_USERNAME"     >> $HOME/.sbt/credentials
  echo "password = $SONATYPE_PASSWORD" >> $HOME/.sbt/credentials

  sbt --server $RELEASE_COMMAND

  rm -f $HOME/.sbt/credentials
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
  nightly)
    echo nightly
    releaseNightly
    ;;
  sonatype)
    echo Sonatype release
    releaseSonatype
    ;;
  *)
    echo no mode is set
    ;;
esac
