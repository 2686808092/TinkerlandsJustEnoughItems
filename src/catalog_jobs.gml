// Catalog data survives UI/world resets; no player state is cached here.
function JEI_CatalogFields() {
    return ["items","byItem","byUses","allRecipes","acquisitions","sources","development","hiddenCount","scriptKeys",
        "searchDocs","searchRows","searchBlobs","normalItems","pinyinEnabled","language","itemCount","recipeCount","cookCount",
        "providerRevision","cubeFingerprint","cubeCount","cubeSkipped","acquisitionsReady"];
}
function JEI_CatalogCopy(_from, _to) {
    var _fields = JEI_CatalogFields();
    for (var _i = 0; _i < array_length(_fields); _i++) {
        var _key = _fields[_i];
        var _value = is_struct(_from) ? variable_struct_get(_from, _key) : variable_instance_get(_from, _key);
        if (is_struct(_to)) variable_struct_set(_to, _key, _value); else variable_instance_set(_to, _key, _value);
    }
}
function JEI_CatalogValid(_s) {
    var _items = variable_global_get("__DB_ITEM"); var _recipes = variable_global_get("__DB_RECIPE");
    var _cooks = variable_global_exists("__DB_COOK") ? variable_global_get("__DB_COOK") : [];
    return _s.language == variable_global_get("__LANG_ENUM") && _s.providerRevision == JEI_API().revision &&
        _s.cubeFingerprint == JEI_CubeFingerprint() && _s.itemCount == array_length(_items) &&
        _s.recipeCount == array_length(_recipes) && _s.cookCount == (is_array(_cooks) ? array_length(_cooks) : 0);
}
function JEI_UseCatalog(_s, _cache) {
    JEI_CatalogCopy(_cache, _s); _s.catalogReady = true; _s.catalogJob = undefined;
    _s.queryCache = {}; _s.queryCacheKeys = []; _s.searchJob = undefined; _s.filterQuery = undefined;
    _s.nameScan = -1; _s.namePack = -1; _s.nextNameScan = 0;
    JEI_RequestSearch(_s); JEI_RecipeRows(_s);
}
function JEI_ResetWorldSession(_s) {
    var _pending = _s.catalogJob;
    if (_s.catalogReady && _s.acquisitionsReady && JEI_CatalogValid(_s)) {
        var _cache = {}; JEI_CatalogCopy(_s, _cache); variable_global_set("__JEI_Catalog", _cache);
    }
    JEI_Init(_s);
    if (variable_global_exists("__JEI_Catalog")) {
        var _cache = variable_global_get("__JEI_Catalog");
        if (JEI_CatalogValid(_cache)) JEI_UseCatalog(_s, _cache);
    }
    if (is_struct(_pending) && JEI_CatalogValid(_pending.work)) {
        if (_pending.corePublished) JEI_UseCatalog(_s, _pending.work);
        _s.catalogJob = _pending;
    }
}
function JEI_NewCatalogWork() {
    var _w = {}; JEI_Init(_w);
    _w.language = variable_global_get("__LANG_ENUM"); _w.providerRevision = JEI_API().revision;
    _w.cubeFingerprint = JEI_CubeFingerprint();
    var _items = variable_global_get("__DB_ITEM"); var _recipes = variable_global_get("__DB_RECIPE");
    var _cooks = variable_global_exists("__DB_COOK") ? variable_global_get("__DB_COOK") : [];
    _w.itemCount = array_length(_items); _w.recipeCount = array_length(_recipes); _w.cookCount = is_array(_cooks) ? array_length(_cooks) : 0;
    _w.sources = {}; _w.scriptKeys = {}; _w.cubeCount = 0; _w.cubeSkipped = 0;
    _w.keyCache = {count:_w.itemCount, keys:{}};
    return _w;
}
function JEI_BeginCatalog(_s) {
    JEI_CancelCatalog(_s);
    var _w = JEI_NewCatalogWork();
    var _cache = JEI_CacheEligible();
    _s.catalogJob = {work:_w, stage:_cache ? -3 : 0, at:1, part:0, provider:0,
        items:variable_global_get("__DB_ITEM"), recipes:variable_global_get("__DB_RECIPE"),
        cooks:variable_global_exists("__DB_COOK") ? variable_global_get("__DB_COOK") : [],
        cache:_cache,signature:"",reader:undefined,writer:undefined,coreReady:false,corePublished:false,
        fullFirst:JEI_API().itemPolicy != JEI_DefaultItemPolicy || JEI_API().searchMetadata != JEI_DefaultSearchMetadata,acquired:[],acquiredAt:0,
        sourceReadTried:false,sourcePublished:false,coreHit:false,sourceHit:false,coreFrames:0,coreUs:0,sourceFrames:0,
        started:get_timer(),coreWallMs:0,cpuUs:0,maxSliceUs:0,slices:0,maxStage:0,
        acquisitionTables:["MOB","NPC","QUEST","CONTRACT","BIOME","LOOT","INTERACTABLE","BLOCK","TOP"],
        sourceTables:["LOOT","ITEM_POOL","NPC","QUEST","FISH","MOB","CONTRACT","BLOCK","INTERACTABLE","TOP","ROOF","UPGRADE","WORLDGEN"]};
}
function JEI_CatalogNext(_j) { _j.stage += 1; _j.at = 1; _j.part = 0; }

