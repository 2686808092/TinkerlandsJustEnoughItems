// Public extension surface v1. Native schema assumptions are centralized here.
function JEI_API() {
    if (!variable_global_exists("__JEI_API")) {
        variable_global_set("__JEI_API", {version: 1, providers: [], revision: 0,
            registerRecipeProvider: JEI_RegisterRecipeProvider, refresh: JEI_Refresh,
            getRecipes: JEI_GetRecipes, getUses: JEI_GetUses, toolbarAction: JEI_DefaultToolbarAction,
            itemPolicy: JEI_DefaultItemPolicy, searchMetadata: JEI_DefaultSearchMetadata,
            runtime: JEI_Runtime(), transferRecipe: undefined, capabilities: ["overlay", "uses", "search_v2", "bindings", "pause"]});
    }
    return variable_global_get("__JEI_API");
}

function JEI_RegisterRecipeProvider(_key, _callback) {
    var _api = JEI_API();
    for (var _i = 0; _i < array_length(_api.providers); _i++) {
        if (_api.providers[_i].key == _key) {
            _api.providers[_i].load = _callback;
            _api.revision += 1;
            return;
        }
    }
    array_push(_api.providers, {key: _key, load: _callback});
    _api.revision += 1;
}

function JEI_Refresh() { JEI_Rebuild(JEI_State()); }
function JEI_GetRecipes(_id) { return JEI_Recipes(JEI_State(), _id); }
function JEI_GetUses(_id) { return JEI_Uses(JEI_State(), _id); }

function JEI_DefaultToolbarAction(_s, _input) {
    if (!_input.leftPressed) return;
    if (_input.ctrl) _s.cheat = !_s.cheat;
    else { JEI_StopSearch(_s); _s.configOpen = !_s.configOpen; _s.binding = ""; }
}

function JEI_ToolbarAction(_s, _input) {
    var _api = JEI_API();
    var _callback = _api.toolbarAction;
    _callback(_s, _input);
}

function JEI_VirtualBase() { return 1000000000; }
function JEI_BlueprintBase() { return 2000000000; }
function JEI_Number(_value) {
    var _type = typeof(_value);
    return _type == "number" || _type == "int32" || _type == "int64";
}
function JEI_IsRitual(_id) { return JEI_Number(_id) && _id >= JEI_VirtualBase() && _id < JEI_BlueprintBase(); }
function JEI_IsBlueprint(_id) { return JEI_Number(_id) && _id >= JEI_BlueprintBase(); }

function JEI_BlueprintTemplate() {
    return JEI_ItemRow(JEI_NativeItemIndex("recipe_blueprint"));
}

function JEI_BlueprintRecipe(_id) {
    var _recipes = variable_global_get("__DB_RECIPE");
    var _index = _id - JEI_BlueprintBase();
    if (_index <= 0 || _index >= array_length(_recipes)) return undefined;
    var _recipe = _recipes[_index];
    // Field 6 is the native default-unlocked flag.
    if (!is_array(_recipe) || array_length(_recipe) < 7 || _recipe[6] != false) return undefined;
    var _nativeId = _recipe[0];
    if (!(JEI_Number(_nativeId) && _nativeId > 0 || is_string(_nativeId) && _nativeId != "") || !is_array(_recipe[4])) return undefined;
    return _recipe;
}

function JEI_BlueprintIndex(_recipeId) {
    var _recipes = variable_global_get("__DB_RECIPE");
    if (JEI_Number(_recipeId) && _recipeId > 0 && _recipeId < array_length(_recipes)) {
        var _id = JEI_BlueprintBase() + _recipeId;
        var _recipe = JEI_BlueprintRecipe(_id);
        if (is_array(_recipe) && _recipe[0] == _recipeId) return _id;
    }
    if (!JEI_Number(_recipeId) && !is_string(_recipeId)) return -1;
    for (var _i = 1; _i < array_length(_recipes); _i++) {
        var _row = _recipes[_i];
        if (!is_array(_row) || array_length(_row) < 2) continue;
        if (_row[0] != _recipeId && (!is_string(_recipeId) || _row[1] != _recipeId)) continue;
        var _id = JEI_BlueprintBase() + _i;
        return is_array(JEI_BlueprintRecipe(_id)) ? _id : -1;
    }
    return -1;
}

