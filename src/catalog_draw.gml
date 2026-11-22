function JEI_FreeCatalogSurface(_s) {
    var _cache = _s.catalogSurface;
    if (is_struct(_cache) && surface_exists(_cache.surface)) surface_free(_cache.surface);
    _s.catalogSurface = undefined;
}

function JEI_DrawCatalogIcons(_s, _l, _first, _count, _x, _y) {
    var _z = _l.z; var _slot = _l.slot;
    for (var _i = 0; _i < _count; _i++) {
        var _id = _s.filtered[_first + _i];
        var _ix = _x + (_i mod 8) * _slot;
        var _iy = _y + (_i div 8) * _slot;
        JEI_Icon(_id, _ix + _slot / 2, _iy + _slot / 2, 40 * _z);
        if (JEI_IsBlueprint(_id)) JEI_Icon(1024, _ix + _slot - 10 * _z, _iy + _slot - 10 * _z, 15 * _z);
    }
}

function JEI_DrawCatalogGrid(_s, _l, _cream) {
    var _first = _s.page * _l.capacity;
    var _count = min(_l.capacity, array_length(_s.filtered) - _first);
    if (_count <= 0) return;
    var _z = _l.z; var _x = _l.grid[0]; var _y = _l.grid[1]; var _slot = _l.slot;
    if (_s.hover >= 0 || _s.detailOpen) {
        for (var _i = 0; _i < _count; _i++) {
            var _id = _s.filtered[_first + _i];
            if (_s.hover != _id && (!_s.detailOpen || _s.selected != _id)) continue;
            var _r = JEI_Rect(_x + (_i mod 8) * _slot + _z, _y + (_i div 8) * _slot + _z, _slot - 2 * _z, _slot - 2 * _z);
            JEI_Fill(_r, _cream, _s.hover == _id ? 0.24 : 0.12);
        }
    }
    var _cache = _s.catalogSurface;
    var _originX = floor(_x); var _originY = floor(_y);
    var _blend = gpu_get_blendmode_ext_sepalpha();
    if (!is_struct(_cache) || _cache.revision != _s.catalogDrawRevision || _cache.first != _first ||
        _cache.count != _count || _cache.slot != _slot || _cache.y != _y || !surface_exists(_cache.surface)) {
        JEI_FreeCatalogSurface(_s);
        var _w = ceil(_l.grid[2]) - _originX;
        var _h = ceil(_y + ceil(_count / 8) * _slot) - _originY;
        var _surface = surface_create(_w, _h);
        if (!surface_exists(_surface)) {
            JEI_DrawCatalogIcons(_s, _l, _first, _count, _x, _y);
            return;
        }
        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0);
        // Composite premultiplied icons so translucent pixels and badges keep their edges.
        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
        JEI_DrawCatalogIcons(_s, _l, _first, _count, _x - _originX, _y - _originY);
        surface_reset_target();
        _cache = {surface:_surface, revision:_s.catalogDrawRevision, first:_first, count:_count, slot:_slot, y:_y};
        _s.catalogSurface = _cache;
    }
    gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
    draw_surface(_cache.surface, _originX, _originY);
    gpu_set_blendmode_ext_sepalpha(_blend[0], _blend[1], _blend[2], _blend[3]);
}
