// Just Enough Items for Tinkerlands @VERSION@.

function JEI_Locale() {
    var _langs = variable_global_get("__ALL_LANGS__");
    var _index = variable_global_get("__LANG_ENUM");
    if (_langs[_index] == "chinese_simplified" || _langs[_index] == "chinese_traditional") return 1;
    return 0;
}

function JEI_Text(_key) {
    var _mode = JEI_Locale();
    var _text = {
        title: ["Just Enough Items", "物品与合成", "物品與合成"],
        drag: ["Drag title to move  |  J / Esc: close", "拖动标题栏移动  |  J / Esc 关闭", "拖動標題列移動  |  J / Esc 關閉"],
        search: ["Search items...", "搜索物品…", "搜尋物品…"],
        browse: ["Wheel / drag scrollbar  |  Click: recipe", "滚轮 / 拖动滚动条  |  点击查看合成", "滾動 / 拖動捲軸  |  點擊查看合成"],
        cheat_hint: ["Left: +1  |  Shift+Left: stack  |  Right: recipe", "左键获取 1 个 | Shift+左键整组 | 右键看配方", "左鍵取得 1 個 | Shift+左鍵整組 | 右鍵看配方"],
        cheat_off: ["Cheat: OFF", "作弊获取：关", "作弊取得：關"],
        cheat_on: ["Cheat: ON", "作弊获取：开", "作弊取得：開"],
        toggle: ["Ctrl + Left click: toggle cheat", "Ctrl+左键切换作弊获取", "Ctrl+左鍵切換作弊取得"],
        select: ["Click an item to view its crafting path", "点击物品，查看合成来源", "點擊物品，查看合成來源"],
        none: ["No crafting recipe", "暂无合成配方", "暫無合成配方"],
        material: ["Acquire this material in the world", "此材料需在游戏中获取", "此材料需在遊戲中取得"],
        acquisition: ["How to obtain", "获取途径", "取得來源"],
        source_mob: ["Monster drop", "怪物掉落", "怪物掉落"],
        source_hard: ["Monster drop - Hard difficulty", "怪物掉落 · 困难难度", "怪物掉落 · 困難難度"],
        source_soul: ["Soul loot - special conditions", "灵魂掉落 · 特殊条件", "靈魂掉落 · 特殊條件"],
        source_net: ["Catch with a bug net", "使用捕虫网捕获", "使用捕蟲網捕獲"],
        source_shop: ["NPC shop / trade", "NPC 商店 / 交易", "NPC 商店 / 交易"],
        source_quest: ["Quest reward", "任务奖励", "任務獎勵"],
        source_contract: ["Contract reward", "契约奖励", "契約獎勵"],
        source_fish: ["Fishing", "钓鱼", "釣魚"],
        source_fish_chest: ["Fishing treasure", "钓鱼宝箱", "釣魚寶箱"],
        source_chest: ["Chest loot - varies by location", "宝箱战利品 · 随地点变化", "寶箱戰利品 · 隨地點變化"],
        source_harvest: ["Gather / dismantle", "采集 / 拆除", "採集 / 拆除"],
        source_mine: ["Mine with a pickaxe", "使用镐开采", "使用鎬開採"],
        source_chop: ["Chop with an axe", "使用斧砍伐", "使用斧砍伐"],
        source_crop: ["Harvest crops", "收获作物", "收穫作物"],
        source_break: ["Break scenery objects", "打破场景摆件", "打破場景擺件"],
        source_container: ["World chest", "场景宝箱", "場景寶箱"],
        source_object: ["World resource (pictured)", "环境资源", "环境资源"],
        source_block: ["World block (pictured)", "场景方块（见左图）", "場景方塊（見左圖）"],
        station: ["Station: ", "制作台：", "製作台："],
        hand: ["By hand", "徒手制作", "徒手製作"],
        cooking: ["Cooking", "烹饪", "烹飪"],
        cube: ["Transmutation Cube", "转化方块", "轉化方塊"],
        reforge_scroll: ["Reforge Scroll", "重铸卷轴", "重鑄卷軸"],
        pattern: ["Cube layout - click ingredients", "魔方排列 · 点击材料查看来源", "魔方排列 · 點擊材料查看來源"],
        totals: ["Total ingredients", "材料总量", "材料總量"],
        config: ["JEI Settings", "JEI 配置", "JEI 設定"],
        developer: ["Developer mode (If you don't know what this does, please leave it off)",
            "开发者模式（如果你不知道这是做什么的，请不要打开它）",
            "開發者模式（如果你不知道這是做什麼的，請不要打開它）"],
        setting_off: ["OFF", "关", "關"],
        setting_on: ["ON", "开", "開"],
        recipe: ["Recipe ", "配方 ", "配方 "],
        switch_recipe: [" (click to switch)", "（点击切换）", "（點擊切換）"],
        ingredients: ["Ingredients", "所需材料", "所需材料"],
        choose: ["Choose any one", "任选一种", "任選一種"],
        path: ["Path: ", "来源：", "來源："],
        loading: ["Loading...", "加载中…", "載入中…"],
        empty: ["No matching items", "没有匹配物品", "沒有符合物品"],
        count: [" items", " 个物品", " 個物品"],
        output: ["Output", "成品", "成品"],
        more: ["Wheel: more ingredients", "滚动查看更多材料", "滾動查看更多材料"],
        hint: ["Left / Right click: crafting path", "左键 / 右键：查看合成来源", "左鍵 / 右鍵：查看合成來源"]
    };
    if (variable_struct_exists(_text, _key)) return variable_struct_get(_text, _key)[_mode];
    return JEI_SettingsText(_key, _mode);
}

