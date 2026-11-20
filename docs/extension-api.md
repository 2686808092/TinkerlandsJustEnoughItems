# JEI 扩展接口 v1

[English](extension-api.en.md)

通过 `JEI_API()` 或全局 `__JEI_API` 获取接口。字段 `version` 当前为 `1`。在 JEI 脚本加载完成后使用；可在 `OnModLoad` 或后续更新事件接入。

## 配方提供器

`registerRecipeProvider(key, callback)` 按稳定键注册，重复注册同一个键会替换旧回调并增加 `revision`。回调接收当前状态，使用 `JEI_AddRecipe(state, recipe)` 添加配方。每帧检测版本变化并安排分帧重建；调用 `refresh()` 可同步完成。提供器回调仍执行一次，应避免在回调中执行昂贵或有副作用的工作。

```gml
var api = JEI_API();
var register = api.registerRecipeProvider;
register("my_mod:recipes", function(state) {
    var output = JEI_NativeItemIndex("my_mod:item");
    var wood = JEI_NativeItemIndex("wood");
    if (output < 0 || wood < 0) return;
    JEI_AddRecipe(state, {
        id: "my_mod:recipe_1", item: output, amount: 1,
        station: undefined, cooking: false, provider: "my_mod",
        groups: [{ids: [wood], amount: 10}]
    });
});
```

`item` 与 `groups[].ids[]` 均使用数据库行索引；先用 `JEI_NativeItemIndex` 解析原生 ID 或键。`station` 使用交互物数据库索引。一个材料组可包含多个替代材料 ID，表示任选其一。可选字段 `grid` 为三个列数组，每列三个 `{id, amount}` 格子。原生转化方块提供器使用 `provider: "cube"` 启用此布局，并将游戏的 `recipe[row][column]` 转为 `grid[column][row]`。

`getRecipes(itemIndex)` 查询产出该物品的配方，`getUses(itemIndex)` 查询消耗该物品的配方。两者均返回数组。注册提供器后，`refresh()` 重新读取数据库和提供器；新增数据库内容无需重建 ZIP。

原版具体配方蓝图有各自的 JEI 目录索引。蓝图的 `getUses()` 返回其解锁的原版配方；获取途径独立按道具蓝图记录。`Item.CreateRecipe` 接收配方的原生 ID，开发者 ID 搜索使用物品模板的原生 ID。

## 可见性策略

`api.itemPolicy(state, itemIndex, row)` 返回空字符串表示正常展示，返回原因字符串表示开发条目。默认实现为 `JEI_DefaultItemPolicy`。策略读取 `state.sources` 中的获取来源索引及 `state.scriptKeys` 中的已加载脚本键。

若后续原版增加可靠的发布标记，可集中修改 `catalog_adapter.gml`，或替换 `itemPolicy` 后增加 `api.revision` / 调用 `refresh()`。隐藏条目由开发者模式显示，可生成的隐藏物品须同时开启作弊模式才可发放。配方效果回调始终只读。

## 工具图标

`api.toolbarAction(state, input)` 是右下角工具图标的点击入口。默认处理普通左键切换 `state.configOpen`，Ctrl＋左键切换 `state.cheat`。配置页操作 `state.developer`，普通物品列表使用相同的索引和搜索状态。

## 游戏更新后的检查位置

- `adapters.gml`：数字与 int64 ID、魔方延迟初始化及配方结构。
- `catalog_adapter.gml`：物品来源表、字段名称、资源检查及 WIP 稳定键。
- `input_adapter.gml`：原生容器函数、打开容器列表、原生标题高度偏移和角色输入字段。
- `events.gml`：Step 阶段处理、文本输入/其他游戏界面的交接、Draw 阶段遮挡。
- `runtime_adapter.gml`：人物栏、联网、暂停、原生悬停和 IME 窗口管理。
- `search.gml`、`settings.gml`、`overlay.gml`：查询语法、持久设置、分页布局。

改动后运行原生引擎验证，更新 `verification/code-notes.md` 的实际依据。接口版本变更须同步本文档。

## 1.4.0 附加能力

保持 `version: 1`，`capabilities` 包含 `overlay`、`uses`、`search_v2`、`bindings`、`pause`。已有配方提供器无需修改。

`api.searchMetadata(state, itemIndex, row)` 返回 `{modName, tooltip, tags, category}`，字段可为字符串或数组，对应 `@`、`$`、`#`、`%` 搜索。默认从原生字段及物品键命名空间读取；可包装 `JEI_DefaultSearchMetadata` 后补充自定义信息，随后调用 `refresh()`。名称搜索使用当前本地化名称与稳定键，后台分批同步同语言下的名称修改。1.5.1 按实际中文显示名称生成全拼和首字母，覆盖官方中文与其他汉化来源；API 版本保持 1。目录与查询任务实现位于 `catalog_jobs.gml`、`search_jobs.gml`，完成后的目录在世界切换时复用。

默认标签包含原生类型、当前语言类型名、中英文常用类型名、目录字段、材料标记和原生标签。`@` 同时接受搜索别名和 `modDisplayName`。开发者模式下 `id:` 按物品原生 ID 精确查找，ID 取自数据库记录的第一个字段。

1.5.2 增加磁盘缓存及分阶段就绪：`state.catalogReady` 表示物品、搜索和配方可用，`state.acquisitionsReady` 表示获取途径齐全。自定义配方提供器、`itemPolicy` 或 `searchMetadata` 时自动绕过磁盘缓存；后两种回调继续在完整获取途径准备后执行。直接修改原生表的翻译 Mod 可复用缓存，指纹覆盖实际数据与语言内容。运行中修改同长度的非名称数据，仍须增加 `revision` 或调用 `refresh()`；显式刷新保持同步。接口版本仍为 1。

1.4.1 增加可选 `modDisplayName`，作为悬停卡的模组署名；缺省使用 `modName`。默认原生物品显示 `Tinkerlands`，搜索仍接受 `@原版` 等别名。`tooltip` 同时供悬停说明使用，原生数字描述 ID 会先通过语言表解析，保留原文大小写；格式颜色由 JEI 统一绘制。

`api.runtime` 与 `JEI_Runtime()` 引用同一适配对象。替换以下函数字段即可接入新的原生生命周期；保留该对象身份：

| 字段 | 参数与返回值 |
| --- | --- |
| `inventoryOpen` | 无参数，返回人物栏是否打开 |
| `closeInventory` | 无参数，关闭原生人物栏 |
| `multiplayer` | 无参数，返回是否联机；默认无法确认联网接口时保持游戏运行 |
| `setPaused` | 接收布尔值，返回是否成功；同时维护 `__PAUSE_ENTITIES` 可观察状态 |
| `hoveredItem` | 无参数，返回原生背包当前悬停物品行索引，无物品返回 `-1` |

可选 `api.transferRecipe(state, recipe, shiftHeld)` 仅在用户点击 `+` 时调用。赋值后详情窗才显示该按钮，默认值为 `undefined`。提供器负责检查所属工作站、玩家库存和转移规则；浏览配方不会触发回调。