function JEI_BlueprintRow(_id) {
    var _recipe = JEI_BlueprintRecipe(_id);
    if (!is_array(_recipe)) return undefined;
    var _base = JEI_BlueprintTemplate();
    var _output = JEI_ItemRow(JEI_NativeItemIndex(_recipe[2]));
    if (!is_array(_base) || !is_array(_output) || _base[0] == _output[0] || is_undefined(_output[5]) || !sprite_exists(_output[5])) return undefined;
    var _name = JEI_LocalizedItemName(_output) + " · " + string(_base[2]) + " #" + string(_recipe[0]);
    return [_base[0], string(_recipe[1]) + "_blueprint", _name, _base[3], _base[4], _output[5], _base[6], _base[7]];
}

function JEI_NativeItemIndex(_id) {
    var _db = variable_global_get("__DB_ITEM");
    if (JEI_Number(_id)) return (_id >= 0 && _id < array_length(_db) && is_array(_db[_id])) ? real(_id) : -1;
    if (is_string(_id)) {
        var _cache = variable_global_exists("__JEI_ItemKeys") ? variable_global_get("__JEI_ItemKeys") : undefined;
        if (!is_struct(_cache) || _cache.count != array_length(_db)) _cache = JEI_IndexItemKeys(_db);
        if (variable_struct_exists(_cache.keys, _id)) {
            var _at = variable_struct_get(_cache.keys, _id); var _row = _db[_at];
            if (is_array(_row) && (_row[0] == _id || _row[1] == _id)) return _at;
            _cache = JEI_IndexItemKeys(_db);
            if (variable_struct_exists(_cache.keys, _id)) return variable_struct_get(_cache.keys, _id);
        }
    }
    return -1;
}

function JEI_IndexItemKeys(_db) {
    var _cache = {count:array_length(_db), keys:{}};
    for (var _i = 0; _i < _cache.count; _i++) {
        var _r = _db[_i]; if (!is_array(_r) || array_length(_r) < 2) continue;
        if (is_string(_r[0]) && !variable_struct_exists(_cache.keys, _r[0])) variable_struct_set(_cache.keys, _r[0], _i);
        if (is_string(_r[1]) && !variable_struct_exists(_cache.keys, _r[1])) variable_struct_set(_cache.keys, _r[1], _i);
    }
    variable_global_set("__JEI_ItemKeys", _cache); return _cache;
}

function JEI_ReforgeAffixName(_row) {
    var _key = string(_row[1]);
    if (string_pos("affix_scroll_", _key) != 1 && _key != "reforge_useless") return "";
    var _db = JEI_AcquisitionDB("ITEM");
    var _ref = JEI_AcquisitionField(_db, _row, "ref_data");
    if (!JEI_Number(_ref) || _ref <= 0) return "";
    var _name = db_affix(_ref, E_ITEM_AFFIX_DATA.name);
    return is_string(_name) && _name != "undefined" ? _name : "";
}

function JEI_LocalizedItemName(_row) {
    var _name = string(_row[2]);
    var _affix = JEI_ReforgeAffixName(_row);
    if (_affix != "") {
        var _locale = JEI_Locale();
        if (_name == "Reforge Scroll" || _name == "Reforge") _name = JEI_Text("reforge_scroll");
        return _locale == 0 ? _name + " (" + _affix + ")" : _name + "（" + _affix + "）";
    }
    if (string_pos("{$refMob}", _name) == 0) return _name;
    // Native get_affix_and_name expands this template using the referenced mob.
    var _itemFields = variable_global_get("__STR_E_ITEM_DATA");
    var _mobFields = variable_global_get("__STR_E_MOB_DATA");
    var _mobs = variable_global_get("__DB_MOB");
    if (!is_struct(_itemFields) || !variable_struct_exists(_itemFields, "ref_mob") ||
        !is_struct(_mobFields) || !variable_struct_exists(_mobFields, "name") || !is_array(_mobs)) return _name;
    var _ref = _itemFields.ref_mob;
    if (_ref >= array_length(_row)) return _name;
    var _mob = _row[_ref];
    if (!JEI_Number(_mob) || _mob <= 0 || _mob >= array_length(_mobs)) return _name;
    var _data = _mobs[_mob];
    var _field = _mobFields.name;
    if (!is_array(_data) || _field >= array_length(_data)) return _name;
    var _mobName = _data[_field];
    if (!is_string(_mobName) || _mobName == "") return _name;
    return string_replace_all(_name, "{$refMob}", _mobName);
}

