#!/usr/bin/env bash
# Verifica, de FORA do servidor, se o sistema da clínica está no ar.
# Só endereços públicos — nenhuma senha, nenhum dado de paciente.
# Sai com 0 se tudo ok; 1 se algo caiu (e escreve o motivo em $GITHUB_STEP_SUMMARY / falhas.txt).
set -u

API=https://api.clinicarochaperyassu.com.br
PAINEL=https://painel.clinicarochaperyassu.com.br
S3=https://s3.clinicarochaperyassu.com.br

# Teste do próprio alarme: SIMULAR_QUEDA=1 aponta o painel para um endereço inexistente.
if [ "${SIMULAR_QUEDA:-}" = "1" ]; then PAINEL=https://simulacao-de-queda.clinicarochaperyassu.com.br; fi

: > falhas.txt

# Uma checagem só conta como falha se falhar duas vezes seguidas (20s entre elas),
# para não acordar ninguém por um soluço de rede.
checar() {
  local nome="$1" url="$2" esperado="$3" exige="${4:-}"
  local tentativa codigo corpo
  for tentativa in 1 2; do
    corpo=$(curl -sS -m 25 -w '\n%{http_code}' "$url" 2>&1)
    codigo=$(printf '%s' "$corpo" | tail -n1)
    corpo=$(printf '%s' "$corpo" | sed '$d')
    if [ "$codigo" = "$esperado" ] && { [ -z "$exige" ] || printf '%s' "$corpo" | grep -q "$exige"; }; then
      echo "ok    $nome ($codigo)"
      return 0
    fi
    [ "$tentativa" = 1 ] && sleep 20
  done
  echo "FALHA $nome: esperado $esperado, veio '$codigo' $(printf '%s' "$corpo" | head -c 200)"
  echo "- **$nome** — esperado $esperado, veio \`$codigo\` (${url})" >> falhas.txt
  return 1
}

falhou=0
# readiness: a API responde E consegue falar com banco, redis e arquivos.
checar "API e Sofia (banco, fila, arquivos)" "$API/health/readiness" 200 '"status":"ok"' || falhou=1
# rota protegida: 401 prova que o código da API está servindo (não só o proxy).
checar "API servindo rotas" "$API/alerts/escalation-whatsapp" 401 || falhou=1
checar "Painel (tela de login)" "$PAINEL/login" 200 || falhou=1
checar "Arquivos (MinIO)" "$S3/minio/health/live" 200 || falhou=1

exit $falhou
