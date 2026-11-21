// Read only explicit acquisition fields. Never execute loot, shop or quest callbacks.
function JEI_AcquisitionDB(_table) {
    var _name = "__DB_" + _table;
    var _schema = "__STR_E_" + _table + "_DATA";
    return {rows: variable_global_exists(_name) ? variable_global_get(_name) : [],
        fields: variable_global_exists(_schema) ? variable_global_get(_schema) : {}};
}

function JEI_AcquisitionField(_db, _row, _field, _fallback = undefined) {
    if (!is_array(_row) || !variable_struct_exists(_db.fields, _field)) return _fallback;
    var _at = variable_struct_get(_db.fields, _field);
    if (_at >= array_length(_row) || is_undefined(_row[_at])) return _fallback;
    return _row[_at];
}

function JEI_AcquisitionRecord(_db, _id) {
    if (JEI_Number(_id)) {
        if (_id > 0 && _id < array_length(_db.rows) && is_array(_db.rows[_id])) return _db.rows[_id];
    } else if (is_string(_id)) {
        for (var _i = 1; _i < array_length(_db.rows); _i++) {
            var _r = _db.rows[_i];
            if (is_array(_r) && array_length(_r) > 1 && (_r[0] == _id || _r[1] == _id)) return _r;
        }
    }
    return undefined;
}

function JEI_AcquisitionName(_name) {
    if (!is_string(_name) || _name == "undefined" || _name == "Null") return "";
    // NPC database names include a save-specific personal-name placeholder.
    _name = string_replace_all(_name, "%Name%", "");
    _name = string_trim(_name);
    if (string_pos("the ", _name) == 1) _name = string_delete(_name, 1, 4);
    return _name;
}

function JEI_AcquisitionSource(_kind, _name, _sprite, _table, _row) {
    return {kind: _kind, name: _name, sprite: _sprite, table: _table, key: _row[1]};
}

function JEI_AcquisitionAdd(_s, _value, _source) {
    var _id = JEI_IsBlueprint(_value) ? _value : JEI_NativeItemIndex(_value);
    if (_id <= 0 || array_length(JEI_Recipes(_s, _id)) > 0) return;
    var _key = string(_id);
    // Repeated rolls and visual variants must not flood a single item's list.
    var _visual = variable_struct_exists(_source, "chestType") ? string(_source.chestType) : string(_source.sprite);
    var _unique = _key + "|" + _source.kind + "|" + _source.name + "|" + _visual;
    if (variable_struct_exists(_s.acquisitionSeen, _unique)) return;
    variable_struct_set(_s.acquisitionSeen, _unique, true);
    var _list = variable_struct_exists(_s.acquisitions, _key) ? variable_struct_get(_s.acquisitions, _key) : [];
    array_push(_list, _source);
    variable_struct_set(_s.acquisitions, _key, _list);
}

function JEI_AcquisitionItemIndex(_value, _database) {
    if (_database == asset_get_index("db_item")) return JEI_NativeItemIndex(_value);
    if (_database == asset_get_index("db_recipe")) return JEI_BlueprintIndex(_value);
    return -1;
}

function JEI_AcquisitionPool(_s, _id, _path = "", _depth = 0) {
    var _key = string(_id);
    if (_depth > 12 || string_pos("|" + _key + "|", _path) > 0) return [];
    if (variable_struct_exists(_s.acquisitionPools, _key)) return variable_struct_get(_s.acquisitionPools, _key);
    var _db = _s.acquisitionPoolDB;
    var _row = JEI_AcquisitionRecord(_db, _id);
    var _entries = JEI_AcquisitionField(_db, _row, "items", []);
    var _out = [];
    var _seen = {};
    if (!is_array(_entries)) return _out;
    for (var _i = 0; _i < array_length(_entries); _i++) {
        var _e = _entries[_i];
        if (!is_array(_e) || array_length(_e) < 5 || !JEI_Number(_e[1]) || _e[1] <= 0) continue;
        var _ids = [];
        if (_e[4] == asset_get_index("db_item_pool")) {
            _ids = JEI_AcquisitionPool(_s, _e[0], _path + "|" + _key + "|", _depth + 1);
        } else {
            var _item = JEI_AcquisitionItemIndex(_e[0], _e[4]);
            if (_item > 0) array_push(_ids, _item);
        }
        for (var _j = 0; _j < array_length(_ids); _j++) {
            var _itemKey = string(_ids[_j]);
            if (!variable_struct_exists(_seen, _itemKey)) {
                variable_struct_set(_seen, _itemKey, true);
                array_push(_out, _ids[_j]);
            }
        }
    }
    // Cache only complete root traversals, so a cycle cut cannot poison another root.
    if (_depth == 0) variable_struct_set(_s.acquisitionPools, _key, _out);
    return _out;
}

