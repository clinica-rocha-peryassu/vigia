#!/usr/bin/env bash
# Abre, lembra ou fecha o aviso de queda conforme o resultado da última checagem ($1: 0 = no ar).
# Uma issue por queda: abre quando cai (menciona o Dr → e-mail), comenta a cada hora enquanto
# continua fora, e fecha quando volta (outro e-mail: "voltou").
set -u
falhou="$1"
aberta=$(gh issue list --state open --label queda --json number --jq '.[0].number // empty')
agora=$(TZ=America/Sao_Paulo date '+%d/%m %H:%M')
if [ "$falhou" != "0" ]; then
  if [ -z "$aberta" ]; then
    gh label create queda --color B60205 2>/dev/null || true
    {
      echo "@rperyassu-cpu o sistema da clínica parece FORA DO AR desde $agora (horário de Brasília)."
      echo
      echo "Enquanto estiver fora, **a Sofia não recebe as mensagens dos pacientes** e o painel não abre."
      echo
      cat falhas.txt
      echo
      echo "Roteiro: memória \`reference-vps-fora-do-ar-runbook\` (entrar pelo Web console da Hostinger)."
    } > corpo.md
    gh issue create --title "🚨 Sistema da clínica fora do ar ($agora)${TESTE:-}" --label queda --body-file corpo.md
  else
    ultimo=$(gh issue view "$aberta" --json updatedAt --jq .updatedAt)
    if [ $(( $(date +%s) - $(date -d "$ultimo" +%s) )) -ge 3600 ]; then
      { echo "@rperyassu-cpu continua fora às $agora."; echo; cat falhas.txt; } > corpo.md
      gh issue comment "$aberta" --body-file corpo.md
    fi
  fi
elif [ -n "$aberta" ]; then
  gh issue close "$aberta" --comment "✅ @rperyassu-cpu voltou ao ar às $agora."
fi