function JEI_RitualRow(_id) {
    if (!variable_global_exists("__DB_CUBE")) return undefined;
    var _db = variable_global_get("__DB_CUBE");
    var _at = _id - JEI_VirtualBase();
    if (_at < 0 || _at >= array_length(_db)) return undefined;
    var _r = _db[_at];
    if (!is_array(_r) || array_length(_r) < 7) return undefined;
    return [_id, "cube:" + string(_r[1]), _r[5], 1, 1, _r[2], 1, "Cube ritual"];
}

function JEI_CubeFingerprint() {
    if (!variable_global_exists("__CUBE_RECIPES")) return -1;
    var _db = variable_global_get("__CUBE_RECIPES");
    if (!is_array(_db)) return -1;
    return array_length(_db);
}

function JEI_LoadCubeRecipes(_s) { JEI_LoadCubeRecipeRange(_s, 1, 1000000000); }
function JEI_LoadCubeRecipeRange(_s, _from, _to) {
    if (_from == 1) { _s.cubeCount = 0; _s.cubeSkipped = 0; }
    if (!variable_global_exists("__CUBE_RECIPES")) return;
    var _db = variable_global_get("__CUBE_RECIPES");
    if (!is_array(_db)) return;
    // Native recipes store rows; the public JEI grid stores columns.
    // The fourth entry is [output, amount, callback, cubeId].
    // Read the completed runtime table. Never execute a recipe's reward callback.
    for (var _i = _from; _i < min(_to, array_length(_db)); _i++) {
        var _r = _db[_i];
        if (!is_array(_r)) continue;
        if (array_length(_r) != 4 || !is_array(_r[3]) || array_length(_r[3]) < 4) { _s.cubeSkipped += 1; continue; }
        var _valid = true;
        var _grid = [];
        var _groups = [];
        for (var _y = 0; _y < 3; _y++) {
            if (!is_array(_r[_y]) || array_length(_r[_y]) != 3) { _valid = false; break; }
        }
        if (!_valid) { _s.cubeSkipped += 1; continue; }
        for (var _x = 0; _x < 3 && _valid; _x++) {
            var _column = [];
            for (var _y = 0; _y < 3; _y++) {
                var _cell = _r[_y][_x];
                if (!is_array(_cell) || array_length(_cell) < 2 || !JEI_Number(_cell[1])) { _valid = false; break; }
                var _id = JEI_NativeItemIndex(_cell[0]);
                if (_cell[1] > 0 && _id < 0) { _valid = false; break; }
                array_push(_column, {id: _id, amount: _cell[1]});
                if (_id >= 0 && _cell[1] > 0) {
                    var _found = false;
                    for (var _g = 0; _g < array_length(_groups); _g++) {
                        if (_groups[_g].ids[0] == _id) { _groups[_g].amount += _cell[1]; _found = true; break; }
                    }
                    if (!_found) array_push(_groups, {ids: [_id], amount: _cell[1]});
                }
            }
            array_push(_grid, _column);
        }
        if (!_valid) { _s.cubeSkipped += 1; continue; }
        var _out = _r[3];
        var _id = JEI_NativeItemIndex(_out[0]);
        var _ritual = _id < 0 && !is_undefined(_out[2]);
        var _cubeId = _out[3];
        if (!JEI_Number(_cubeId)) { _s.cubeSkipped += 1; continue; }
        if (_ritual) {
            _id = JEI_VirtualBase() + _cubeId;
            if (is_undefined(JEI_RitualRow(_id))) { _s.cubeSkipped += 1; continue; }
            array_push(_s.items, _id);
        }
        if (_id < 0) { _s.cubeSkipped += 1; continue; }
        JEI_AddRecipe(_s, {id: _cubeId, item: _id, station: undefined, amount: _ritual ? 0 : _out[1],
            groups: _groups, cooking: false, provider: "cube", grid: _grid, ritual: _ritual});
        _s.cubeCount += 1;
    }
    if (_s.cubeSkipped > 0) show_debug_message("JustEnoughItems: skipped " + string(_s.cubeSkipped) + " incompatible cube rows");
}

function JEI_RunRecipeProviders(_s) {
    var _api = JEI_API();
    for (var _i = 0; _i < array_length(_api.providers); _i++) {
        var _provider = _api.providers[_i];
        var _callback = _provider.load;
        _callback(_s);
    }
    _s.providerRevision = _api.revision;
    _s.cubeFingerprint = JEI_CubeFingerprint();
}