function JEI_AcquisitionLoot(_s, _loot, _source) {
    if (!is_array(_loot)) return;
    for (var _i = 0; _i < array_length(_loot); _i++) {
        var _e = _loot[_i];
        if (!is_array(_e) || array_length(_e) < 5 || !JEI_Number(_e[1]) || _e[1] <= 0 || !JEI_Number(_e[3]) || _e[3] <= 0) continue;
        if (_e[4] == asset_get_index("db_item_pool")) {
            var _ids = JEI_AcquisitionPool(_s, _e[0]);
            for (var _j = 0; _j < array_length(_ids); _j++) JEI_AcquisitionAdd(_s, _ids[_j], _source);
        } else {
            JEI_AcquisitionAdd(_s, JEI_AcquisitionItemIndex(_e[0], _e[4]), _source);
        }
    }
}

function JEI_AcquisitionShop(_s, _entries, _source) {
    if (!is_array(_entries)) return;
    for (var _i = 0; _i < array_length(_entries); _i++) {
        var _e = _entries[_i];
        // Custom shops append payment fields; only columns 0/1 identify the goods.
        if (is_array(_e) && array_length(_e) >= 2) JEI_AcquisitionAdd(_s, JEI_AcquisitionItemIndex(_e[0], _e[1]), _source);
    }
}

function JEI_AcquisitionObjectName(_db, _row, _field, _fallback) {
    var _item = JEI_NativeItemIndex(JEI_AcquisitionField(_db, _row, _field));
    return _item > 0 ? JEI_Name(_item) : JEI_Text(_fallback);
}

