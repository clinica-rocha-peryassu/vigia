#!/usr/bin/env bash
# Uma rodada longa do vigia: checa a cada 5 min por até $DURACAO_MIN minutos.
#
# Por quê (27/10/2026): o GitHub não roda o agendamento `*/5` de verdade — em 22–27/10 foram só
# 5 a 8 rodadas por dia, com buracos de até 5 horas. Uma queda curta passava sem ser vista, e uma
# longa só era vista horas depois. Agora cada rodada fica viva quase 6 horas checando sozinha, e
# a próxima já espera na fila (concurrency) para emendar quando esta terminar.
set -u
fim=$(( $(date +%s) + ${DURACAO_MIN:-340} * 60 ))
caiu_por_ultimo=0
while :; do
  bash verificar.sh
  caiu_por_ultimo=$?
  bash avisar.sh "$caiu_por_ultimo" || echo "aviso falhou (gh) — tenta de novo na próxima checagem"
  [ "$(( $(date +%s) + 300 ))" -ge "$fim" ] && break
  sleep 300
done
exit "$caiu_por_ultimo"
