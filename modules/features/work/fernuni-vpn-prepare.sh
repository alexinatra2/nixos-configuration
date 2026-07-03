set -euo pipefail

cp @passwordSecretPath@ @passwordFile@

totpSecret="$(@pythonExe@ @normalizeTotpSeedScript@ @totpSeedSecretPath@)"

if [ -z "$totpSecret" ]; then
  printf 'FernUni TOTP secret is missing or empty\n' >&2
  exit 1
fi

printf 'base32:%s\n' "$totpSecret" > @tokenSecretFile@
