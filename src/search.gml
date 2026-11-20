function JEI_Uses(_s, _id) {
    var _key = string(_id);
    return variable_struct_exists(_s.byUses, _key) ? variable_struct_get(_s.byUses, _key) : [];
}

function JEI_CategoryKey(_r) { return _r.provider + ":" + string(_r.station); }

function JEI_ViewRecipes(_s) {
    if (_s.viewMode == "category") {
        var _out = [];
        for (var _i = 0; _i < array_length(_s.allRecipes); _i++) {
            var _r = _s.allRecipes[_i];
            if (JEI_CategoryKey(_r) == _s.category) array_push(_out, _r);
        }
        return _out;
    }
    return _s.viewMode == "uses" ? JEI_Uses(_s, _s.selected) : JEI_Recipes(_s, _s.selected);
}

function JEI_SearchScalar(_v) {
    if (is_undefined(_v)) return "";
    if (is_array(_v)) {
        var _out = "";
        for (var _i = 0; _i < array_length(_v); _i++) _out += " " + JEI_SearchScalar(_v[_i]);
        return _out;
    }
    return string(_v);
}

function JEI_ItemTypeTags(_type) {
    if (!variable_global_exists("__JEI_ItemTypeTags")) {
        variable_global_set("__JEI_ItemTypeTags", {
            weapon:"Weapons 武器", tool:"Tools 工具", etc:"Miscellaneous 杂项 杂类",
            building:"Buildings 建筑 建材", floor:"Floors 地板 地面",
            throwable:"Throwables 投掷物", usable:"Usable 可用物品",
            crafting_table:"Crafting Table Workstation 制作台 工作站", storage:"Storage 容器 收纳",
            ammo:"Ammo Ammunition 弹药",
            accessory:"Accessory Accessories 饰品 配饰 配件",
            head:"Head Helmet Armor 头部 头盔 护甲",
            body:"Body Chest Armor 身体 胸甲 护甲",
            legs:"Legs Armor 腿部 腿甲 护甲", summon:"Summon 召唤",
            currency:"Currency 货币", hook:"Hooks 钩子 钩索",
            material:"Material Materials 材料", ingredient:"Ingredients 食材 材料",
            fishing_rod:"Fishing Rod 鱼竿 钓竿", spice:"Spices 香料 香辛料",
            fish:"Fish 鱼", pet:"Pets 宠物", cable:"Cables 缆线",
            portable_storage:"Portable Storage 便携储物", reforge:"Reforge 重铸",
            map:"Maps 地图", rune:"Runes 符文", contract:"Contracts 契约",
            instrument:"Instruments 乐器", mount:"Mounts 坐骑",
            recipe:"Recipes Blueprints 配方 蓝图", cube_ritual:"Summon Ritual 召唤"
        });
    }
    var _tags = variable_global_get("__JEI_ItemTypeTags");
    var _key = string_replace_all(string_lower(_type), " ", "_");
    if (_key == "accesory") _key = "accessory";
    return variable_struct_exists(_tags, _key) ? variable_struct_get(_tags, _key) : "";
}

function JEI_ItemNamespace(_key) {
    var _at = string_pos("@", _key);
    var _colon = string_pos(":", _key);
    if (_at == 0 || _colon > 0 && _colon < _at) _at = _colon;
    return _at > 1 ? string_copy(_key, 1, _at - 1) : "";
}

