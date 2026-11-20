// Query the packed columns with native substring search; yield between matches.
function JEI_SearchIndexStart(_s) {
    _s.searchBlobs = {name:[], modName:[], tooltip:[], tags:[], category:[], nativeId:[]};
    _s.searchRows = []; _s.normalItems = [];
    _s.queryCache = {}; _s.queryCacheKeys = []; _s.searchJob = undefined;
    _s.nameScan = -1; _s.namePack = -1; _s.nameDirty = false;
    _s.nextNameScan = 0;
}

function JEI_SearchIndexAdd(_s, _doc) {
    var _ordinal = array_length(_s.searchRows);
    array_push(_s.searchRows, _doc);
    if (!_doc.hidden) array_push(_s.normalItems, _doc.id);
    var _suffix = chr(31) + chr(57344 + _ordinal) + chr(30);
    var _block = _ordinal div 32;
    var _fields = ["name", "modName", "tooltip", "tags", "category", "nativeId"];
    for (var _i = 0; _i < array_length(_fields); _i++) {
        var _field = _fields[_i];
        var _blocks = variable_struct_get(_s.searchBlobs, _field);
        if (_block >= array_length(_blocks)) array_push(_blocks, "");
        _blocks[_block] += variable_struct_get(_doc, _field) + _suffix;
        variable_struct_set(_s.searchBlobs, _field, _blocks);
    }
}

function JEI_PublishSearch(_s, _query, _items) {
    if (_query != _s.search) return;
    _s.filtered = _items; _s.filterQuery = _query;
    _s.filterDeveloper = _s.developer; _s.page = 0; _s.scroll = 0;
    var _key = string(_s.developer) + ":" + _query;
    if (!variable_struct_exists(_s.queryCache, _key)) array_push(_s.queryCacheKeys, _key);
    variable_struct_set(_s.queryCache, _key, _items);
    if (array_length(_s.queryCacheKeys) > 32) {
        variable_struct_remove(_s.queryCache, _s.queryCacheKeys[0]); array_delete(_s.queryCacheKeys, 0, 1);
    }
}

function JEI_RequestSearch(_s) {
    if (_s.filterQuery == _s.search && _s.filterDeveloper == _s.developer) { _s.searchJob = undefined; return; }
    if (is_struct(_s.searchJob) && _s.searchJob.query == _s.search && _s.searchJob.developer == _s.developer) return;
    _s.searchJob = undefined;
    var _key = string(_s.developer) + ":" + _s.search;
    if (variable_struct_exists(_s.queryCache, _key)) { JEI_PublishSearch(_s, _s.search, variable_struct_get(_s.queryCache, _key)); return; }
    var _branches = JEI_ParseSearch(_s.search, _s.developer);
    if (array_length(_branches) == 0) { JEI_PublishSearch(_s, _s.search, _s.developer ? _s.items : _s.normalItems); return; }
    _s.searchJob = {query:_s.search, developer:_s.developer, branches:_branches, branch:0, block:0, offset:1, cursor:0,
        anchor:-2, found:[], seen:{}};
}

