## Meus agents (time personalizado de finanças/jurídico)

Tenho 9 custom agents instalados em `~/.codex/agents/`: github_deep_research, fidc_economics, credito_analyst, backtest_analyst, equity_research_br, equity_research_us, macro_economist, quant_data_engineer, juridico_societario. Delegue a eles via Spawn sempre que a tarefa casar com a description.

Quando eu disser "atualize meus agents" (opcionalmente citando nomes para filtrar):
1. Para cada agente da lista, spawn o agente com: "Execute seu Protocolo de auto-atualização: pesquise ~35 dias de novidades dos seus domínios, rode o Radar GitHub e retorne os itens novos para a Base dinâmica."
2. Com o retorno de cada um, edite VOCÊ (sessão principal) o TOML correspondente em `~/.codex/agents/` (ou `.codex/agents/` do projeto): atualize apenas a seção "Base dinâmica" dentro de developer_instructions — `last_updated` para hoje + itens `- [AAAA-MM-DD] fato — fonte`, máximo 30 linhas. Nunca altere name/description/model.
3. Feche com relatório consolidado: agente | mudanças no mundo | ferramentas novas do GitHub.