function JEI_Init(_s) {
    _s.ready = true;
    _s.open = false;
    _s.inventoryWasOpen = false;
    _s.detailOpen = false;
    _s.viewMode = "recipes";
    _s.category = "";
    _s.page = 0;
    _s.detailPage = 0;
    _s.pauseOwned = false;
    _s.searchFocused = false;
    _s.textInput = undefined;
    _s.searchHistory = [];
    _s.searchHistoryAt = -1;
    _s.searchCursor = 0;
    _s.searchTail = "";
    _s.searchViewStart = 0;
    _s.searchCaretAt = 0;
    _s.searchRepeatKey = -1;
    _s.searchRepeatAt = 0;
    _s.searchRenderCache = undefined;
    _s.pinyinEnabled = true;
    _s.filterDeveloper = false;
    _s.catalogJob = undefined;
    _s.catalogReady = false;
    _s.acquisitionsReady = false;
    JEI_SearchIndexStart(_s);
    _s.tooltipCache = undefined;
    _s.settings = JEI_Settings();
    _s.configTab = 0;
    _s.sourceCollapsed = {};
    _s.binding = "";
    _s.bindingNotice = "";
    _s.byUses = {};
    _s.allRecipes = [];
    _s.searchDocs = {};
    _s.configOpen = false;
    _s.cheat = false;
    _s.developer = false;
    _s.development = {};
    _s.hiddenCount = 0;
    _s.dragTarget = "";
    _s.positioned = false;
    _s.x = 0;
    _s.y = 0;
    _s.offsetX = 0;
    _s.offsetY = 0;
    _s.pointerX = -1;
    _s.pointerY = -1;
    _s.search = "";
    _s.filterQuery = undefined;
    _s.language = -1;
    _s.itemCount = -1;
    _s.recipeCount = -1;
    _s.cookCount = -1;
    _s.items = [];
    _s.filtered = [];
    _s.byItem = {};
    _s.acquisitions = {};
    _s.scroll = 0;
    _s.recipeScroll = 0;
    _s.selected = -1;
    _s.variant = 0;
    _s.rows = [];
    _s.hover = -1;
    _s.hoverToggle = false;
    _s.shielded = false;
    _s.savedInput = [];
    _s.guardContainer = undefined;
    _s.captureLeft = false;
    _s.captureRight = false;
    _s.frameCapture = false;
    _s.cubeGrid = [];
    _s.recipeVisible = 9;
    _s.providerRevision = -1;
    _s.cubeFingerprint = -1;
    _s.skin = {panel: asset_get_index("sprGUI9SliceInventorySlot"), row: asset_get_index("sprGUI9SliceButton02"),
        selected: asset_get_index("sprGUI9SliceWood01"), hover: asset_get_index("sprGUI9SliceButton02"),
        wrench: asset_get_index("sprGUIIngameIconCrafting")};
}

function JEI_State() {
    var _s = ModInstance.Find("jei");
    if (!ModInstance.Exists(_s)) _s = ModInstance.Create("jei", undefined, undefined, undefined, undefined, "");
    if (!variable_instance_exists(_s, "ready")) JEI_Init(_s);
    return _s;
}

