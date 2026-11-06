#!/usr/bin/env bash
set -euo pipefail

: "${PILOT_USERNAME:?Defina PILOT_USERNAME}"
: "${PILOT_PASSWORD:?Defina PILOT_PASSWORD}"

# La API histórica recibe credenciales por query string. Revise logs de proxy.
# No activar xtrace (-x), no imprimir ni guardar token.
response="$(curl --fail-with-body --silent --show-error --get \
  --request POST \
  --data-urlencode "username=${PILOT_USERNAME}" \
  --data-urlencode "password=${PILOT_PASSWORD}" \
  'https://api.pilotsolution.net/v1/users/auth.php')"

token="$(printf '%s' "$response" | jq -r '.result.entitydata // empty')"
if [[ -z "$token" ]]; then
  echo "No se recibió token válido de Pilot" >&2
  exit 1
fi
echo "Autenticación completada. Token omitido por seguridad."
