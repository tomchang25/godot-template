# Lot & Haul → 通用 Godot Template 改造計畫

> 目標：把 Lot & Haul 抽掉遊戲血肉，留下一套**資料驅動骨架**，可直接拿來開發 RPG / Incremental 遊戲。
> 策略（已確認）：保留**最小可運作垂直切片** + **保留並泛用化 YAML→TRES 資料管線**。
> 本文件是一次性轉換指南，轉換完成後可刪除。

---

## 1. 設計總則

template 的核心價值在四條「脊椎」，全部與遊戲題材無關：

1. **資料管線**：YAML（人寫）→ `.tres`（生成）→ `ResourceDirLoader` → Registry → 遊戲讀取。
2. **啟動編排**：`RegistryCoordinator` 統一 register / migrate / validate 生命週期。
3. **存檔**：JSON 序列化 + schema 版本 + migration。
4. **場景路由**：`GameManager` + `SceneRegistry` 集中切場景。

外加開發基礎建設（同樣保留）：狀態機 framework、事件驅動 audio、commit / lint / docs 分層規範。

改造不是「刪到空」，而是**抽掉 Storage Wars 的概念（item / clue / car / auction / customer…），把每條脊椎泛用化，再留一個 generic 範例把整條鏈跑通**。

---

## 2. 三類檔案盤點

### ✅ 保留（基礎設施，多半原樣或小改）

| 路徑 | 處理 |
|---|---|
| `common/framework/state_machine/` | 原樣保留 |
| `common/audio/`（events / bus） | 原樣保留（音效類別都是 generic） |
| `common/utils/random_utils.gd`、`spatial_random_utils.gd` | 原樣保留 |
| `global/autoload/event_bus.gd` | 保留（目前是空殼，正好當乾淨範本） |
| `global/autoload/registry_coordinator.gd` | 原樣保留 |
| `global/autoload/resource_dir_loader.gd` | 原樣保留 |
| `dev/tools/` 管線（`yaml_to_tres.py`、`tres_to_yaml.py`、`validate_yaml.py`、`yaml_stats.py`、`tres_lib/`） | 保留 + 泛用化（見 §4） |
| `dev/tools/lint_standards.py`、`lint_changed.py`、`hooks/pre-commit` | 原樣保留 |
| `dev/skills/`（commit、gdscript、theme、semver） | 原樣保留（全 generic） |
| `dev/standards/` | 保留 + 去遊戲化（見 §5） |
| `dev/docs/README.md`（三層文件規則） | 原樣保留 |
| `global/theme/`、`project.godot` 設定、folder colors | 保留 + 改名清單（見 §6） |
| `LICENSE`、`NOTICE`、`.editorconfig`、`.gitattributes`、`.gitignore` | 原樣保留 |

### 🔧 改造（泛用化，不是刪）

| 目標 | 現狀 | 改造方向 |
|---|---|---|
| Registry 模式 | 六個 registry 幾乎重複的樣板 | 抽出 generic `ResourceRegistry` 基底（§3.1） |
| `SaveManager` | 欄位全硬編 Lot&Haul 概念 | 改成 section 註冊機制（§3.2） |
| `GameManager` + `SceneRegistry` | 固定 19 場景 + 19 個 `go_to_*` | 改成字典式場景表 + 單一 `go_to()`（§3.3） |
| `global/constants/data_paths.gd` | 列十種遊戲資料夾 | 只留範例 + 自家新增的目錄 |
| `global/utils/registry_audit.gd` | 對 SceneRegistry 硬檢查欄位 | 改成走泛用場景表 |
| `dev/tools/tres_lib/registry.py` | 註冊九種遊戲 entity spec | 只留範例 spec（§4） |

### ❌ 移除（Lot & Haul 專屬血肉）