function JEI_ItemRow(_id) {
    if (JEI_IsBlueprint(_id)) return JEI_BlueprintRow(_id);
    if (JEI_IsRitual(_id)) return JEI_RitualRow(_id);
    var _db = variable_global_get("__DB_ITEM");
    if (!JEI_Number(_id) || _id < 0 || _id >= array_length(_db)) return undefined;
    var _row = _db[_id];
    if (!is_array(_row) || array_length(_row) <= 7) return undefined;
    return _row;
}

function JEI_Name(_id) {
    var _row = JEI_ItemRow(_id);
    if (is_undefined(_row)) return "#" + string(_id);
    return JEI_LocalizedItemName(_row);
}

function JEI_Alternatives(_entry) {
    var _out = [];
    if (!is_array(_entry) || array_length(_entry) < 2) return _out;
    // Current native recipes can use db_item_pool (e.g. any wood).
    var _pool = false;
    if (array_length(_entry) > 2) _pool = _entry[2] == asset_get_index("db_item_pool");
    if (!_pool) {
        if (!is_undefined(JEI_ItemRow(_entry[0]))) array_push(_out, _entry[0]);
        return _out;
    }
    var _db = variable_global_get("__DB_ITEM_POOL");
    var _id = _entry[0];
    if (_id < 0 || _id >= array_length(_db)) return _out;
    var _row = _db[_id];
    if (!is_array(_row) || array_length(_row) < 3 || !is_array(_row[2])) return _out;
    var _items = _row[2];
    for (var _i = 0; _i < array_length(_items); _i++) {
        var _item = _items[_i];
        if (is_array(_item) && array_length(_item) > 0 && !is_undefined(JEI_ItemRow(_item[0]))) array_push(_out, _item[0]);
    }
    return _out;
}

function JEI_AddRecipe(_s, _recipe) {
    if (!variable_struct_exists(_recipe, "provider")) _recipe.provider = _recipe.cooking ? "cooking" : "craft";
    if (!variable_struct_exists(_recipe, "grid")) _recipe.grid = [];
    if (!variable_struct_exists(_recipe, "ritual")) _recipe.ritual = false;
    var _key = string(_recipe.item);
    var _list = [];
    if (variable_struct_exists(_s.byItem, _key)) _list = variable_struct_get(_s.byItem, _key);
    array_push(_list, _recipe);
    variable_struct_set(_s.byItem, _key, _list);
    array_push(_s.allRecipes, _recipe);
    var _seen = {};
    for (var _g = 0; _g < array_length(_recipe.groups); _g++) {
        var _ids = _recipe.groups[_g].ids;
        for (var _j = 0; _j < array_length(_ids); _j++) {
            var _useKey = string(_ids[_j]);
            if (variable_struct_exists(_seen, _useKey)) continue;
            variable_struct_set(_seen, _useKey, true);
            var _uses = variable_struct_exists(_s.byUses, _useKey) ? variable_struct_get(_s.byUses, _useKey) : [];
            array_push(_uses, _recipe);
            variable_struct_set(_s.byUses, _useKey, _uses);
        }
    }
}

function JEI_EnsureCatalog(_s) {
    var _api = JEI_API();
    var _items = variable_global_get("__DB_ITEM");
    var _recipes = variable_global_get("__DB_RECIPE");
    if (!is_array(_items) || !is_array(_recipes)) return;
    var _cooks = variable_global_exists("__DB_COOK") ? variable_global_get("__DB_COOK") : undefined;
    var _cookCount = is_array(_cooks) ? array_length(_cooks) : 0;
    if (_s.language != variable_global_get("__LANG_ENUM") || _s.providerRevision != _api.revision ||
        _s.cubeFingerprint != JEI_CubeFingerprint() || _s.itemCount != array_length(_items) ||
        _s.recipeCount != array_length(_recipes) || _s.cookCount != _cookCount) JEI_Rebuild(_s);
}

function JEI_Rebuild(_s) {
    JEI_CancelCatalog(_s);
    JEI_IndexItemKeys(variable_global_get("__DB_ITEM"));
    _s.items = [];
    _s.byItem = {};
    _s.byUses = {};
    _s.allRecipes = [];
    var _items = variable_global_get("__DB_ITEM");
    _s.itemCount = array_length(_items);
    var _seen = {};
    for (var _i = 1; _i < array_length(_items); _i++) {
        JEI_AddCatalogItem(_s, _i, _items[_i], _seen);
    }
    var _recipes = variable_global_get("__DB_RECIPE");
    _s.recipeCount = array_length(_recipes);
    for (var _i = 1; _i < array_length(_recipes); _i++) JEI_BuildRecipeRow(_s, _recipes[_i], _i);
    var _cooks = variable_global_exists("__DB_COOK") ? variable_global_get("__DB_COOK") : undefined;
    _s.cookCount = is_array(_cooks) ? array_length(_cooks) : 0;
    if (_s.cookCount > 0) {
        for (var _i = 1; _i < array_length(_cooks); _i++) JEI_BuildCookRow(_s, _cooks[_i]);
    }
    JEI_RunRecipeProviders(_s);
    JEI_BuildAcquisitions(_s);
    JEI_ClassifyCatalog(_s);
    JEI_BuildSearch(_s);
    _s.language = variable_global_get("__LANG_ENUM");
    _s.filterQuery = undefined;
    JEI_Filter(_s);
    JEI_RecipeRows(_s);
    _s.catalogReady = true; _s.acquisitionsReady = true;
}

