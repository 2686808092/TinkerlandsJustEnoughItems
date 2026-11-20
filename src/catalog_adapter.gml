// Catalog visibility is separate from cheat permission and uses stable item keys.
// The shipped game strips the optional implementation column from every item.
// Use explicit WIP/placeholder markers, resource integrity, and runtime sources.
function JEI_SourceAdd(_s, _value) {
    var _id = JEI_NativeItemIndex(_value);
    if (_id >= 0) variable_struct_set(_s.sources, string(_id), true);
}

function JEI_SourceWalk(_s, _value, _depth) {
    if (!is_array(_value) || _depth > 9) return;
    var _n = array_length(_value);
    if (_n > 1 && _value[_n - 1] == asset_get_index("db_item")) {
        JEI_SourceAdd(_s, _value[0]);
        return;
    }
    for (var _i = 0; _i < _n; _i++) {
        if (is_array(_value[_i])) JEI_SourceWalk(_s, _value[_i], _depth + 1);
    }
}

function JEI_CatalogSources(_s) {
    _s.sources = {};
    var _acquired = variable_struct_get_names(_s.acquisitions);
    for (var _i = 0; _i < array_length(_acquired); _i++) variable_struct_set(_s.sources, _acquired[_i], true);
    var _recipeKeys = variable_struct_get_names(_s.byItem);
    for (var _k = 0; _k < array_length(_recipeKeys); _k++) {
        var _recipes = variable_struct_get(_s.byItem, _recipeKeys[_k]);
        for (var _i = 0; _i < array_length(_recipes); _i++) {
            var _r = _recipes[_i];
            JEI_SourceAdd(_s, _r.item);
            for (var _g = 0; _g < array_length(_r.groups); _g++) {
                var _ids = _r.groups[_g].ids;
                for (var _j = 0; _j < array_length(_ids); _j++) JEI_SourceAdd(_s, _ids[_j]);
            }
        }
    }
    var _tables = ["LOOT", "ITEM_POOL", "NPC", "QUEST", "FISH", "MOB", "CONTRACT", "BLOCK", "INTERACTABLE", "TOP", "ROOF", "UPGRADE", "WORLDGEN"];
    for (var _t = 0; _t < array_length(_tables); _t++) {
        var _name = "__DB_" + _tables[_t];
        if (!variable_global_exists(_name)) continue;
        var _db = variable_global_get(_name);
        JEI_SourceWalk(_s, _db, 0);
        var _schemaName = "__STR_E_" + _tables[_t] + "_DATA";
        if (!variable_global_exists(_schemaName)) continue;
        var _schema = variable_global_get(_schemaName);
        var _fields = ["item", "drop", "ref_item", "reward_item", "reward_item_ref"];
        for (var _f = 0; _f < array_length(_fields); _f++) {
            if (!variable_struct_exists(_schema, _fields[_f])) continue;
            var _at = variable_struct_get(_schema, _fields[_f]);
            for (var _i = 1; _i < array_length(_db); _i++) {
                var _row = _db[_i];
                if (is_array(_row) && array_length(_row) > _at) JEI_SourceAdd(_s, _row[_at]);
            }
        }
    }
    // The character creator equips these two stock clothes directly.
    JEI_SourceAdd(_s, "clothing_worn_out_jeans");
    JEI_SourceAdd(_s, "clothing_worn_out_shirt");
}