function JEI_SearchTick(_s, _budget) {
    var _job = _s.searchJob; if (!is_struct(_job)) return;
    if (_job.query != _s.search || _job.developer != _s.developer) { JEI_RequestSearch(_s); _job = _s.searchJob; if (!is_struct(_job)) return; }
    var _deadline = get_timer() + _budget;
    while (_job.branch < array_length(_job.branches)) {
        var _terms = _job.branches[_job.branch];
        if (_job.anchor == -2) {
            _job.anchor = -1;
            for (var _i = 0; _i < array_length(_terms); _i++) {
                if (!_terms[_i].negative && (_job.anchor < 0 || (string_length(_terms[_i].value) + (_terms[_i].field == "name" ? 100 : 0)) > (string_length(_terms[_job.anchor].value) + (_terms[_job.anchor].field == "name" ? 100 : 0)))) _job.anchor = _i;
            }
        }
        var _at = -1;
        if (_job.anchor >= 0) {
            var _term = _terms[_job.anchor]; var _blocks = variable_struct_get(_s.searchBlobs, _term.field);
            var _blob = _job.block < array_length(_blocks) ? _blocks[_job.block] : "";
            var _pos = _job.block < array_length(_blocks) ? string_pos_ext(_term.value, _blob, _job.offset) : 0;
            if (_pos > 0) {
                var _end = string_pos_ext(chr(30), _blob, _pos);
                var _sep = string_pos_ext(chr(31), _blob, _pos);
                _job.offset = _end > 0 ? _end + 1 : string_length(_blob) + 1;
                if (_sep > 0 && _sep < _end && _pos + string_length(_term.value) <= _sep) _at = ord(string_char_at(_blob, _sep + 1)) - 57344;
            } else { _job.block += 1; _job.offset = _job.block < array_length(_blocks) ? 1 : -1; }
        } else if (_job.cursor < array_length(_s.searchRows)) { _at = _job.cursor; _job.cursor += 1; }
        else _job.offset = -1;
        if (_at >= 0) {
            var _doc = _s.searchRows[_at]; var _ok = _job.developer || !_doc.hidden;
            for (var _t = 0; _ok && _t < array_length(_terms); _t++) {
                var _term = _terms[_t];
                if (_t == _job.anchor && _term.field != "nativeId") continue;
                if (JEI_SearchTermMatches(_doc, _term) == _term.negative) _ok = false;
            }
            var _key = string(_at);
            if (_ok && !variable_struct_exists(_job.seen, _key)) { variable_struct_set(_job.seen, _key, true); array_push(_job.found, _at); }
        }
        if (_job.offset < 0) { _job.branch += 1; _job.block = 0; _job.offset = 1; _job.cursor = 0; _job.anchor = -2; }
        if (get_timer() >= _deadline) return;
    }
    // Native sort preserves catalog order across OR branches without a full scan.
    if (!variable_struct_exists(_job, "items")) {
        if (array_length(_job.branches) > 1) array_sort(_job.found, true);
        _job.items = []; _job.output = 0;
    }
    while (_job.output < array_length(_job.found)) {
        array_push(_job.items, _s.searchRows[_job.found[_job.output]].id); _job.output += 1;
        if (get_timer() >= _deadline) return;
    }
    JEI_PublishSearch(_s, _job.query, _job.items); _s.searchJob = undefined;
}

function JEI_SearchNamesTick(_s, _budget, _force) {
    if (array_length(_s.searchRows) == 0) return;
    var _now = get_timer();
    if (_s.nameScan < 0 && _s.namePack < 0) {
        if (!_force && _now < _s.nextNameScan) return;
        _s.nameScan = 0; _s.nameDirty = false;
    }
    var _deadline = _now + _budget; var _rows = variable_global_get("__DB_ITEM");
    while (_s.nameScan >= 0 && _s.nameScan < array_length(_s.searchRows)) {
        var _doc = _s.searchRows[_s.nameScan]; var _id = _doc.id;
        var _row = _id >= 0 && _id < array_length(_rows) ? _rows[_id] : JEI_ItemRow(_id);
        if (is_array(_row) && array_length(_row) > 2 && (_row[2] != _doc.rawName || _row[1] != _doc.internalKey || _doc.template)) {
            var _old = _doc.name; JEI_UpdateSearchName(_id, _doc, _s.pinyinEnabled);
            if (_old != _doc.name) _s.nameDirty = true;
        }
        _s.nameScan += 1;
        if (get_timer() >= _deadline) return;
    }
    if (_s.nameScan >= 0) {
        _s.nameScan = -1; _s.nextNameScan = get_timer() + 1000000;
        if (_s.nameDirty) { _s.namePack = 0; _s.nameBlob = []; }
    }
    while (_s.namePack >= 0 && _s.namePack < array_length(_s.searchRows)) {
        var _block = _s.namePack div 32;
        if (_block >= array_length(_s.nameBlob)) array_push(_s.nameBlob, "");
        _s.nameBlob[_block] += _s.searchRows[_s.namePack].name + chr(31) + chr(57344 + _s.namePack) + chr(30);
        _s.namePack += 1;
        if (get_timer() >= _deadline) return;
    }
    if (_s.namePack >= 0) {
        _s.namePack = -1; _s.searchBlobs.name = _s.nameBlob;
        _s.queryCache = {}; _s.queryCacheKeys = []; _s.filterQuery = undefined; _s.searchJob = undefined;
        JEI_RequestSearch(_s);
    }
}

function JEI_SearchWork(_s) {
    // Search gets priority; live name checks use a separate small frame budget.
    JEI_SearchTick(_s, 2200);
    JEI_SearchNamesTick(_s, 1200, false);
}
