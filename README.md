# Vigia

Verifica de fora, a cada 5 minutos, se o sistema da clínica está no ar (API, painel e arquivos).
Usa só endereços públicos — não há senha nem dado de paciente aqui.

Se cair: abre uma issue com o rótulo `queda` mencionando o responsável (chega e-mail), lembra a cada
hora e fecha sozinha quando volta. O job também falha, o que gera o e-mail de falha do GitHub.

Existe porque, em 17–19/10/2026, o servidor reiniciou e ficou 2,5 dias fora sem nenhum aviso —
o alarme antigo rodava dentro do próprio servidor que caiu.