function JEI_DefaultItemPolicy(_s, _id, _row) {
    if (JEI_IsRitual(_id)) return "";
    if (JEI_IsBlueprint(_id)) {
        var _recipe = JEI_BlueprintRecipe(_id);
        var _output = JEI_NativeItemIndex(_recipe[2]);
        return JEI_DefaultItemPolicy(_s, _output, JEI_ItemRow(_output));
    }
    var _key = string_lower(string(_row[1]));
    var _name = string_lower(string(_row[2]));
    // Native blueprint items require additional per-instance recipe data.
    if (_key == "recipe_blueprint") return "requires_instance_data";
    if (string_pos("spare", _key) > 0 || string_pos("placeholder", _key) > 0 ||
        string_pos("unused", _key) > 0 || string_pos("unimplemented", _key) > 0 ||
        string_pos("test_", _key) == 1 || string_pos("debug_", _key) == 1 || string_pos("dev_", _key) == 1 || string_pos("nea_", _key) == 1) return "development_marker";
    // These keys carry explicit WIP names in the shipped English language file;
    // stable keys keep the decision identical after translations are applied.
    var _wip = ["wall_flesh", "wall_miasma_01", "wall_miasma_02", "miasma_wood", "chest_miasma", "miasma_door_01", "miasma_door_02",
        "floor_grass_miasma_01", "floor_grass_miasma_02", "floor_grass_miasma_03", "floor_wood_miasma", "floor_flesh_miasma", "floor_dirt_miasma", "map_miasma",
        "floor_pirate_01", "floor_pirate_02", "floor_pirate_03", "roof_pirate_01", "roof_pirate_02", "roof_pirate_03"];
    // Localized WIP labels can be stale (e.g. pirate walls). Only the confirmed
    // native English identities above determine this classification.
    for (var _i = 0; _i < array_length(_wip); _i++) if (_key == _wip[_i]) return "native_wip";
    if (!JEI_Number(_row[6]) || _row[6] < 1 || _name == "" || _name == "undefined") return "incomplete_record";
    var _schema = variable_global_get("__STR_E_ITEM_DATA");
    if (variable_struct_exists(_schema, "implementation")) {
        var _flag = _row[_schema.implementation];
        if (!is_undefined(_flag) && (_flag == false || _flag == "WIP" || _flag == "unimplemented")) return "implementation_flag";
    }
    var _codeFields = ["cs_onitemuse", "cs_onitemgenerate", "cs_onweapontrigger", "cs_onweaponcharged", "cs_onweaponhit", "cs_onweaponkill"];
    for (var _f = 0; _f < array_length(_codeFields); _f++) {
        if (!variable_struct_exists(_schema, _codeFields[_f])) continue;
        var _code = _row[variable_struct_get(_schema, _codeFields[_f])];
        if (is_string(_code) && _code != "undefined" && _code != "" &&
            !variable_struct_exists(_s.scriptKeys, _code) && asset_get_index(_code) == -1) return "missing_script";
    }
    var _animations = ["use_animation", "use_animation_charged"];
    for (var _f = 0; _f < array_length(_animations); _f++) {
        var _animation = _row[variable_struct_get(_schema, _animations[_f])];
        if (is_string(_animation) && _animation != "undefined" && _animation != "" && asset_get_index(_animation) == -1) return "missing_animation";
    }
    if (is_string(_row[0])) return ""; // Valid mod entries have their own acquisition code.
    // The complete Day / Night dictionary series has native use scripts.
    if (string_pos("dictionary_", _key) == 1) return "";
    if (!variable_struct_exists(_s.sources, string(_id))) return "no_runtime_source";
    return "";
}

function JEI_ClassifyCatalog(_s) {
    JEI_CatalogSources(_s);
    _s.scriptKeys = {};
    var _scripts = variable_global_get("__DB_SCRIPT");
    for (var _i = 0; _i < array_length(_scripts); _i++) {
        var _r = _scripts[_i];
        if (is_array(_r) && array_length(_r) > 1) variable_struct_set(_s.scriptKeys, string(_r[1]), true);
    }
    _s.development = {};
    _s.hiddenCount = 0;
    var _api = JEI_API();
    var _policy = _api.itemPolicy;
    for (var _i = 0; _i < array_length(_s.items); _i++) {
        var _id = _s.items[_i];
        var _row = JEI_ItemRow(_id);
        var _reason = _policy(_s, _id, _row);
        if (_reason != "") {
            variable_struct_set(_s.development, string(_id), _reason);
            _s.hiddenCount += 1;
        }
    }
}

function JEI_DevelopmentItem(_s, _id) { return variable_struct_exists(_s.development, string(_id)); }
function JEI_CanGive(_s, _id) {
    if (!_s.cheat || JEI_IsRitual(_id) || (!_s.developer && JEI_DevelopmentItem(_s, _id))) return false;
    var _row = JEI_ItemRow(_id);
    // Concrete blueprint rows carry a validated recipe binding. The base template never does.
    return is_array(_row) && _row[1] != "recipe_blueprint" && JEI_Number(_row[6]) && _row[6] >= 1;
}

function JEI_ToggleDeveloper(_s) {
    _s.developer = !_s.developer;
    if (!_s.developer && JEI_DevelopmentItem(_s, _s.selected)) {
        _s.selected = -1;
        JEI_RecipeRows(_s);
    }
    _s.filterQuery = undefined;
    JEI_RequestSearch(_s);
}