| 路徑 | 說明 |
|---|---|
| `game/run/`（auction、cargo、inspection、lot_browse、reveal、location_entry、run_review） | 全部 run-phase 場景 |
| `game/meta/`（customer_sell、day_summary、hub、knowledge、location_select、storage、vehicle） | 全部 hub-phase 場景 |
| `game/shared/item_display/`、`game/shared/packing/` | 遊戲專屬 UI |
| `common/gameplay/`（customer、day_summary、item_entry、lot_entry、run_record、research_slot） | 遊戲 runtime 型別 |
| `common/utils/sell_math.gd`、`perk_effects.gd` | 遊戲計價 / perk 邏輯 |
| `data/definitions/`（item、clue、car、category、location、lot、perk、attribute、super_category、cargo_shapes） | 全部遊戲資源類別 |
| `data/yaml/`、`data/tres/` 全部內容 | 全部遊戲內容 |
| `global/autoload/registries/`（item、clue、car、location、category、super_category） | 全部遊戲 registry |
| `global/autoload/knowledge_manager.gd`、`meta_manager.gd`、`run_manager.gd` | 遊戲 manager |
| `global/constants/economy.gd` | 遊戲經濟常數 |
| `assets/cars/` | 遊戲美術 |
| `stage/`（runs / testbeds / tilesets） | 遊戲測試場 |
| `dev/docs/systems/`、`dev/docs/plans/`、`dev/docs/archived/`、`dev/docs/vision/` | 全部遊戲設計文件 |
| `dev/tools/prompts/yaml_generation/`（item/category 規則）、`yaml_generation_prompt.md` | 遊戲內容生成規則（留 base 改寫成範例） |
| `dev/tools/tres_lib/entities/`（item、clue、car、category、location、lot、perk、super_category、attribute_data、commodity、clue_data） | 遊戲 entity spec |
| `CHANGELOG.md`、`TODO.md` 內容 | 清空重置（檔案保留） |

---

## 3. 脊椎泛用化設計

### 3.1 Generic ResourceRegistry 基底

六個 registry 的共通形狀：載入目錄 → `_by_id` 字典 → `get_*_by_id` / `get_all_*` / `size` / `validate`。

新增 `global/autoload/registry/resource_registry.gd`：

```gdscript
# resource_registry.gd
# Base autoload for a data-driven registry: loads all .tres under a directory,
# keyed by an id getter, and exposes generic lookup + lifecycle hooks.
class_name ResourceRegistry
extends Node

var _by_id: Dictionary = {}        # id (String) -> Resource

## Subclass overrides: directory of .tres files and how to read each id.
func _dir_path() -> String:        return ""
func _id_of(_r: Resource) -> String: return ""

func _ready() -> void:
    _by_id = ResourceDirLoader.load_by_id(_dir_path(), _id_of)
    RegistryCoordinator.register(self)

func get_by_id(id: String) -> Resource: return _by_id.get(id, null)
func get_all() -> Array:           return _by_id.values()
func size() -> int:                return _by_id.size()

## Default validation: non-empty. Subclasses override for save cross-checks.
func validate() -> bool:
    if size() == 0:
        push_error("%s: registry is empty" % name); return false
    return true
```

具體 registry 縮成幾行：

```gdscript
# example_registry.gd
extends ResourceRegistry
func _dir_path() -> String: return DataPaths.EXAMPLES_DIR
func _id_of(r: Resource) -> String:
    return (r as ExampleEntityData).entity_id if r is ExampleEntityData else ""
```

**取捨**：GDScript 沒有泛型，`get_all()` 回傳 untyped `Array`。若呼叫端要 `Array[ExampleEntityData]`，在具體 registry 加一個薄包裝（如 `get_all_examples()`）即可。`registries.md` 標準需據此更新（仍要求 `get_<singular>_by_id` 等 API，但允許繼承基底）。

### 3.2 SaveManager → section 註冊機制

把硬編欄位換成「各系統自行登記要存什麼」。新增介面：

```gdscript
# save_section.gd — 一個可序列化的存檔區塊。
class_name SaveSection
extends RefCounted
func section_id() -> String: return ""
func to_dict() -> Dictionary: return {}
func from_dict(_data: Dictionary) -> void: pass
```

`SaveManager` 改成：

