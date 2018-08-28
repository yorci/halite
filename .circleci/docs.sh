#!/usr/bin/env sh

DOCS_PATH="docs"
TAGS=$(git tag -l)
DEFAULT_VERSION=$(git tag --merged master | sort | tail -n 1)
DEFAULT_VERSION=$(echo $DEFAULT_VERSION | awk '{gsub(/^v/, ""); print}')

# Clean up
rm -rf $DOCS_PATH
mkdir -p $DOCS_PATH

# Generate master docs
crystal docs --output="${DOCS_PATH}/master"

# Generate version docs
for TAG in $TAGS; do
  NAME=$(echo $TAG | awk '{gsub(/^v/, ""); print}')
  git checkout -b $NAME $TAG

  COMMIT_STATUS="[${TAG}](${GH_REF}/blob/master/CHANGELOG.md)"
  sed -i -e "s/latest commit/$(echo ${COMMIT_STATUS} | sed -e "s/\//\\\\\//g")/" README.md
  crystal docs --output="${DOCS_PATH}/${NAME}"
  git reset --hard
  git checkout master
  git branch -d $NAME
done

echo "<html>
<header>
  <meta http-equiv=\"refresh\" content=\"3; url=\"${GH_URL}/${DEFAULT_VERSION}/index.html\" />
</header>
<body>
<p><a href=\"${GH_URL}/${DEFAULT_VERSION}/index.html\">Redirect to ${DEFAULT_VERSION}</a></p>
</body>
</html>" > "${DOCS_PATH}/index.html"
