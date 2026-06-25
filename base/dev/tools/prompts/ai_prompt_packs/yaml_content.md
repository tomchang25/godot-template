# YAML Content Prompt

Generate designer-authored YAML for a registered template data entity type.

Inputs:

- Entity type: `<example_entity or project type>`
- Schema reference: `<resource fields / prompt file>`
- Count: `<number of entries>`
- Theme constraints: `<tone, genre, naming, difficulty, etc>`

Output requirements:

- Return only YAML, no fences or commentary.
- Follow `dev/tools/prompts/yaml_generation/base.md` and the entity-specific prompt.
- Use stable snake_case IDs.
- Keep generated content internally consistent and easy to hand-edit.