```gdscript
const SAVE_PATH := "user://save.json"
const SCHEMA_VERSION := 1
var _sections: Dictionary = {}   # id -> SaveSection

func register_section(s: SaveSection) -> void: _sections[s.section_id()] = s

func save() -> void:
    var out := {"schema_version": SCHEMA_VERSION, "sections": {}}
    for id in _sections: out["sections"][id] = _sections[id].to_dict()
    FileAccess.open(SAVE_PATH, FileAccess.WRITE).store_string(JSON.stringify(out, "\t"))

func load() -> void:
    # read file → migrate by schema_version → for each section: from_dict(...)
    ...
```

範例切片提供一個 `ExampleSaveSection`（存玩家擁有的 example id 清單 + 一個數值），在自己的 `_ready()` 呼叫 `SaveManager.register_section(self)`。Migration 由 `RegistryCoordinator.run_migrations()` 既有機制承接。

### 3.3 GameManager / SceneRegistry → 字典式場景表

`SceneRegistry` 改成：

```gdscript
# scene_registry.gd
class_name SceneRegistry
extends Resource
@export var scenes: Dictionary = {}   # String key -> PackedScene
func get_scene(key: String) -> PackedScene: return scenes.get(key, null)
```

`GameManager` 收斂成單一入口 + 通用 payload 交接（把現有 `_pending_day_summary` 泛化）：

```gdscript
@export var scenes: SceneRegistry
var _pending_payload: Variant = null

func go_to(key: String, payload: Variant = null) -> void:
    _pending_payload = payload
    var ps := scenes.get_scene(key)
    if ps == null: push_error("GameManager: no scene for '%s'" % key); return
    get_tree().change_scene_to_packed(ps)

func consume_payload() -> Variant:
    var p := _pending_payload; _pending_payload = null; return p
```

`registry_audit.gd` 改成檢查 `scenes.scenes` 字典裡每個值都非 null。

---

## 4. 資料管線泛用化

管線本身是 spec-plugin 架構（`EntitySpec` protocol + `REGISTRY` 清單），加新型別＝寫一個 spec 模組並註冊，已經很通用。改造重點是**清掉九個遊戲 entity，只留一個範例 entity**：

1. `dev/tools/tres_lib/entities/` 只留 `example_entity.py`（由 `item.py` 簡化：id + name + 數值，去掉 clue 交叉參照、rarity、category link）。
2. `dev/tools/tres_lib/registry.py` 的 `REGISTRY` 只列 `example_entity_spec`。
3. `yaml_to_tres.py` 的 `_SKIP_IF_EMPTY` 清成空集合或只留範例。
4. `dev/tools/prompts/`：刪 `yaml_generation/category.md`、`item.md` 與遊戲版 `yaml_generation_prompt.md`；把 `base.md` 改寫成「如何替 template 新增一種 entity（寫 spec + yaml + registry）」的教學。
5. `validate_yaml.py`：移除遊戲專屬交叉驗證（clue 參照、category 連結等），只留範例 schema 檢查。

> **新增 entity 的流程**（寫進 README）：寫 `data/definitions/<x>_data.gd` → 寫 `data/yaml/<x>.yaml` → 寫 `tres_lib/entities/<x>.py` spec 並加入 `REGISTRY` → 寫 `<x>_registry.gd extends ResourceRegistry` → 加進 `project.godot` autoload + `data_paths.gd`。

---

## 5. 最小垂直切片（活範本）

留一條端到端鏈，證明四條脊椎都通：

```
data/definitions/example_entity_data.gd   # class ExampleEntityData: entity_id, display_name, value
data/yaml/example_entity.yaml             # 2~3 筆範例資料
tres_lib/entities/example_entity.py       # spec
data/tres/examples/*.tres                 # 由管線生成
global/autoload/registry/example_registry.gd
global/autoload/example_save_section.gd
game/example/example_scene.gd + .tscn     # 列出所有 example、點一個 +1 存值、可存檔/讀檔、按鈕回主畫面
```

`example_scene` 設為 `project.godot` 的 `run/main_scene`。它示範：Registry 讀資料、SaveSection 存狀態、`GameManager.go_to()` 切場景、`EventBus` 發訊號。開發者照這條鏈複製就能長出 RPG 的 `MonsterData`/`SkillData` 或 Incremental 的 `GeneratorData`/`UpgradeData`。