function JEI_Recipes(_s, _id) {
    var _key = string(_id);
    if (variable_struct_exists(_s.byItem, _key)) return variable_struct_get(_s.byItem, _key);
    return [];
}

function JEI_RecipeRows(_s) {
    _s.rows = [];
    _s.cubeGrid = [];
    _s.recipeVisible = 9;
    var _recipes = JEI_ViewRecipes(_s);
    if (array_length(_recipes) == 0) {
        var _sources = _s.viewMode == "recipes" ? JEI_Acquisitions(_s, _s.selected) : [];
        for (var _i = 0; _i < array_length(_sources); _i++) array_push(_s.rows, {id: -1, source: _sources[_i]});
        return;
    }
    _s.variant = clamp(_s.variant, 0, array_length(_recipes) - 1);
    var _recipe = _recipes[_s.variant];
    if (_recipe.provider == "cube") { _s.cubeGrid = _recipe.grid; _s.recipeVisible = 5; }
    for (var _g = 0; _g < array_length(_recipe.groups); _g++) {
        var _group = _recipe.groups[_g];
        if (array_length(_group.ids) > 1) array_push(_s.rows, {id: -1, amount: _group.amount, choice: true});
        for (var _i = 0; _i < array_length(_group.ids); _i++) {
            array_push(_s.rows, {id: _group.ids[_i], amount: _group.amount, choice: array_length(_group.ids) > 1});
        }
    }
}

function JEI_Select(_s, _id, _mode = "recipes") {
    if (_mode == "uses" && array_length(JEI_Uses(_s, _id)) == 0) return;
    var _sameItem = _s.detailOpen && _s.selected == _id;
    if (_sameItem && _s.viewMode == _mode && _mode != "category") return;
    _s.selected = _id;
    _s.detailOpen = true;
    _s.viewMode = _mode;
    _s.category = "";
    _s.sourceCollapsed = {};
    _s.detailPage = 0;
    _s.variant = 0;
    _s.recipeScroll = 0;
    JEI_RecipeRows(_s);
}

function JEI_Hit(_r, _x, _y) {
    return _x >= _r[0] && _x < _r[2] && _y >= _r[1] && _y < _r[3];
}

function JEI_InputKeys() {
    return ["__MOUSE_WINDOW_X__", "__MOUSE_WINDOW_Y__", "__MOUSE_X__", "__MOUSE_Y__",
        "__K_MENU_LEFT_CLICK", "__K_MENU_LEFT_CLICK_PRESSED", "__K_MENU_LEFT_CLICK_RELEASED",
        "__K_MENU_RIGHT_CLICK", "__K_MENU_RIGHT_CLICK_PRESSED", "__K_MENU_RIGHT_CLICK_RELEASED"];
}

function JEI_BlockNative(_s) {
    if (_s.shielded) return;
    var _keys = JEI_InputKeys();
    _s.savedInput = [];
    for (var _i = 0; _i < array_length(_keys); _i++) {
        var _key = _keys[_i];
        var _exists = variable_global_exists(_key);
        var _value = undefined;
        if (_exists) _value = variable_global_get(_key);
        array_push(_s.savedInput, {exists: _exists, value: _value});
        if (_exists) variable_global_set(_key, _i < 4 ? -100000 : false);
    }
    _s.shielded = true;
}

function JEI_RestoreNative(_s) {
    if (!_s.shielded) return;
    var _keys = JEI_InputKeys();
    for (var _i = 0; _i < array_length(_keys); _i++) {
        var _saved = _s.savedInput[_i];
        if (_saved.exists) variable_global_set(_keys[_i], _saved.value);
    }
    _s.shielded = false;
}

