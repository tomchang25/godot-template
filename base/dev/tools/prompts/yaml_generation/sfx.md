# SFX YAML Generation Standard

Use this with `base.md` when generating placeholder SFX patch YAML files.

## Output Rules

- Each sound is its own YAML file under `data/yaml/sfx/`.
- One YAML = one playable sound with optional deterministic variants.
- The filename must match `sound_id` + `.yaml`, for example `ui_click.yaml`.
- Follow `base.md` output format rules: no fences, two-space indent, no YAML comments, snake_case IDs.
- Placeholder SFX should be useful enough for iteration, not final-production audio.

## Schema

```yaml
sound_id: ui_click
seed: 42
variant_count: 2
source:
  waveform: square
  duty_cycle: 0.5
pitch:
  start_hz: 800
  end_hz: 400
  slide_curve: 0.0
  vibrato_depth: 0.0
  vibrato_rate: 0.0
  arpeggio_shifts: []
  arpeggio_step_time: 0.0
envelope:
  attack_s: 0.001
  decay_s: 0.02
  sustain_s: 0.05
  release_s: 0.03
  sustain_level: 0.6
  sustain_punch: 0.0
color:
  lp_cutoff_hz: 0
  hp_cutoff_hz: 0
  bitcrush_bits: 16
playback:
  volume_db: -6.0
  pitch_random_min: 0.98
  pitch_random_max: 1.02
  limiter_key: ""
  max_per_window: 8
  window_sec: 0.05
```

## Generic Placeholder Set

- `ui_click`: short square tick for buttons.
- `ui_hover`: very quiet sine tick for hover/focus.
- `ui_confirm`: rising chime for accept/success/select.
- `ui_cancel`: descending blip for cancel/back/fail.
- `hit_light`: filtered noise burst for light impacts.
- `dash`: filtered noise sweep for quick movement.
- `pickup`: rising triangle/arpeggio for collectibles.
- `error`: dark descending tone for blocked actions.

## Validation Rules

1. `sound_id` is required and must be a non-empty snake_case string.
2. `seed` is required and must be an integer.
3. `variant_count` must be >= 1.
4. Total envelope duration should stay under 2.0 seconds.
5. Use explicit values rather than relying on renderer defaults.
6. `start_hz` and `end_hz` should stay between 20 and 8000.
7. `duty_cycle` must be 0.0-1.0 and only matters for `square`.
8. `bitcrush_bits` must be 1-16.
9. `volume_db` should usually be -24 to 0.
