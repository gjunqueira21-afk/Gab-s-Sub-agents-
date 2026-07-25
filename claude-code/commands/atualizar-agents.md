---
description: Atualiza os subagentes do time de finanças/jurídico (pesquisa + auto-edição da Base dinâmica)
argument-hint: [nome parcial de um agente, opcional — ex. fidc]
---

O usuário pediu para atualizar "meus agents" — o time personalizado de subagentes: github-deep-research, fidc-economics, credito-analyst, backtest-analyst, equity-research-br, equity-research-us, macro-economist, quant-data-engineer, juridico-societario.

Faça o seguinte:

1. Confirme quais desses arquivos existem em `.claude/agents/` (projeto) e `~/.claude/agents/` (usuário).
2. Se `$ARGUMENTS` não estiver vazio, filtre apenas os agentes cujo nome contenha `$ARGUMENTS`; caso contrário, atualize todos.
3. Para cada agente da lista, um por vez, invoque o próprio subagente com esta instrução exata: "Execute seu Protocolo de auto-atualização: pesquise as novidades dos últimos 35 dias nos seus domínios de conhecimento, rode o Radar GitHub e edite a seção 'Base dinâmica' do seu arquivo. Retorne o resumo do que mudou."
4. Se algum subagente falhar em editar o próprio arquivo, aplique você mesmo a edição na seção "Base dinâmica" dele com o resultado que o subagente retornou (nunca altere frontmatter nem seções fixas).
5. Ao final, apresente um relatório consolidado em tabela: agente | principais mudanças no mundo | o que foi gravado | ferramentas novas do GitHub. Destaque em uma linha o achado mais importante do mês.

Observação: atualizar os 9 agentes consome bastante contexto/tokens — se o usuário estiver com pressa, sugira rodar em blocos (ex.: `/atualizar-agents equity`).
