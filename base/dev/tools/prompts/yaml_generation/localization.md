# Localization YAML Generation Standard

Use this when generating localization source YAML under `localization/source/<locale>/`.

## Output Rules

- Files are grouped by block: `<locale>_<block>.yaml`, for example `en_ui.yaml`.
- The top-level key is the locale id.
- English (`en`) is the canonical key set. Other locales should mirror the same keys unless a fallback is intentionally used.
- Keys are upper snake case with a domain prefix: `UI_OK`, `SYSTEM_LOADING`, `ITEM_APPLE_NAME`.
- Keep values human-readable strings only. Do not include Godot BBCode unless the consuming UI expects it.

## Schema

```yaml
en:
  UI_OK: "OK"
  UI_CANCEL: "Cancel"
```

## Workflow

1. Add or edit source YAML under `localization/source/<locale>/`.
2. Ensure `localization/localization_config.yaml` includes the block.
3. Run `python dev/tools/localization_yaml_to_csv.py --godot-root .`.
4. Generated CSV files land in `localization/generated/`.