function JEI_ReleaseFrame(_s) {
    if (!_s.shielded) return;
    // Input may already have refreshed in Begin Step. Keep fresh pointer/button
    // values, and never replay last frame's captured clicks into the next frame.
    var _keys = JEI_InputKeys();
    for (var _i = 0; _i < 4; _i++) {
        var _saved = _s.savedInput[_i];
        if (_saved.exists && variable_global_get(_keys[_i]) == -100000) variable_global_set(_keys[_i], _saved.value);
    }
    _s.shielded = false;
}

function JEI_StationName(_recipe) {
    if (_recipe.provider == "cube") {
        var _item = JEI_StationItem(_recipe);
        return _item >= 0 ? JEI_Name(_item) : JEI_Text("cube");
    }
    if (_recipe.cooking) return JEI_Text("cooking");
    if (is_undefined(_recipe.station) || _recipe.station <= 0) return JEI_Text("hand");
    var _db = variable_global_get("__DB_INTERACTABLE");
    if (_recipe.station < array_length(_db)) {
        var _row = _db[_recipe.station];
        if (is_array(_row) && array_length(_row) > 9 && is_real(_row[9])) return JEI_Name(_row[9]);
    }
    return "#" + string(_recipe.station);
}

function JEI_Box(_s, _r, _selected, _z, _interactive = true) {
    var _hover = _interactive && JEI_Hit(_r, _s.pointerX, _s.pointerY);
    JEI_Fill(_r, _selected ? make_color_rgb(91, 69, 48) : (_hover ? make_color_rgb(66, 56, 57) : JEI_SurfaceColor()), !_interactive ? 0 : (_selected || _hover ? 0.96 : 0.18));
    draw_set_color(_selected ? make_color_rgb(222, 189, 137) : make_color_rgb(117, 98, 87));
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], true);
    draw_set_color(c_white);
}

function JEI_Fit(_text, _chars) {
    if (string_length(_text) <= _chars) return _text;
    return string_copy(_text, 1, max(1, _chars - 2)) + "..";
}

function JEI_Icon(_id, _x, _y, _size) {
    var _row = JEI_ItemRow(_id);
    if (is_undefined(_row) || is_undefined(_row[5]) || !sprite_exists(_row[5])) return;
    var _sprite = _row[5];
    JEI_SpriteIcon(_sprite, _x, _y, _size);
}

function JEI_SpriteIcon(_sprite, _x, _y, _size) {
    if (is_undefined(_sprite) || !sprite_exists(_sprite)) return;
    var _w = sprite_get_width(_sprite);
    var _h = sprite_get_height(_sprite);
    var _scale = _size / max(_w, _h);
    var _ox = sprite_get_xoffset(_sprite);
    var _oy = sprite_get_yoffset(_sprite);
    draw_sprite_ext(_sprite, 0, _x + (_ox - _w / 2) * _scale, _y + (_oy - _h / 2) * _scale,
        _scale, _scale, 0, c_white, 1);
}


function JEI_BuildRecipeRow(_s, _row, _index) {
    if (!is_array(_row) || array_length(_row) < 6 || !is_array(_row[4])) return;
    var _item = JEI_NativeItemIndex(_row[2]);
    if (_item <= 0) return;
    var _groups = [];
    var _raw = _row[4];
    for (var _g = 0; _g < array_length(_raw); _g++) {
        var _entry = _raw[_g];
        var _ids = JEI_Alternatives(_entry);
        if (array_length(_ids) > 0) array_push(_groups, {ids: _ids, amount: _entry[1]});
    }
    var _recipe = {id: _row[0], item: _item, station: _row[3], amount: max(1, _row[5]), groups: _groups, cooking: false};
    JEI_AddRecipe(_s, _recipe);
    var _blueprint = JEI_BlueprintBase() + _index;
    if (is_array(JEI_BlueprintRow(_blueprint)) && JEI_BlueprintIndex(_row[0]) == _blueprint) {
        array_push(_s.items, _blueprint);
        variable_struct_set(_s.byUses, string(_blueprint), [_recipe]);
    }
}

function JEI_BuildCookRow(_s, _row) {
            if (!is_array(_row) || array_length(_row) < 7 || !is_real(_row[6]) || !is_array(_row[3])) return;
            var _groups = [];
            var _raw = _row[3];
            for (var _g = 0; _g < array_length(_raw); _g++) {
                var _ids = _raw[_g];
                if (is_array(_ids) && array_length(_ids) > 0) array_push(_groups, {ids: _ids, amount: 1});
            }
            JEI_AddRecipe(_s, {id: _row[0], item: _row[6], station: undefined, amount: 1, groups: _groups, cooking: true});
}