function JEI_CatalogStep(_j) {
    var _w = _j.work; var _i = _j.at;
    if (_j.stage == -3) {
        if (!variable_struct_exists(_j, "hashJob")) JEI_CacheHashStart(_j);
        if (JEI_CacheHashStep(_j)) {
            _j.reader = JEI_CacheReadBegin("core",_j.signature);
            _j.stage = is_struct(_j.reader) ? -2 : 0;
        }
        return;
    }
    if (_j.stage == -2) {
        JEI_CacheReadStep(_w,_j.reader);
        if (_j.reader.done) {
            if (_j.reader.failed) { _j.work = JEI_NewCatalogWork(); _j.stage = 0; }
            else { _j.coreHit = true; _j.coreReady = true; _j.stage = 10; variable_global_set("__JEI_ItemKeys",_w.keyCache); }
            _j.reader = undefined;
        }
        return;
    }
    if (_j.stage == 12 || _j.stage == 13) {
        if (_j.cache) {
            if (!is_struct(_j.writer)) _j.writer = JEI_CacheWriteBegin(_j.stage == 12 ? "core" : "sources",_j.signature);
            if (is_struct(_j.writer)) { JEI_CacheWriteStep(_w,_j.writer); if (!_j.writer.done) return; }
        }
        _j.writer = undefined; _j.stage = _j.stage == 12 ? 10 : 14; _j.at = 1; _j.part = 0; return;
    }
    if (_j.stage == 0) {
        if (_i >= _w.itemCount) { variable_global_set("__JEI_ItemKeys", _w.keyCache); JEI_CatalogNext(_j); return; }
        var _r = _j.items[_i];
        if (is_array(_r) && array_length(_r) > 1) {
            if (is_string(_r[0]) && !variable_struct_exists(_w.keyCache.keys, _r[0])) variable_struct_set(_w.keyCache.keys, _r[0], _i);
            if (is_string(_r[1]) && !variable_struct_exists(_w.keyCache.keys, _r[1])) variable_struct_set(_w.keyCache.keys, _r[1], _i);
        }
    } else if (_j.stage == 1) {
        if (_i >= _w.itemCount) { JEI_CatalogNext(_j); return; }
        var _row = _j.items[_i];
        if (is_array(_row) && array_length(_row) > 7 && _row[0] != 1024 && !is_undefined(_row[5]) && sprite_exists(_row[5])) array_push(_w.items, _i);
    } else if (_j.stage == 2) {
        if (_i >= _w.recipeCount) { JEI_CatalogNext(_j); return; }
        JEI_BuildRecipeRow(_w, _j.recipes[_i], _i);
    } else if (_j.stage == 3) {
        if (_i >= _w.cookCount) { JEI_CatalogNext(_j); return; }
        JEI_BuildCookRow(_w, _j.cooks[_i]);
    } else if (_j.stage == 4) {
        var _providers = JEI_API().providers;
        if (_j.provider >= array_length(_providers)) {
            _j.stage = _j.fullFirst ? 10 : 5; _j.at = _j.fullFirst ? 1 : 0; _j.part = 0; return;
        }
        var _provider = _providers[_j.provider];
        if (_provider.key == "native_cube_v1" && _provider.load == JEI_LoadCubeRecipes) {
            if (_i < _w.cubeFingerprint) { JEI_LoadCubeRecipeRange(_w, _i, _i + 1); _j.at += 1; return; }
        } else { var _load = _provider.load; _load(_w); }
        _j.provider += 1; _j.at = 1; return;
    } else if (_j.stage == 5) {
        if (_j.acquiredAt < array_length(_j.acquired)) {
            variable_struct_set(_w.sources,_j.acquired[_j.acquiredAt],true); _j.acquiredAt += 1; return;
        }
        if (_i >= array_length(_w.allRecipes)) { JEI_CatalogNext(_j); return; }
        var _r = _w.allRecipes[_i]; JEI_SourceAdd(_w, _r.item);
        for (var _g = 0; _g < array_length(_r.groups); _g++) {
            var _ids = _r.groups[_g].ids;
            for (var _k = 0; _k < array_length(_ids); _k++) JEI_SourceAdd(_w, _ids[_k]);
        }
    } else if (_j.stage == 6) {
        if (_j.part >= array_length(_j.sourceTables)) {
            JEI_SourceAdd(_w, "clothing_worn_out_jeans"); JEI_SourceAdd(_w, "clothing_worn_out_shirt");
            JEI_CatalogNext(_j); _j.at = 0; return;
        }
        var _table = _j.sourceTables[_j.part]; var _db = JEI_AcquisitionDB(_table);
        if (_i >= array_length(_db.rows)) { _j.part += 1; _j.at = 1; return; }
        var _r = _db.rows[_i]; JEI_SourceWalk(_w, _r, 1);
        var _fields = ["item", "drop", "ref_item", "reward_item", "reward_item_ref"];
        for (var _k = 0; _k < array_length(_fields); _k++) {
            if (is_array(_r) && variable_struct_exists(_db.fields, _fields[_k])) {
                var _at = variable_struct_get(_db.fields, _fields[_k]);
                if (_at < array_length(_r)) JEI_SourceAdd(_w, _r[_at]);
            }
        }
        if (_table == "CONTRACT" && JEI_AcquisitionField(_db,_r,"reward_amount",0) > 0 &&
            JEI_AcquisitionName(JEI_AcquisitionField(_db,_r,"title",undefined)) != "") JEI_SourceAdd(_w,JEI_AcquisitionField(_db,_r,"reward",undefined));
        if (_table == "NPC" && JEI_AcquisitionName(JEI_AcquisitionField(_db,_r,"name",undefined)) != "") {
            var _shops = [JEI_AcquisitionField(_db,_r,"shop",[]),JEI_AcquisitionField(_db,_r,"shop_custom",[])];
            for (var _shop = 0; _shop < 2; _shop++) {
                var _entries = _shops[_shop]; if (!is_array(_entries)) continue;
                for (var _entry = 0; _entry < array_length(_entries); _entry++) {
                    var _e = _entries[_entry];
                    if (is_array(_e) && array_length(_e) >= 2 && _e[1] == asset_get_index("db_item")) JEI_SourceAdd(_w,_e[0]);
                }
            }
        }
    } else if (_j.stage == 7) {
        var _scripts = variable_global_get("__DB_SCRIPT");
        if (_i >= array_length(_scripts)) { JEI_CatalogNext(_j); _j.at = 0; return; }
        var _r = _scripts[_i];
        if (is_array(_r) && array_length(_r) > 1) variable_struct_set(_w.scriptKeys, string(_r[1]), true);
    } else if (_j.stage == 8) {
        if (_i >= array_length(_w.items)) { JEI_CatalogNext(_j); _j.at = 0; return; }
        var _id = _w.items[_i]; var _policy = JEI_API().itemPolicy; var _reason = _policy(_w, _id, JEI_ItemRow(_id));
        if (_reason != "") { variable_struct_set(_w.development, string(_id), _reason); _w.hiddenCount += 1; }
    } else if (_j.stage == 9) {
        if (_i >= array_length(_w.items)) { _j.coreReady = true; _j.stage = _w.acquisitionsReady ? 14 : 12; _j.at = 1; return; }
        JEI_BuildSearchRow(_w, _w.items[_i]);
    } else if (_j.stage == 10) {
        if (!_j.sourceReadTried) {
            _j.sourceReadTried = true;
            if (_j.cache) _j.reader = JEI_CacheReadBegin("sources",_j.signature);
        }
        if (is_struct(_j.reader)) {
            JEI_CacheReadStep(_w,_j.reader);
            if (!_j.reader.done) return;
            if (!_j.reader.failed) { _w.acquisitionsReady = true; _j.sourceHit = true; _j.stage = 14; _j.reader = undefined; return; }
            _j.reader = undefined;
        }
        if (_j.part >= array_length(_j.acquisitionTables)) {
            JEI_AcquisitionBuildDone(_w); _w.acquisitionsReady = true;
            if (_j.fullFirst && !_j.coreReady) { _j.acquired = variable_struct_get_names(_w.acquisitions); _j.stage = 5; _j.at = 0; _j.part = 0; }
            else _j.stage = 13;
            return;
        }
        var _db = JEI_AcquisitionDB(_j.acquisitionTables[_j.part]);
        if (_i == 1 && _j.part == 0 && array_length(_db.rows) <= 1) JEI_BuildAcquisitionRange(_w,0,1,1);
        if (_i >= array_length(_db.rows)) { _j.part += 1; _j.at = 1; return; }
        JEI_BuildAcquisitionRange(_w,_j.part,_i,_i + 1);
    }
    _j.at += 1;
}