function JEI_BuildAcquisitions(_s) { JEI_BuildAcquisitionRange(_s, -1, 1, 1000000000); }
function JEI_BuildAcquisitionRange(_s, _part, _from, _to) {
    if (_part < 0 || _part == 0 && _from == 1) {
    _s.acquisitions = {};
    _s.acquisitionSeen = {};
    _s.acquisitionPools = {};
    _s.acquisitionPoolDB = JEI_AcquisitionDB("ITEM_POOL");
    _s.acquisitionQuestOwners = {};
    }
    var _db = JEI_AcquisitionDB("MOB");
    var _fields = ["loot", "loot_hard_difficulty", "soul_loot", "bug_net_loot"];
    var _kinds = ["source_mob", "source_hard", "source_soul", "source_net"];
    for (var _i = _from; (_part < 0 || _part == 0) && _i < min(_to, array_length(_db.rows)); _i++) {
        var _r = _db.rows[_i];
        var _name = JEI_AcquisitionName(JEI_AcquisitionField(_db, _r, "name"));
        if (_name == "") continue;
        var _icon = JEI_AcquisitionField(_db, _r, "icon");
        for (var _f = 0; _f < array_length(_fields); _f++) {
            JEI_AcquisitionLoot(_s, JEI_AcquisitionField(_db, _r, _fields[_f]), JEI_AcquisitionSource(_kinds[_f], _name, _icon, "MOB", _r));
        }
    }
    _db = JEI_AcquisitionDB("NPC");
    var _questOwners = _s.acquisitionQuestOwners;
    for (var _i = _from; (_part < 0 || _part == 1) && _i < min(_to, array_length(_db.rows)); _i++) {
        var _r = _db.rows[_i];
        var _name = JEI_AcquisitionName(JEI_AcquisitionField(_db, _r, "name"));
        if (_name == "") continue;
        var _icon = JEI_AcquisitionField(_db, _r, "portrait");
        var _source = JEI_AcquisitionSource("source_shop", _name, _icon, "NPC", _r);
        JEI_AcquisitionShop(_s, JEI_AcquisitionField(_db, _r, "shop"), _source);
        JEI_AcquisitionShop(_s, JEI_AcquisitionField(_db, _r, "shop_custom"), _source);
        var _quests = JEI_AcquisitionField(_db, _r, "quests", []);
        if (!is_array(_quests)) continue;
        for (var _q = 0; _q < array_length(_quests); _q++) {
            if (is_array(_quests[_q]) && array_length(_quests[_q]) > 0) variable_struct_set(_questOwners, string(_quests[_q][0]), _source);
        }
    }
    _db = JEI_AcquisitionDB("QUEST");
    for (var _i = _from; (_part < 0 || _part == 2) && _i < min(_to, array_length(_db.rows)); _i++) {
        var _r = _db.rows[_i];
        var _name = JEI_AcquisitionName(JEI_AcquisitionField(_db, _r, "title"));
        if (_name == "") continue;
        var _icon = undefined;
        if (variable_struct_exists(_questOwners, string(_r[0]))) {
            var _owner = variable_struct_get(_questOwners, string(_r[0]));
            _name = _owner.name + " - " + _name;
            _icon = _owner.sprite;
        }
        JEI_AcquisitionLoot(_s, JEI_AcquisitionField(_db, _r, "reward"), JEI_AcquisitionSource("source_quest", _name, _icon, "QUEST", _r));
    }
    _db = JEI_AcquisitionDB("CONTRACT");
    for (var _i = _from; (_part < 0 || _part == 3) && _i < min(_to, array_length(_db.rows)); _i++) {
        var _r = _db.rows[_i];
        var _name = JEI_AcquisitionName(JEI_AcquisitionField(_db, _r, "title"));
        if (_name != "" && JEI_AcquisitionField(_db, _r, "reward_amount", 0) > 0) {
            JEI_AcquisitionAdd(_s, JEI_AcquisitionField(_db, _r, "reward"), JEI_AcquisitionSource("source_contract", _name, undefined, "CONTRACT", _r));
        }
    }
    _db = JEI_AcquisitionDB("BIOME");
    var _fishDB = JEI_AcquisitionDB("FISH");
    _fields = ["fish", "fish_chests"];
    _kinds = ["source_fish", "source_fish_chest"];
    for (var _i = _from; (_part < 0 || _part == 4) && _i < min(_to, array_length(_db.rows)); _i++) {
        var _r = _db.rows[_i];
        var _name = JEI_AcquisitionName(JEI_AcquisitionField(_db, _r, "name"));
        if (_name == "") continue;
        for (var _f = 0; _f < 2; _f++) {
            var _entries = JEI_AcquisitionField(_db, _r, _fields[_f], []);
            if (!is_array(_entries)) continue;
            for (var _j = 0; _j < array_length(_entries); _j++) {
                var _entry = _entries[_j];
                if (!is_array(_entry) || array_length(_entry) < 2 || _entry[1] <= 0) continue;
                var _fish = JEI_AcquisitionRecord(_fishDB, _entry[0]);
                var _source = JEI_AcquisitionSource(_kinds[_f], _name, JEI_AcquisitionField(_db, _r, "icon"), "BIOME", _r);
                JEI_AcquisitionLoot(_s, JEI_AcquisitionField(_fishDB, _fish, "loot"), _source);
            }
        }
    }
    var _objects = JEI_AcquisitionDB("INTERACTABLE");
    _db = JEI_AcquisitionDB("LOOT");
    for (var _i = _from; (_part < 0 || _part == 5) && _i < min(_to, array_length(_db.rows)); _i++) {
        var _r = _db.rows[_i];
        if (JEI_AcquisitionField(_db, _r, "type") != "Container") continue;
        var _object = JEI_AcquisitionRecord(_objects, JEI_AcquisitionField(_db, _r, "interactable"));
        if (!is_array(_object)) continue;
        var _name = JEI_AcquisitionObjectName(_objects, _object, "item", "source_container");
        var _icon = JEI_AcquisitionField(_db, _r, "icon", JEI_AcquisitionField(_objects, _object, "sprite"));
        var _source = JEI_AcquisitionSource("source_chest", _name, _icon, "LOOT", _r);
        _source.chestType = _object[0];
        JEI_AcquisitionLoot(_s, JEI_AcquisitionField(_db, _r, "loot"), _source);
    }
    var _tables = ["INTERACTABLE", "BLOCK", "TOP"];
    for (var _t = 0; _t < array_length(_tables); _t++) {
        if (_part >= 0 && _part != 6 + _t) continue;
        _db = JEI_AcquisitionDB(_tables[_t]);
        for (var _i = _from; _i < min(_to, array_length(_db.rows)); _i++) {
            var _r = _db.rows[_i];
            if (!is_array(_r)) continue;
            var _loot = JEI_AcquisitionField(_db, _r, "loot");
            if (!is_array(_loot)) continue;
            var _kind = _t == 0 ? "source_harvest" : (_t == 1 ? "source_mine" : "source_break");
            var _fallback = _t == 1 ? "source_block" : "source_object";
            if (_t == 0) {
                var _pick = JEI_AcquisitionField(_db, _r, "harvest_pickaxe", false);
                var _axe = JEI_AcquisitionField(_db, _r, "harvest_axe", false);
                var _hoe = JEI_AcquisitionField(_db, _r, "harvest_hoe", false);
                if (_pick && !_axe && !_hoe) _kind = "source_mine";
                if (_axe && !_pick && !_hoe) _kind = "source_chop";
                if (JEI_AcquisitionField(_db, _r, "object") == asset_get_index("objInteractableCrop")) _kind = "source_crop";
            }
            var _name = JEI_AcquisitionObjectName(_db, _r, _t == 1 ? "drop" : "item", _fallback);
            JEI_AcquisitionLoot(_s, _loot, JEI_AcquisitionSource(_kind, _name, JEI_AcquisitionField(_db, _r, "sprite"), _tables[_t], _r));
        }
    }
    if (_part < 0) JEI_AcquisitionBuildDone(_s);
}

function JEI_AcquisitionBuildDone(_s) {
    // Temporary build caches are deliberately excluded from persistent UI state.
    _s.acquisitionSeen = {};
    _s.acquisitionPools = {};
    _s.acquisitionPoolDB = undefined; _s.acquisitionQuestOwners = {};
}

function JEI_Acquisitions(_s, _id) {
    var _key = string(_id);
    return variable_struct_exists(_s.acquisitions, _key) ? variable_struct_get(_s.acquisitions, _key) : [];
}
