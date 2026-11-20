# JEI Extension API v1

[简体中文](extension-api.md) · [English README](readme/README.en.md)

Use `JEI_API()` or the global `__JEI_API` to access the interface. The current `version` is `1`. Access the API after JEI's scripts have loaded, such as during `OnModLoad` or a later update event.

## Recipe providers

`registerRecipeProvider(key, callback)` registers a provider by a stable key. Registering the same key again replaces its callback and increments `revision`. The callback receives the current state and uses `JEI_AddRecipe(state, recipe)` to add recipes. JEI checks for revision changes each frame and schedules a rebuild across frames. Call `refresh()` to rebuild synchronously. A provider callback runs once per rebuild, so keep it inexpensive and avoid side effects.

~~~gml
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
~~~

`item` and `groups[].ids[]` use item database row indices. Use `JEI_NativeItemIndex` to resolve a native ID or key first. `station` uses an interactable database index. An ingredient group can contain several item IDs, any one of which satisfies the requirement. The optional `grid` field contains three column arrays with three `{id, amount}` cells each. The native Transmutation Cube provider uses `provider: "cube"` to enable this layout and converts the game's `recipe[row][column]` to `grid[column][row]`.

`getRecipes(itemIndex)` returns the recipes that produce an item. `getUses(itemIndex)` returns the recipes that consume it. Both return arrays. After registering a provider, use `refresh()` to reload database rows and providers. Adding database entries requires no ZIP rebuild.

Every concrete native recipe blueprint has its own JEI catalog index. Calling `getUses()` for a blueprint returns the native recipe that it unlocks. Acquisition sources are tracked separately for each blueprint item. `Item.CreateRecipe` takes the native recipe ID, while developer ID search uses the native item ID of the blueprint template.

## Visibility policy

`api.itemPolicy(state, itemIndex, row)` returns an empty string to show the item in the regular catalog or a reason string to classify it as a developer item. The default is `JEI_DefaultItemPolicy`. The policy reads the acquisition index in `state.sources` and the loaded script keys in `state.scriptKeys`.

If the game adds a reliable flag for released items, update `catalog_adapter.gml` or replace `itemPolicy`, then increment `api.revision` or call `refresh()`. Developer mode reveals hidden items. Obtaining a hidden item that the game can generate requires cheat mode as well. Recipe effect callbacks are read-only during browsing.

## Toolbar icon

`api.toolbarAction(state, input)` handles clicks on the tool icon beside the search field. By default, left-click toggles `state.configOpen` and Ctrl+left-click toggles `state.cheat`. The settings panel toggles `state.developer`. The regular catalog uses the same item index and search state.

## What to check after a game update

- `adapters.gml` covers numeric and int64 IDs, delayed Transmutation Cube initialization, and recipe structures.
- `catalog_adapter.gml` covers item source tables, field names, asset checks, and stable WIP keys.
- `input_adapter.gml` covers native container functions, open container lists, the native title height offset, and player input fields.
- `events.gml` covers Step handling, input handoff to text fields and other game interfaces, and input shielding during drawing.
- `runtime_adapter.gml` covers inventory, multiplayer, pause, native hover, and IME window management.
- `search.gml`, `settings.gml`, and `overlay.gml` cover query syntax, persistent settings, and pagination.

After a change, run the native engine checks in the development workspace and update `verification/code-notes.md` with the observed behavior. Update this document whenever the API version changes.

## Additional capabilities since 1.4.0

The API still reports `version: 1`. Its `capabilities` include `overlay`, `uses`, `search_v2`, `bindings`, and `pause`. Existing recipe providers can continue to use the same interface.

`api.searchMetadata(state, itemIndex, row)` returns `{modName, tooltip, tags, category}`. Fields can be strings or arrays and correspond to the `@`, `$`, `#`, and `%` search prefixes. The default reads native fields and the item's namespace. You can wrap `JEI_DefaultSearchMetadata` to supply your own values, then call `refresh()`. Name search uses current localized names and stable keys. Changes to names in the same language are synchronized in batches. Since 1.5.1, pinyin spelling and initials are derived from displayed Chinese names, including official translations and names provided by translation mods. Catalog and query tasks are implemented in `catalog_jobs.gml` and `search_jobs.gml`. A completed catalog is reused across worlds.

Default tags include the native type, the localized type name, common Chinese and English type names, the folder field, the material flag, and native tags. The `@` filter accepts both search aliases and `modDisplayName`. In developer mode, `id:` matches the exact native item ID from the first field of the database row.

Version 1.5.2 added disk caching and separate readiness states. `state.catalogReady` means the item list, search, and recipes are available. `state.acquisitionsReady` means acquisition sources are ready. Custom recipe providers, `itemPolicy`, and `searchMetadata` bypass disk caching. The two metadata and policy callbacks still run after acquisition data is ready. Translation mods that edit native rows directly can reuse the cache. The fingerprint includes database contents and language data. When changing non-name data at runtime without changing table lengths, increment `revision` or call `refresh()`. Explicit refreshes remain synchronous. The API version remains 1.

Version 1.4.1 added optional `modDisplayName` for the mod name shown in hover tooltips. It falls back to `modName`. Base-game items display `Tinkerlands`, and search also accepts aliases such as `@原版`. The `tooltip` field also supplies the hover description. JEI resolves numeric native description IDs through the language table, retains the source capitalization, and renders text colors itself.

`api.runtime` and `JEI_Runtime()` refer to the same adapter object. Replace the following function fields to integrate a different native lifecycle while keeping that object identity.

| Field | Parameters and return value |
| --- | --- |
| `inventoryOpen` | No parameters. Returns whether the player inventory is open. |
| `closeInventory` | No parameters. Closes the native inventory. |
| `multiplayer` | No parameters. Returns whether the game is connected to multiplayer. The default keeps the game running if it cannot determine the network state. |
| `setPaused` | Takes a Boolean, returns whether the operation succeeded, and maintains the observable `__PAUSE_ENTITIES` state. |
| `hoveredItem` | No parameters. Returns the row index of the currently hovered native inventory item or `-1` when no item is hovered. |

The optional `api.transferRecipe(state, recipe, shiftHeld)` callback runs only when the user clicks `+`. Its default value is `undefined`, so the button appears only once a callback is assigned. The provider is responsible for checking the crafting station, player inventory, and transfer rules. Viewing recipes never calls it.
