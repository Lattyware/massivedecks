set -e

# Ugly hack to get around issues with typescript-json-validator.

npx typescript-json-validator src/ts/action/validation.ts \
  --collection \
  --noExtraProps \
  --format=full \
  --aliasRefs \
  --ignoreErrors \
  --usedNamedExport

sed -i \
  -e 's/allErrors: true/allErrors: false/g' \
  -e 's/<any>//g' \
  -e 's/\/\* tslint:disable \*\//\/\* eslint-disable \*\//g' \
  -e 's/ajv.addMetaSchema(require("\(.*\)"));/import metaSchema from "\1";\najv.addMetaSchema(metaSchema);/g' \
  src/ts/action/validation.validator.ts