function JEI_DefaultSearchMetadata(_s, _id, _row) {
    var _origin = JEI_IsRitual(_id) ? "" : JEI_ItemNamespace(string(_row[1]));
    if (_origin == "" && is_string(_row[0])) _origin = JEI_ItemNamespace(_row[0]);
    if (_origin == "") _origin = "Tinkerlands";
    var _mod = _origin == "Tinkerlands" ? "Tinkerlands 原版 原版遊戲 vanilla" : _origin;
    var _db = JEI_AcquisitionDB("ITEM");
    var _descriptionRow = JEI_IsBlueprint(_id) ? JEI_BlueprintTemplate() : _row;
    var _tooltip = JEI_Description(JEI_AcquisitionField(_db, _descriptionRow, "description", ""));
    if (string_pos("{refAffixNam}", _tooltip) > 0) {
        var _affix = JEI_ReforgeAffixName(_row);
        if (_affix != "") _tooltip = string_replace_all(_tooltip, "{refAffixNam}", _affix);
    }
    var _type = JEI_SearchScalar(JEI_AcquisitionField(_db, _row, "type", "Etc"));
    var _types = JEI_AcquisitionDB("ITEM_TYPE");
    var _typeRow = JEI_AcquisitionRecord(_types, JEI_AcquisitionField(_db, _row, "type"));
    var _typeName = JEI_Description(JEI_AcquisitionField(_types, _typeRow, "name", ""));
    var _category = _type + " " + _typeName + " " + JEI_ItemTypeTags(_type) + " " + JEI_SearchScalar(JEI_AcquisitionField(_db, _row, "folder", ""));
    var _tags = _category + " " + JEI_SearchScalar(JEI_AcquisitionField(_db, _row, "tags", ""));
    if (JEI_AcquisitionField(_db, _row, "is_material", false)) _tags += " Material Materials 材料";
    return {modName: _mod, modDisplayName: _origin, tooltip: _tooltip, tags: _tags, category: _category};
}

function JEI_BuildSearch(_s) {
    _s.searchDocs = {};
    _s.tooltipCache = undefined;
    _s.pinyinEnabled = true;
    JEI_SearchIndexStart(_s);
    for (var _i = 0; _i < array_length(_s.items); _i++) JEI_BuildSearchRow(_s, _s.items[_i]);
}

function JEI_BuildSearchRow(_s, _id) {
    var _fn = JEI_API().searchMetadata; var _row = JEI_ItemRow(_id); var _m = _fn(_s, _id, _row);
    if (!is_struct(_m)) _m = {};
    var _nativeId = _row[0];
    var _doc = {id:_id, hidden:JEI_DevelopmentItem(_s, _id), name:"", displayName:undefined, rawName:undefined,
        template:false, internalKey:"", pinyin:"", pinyinEnabled:false, modName:"", tooltip:"", tags:"", category:"",
        nativeId:!JEI_IsRitual(_id) && (JEI_Number(_nativeId) || is_string(_nativeId)) ? string_lower(string(_nativeId)) : ""};
    JEI_UpdateSearchName(_id, _doc, _s.pinyinEnabled);
    _doc.description = variable_struct_exists(_m, "tooltip") ? JEI_Description(_m.tooltip) : "";
    _doc.tooltip = string_lower(_doc.description);
    _doc.origin = variable_struct_exists(_m, "modDisplayName") ? JEI_SearchScalar(_m.modDisplayName) : (variable_struct_exists(_m, "modName") ? JEI_SearchScalar(_m.modName) : "Tinkerlands");
    var _fields = ["modName", "tags", "category"];
    for (var _k = 0; _k < array_length(_fields); _k++) {
        var _field = _fields[_k];
        if (variable_struct_exists(_m, _field)) variable_struct_set(_doc, _field, string_lower(JEI_SearchScalar(variable_struct_get(_m, _field))));
    }
    if (variable_struct_exists(_m, "modDisplayName")) _doc.modName += " " + string_lower(_doc.origin);
    variable_struct_set(_s.searchDocs, string(_id), _doc);
    JEI_SearchIndexAdd(_s, _doc);
}

function JEI_UpdateSearchName(_id, _doc, _pinyinEnabled) {
    var _name = JEI_Name(_id); var _key = string(JEI_ItemRow(_id)[1]);
    if (_doc.displayName == _name && _doc.internalKey == _key && _doc.pinyinEnabled == _pinyinEnabled) return;
    _doc.displayName = _name; _doc.internalKey = _key;
    _doc.rawName = JEI_ItemRow(_id)[2];
    _doc.template = string_pos("{$refMob}", _doc.rawName) > 0 || string_pos("affix_scroll_", _key) == 1 || _key == "reforge_useless";
    _doc.pinyinEnabled = _pinyinEnabled;
    _doc.pinyin = _pinyinEnabled ? JEI_Pinyin(_name) : "";
    _doc.name = string_lower(_name + " " + _key + " " + _doc.pinyin);
    if (string_pos("v", _doc.pinyin) > 0) _doc.name += " " + string_replace_all(_doc.pinyin, "v", "ü");
}

