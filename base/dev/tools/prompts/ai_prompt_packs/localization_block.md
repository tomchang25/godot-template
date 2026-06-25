# Localization Block Prompt

Generate localization YAML for one block and locale.

Inputs:

- Locale: `<locale id>`
- Block: `<ui/system/tutorial/etc>`
- Canonical English keys and meanings: `<list>`
- Tone: `<neutral/playful/formal/etc>`

Output requirements:

- Return only YAML, no fences or commentary.
- Follow `dev/tools/prompts/yaml_generation/localization.md`.
- Preserve all keys exactly.
- Do not invent new keys unless asked.
- Keep placeholders such as `{count}` or `%s` exactly intact.
