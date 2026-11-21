// Two checked, paged files: usable catalog first, acquisition descriptions later.
function JEI_CacheEligible() {
    var _api = JEI_API();
    return _api.itemPolicy == JEI_DefaultItemPolicy && _api.searchMetadata == JEI_DefaultSearchMetadata &&
        array_length(_api.providers) == 1 && _api.providers[0].key == "native_cube_v1" && _api.providers[0].load == JEI_LoadCubeRecipes;
}
function JEI_CachePath(_kind) {
    var _prefix = variable_global_exists("__JEI_CachePath") ? variable_global_get("__JEI_CachePath") : "jei-catalog-";
    return _prefix + _kind + ".cache";
}
function JEI_CacheHashStart(_j) {
    var _tables = ["ITEM","RECIPE","COOK","CRAFT_TABLE","ITEM_TYPE","ITEM_POOL","MOB","NPC","QUEST","CONTRACT",
        "BIOME","LOOT","FISH","INTERACTABLE","BLOCK","TOP","ROOF","UPGRADE","WORLDGEN","CUBE"];
    var _globals = [];
    for (var _i = 0; _i < array_length(_tables); _i++) {
        array_push(_globals, "__DB_" + _tables[_i]); array_push(_globals, "__STR_E_" + _tables[_i] + "_DATA");
    }
    array_push(_globals, "__LANG", "__DB_SCRIPT", "__CUBE_RECIPES");
    _j.hashJob = {globals:_globals, table:0, at:0, keys:[], hashes:[], hash:md5_string_utf8("JEI @VERSION@ cache 2:" + string(_j.work.language)), data:undefined};
}
function JEI_CacheHashStep(_j) {
    var _h = _j.hashJob;
    if (_h.table >= array_length(_h.globals)) { _j.signature = _h.hash; return true; }
    var _name = _h.globals[_h.table];
    if (_h.at == 0) {
        _h.data = variable_global_exists(_name) ? variable_global_get(_name) : undefined;
        _h.keys = is_struct(_h.data) ? variable_struct_get_names(_h.data) : [];
        _h.hash = md5_string_utf8(_h.hash + _name);
    }
    var _v = _h.data; var _page = [];
    if (_name == "__LANG" && !is_undefined(_v)) {
        var _height = ds_grid_height(_v); var _width = ds_grid_width(_v); var _end = min(_height,_h.at + 128);
        var _part = ds_grid_create(_width,max(1,_end - _h.at));
        if (_end > _h.at) ds_grid_set_grid_region(_part,_v,0,_h.at,_width - 1,_end - 1,0,0);
        _h.hash = md5_string_utf8(_h.hash + ds_grid_write(_part)); ds_grid_destroy(_part); _h.at = _end;
        if (_end >= _height) { array_push(_h.hashes,[_name,_h.hash]); _h.table += 1; _h.at = 0; }
        return false;
    }
    var _length = is_array(_v) ? array_length(_v) : (is_struct(_v) ? array_length(_h.keys) : 1);
    var _end = min(_length, _h.at + 32);
    if (_name == "__DB_SCRIPT" && is_array(_v)) {
        for (var _i = _h.at; _i < _end; _i++) {
            var _r = _v[_i];
            // Only script identities affect classification. JEI's own fixture code is irrelevant.
            if (is_array(_r) && array_length(_r) > 1 && string_pos("JEI@", string(_r[1])) != 1) array_push(_page, [_r[0], _r[1]]);
        }
    } else if (is_array(_v)) array_copy(_page, 0, _v, _h.at, _end - _h.at);
    else if (is_struct(_v)) {
        for (var _i = _h.at; _i < _end; _i++) array_push(_page, [_h.keys[_i], variable_struct_get(_v, _h.keys[_i])]);
    } else _page = [_v];
    _h.hash = md5_string_utf8(_h.hash + json_stringify(_page)); _h.at = _end;
    if (_end >= _length) { array_push(_h.hashes,[_name,_h.hash]); _h.table += 1; _h.at = 0; }
    return false;
}
function JEI_CacheFields(_kind) {
    // [field, type: scalar/array/struct, entries per packet]
    if (_kind == "sources") return [["acquisitions",2,8]];
    return [["meta",0,1],["items",1,256],["normalItems",1,256],["allRecipes",1,32],
        ["byItem",2,16],["byUses",2,8],["sources",2,128],["development",2,128],["scriptKeys",2,128],
        ["itemKeys",2,128],["searchRows",1,16],["blob_name",1,2],["blob_modName",1,2],
        ["blob_tooltip",1,2],["blob_tags",1,2],["blob_category",1,2],["blob_nativeId",1,2]];
}
function JEI_CacheValue(_w, _key) {
    if (_key == "meta") return {hiddenCount:_w.hiddenCount,cubeCount:_w.cubeCount,cubeSkipped:_w.cubeSkipped};
    if (_key == "itemKeys") return _w.keyCache.keys;
    if (string_pos("blob_", _key) == 1) return variable_struct_get(_w.searchBlobs, string_delete(_key,1,5));
    return variable_struct_get(_w, _key);
}
function JEI_CacheSet(_w, _key, _value) {
    if (_key == "meta") { _w.hiddenCount = _value.hiddenCount; _w.cubeCount = _value.cubeCount; _w.cubeSkipped = _value.cubeSkipped; }
    else if (_key == "itemKeys") _w.keyCache.keys = _value;
    else if (string_pos("blob_", _key) == 1) variable_struct_set(_w.searchBlobs, string_delete(_key,1,5), _value);
    else variable_struct_set(_w, _key, _value);
}
function JEI_CacheReadBegin(_kind, _signature) {
    var _path = JEI_CachePath(_kind); if (!file_exists(_path)) return undefined;
    var _f = file_text_open_read(_path); if (_f < 0) return undefined;
    var _header = file_text_read_string(_f); file_text_readln(_f);
    if (_header != "JEI-CATALOG-1:" + _signature) { file_text_close(_f); return undefined; }
    return {file:_f,fields:JEI_CacheFields(_kind),field:0,at:0,hash:_signature,done:false,failed:false};
}
function JEI_CacheReadStep(_w, _io) {
    if (_io.done) return;
    var _valid = true;
    try {
        if (file_text_eof(_io.file)) _valid = false;
        else {
            var _line = file_text_read_string(_io.file); file_text_readln(_io.file);
            if (string_pos("END:", _line) == 1) {
                _valid = _line == "END:" + _io.hash && _io.field == array_length(_io.fields);
                _io.done = true;
            } else {
                var _checksum = string_copy(_line,1,32); var _json = string_delete(_line,1,33);
                _valid = string_length(_line) > 35 && string_char_at(_line,33) == ":" && md5_string_utf8(_json) == _checksum && _io.field < array_length(_io.fields);
                if (_valid) {
                    var _packet = json_parse(_json); var _field = _io.fields[_io.field];
                    _valid = is_array(_packet) && array_length(_packet) == 3 && _packet[0] == _io.field;
                    if (_valid) {
                        var _data = _packet[2]; var _value = JEI_CacheValue(_w, _field[0]);
                        if (_field[1] == 1 && is_array(_data)) {
                            if (_io.at == 0) _value = [];
                            array_copy(_value, array_length(_value), _data, 0, array_length(_data));
                            if (_field[0] == "searchRows") {
                                for (var _i = 0; _i < array_length(_data); _i++) variable_struct_set(_w.searchDocs, string(_data[_i].id), _data[_i]);
                            }
                        } else if (_field[1] == 2 && is_struct(_data)) {
                            if (_io.at == 0) _value = {};
                            var _keys = variable_struct_get_names(_data);
                            for (var _i = 0; _i < array_length(_keys); _i++) variable_struct_set(_value,_keys[_i],variable_struct_get(_data,_keys[_i]));
                        } else if (_field[1] == 0 && is_struct(_data)) _value = _data;
                        else _valid = false;
                        if (_valid) {
                            JEI_CacheSet(_w,_field[0],_value); _io.at += 1;
                            _io.hash = md5_string_utf8(_io.hash + _checksum);
                            if (_packet[1]) { _io.field += 1; _io.at = 0; }
                        }
                    }
                }
            }
        }
    } catch (_e) { _valid = false; }
    if (!_valid) { _io.failed = true; _io.done = true; }
    if (_io.done) { file_text_close(_io.file); _io.file = -1; }
}
function JEI_CacheWriteBegin(_kind, _signature) {
    var _path = JEI_CachePath(_kind); var _f = file_text_open_write(_path + ".tmp");
    if (_f < 0) return undefined;
    file_text_write_string(_f,"JEI-CATALOG-1:" + _signature); file_text_writeln(_f);
    return {file:_f,path:_path,fields:JEI_CacheFields(_kind),field:0,at:0,keys:[],hash:_signature,done:false};
}
function JEI_CacheWriteStep(_w, _io) {
    if (_io.done) return;
    try {
        if (_io.field >= array_length(_io.fields)) {
            file_text_write_string(_io.file,"END:" + _io.hash); file_text_writeln(_io.file);
            file_text_close(_io.file); _io.file = -1;
            if (file_exists(_io.path)) file_delete(_io.path);
            file_rename(_io.path + ".tmp", _io.path); _io.done = true; return;
        }
        var _field = _io.fields[_io.field]; var _value = JEI_CacheValue(_w,_field[0]);
        if (_io.at == 0 && _field[1] == 2) _io.keys = variable_struct_get_names(_value);
        var _length = _field[1] == 1 ? array_length(_value) : (_field[1] == 2 ? array_length(_io.keys) : 1);
        var _end = min(_length, _io.at + _field[2]); var _data = _value;
        if (_field[1] == 1) { _data = []; array_copy(_data,0,_value,_io.at,_end - _io.at); }
        if (_field[1] == 2) {
            _data = {};
            for (var _i = _io.at; _i < _end; _i++) variable_struct_set(_data,_io.keys[_i],variable_struct_get(_value,_io.keys[_i]));
        }
        var _json = json_stringify([_io.field,_end >= _length,_data]); var _checksum = md5_string_utf8(_json);
        file_text_write_string(_io.file,_checksum + ":" + _json); file_text_writeln(_io.file);
        _io.hash = md5_string_utf8(_io.hash + _checksum); _io.at = _end;
        if (_end >= _length) { _io.field += 1; _io.at = 0; }
    } catch (_e) { if (_io.file >= 0) file_text_close(_io.file); _io.file = -1; _io.done = true; }
}
function JEI_CancelCatalog(_s) {
    var _j = _s.catalogJob; if (!is_struct(_j)) return;
    if (is_struct(_j.reader) && _j.reader.file >= 0) file_text_close(_j.reader.file);
    if (is_struct(_j.writer) && _j.writer.file >= 0) file_text_close(_j.writer.file);
    _s.catalogJob = undefined;
}
