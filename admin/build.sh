#!/bin/bash

set -e

# prep environment for publish to sonatype staging if the HEAD commit is tagged

# git on travis does not fetch tags, but we have TRAVIS_TAG
# headTag=$(git describe --exact-match ||:)

# bash string.contains according to http://stackoverflow.com/a/229606/248998
if [[ "$PUBLISH_JDK" == *"$TRAVIS_JDK_VERSION"* ]] && [[ "$TRAVIS_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9-]+)? ]]; then
  echo "Going to release from tag $TRAVIS_TAG!"
  myVer=$(echo $TRAVIS_TAG | sed -e s/^v//)
  publishVersion='set every version := "'$myVer'"'
  extraTarget="+publish-signed"
  cat admin/gpg.sbt >> project/plugins.sbt
  cp admin/publish-settings.sbt .

  # Copied from the output of genKeyPair.sh
  K=$encrypted_abe708fa1965_key
  IV=$encrypted_abe708fa1965_iv

  openssl aes-256-cbc -K $K -iv $IV -in admin/secring.asc.enc -out admin/secring.asc -d
else
  # Allow running on JVMs other than those required to build releases
  allowAnyJVM="-Dsbt.allowCrossBuildingAnyJVM=true"
fi

sbt $allowAnyJVM "$publishVersion" clean update +test +publishLocal $extraTarget