---

## 6. 設定與文件重置

- `project.godot`：`config/name` 改名（如 `"Godot Data-Driven Template"`）；autoload 收斂成 `EventBus → RegistryCoordinator → ExampleRegistry → SaveManager → AudioManager → GameManager`；`folder_colors` 去掉 `stage`，保留 common/data/game/global；`main_scene` 指向 example_scene。
- `CLAUDE.md`：改寫成 template 說明——四條脊椎、新增 entity 流程、目錄結構、規範連結。保留「sandboxed shell phantom corruption」「conventions / don'ts」等與題材無關的段落。
- `TODO.md` / `CHANGELOG.md`：清空成 template 起始狀態（CHANGELOG 留一筆 `template extracted from lot-and-haul`）。
- `dev/standards/project_structure.md`、`registries.md`：更新目錄樹與 registry 基底規則。其餘標準（naming、commit、scene architecture、enforcement）多半 generic，小修即可。
- `dev/docs/`：刪 `systems/ plans/ archived/ vision/`，只留 `README.md`（三層規則）。

---

## 7. 建議執行順序（每步都讓專案維持可開啟）

> 重點：先**加**泛用設施與範例切片（不破壞現有），確認能 boot，**再拆**遊戲內容。避免拆到一半專案開不起來。

1. **開分支 + 標記**：`git switch -c template-extraction`，先 commit 現狀當還原點。
2. **加基礎設施（非破壞）**：新增 `ResourceRegistry` 基底、`SaveSection` 介面、字典式 `SceneRegistry` / `GameManager.go_to()`（與舊版並存）。
3. **建範例切片**：`ExampleEntityData` + yaml + spec + registry + save section + `example_scene`；跑 `yaml_to_tres.py` 生 `.tres`；把 main_scene 指過去，確認能 boot 並跑通存讀檔。
4. **拆遊戲內容**：刪 `game/run`、`game/meta`、`game/shared`、`common/gameplay`、遊戲 utils、`data/definitions` 遊戲型別、`data/yaml|tres` 遊戲內容、六個遊戲 registry、三個 manager、`economy.gd`、`assets/cars`、`stage/`。
5. **泛用化管線**：精簡 `tres_lib/entities` 與 `registry.py`、改寫 prompts、瘦身 `validate_yaml.py`、更新 `data_paths.gd`。
6. **清設定與文件**：`project.godot` autoload / 改名 / folder colors、`registry_audit.gd`、`CLAUDE.md`、`TODO.md`、`CHANGELOG.md`、`dev/standards`、`dev/docs`。
7. **驗證**：
   - `python dev/tools/yaml_to_tres.py --godot-root .`（範例資料生成成功）
   - `python dev/tools/validate_yaml.py`
   - `python dev/tools/lint_standards.py --files <changed>`
   - `grep -rn` 搜尋遺留參照：`ItemData|ClueData|CarData|RunManager|MetaManager|KnowledgeManager|Economy|customer|auction`，確認沒有 dangling reference。
   - 在 Godot 4.6 開啟專案、執行 example_scene（需人工，沙箱無法跑 Godot 編輯器）。
   - 刪除本檔 `TEMPLATE_CONVERSION_PLAN.md`。

---

## 8. 風險與待確認

- **audio presets**：若 audio 系統有引用具體音檔的 preset 資源（非僅 class），需一併清理；目前看 events/ 都是 generic 類別，`assets/` 只有 `cars/`，風險低。
- **theme 依賴**：`global/theme` 若引用被刪場景的字型/圖示需檢查（多半自含）。
- **RPG vs Incremental 差異**：兩者都吃這套資料驅動骨架；差別在 runtime loop（回合戰鬥 vs tick 累加），那是 template **之上**的東西，本次不預建——範例切片刻意保持中性。若日後想要，可在純骨架上再各開一個範例分支。
- **`.opencode` / `.commitsage` / `.vscode`**：個人/工具設定，建議保留或視情況加入 `.gitignore`。
```
