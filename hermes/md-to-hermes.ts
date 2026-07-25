// md-to-hermes.ts — converte os agentes .md (frontmatter YAML + corpo) em JSON para o Hermes.
// Uso: bun md-to-hermes.ts ./pasta-dos-agentes
// Rode de novo sempre que atualizar os .md para manter o Hermes em sincronia.
import { readdirSync, readFileSync, writeFileSync } from "fs";

const dir = process.argv[2] ?? ".";
const skip = /README|atualizar/i;

const agents = readdirSync(dir)
  .filter((f) => f.endsWith(".md") && !skip.test(f))
  .map((f) => {
    const raw = readFileSync(`${dir}/${f}`, "utf8");
    const m = raw.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
    if (!m) throw new Error(`frontmatter inválido: ${f}`);
    const fm: Record<string, string> = {};
    for (const line of m[1].split("\n")) {
      const i = line.indexOf(":");
      if (i > 0) fm[line.slice(0, i).trim()] = line.slice(i + 1).trim();
    }
    return {
      name: fm.name,
      description: fm.description,
      tools: (fm.tools ?? "").split(",").map((s) => s.trim()).filter(Boolean),
      system_prompt: m[2].trim(),
    };
  });

writeFileSync("hermes-agents.json", JSON.stringify(agents, null, 2));
console.log(`ok: ${agents.length} agentes → hermes-agents.json`);