// Spaces AND terms, | OR branches. Quotes protect spaces and separators.
function JEI_ParseSearch(_text, _developer = false) {
    var _branches = [];
    var _terms = [];
    var _token = "";
    var _quote = false;
    var _literal = false;
    _text = string_lower(_text);
    for (var _i = 1; _i <= string_length(_text) + 1; _i++) {
        var _c = _i <= string_length(_text) ? string_char_at(_text, _i) : " ";
        if (_c == chr(34)) {
            if (!_quote && (_token == "" || _token == "-")) _literal = true;
            _quote = !_quote; continue;
        }
        if (!_quote && (_c == " " || _c == "　" || _c == "|" || _c == "｜" || _c == chr(9)) || _i > string_length(_text)) {
            if (_token != "") {
                var _negative = string_char_at(_token, 1) == "-";
                if (_negative) _token = string_delete(_token, 1, 1);
                var _prefix = string_char_at(_token, 1);
                var _field = "name";
                if (!_literal) {
                    if (_prefix == "@" || _prefix == "＠") _field = "modName";
                    if (_prefix == "#" || _prefix == "＃") _field = "tags";
                    if (_prefix == "$" || _prefix == "＄") _field = "tooltip";
                    if (_prefix == "%" || _prefix == "％") _field = "category";
                    if (_field != "name") _token = string_delete(_token, 1, 1);
                    else if (_developer) {
                        var _idPrefix = string_copy(_token, 1, 3);
                        if (_idPrefix == "id:" || _idPrefix == "id：") {
                            _field = "nativeId"; _token = string_delete(_token, 1, 3);
                        } else if (_token != "" && string_digits(_token) == _token) _field = "nativeId";
                    }
                }
                if (_token != "") array_push(_terms, {field: _field, value: _token, negative: _negative});
                _token = "";
            }
            _literal = false;
            if (_c == "|" || _c == "｜" || _i > string_length(_text)) {
                if (array_length(_terms) > 0) array_push(_branches, _terms);
                _terms = [];
            }
        } else _token += _c;
    }
    return _branches;
}

function JEI_SearchTermMatches(_doc, _term) {
    var _text = variable_struct_get(_doc, _term.field);
    if (_term.field == "nativeId") return _text == _term.value;
    return string_pos(_term.value, _text) > 0;
}

function JEI_SearchMatches(_doc, _branches) {
    if (array_length(_branches) == 0) return true;
    for (var _b = 0; _b < array_length(_branches); _b++) {
        var _terms = _branches[_b];
        var _match = true;
        for (var _t = 0; _t < array_length(_terms); _t++) {
            var _term = _terms[_t];
            var _found = JEI_SearchTermMatches(_doc, _term);
            if (_found == _term.negative) { _match = false; break; }
        }
        if (_match) return true;
    }
    return false;
}

// Synchronous API for explicit callers; the live UI uses bounded search jobs.
function JEI_Filter(_s) {
    JEI_SearchNamesTick(_s, 10000000, true);
    JEI_RequestSearch(_s);
    while (is_struct(_s.searchJob)) JEI_SearchTick(_s, 10000000);
}

function JEI_RememberSearch(_s) {
    var _text = string_trim(_s.search);
    if (_text == "") return;
    var _h = _s.searchHistory;
    if (array_length(_h) == 0 || _h[array_length(_h) - 1] != _text) array_push(_h, _text);
    if (array_length(_h) > 32) array_delete(_h, 0, 1);
    _s.searchHistory = _h;
    _s.searchHistoryAt = array_length(_h);
}