function JEI_BackgroundCatalog(_s, _budget) {
    var _start = get_timer();
    if (_s.catalogReady && _s.acquisitionsReady && !is_struct(_s.catalogJob) && JEI_CatalogValid(_s)) return;
    if (!is_struct(_s.catalogJob)) {
        if (variable_global_exists("__JEI_Catalog")) {
            var _cache = variable_global_get("__JEI_Catalog");
            if (JEI_CatalogValid(_cache)) { JEI_UseCatalog(_s, _cache); return; }
        }
        JEI_BeginCatalog(_s);
    }
    if (!JEI_CatalogValid(_s.catalogJob.work)) JEI_BeginCatalog(_s);
    var _j = _s.catalogJob; var _deadline = get_timer() + _budget;
    while (_j.stage < 14 && get_timer() < _deadline) {
        JEI_CatalogStep(_j);
        if (_j.coreReady && !_j.corePublished || _j.work.acquisitionsReady && !_j.sourcePublished) break;
    }
    var _elapsed = get_timer() - _start; _j.cpuUs += _elapsed; _j.slices += 1;
    if (_elapsed > _j.maxSliceUs) { _j.maxSliceUs = _elapsed; _j.maxStage = _j.stage; }
    if (_j.coreReady && !_j.corePublished) {
        _j.corePublished = true; _j.coreFrames = _j.slices; _j.coreUs = _j.cpuUs; _j.coreWallMs = (get_timer() - _j.started) / 1000;
        JEI_UseCatalog(_s,_j.work); _s.catalogJob = _j;
    }
    if (_j.work.acquisitionsReady && !_j.sourcePublished) {
        _j.sourcePublished = true; _j.sourceFrames = _j.slices;
        _s.acquisitions = _j.work.acquisitions; _s.acquisitionsReady = true; JEI_RecipeRows(_s);
    }
    _s.catalogTiming = {cpu_ms:_j.cpuUs / 1000,max_slice_ms:_j.maxSliceUs / 1000,frames:_j.slices,max_stage:_j.maxStage,
        core_frames:_j.coreFrames,core_cpu_ms:_j.coreUs / 1000,core_wall_ms:_j.coreWallMs,total_wall_ms:(get_timer() - _j.started) / 1000,
        sources_frames:_j.sourceFrames,core_cache_hit:_j.coreHit,sources_cache_hit:_j.sourceHit,signature:_j.signature};
    if (_j.stage < 14) return;
    var _cache = {}; JEI_CatalogCopy(_s,_cache); variable_global_set("__JEI_Catalog",_cache); _s.catalogJob = undefined;
}
