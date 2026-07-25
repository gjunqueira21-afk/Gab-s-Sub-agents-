## Meus agents (time personalizado de finanças/jurídico)

Tenho 9 skills de especialistas instaladas em `~/.hermes/skills/`: github-deep-research, fidc-economics, credito-analyst, backtest-analyst, equity-research-br, equity-research-us, macro-economist, quant-data-engineer, juridico-societario. Sempre que a tarefa casar com a description de uma delas, carregue a skill e assuma o papel descrito nela antes de responder.

Quando eu disser "atualize meus agents" (opcionalmente citando nomes para filtrar):
1. Para cada skill da lista, siga o "Protocolo de auto-atualização" descrito no SKILL.md dela: pesquise ~35 dias de novidades dos domínios da skill e rode o Radar GitHub.
2. Edite APENAS a seção "Base dinâmica" do `~/.hermes/skills/<nome>/SKILL.md` correspondente: `last_updated` para hoje + itens `- [AAAA-MM-DD] fato — fonte`, máximo 30 linhas. Nunca altere o frontmatter nem as seções fixas.
3. Feche com relatório consolidado: agente | mudanças no mundo | ferramentas novas do GitHub.
