function JEI_Rect(_x, _y, _w, _h) { return [_x, _y, _x + _w, _y + _h]; }
function JEI_SurfaceColor() { return make_color_rgb(25, 22, 30); }

function JEI_Layout(_s, _gw, _gh) {
    var _z = min(_gw / 1920, _gh / 1080);
    var _w = 428 * _z;
    var _hudScale = variable_global_exists("__CUSTOMIZATION_GUI_SCALE") ? variable_global_get("__CUSTOMIZATION_GUI_SCALE") : 4 * _z;
    var _top = max(245 * _z, 56 * _hudScale + 24 * _z);
    _top = min(_top, _gh - 198 * _z);
    var _rows = max(1, floor((_gh - 64 * _z - _top) / (48 * _z)));
    var _capacity = 8 * _rows;
    var _pages = max(1, ceil(array_length(_s.filtered) / _capacity));
    _s.page = clamp(_s.page, 0, _pages - 1);
    var _l = {z: _z, gw: _gw, gh: _gh, w: _w, h: _gh, x: 0, y: 0, cols: 8, rows: _rows,
        slot: 48 * _z, capacity: _capacity, pages: _pages, panel: JEI_Rect(0, 0, _w, _gh),
        sidebar: JEI_Rect(0, 0, _w, _gh), grid: JEI_Rect(16 * _z, _top, 384 * _z, _rows * 48 * _z),
        previous: JEI_Rect(16 * _z, _top - 36 * _z, 34 * _z, 30 * _z),
        next: JEI_Rect(366 * _z, _top - 36 * _z, 34 * _z, 30 * _z),
        search: JEI_Rect(12 * _z, _gh - 54 * _z, 364 * _z, 46 * _z),
        toggle: JEI_Rect(376 * _z, _gh - 54 * _z, 40 * _z, 46 * _z),
        materialSlots: [], cubeSlots: [], sourceSlots: [], sourceGroups: [], tabs: [], options: [], bindings: [],
        popup: [0, 0, 0, 0], header: [0, 0, 0, 0], close: [0, 0, 0, 0],
        category: [0, 0, 0, 0], variant: [0, 0, 0, 0],
        recipePrevious: [0, 0, 0, 0], recipeNext: [0, 0, 0, 0],
        materialPrevious: [0, 0, 0, 0], materialNext: [0, 0, 0, 0],
        transfer: [0, 0, 0, 0], outputSlot: [0, 0, 0, 0], outputItem: -1, detailPages: 1, variants: 0};
    var _pw = 650 * _z;
    var _view = JEI_ViewRecipes(_s);
    var _compact = array_length(_view) > 0 && _view[clamp(_s.variant, 0, array_length(_view) - 1)].provider != "cube" &&
        array_length(_view[clamp(_s.variant, 0, array_length(_view) - 1)].groups) <= 3;
    var _ph = (_s.configOpen ? (_s.configTab == 0 ? 284 : 444) : (_compact ? 320 : 449)) * _z;
    if (!_s.positioned) { _s.x = max(_w + 16 * _z, _gw * 0.56 - _pw / 2); _s.y = _gh * 0.11; _s.positioned = true; }
    var _px = clamp(_s.x, _w + 8 * _z, max(_w + 8 * _z, _gw - _pw - 8 * _z));
    var _py = clamp(_s.y, 8 * _z, max(8 * _z, _gh - _ph - 8 * _z));
    _l.popup = JEI_Rect(_px, _py, _pw, _ph);
    _l.header = JEI_Rect(_px + 20 * _z, _py + 16 * _z, _pw - 66 * _z, 65 * _z);
    _l.close = JEI_Rect(_px + _pw - 42 * _z, _py + 19 * _z, 28 * _z, 28 * _z);
    if (_s.configOpen) {
        _l.panel = _l.popup;
        _l.tabs = [JEI_Rect(_px + 25 * _z, _py + 84 * _z, 600 * _z, 42 * _z),
            JEI_Rect(_px + 25 * _z, _py + 146 * _z, 600 * _z, 56 * _z)];
        array_push(_l.options, JEI_Rect(_px + 25 * _z, _py + 89 * _z, 600 * _z, 56 * _z));
        _l.developer = JEI_Rect(_px + 25 * _z, _py + 203 * _z, 600 * _z, 57 * _z);
        for (var _i = 0; _i < array_length(JEI_BindingNames()); _i++) array_push(_l.bindings, JEI_Rect(_px + 25 * _z, _py + (132 + _i * 44) * _z, 600 * _z, 42 * _z));
        return _l;
    }
    if (!_s.detailOpen) return _l;
    _l.category = JEI_Rect(_px + 24 * _z, _py + 86 * _z, 466 * _z, 36 * _z);
    _l.variant = JEI_Rect(_px + 504 * _z, _py + 87 * _z, 119 * _z, 30 * _z);
    _l.recipePrevious = JEI_Rect(_l.variant[0], _l.variant[1], 32 * _z, 30 * _z);
    _l.recipeNext = JEI_Rect(_l.variant[2] - 32 * _z, _l.variant[1], 32 * _z, 30 * _z);
    _l.card = JEI_Rect(_px + 16 * _z, _py + 125 * _z, 618 * _z, _ph - 152 * _z);
    var _recipes = JEI_ViewRecipes(_s);
    _l.variants = array_length(_recipes);
    if (_l.variants == 0) {
        var _sources = _s.viewMode == "recipes" ? JEI_Acquisitions(_s, _s.selected) : [];
        var _buckets = {}; var _kinds = []; var _entries = [];
        for (var _i = 0; _i < array_length(_sources); _i++) {
            var _source = _sources[_i]; var _kind = _source.kind;
            if (!variable_struct_exists(_buckets, _kind)) array_push(_kinds, _kind);
            var _bucket = variable_struct_exists(_buckets, _kind) ? variable_struct_get(_buckets, _kind) : [];
            array_push(_bucket, _source); variable_struct_set(_buckets, _kind, _bucket);
        }
        for (var _i = 0; _i < array_length(_kinds); _i++) {
            var _kind = _kinds[_i]; var _bucket = variable_struct_get(_buckets, _kind);
            var _collapsed = variable_struct_exists(_s.sourceCollapsed, _kind);
            array_push(_entries, {kind:_kind, count:array_length(_bucket), collapsed:_collapsed});
            if (!_collapsed) for (var _j = 0; _j < array_length(_bucket); _j++) array_push(_entries, {source:_bucket[_j]});
        }
        _l.detailPages = max(1, ceil(array_length(_entries) / 5));
        _s.detailPage = clamp(_s.detailPage, 0, _l.detailPages - 1);
        for (var _i = 0; _i < 5; _i++) {
            var _index = _s.detailPage * 5 + _i;
            if (_index >= array_length(_entries)) break;
            var _entry = _entries[_index];
            _entry.rect = JEI_Rect(_px + 25 * _z, _py + (130 + _i * 55) * _z, 600 * _z, 51 * _z);
            if (variable_struct_exists(_entry, "source")) array_push(_l.sourceSlots, _entry);
            else array_push(_l.sourceGroups, _entry);
        }
        return _l;
    }
    _s.variant = clamp(_s.variant, 0, _l.variants - 1);
    var _recipe = _recipes[_s.variant];
    _l.outputItem = _recipe.item;
    _l.outputAmount = _recipe.amount;
    var _flowY = (_l.card[1] + _l.card[3]) / 2 - 14 * _z;
    var _materialStart = _px + 74 * _z;
    var _materialEnd = _materialStart + 242 * _z;
    if (_recipe.provider == "cube" && array_length(_recipe.grid) == 3) {
        for (var _cx = 0; _cx < 3; _cx++) for (var _cy = 0; _cy < 3; _cy++) {
            var _cell = _recipe.grid[_cx][_cy];
            array_push(_l.cubeSlots, {rect: JEI_Rect(_px + (111 + _cx * 56) * _z, _flowY + (-83 + _cy * 56) * _z, 54 * _z, 54 * _z),
                id: _cell.id, amount: _cell.amount, alternatives: 1});
        }
    } else {
        var _groups = _recipe.groups;
        _l.detailPages = max(1, ceil(array_length(_groups) / 6));
        _s.detailPage = clamp(_s.detailPage, 0, _l.detailPages - 1);
        var _visible = min(6, array_length(_groups) - _s.detailPage * 6);
        var _cols = min(3, max(1, _visible));
        _materialStart = _px + (190 - ((_cols - 1) * 96 + 68) / 2) * _z;
        _materialEnd = _px + (190 + ((_cols - 1) * 96 + 68) / 2) * _z;
        if (_l.detailPages > 1) _flowY -= 14 * _z;
        for (var _i = 0; _i < _visible; _i++) {
            var _g = _groups[_s.detailPage * 6 + _i];
            var _alt = floor(get_timer() / 1500000) mod max(1, array_length(_g.ids));
            var _rowCols = min(3, _visible - floor(_i / 3) * 3);
            var _left = 190 - ((_rowCols - 1) * 96 + 68) / 2;
            var _rowY = _flowY + (_visible <= 3 ? 0 : -55 + floor(_i / 3) * 110) * _z;
            array_push(_l.materialSlots, {rect: JEI_Rect(_px + (_left + (_i mod 3) * 96) * _z, _rowY - 34 * _z, 68 * _z, 68 * _z),
                id: _g.ids[_alt], amount: _g.amount, alternatives: array_length(_g.ids)});
        }
        _l.materialPrevious = JEI_Rect(_px + 30 * _z, _py + 370 * _z, 28 * _z, 24 * _z);
        _l.materialNext = JEI_Rect(_px + 310 * _z, _py + 370 * _z, 28 * _z, 24 * _z);
    }
    // One centerline drives ingredients, output and the arrow in every recipe shape.
    _l.flowY = _flowY;
    var _inputWidth = _materialEnd - _materialStart;
    var _flowLeft = (_l.popup[0] + _l.popup[2] - _inputWidth - 188 * _z) / 2;
    var _shift = _flowLeft - _materialStart;
    var _slots = array_concat(_l.materialSlots, _l.cubeSlots);
    for (var _i = 0; _i < array_length(_slots); _i++) { _slots[_i].rect[0] += _shift; _slots[_i].rect[2] += _shift; }
    if (array_length(_l.cubeSlots) > 0) _l.cubeHousing = JEI_Rect(_flowLeft, _flowY - 92 * _z, 242 * _z, 184 * _z);
    _l.outputSlot = JEI_Rect(_flowLeft + _inputWidth + 120 * _z, _l.flowY - 34 * _z, 68 * _z, 68 * _z);
    _l.arrowX = _flowLeft + _inputWidth + 60 * _z;
    if (!is_undefined(JEI_API().transferRecipe)) _l.transfer = JEI_Rect(_px + 530 * _z, _py + _ph - 54 * _z, 28 * _z, 28 * _z);
    return _l;
}

function JEI_UICaptureArea(_s, _l, _x, _y) {
    if (!_s.open) return false;
    if (_s.configOpen) return true;
    if (JEI_Hit(_l.sidebar, _x, _y)) return true;
    return _s.detailOpen && JEI_Hit(_l.popup, _x, _y);
}

function JEI_GridItem(_s, _l, _x, _y) {
    if (!JEI_Hit(_l.grid, _x, _y)) return -1;
    var _at = _s.page * _l.capacity + floor((_y - _l.grid[1]) / _l.slot) * 8 + floor((_x - _l.grid[0]) / _l.slot);
    return _at < array_length(_s.filtered) ? _s.filtered[_at] : -1;
}

function JEI_MaterialItem(_s, _l, _x, _y) {
    if (!_s.detailOpen) return -1;
    var _slots = array_concat(_l.materialSlots, _l.cubeSlots);
    for (var _i = 0; _i < array_length(_slots); _i++) if (JEI_Hit(_slots[_i].rect, _x, _y)) return _slots[_i].id;
    if (JEI_Hit(_l.outputSlot, _x, _y)) return _l.outputItem;
    return -1;
}

function JEI_KeyPressed(_input, _key) {
    if (!variable_struct_exists(_input, "pressed")) return false;
    for (var _i = 0; _i < array_length(_input.pressed); _i++) if (_input.pressed[_i] == _key) return true;
    return false;
}

function JEI_ReadInput() {
    var _s = JEI_State(); var _pressed = [];
    if (_s.binding != "") {
        for (var _key = 8; _key <= 222; _key++) if (keyboard_check_pressed(_key)) array_push(_pressed, _key);
    } else {
        var _keys = [vk_escape, vk_up, vk_down, vk_left, vk_right, vk_home, vk_end, vk_delete]; var _names = JEI_BindingNames();
        for (var _i = 0; _i < array_length(_names); _i++) array_push(_keys, variable_struct_get(_s.settings.bindings, _names[_i]).key);
        for (var _i = 0; _i < array_length(_keys); _i++) if (keyboard_check_pressed(_keys[_i])) array_push(_pressed, _keys[_i]);
    }
    return {x: device_mouse_x_to_gui(0), y: device_mouse_y_to_gui(0),
        leftPressed: mouse_check_button_pressed(mb_left), leftDown: mouse_check_button(mb_left),
        rightPressed: mouse_check_button_pressed(mb_right), rightDown: mouse_check_button(mb_right),
        wheel: mouse_wheel_down() - mouse_wheel_up(), ctrl: keyboard_check(vk_control),
        shift: keyboard_check(vk_shift), alt: keyboard_check(vk_alt), focused: window_has_focus(), pressed: _pressed};
}

function JEI_ClosePanel(_s) {
    if (_s.searchFocused) JEI_StopSearch(_s);
    _s.open = false;
    _s.detailOpen = false;
    _s.configOpen = false;
    _s.binding = "";
    _s.dragTarget = "";
    _s.hover = -1;
}

function JEI_ChangeDetailPage(_s, _l, _delta) {
    if (_l.variants > 0) {
        var _new = clamp(_s.variant + _delta, 0, _l.variants - 1);
        if (_new != _s.variant) { _s.variant = _new; _s.detailPage = 0; JEI_RecipeRows(_s); }
    } else _s.detailPage = clamp(_s.detailPage + _delta, 0, _l.detailPages - 1);
}

function JEI_Frame(_s, _input, _gw, _gh, _l = undefined) {
    var _action = {capture: false, search: false, give: -1, amount: 0, transfer: false};
    if (!_s.open) return _action;
    if (is_undefined(_l)) _l = JEI_Layout(_s, _gw, _gh);
    _s.pointerX = _input.x; _s.pointerY = _input.y; _s.hover = -1;
    if (!_input.focused) { _s.dragTarget = ""; return _action; }
    _action.capture = JEI_UICaptureArea(_s, _l, _input.x, _input.y);
    if (_s.dragTarget == "panel") {
        _action.capture = true;
        if (!_input.leftDown) { _s.dragTarget = ""; return _action; }
        _s.x = clamp(_input.x - _s.offsetX, _l.w + 8 * _l.z, _gw - (_l.popup[2] - _l.popup[0]) - 8 * _l.z);
        _s.y = clamp(_input.y - _s.offsetY, 8 * _l.z, _gh - (_l.popup[3] - _l.popup[1]) - 8 * _l.z);
        return _action;
    }
    if (_s.configOpen) { JEI_ConfigClick(_s, _l, _input); return _action; }
    var _insideDetail = _s.detailOpen && JEI_Hit(_l.popup, _input.x, _input.y);
    if (_input.leftPressed || _input.rightPressed) {
        if (_s.searchFocused && !JEI_Hit(_l.search, _input.x, _input.y)) JEI_StopSearch(_s);
    }
    if (_input.wheel != 0) {
        if (_insideDetail) JEI_ChangeDetailPage(_s, _l, _input.wheel);
        else if (JEI_Hit(_l.sidebar, _input.x, _input.y)) _s.page = clamp(_s.page + _input.wheel, 0, _l.pages - 1);
    }
    var _gridItem = _insideDetail ? -1 : JEI_GridItem(_s, _l, _input.x, _input.y);
    var _material = _insideDetail ? JEI_MaterialItem(_s, _l, _input.x, _input.y) : -1;
    _s.hover = max(_gridItem, _material);
    if (JEI_Hit(_l.search, _input.x, _input.y)) {
        if (_input.rightPressed) { JEI_SearchEdit(_s, ""); _s.searchHistoryAt = array_length(_s.searchHistory); }
        if (_input.leftPressed) _action.search = true;
        return _action;
    }
    if (_input.leftPressed) {
        if (_insideDetail) for (var _i = 0; _i < array_length(_l.sourceGroups); _i++) {
            var _group = _l.sourceGroups[_i];
            if (!JEI_Hit(_group.rect, _input.x, _input.y)) continue;
            if (_group.collapsed) variable_struct_remove(_s.sourceCollapsed, _group.kind);
            else variable_struct_set(_s.sourceCollapsed, _group.kind, true);
            return _action;
        }
        if (JEI_Hit(_l.toggle, _input.x, _input.y)) JEI_ToolbarAction(_s, _input);
        else if (_insideDetail && JEI_Hit(_l.close, _input.x, _input.y)) _s.detailOpen = false;
        else if (_insideDetail && JEI_Hit(_l.category, _input.x, _input.y) && _l.variants > 0) {
            var _r = JEI_ViewRecipes(_s)[_s.variant];
            JEI_Select(_s, _s.selected, "category");
            _s.category = JEI_CategoryKey(_r); JEI_RecipeRows(_s);
        } else if (_insideDetail && JEI_Hit(_l.recipePrevious, _input.x, _input.y)) JEI_ChangeDetailPage(_s, _l, -1);
        else if (_insideDetail && JEI_Hit(_l.recipeNext, _input.x, _input.y)) JEI_ChangeDetailPage(_s, _l, 1);
        else if (_insideDetail && _l.detailPages > 1 && JEI_Hit(_l.materialPrevious, _input.x, _input.y)) _s.detailPage = max(0, _s.detailPage - 1);
        else if (_insideDetail && _l.detailPages > 1 && JEI_Hit(_l.materialNext, _input.x, _input.y)) _s.detailPage = min(_l.detailPages - 1, _s.detailPage + 1);
        else if (_insideDetail && JEI_Hit(_l.transfer, _input.x, _input.y)) _action.transfer = true;
        else if (_insideDetail && JEI_Hit(_l.header, _input.x, _input.y)) {
            _s.dragTarget = "panel"; _s.offsetX = _input.x - _l.popup[0]; _s.offsetY = _input.y - _l.popup[1];
        } else if (JEI_Hit(_l.previous, _input.x, _input.y)) _s.page = max(0, _s.page - 1);
        else if (JEI_Hit(_l.next, _input.x, _input.y)) _s.page = min(_l.pages - 1, _s.page + 1);
        else if (_material >= 0) JEI_Select(_s, _material);
        else if (_gridItem >= 0) {
            if (JEI_CanGive(_s, _gridItem)) { _action.give = _gridItem; _action.amount = _input.shift ? max(1, JEI_ItemRow(_gridItem)[6]) : 1; }
            else { JEI_RememberSearch(_s); JEI_Select(_s, _gridItem); }
        }
    }
    if (_input.rightPressed && _s.hover >= 0) {
        if (_gridItem >= 0 && JEI_CanGive(_s, _gridItem)) { _action.give = _gridItem; _action.amount = _input.shift ? max(1, JEI_ItemRow(_gridItem)[6]) : 1; }
        else JEI_Select(_s, _s.hover, "uses");
    }
    return _action;
}

function JEI_Fill(_r, _color, _alpha = 1) {
    draw_set_color(_color); draw_set_alpha(_alpha);
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], false);
    draw_set_alpha(1); draw_set_color(c_white);
}

function JEI_Label(_x, _y, _text, _z, _align = 4, _color = c_white) {
    GUI.DrawText(_x, _y, _text, _align, _color, 1, _z);
}

function JEI_Arrow(_r, _direction, _active, _s, _z) {
    var _hover = _active && JEI_Hit(_r, _s.pointerX, _s.pointerY);
    JEI_Fill(_r, _hover ? make_color_rgb(123, 91, 76) : make_color_rgb(37, 30, 34), _active ? 0.96 : 0.55);
    var _color = _active ? make_color_rgb(242, 216, 177) : make_color_rgb(112, 98, 91);
    var _cx = (_r[0] + _r[2]) / 2 - 2 * _direction * _z;
    var _cy = (_r[1] + _r[3]) / 2;
    for (var _i = 0; _i < 4; _i++) {
        var _ax = _cx + _direction * _i * 2 * _z;
        JEI_Fill(JEI_Rect(_ax, _cy - (7 - _i * 2) * _z, 2 * _z, (14 - _i * 4) * _z), _color);
    }
}

function JEI_DrawBackdrop(_s, _l) {
    // Keep the approved sidebar-only backing below the native HUD.
    // The recipe/settings popup paints its own backing in Draw GUI End.
    JEI_Fill(_l.sidebar, make_color_rgb(50, 37, 39), _s.settings.opacity);
}

function JEI_DrawToolbar(_s, _l) {
    var _r = _l.toggle;
    if (JEI_Hit(_r, _s.pointerX, _s.pointerY)) JEI_Fill(_r, make_color_rgb(106, 79, 68), 0.85);
    var _sprite = _s.skin.wrench;
    if (!sprite_exists(_sprite)) return;
    var _scale = 30 * _l.z / max(sprite_get_width(_sprite), sprite_get_height(_sprite));
    var _cx = (_r[0] + _r[2]) / 2 + (sprite_get_xoffset(_sprite) - sprite_get_width(_sprite) / 2) * _scale;
    var _cy = (_r[1] + _r[3]) / 2 + (sprite_get_yoffset(_sprite) - sprite_get_height(_sprite) / 2) * _scale;
    draw_sprite_ext(_sprite, 0, _cx, _cy, _scale, _scale, 0, _s.cheat ? make_color_rgb(255, 65, 65) : c_white, 1);
}

function JEI_DrawCatalog(_s, _l, _cream, _muted) {
    var _z = _l.z;
    var _text = string(_s.page + 1) + " / " + string(_l.pages);
    JEI_Label(_l.w / 2, _l.grid[1] - 21 * _z, _text, 2 * _z * _s.settings.font, 5, _cream);
    JEI_Arrow(_l.previous, -1, _s.page > 0, _s, _z);
    JEI_Arrow(_l.next, 1, _s.page + 1 < _l.pages, _s, _z);
    for (var _i = 0; _i < _l.capacity; _i++) {
        var _index = _s.page * _l.capacity + _i;
        if (_index >= array_length(_s.filtered)) break;
        var _id = _s.filtered[_index];
        var _x = _l.grid[0] + (_i mod 8) * _l.slot;
        var _y = _l.grid[1] + floor(_i / 8) * _l.slot;
        var _r = JEI_Rect(_x + _z, _y + _z, _l.slot - 2 * _z, _l.slot - 2 * _z);
        if (_s.hover == _id || _s.detailOpen && _s.selected == _id) JEI_Fill(_r, _cream, _s.hover == _id ? 0.24 : 0.12);
        JEI_Icon(_id, _x + _l.slot / 2, _y + _l.slot / 2, 46 * _z);
        if (JEI_IsBlueprint(_id)) JEI_Icon(1024, _x + _l.slot - 11 * _z, _y + _l.slot - 11 * _z, 16 * _z);
    }
    if (array_length(_s.filtered) == 0) JEI_Label(_l.w / 2, _l.grid[1] + 60 * _z, JEI_Text(_s.catalogReady ? "empty" : "loading"), 1.8 * _z, 5, _muted);
    var _footer = [_l.search[0], _l.search[1], _l.toggle[2], _l.toggle[3]];
    JEI_Fill(_footer, JEI_SurfaceColor());
    draw_set_color(_s.searchFocused ? _cream : _muted);
    draw_rectangle(_footer[0], _footer[1], _footer[2], _footer[3], true);
    draw_line(_l.toggle[0], _footer[1] + 4 * _z, _l.toggle[0], _footer[3] - 4 * _z);
    draw_set_color(c_white);
    var _field = JEI_SearchField(_s, _l);
    var _fieldX = _l.search[0] + 12 * _z; var _fieldY = (_l.search[1] + _l.search[3]) / 2;
    JEI_Label(_fieldX, _fieldY, _field.text, 2 * _z * _s.settings.font, 4, _cream);
    if (_s.searchFocused && (floor((get_timer() - _s.searchCaretAt) / 500000) mod 2) == 0) {
        var _height = 24 * _z * _s.settings.font;
        JEI_Fill(JEI_Rect(_fieldX + _field.caretX, _fieldY - _height / 2, max(1, _z), _height), _cream);
    }
    JEI_DrawToolbar(_s, _l);
}

function JEI_SearchField(_s, _l) {
    var _text = _s.search == "" && !_s.searchFocused ? JEI_Text("search") : _s.search;
    var _caret = _s.searchFocused ? clamp(_s.searchCursor, 0, string_length(_text)) : 0;
    var _scale = 2 * _l.z * _s.settings.font;
    var _width = _l.search[2] - _l.search[0] - 26 * _l.z;
    var _cache = _s.searchRenderCache;
    if (is_struct(_cache) && _cache.source == _text && _cache.cursor == _caret && _cache.scale == _scale && _cache.width == _width && _cache.focused == _s.searchFocused) return _cache;
    var _start = _s.searchFocused ? clamp(_s.searchViewStart, 0, _caret) : 0;
    while (_start < _caret && JEI_TextWidth(string_copy(_text, _start + 1, _caret - _start), _scale) > _width) _start += 1;
    var _end = _start;
    while (_end < string_length(_text) && JEI_TextWidth(string_copy(_text, _start + 1, _end - _start + 1), _scale) <= _width) _end += 1;
    _s.searchViewStart = _start;
    _cache = {source:_text, cursor:_caret, scale:_scale, width:_width, focused:_s.searchFocused,
        text:string_copy(_text, _start + 1, _end - _start), caretX:_caret > _start ? JEI_TextWidth(string_copy(_text, _start + 1, _caret - _start), _scale) : 0};
    _s.searchRenderCache = _cache;
    return _cache;
}

function JEI_DrawSlot(_s, _entry, _z, _ink, _cube = false, _label = true) {
    var _r = _entry.rect;
    var _sprite = asset_get_index(_cube ? "sprGUIIngameEquipmentSlotCube" : "sprGUIIngameInventorySlot");
    JEI_DrawTile(_sprite, _r);
    if (_entry.id < 0) return;
    var _cx = (_r[0] + _r[2]) / 2;
    var _cy = (_r[1] + _r[3]) / 2;
    if (_s.hover == _entry.id) JEI_Fill(_r, c_white, 0.16);
    JEI_Icon(_entry.id, _cx, _cy - (_cube ? 5 * _z : 0), (_cube ? 35 : 54) * _z);
    var _count = _entry.amount > 1 ? string(_entry.amount) : "";
    if (_count != "" && _cube) {
        JEI_Label(_r[2] - 4 * _z, _r[3] - 8 * _z, _count, 1.3 * _z, 6, c_white);
    }
    if (_label) {
        var _scale = 1.65 * _z * _s.settings.font;
        var _suffix = _count == "" ? "" : (JEI_Locale() == 1 ? " ×" : " x") + _count;
        var _fit = JEI_FitWidth(JEI_Name(_entry.id), _scale, 94 * _z - JEI_TextWidth(_suffix, _scale));
        JEI_Label(_cx, _r[3] + 14 * _z, _fit + _suffix, _scale, 5, _ink);
    }
}

function JEI_DrawTile(_sprite, _rect) {
    if (!sprite_exists(_sprite)) return;
    var _w = sprite_get_width(_sprite); var _h = sprite_get_height(_sprite);
    draw_sprite_part_ext(_sprite, 0, 0, 0, _w, _h, _rect[0], _rect[1],
        (_rect[2] - _rect[0]) / _w, (_rect[3] - _rect[1]) / _h, c_white, 1);
}

function JEI_DrawPopupFrame(_s, _l, _title, _item = -1) {
    var _r = _l.popup; var _z = _l.z; var _border = max(4, round(17 * _z));
    var _left = round(_r[0]); var _top = round(_r[1]);
    var _right = round(_r[2]); var _bottom = round(_r[3]);
    JEI_Fill([_left + _border - 1, _top + _border - 1, _right - _border, _bottom - _border], make_color_rgb(215, 179, 142));
    var _sprite = asset_get_index("sprGUIIngameEquipmentContainer");
    if (sprite_exists(_sprite)) {
        var _w = sprite_get_width(_sprite); var _h = sprite_get_height(_sprite);
        var _sx = [0, 9, _w - 9, _w]; var _sy = [0, 9, _h - 9, _h];
        var _dx = [_left, _left + _border, _right - _border, _right];
        var _dy = [_top, _top + _border, _bottom - _border, _bottom];
        for (var _x = 0; _x < 3; _x++) for (var _y = 0; _y < 3; _y++) {
            if (_x == 1 && _y == 1) continue;
            var _sw = _sx[_x + 1] - _sx[_x]; var _sh = _sy[_y + 1] - _sy[_y];
            draw_sprite_part_ext(_sprite, 0, _sx[_x], _sy[_y], _sw, _sh, _dx[_x], _dy[_y],
                (_dx[_x + 1] - _dx[_x]) / _sw, (_dy[_y + 1] - _dy[_y]) / _sh, c_white, 1);
        }
    }
    var _ink = make_color_rgb(68, 39, 39);
    var _titleX = _left + 26 * _z;
    if (_item >= 0) {
        JEI_Icon(_item, _left + 44 * _z, _top + 46 * _z, 38 * _z);
        _titleX += 46 * _z;
    }
    var _scale = 2.2 * _z * _s.settings.font;
    var _fit = JEI_FitWidth(_title, _scale, _r[2] - _titleX - 61 * _z);
    JEI_Label(_titleX, _top + (_item >= 0 ? 36 : 45) * _z, _fit, _scale, 4, _ink);
    if (_item >= 0) {
        var _doc = variable_struct_get(_s.searchDocs, string(_item));
        var _origin = is_struct(_doc) ? _doc.origin : "Tinkerlands";
        JEI_Label(_titleX, _top + 61 * _z, _origin, 1.5 * _z, 4, _ink);
    }
    JEI_Fill(JEI_Rect(_left + 24 * _z, _top + 79 * _z, _right - _left - 48 * _z, max(1, _z)), make_color_rgb(160, 112, 90));
    JEI_Fill(_l.close, make_color_rgb(111, 67, 53));
    JEI_Label((_l.close[0] + _l.close[2]) / 2, (_l.close[1] + _l.close[3]) / 2, "X", 1.8 * _z, 5, c_white);
}

function JEI_StationItem(_recipe) {
    if (_recipe.provider == "cube") return JEI_NativeItemIndex("transmute_cube");
    var _db = JEI_AcquisitionDB("INTERACTABLE");
    var _row = JEI_AcquisitionRecord(_db, _recipe.station);
    return JEI_NativeItemIndex(JEI_AcquisitionField(_db, _row, "item"));
}

function JEI_DrawRecipe(_s, _l, _ink, _muted) {
    var _z = _l.z; var _x = _l.popup[0]; var _y = _l.popup[1];
    var _recipes = JEI_ViewRecipes(_s);
    var _has = array_length(_recipes) > 0;
    var _uses = _s.viewMode == "uses";
    JEI_DrawPopupFrame(_s, _l, JEI_Name(_s.selected), _s.selected);
    if (_has) {
        var _r = _recipes[_s.variant];
        var _station = JEI_StationItem(_r);
        var _label = JEI_StationName(_r);
        if (_uses) _label = JEI_Text("uses") + " · " + _label;
        if (_station >= 0) JEI_Icon(_station, _x + 39 * _z, _y + 103 * _z, 26 * _z);
        var _size = 1.8 * _z * _s.settings.font;
        var _fit = JEI_FitWidth(_label, _size, 427 * _z);
        JEI_Label(_x + 60 * _z, _y + 103 * _z, _fit, _size, 4, _ink);
    } else {
        var _count = _uses ? 0 : array_length(JEI_Acquisitions(_s, _s.selected));
        if (_count > 0) {
            var _label = JEI_Text("acquisition") + " (" + string(_count) + ")";
            JEI_Label(_x + 25 * _z, _y + 103 * _z, _label, 1.8 * _z, 4, _ink);
        }
    }
    var _page = _has ? _s.variant : _s.detailPage;
    var _pages = _has ? _l.variants : _l.detailPages;
    if (_pages > 1) {
        var _pageText = string(_page + 1) + " / " + string(_pages);
        JEI_Label(_x + 564 * _z, _y + 103 * _z, _pageText, 1.5 * _z, 5, _ink);
        JEI_Arrow(_l.recipePrevious, -1, _page > 0, _s, _z);
        JEI_Arrow(_l.recipeNext, 1, _page + 1 < _pages, _s, _z);
    }
    if (!_has) {
        if (!_uses && !_s.acquisitionsReady && array_length(_l.sourceSlots) == 0) JEI_Label(_x + 325 * _z, _y + 220 * _z, JEI_Text("loading"), 1.8 * _z, 5, _muted);
        for (var _i = 0; _i < array_length(_l.sourceGroups); _i++) {
            var _group = _l.sourceGroups[_i]; var _gr = _group.rect;
            var _arrow = asset_get_index(_group.collapsed ? "sprGUIIngameArrowRight" : "sprGUIIngameArrowDown");
            JEI_Fill(_gr, make_color_rgb(192, 150, 117), JEI_Hit(_gr, _s.pointerX, _s.pointerY) ? 0.8 : 0.44);
            JEI_SpriteIcon(_arrow, _gr[0] + 16 * _z, _gr[1] + 24 * _z, 15 * _z);
            JEI_Label(_gr[0] + 33 * _z, _gr[1] + 24 * _z, JEI_Text(_group.kind), 1.65 * _z, 4, _ink);
            JEI_Label(_gr[2] - 12 * _z, _gr[1] + 24 * _z, string(_group.count), 1.5 * _z, 6, _ink);
        }
        for (var _i = 0; _i < array_length(_l.sourceSlots); _i++) {
            var _entry = _l.sourceSlots[_i]; var _source = _entry.source; var _sr = _entry.rect;
            JEI_Fill(JEI_Rect(_sr[0], _sr[3] - _z, _sr[2] - _sr[0], max(1, _z)), make_color_rgb(174, 130, 104));
            JEI_SpriteIcon(_source.sprite, _sr[0] + 22 * _z, _sr[1] + 25 * _z, 34 * _z);
            JEI_Label(_sr[0] + 52 * _z, _sr[1] + 12 * _z, JEI_Text(_source.kind), 1.35 * _z * _s.settings.font, 4, _muted);
            JEI_Label(_sr[0] + 52 * _z, _sr[1] + 34 * _z, JEI_Fit(_source.name, JEI_Locale() == 0 ? 44 : 26), 1.7 * _z * _s.settings.font, 4, _ink);
            if (JEI_Hit(_sr, _s.pointerX, _s.pointerY)) _l.hoverSource = _source;
        }
        return;
    }
    var _cube = array_length(_l.cubeSlots) > 0;
    if (_cube) {
        var _housing = asset_get_index("sprGUIIngameCubeContainer");
        JEI_DrawTile(_housing, _l.cubeHousing);
        for (var _i = 0; _i < array_length(_l.cubeSlots); _i++) JEI_DrawSlot(_s, _l.cubeSlots[_i], _z, _ink, true, false);
        var _arrow = asset_get_index("sprGUIIngameArrowRight");
        JEI_SpriteIcon(_arrow, _l.arrowX, _l.flowY, 29 * _z);
    } else {
        for (var _i = 0; _i < array_length(_l.materialSlots); _i++) JEI_DrawSlot(_s, _l.materialSlots[_i], _z, _ink);
        var _arrow = asset_get_index("sprGUIIngameArrowRight");
        JEI_SpriteIcon(_arrow, _l.arrowX, _l.flowY, 26 * _z);
    }
    JEI_DrawSlot(_s, {rect: _l.outputSlot, id: _l.outputItem, amount: _l.outputAmount}, _z, _ink, false, !_cube);
    if (_cube && _l.outputAmount > 1) JEI_Label(_l.outputSlot[2] - 4 * _z, _l.outputSlot[3] - 8 * _z, string(_l.outputAmount), 1.3 * _z, 6, _ink);
    if (_l.detailPages > 1) {
        JEI_Arrow(_l.materialPrevious, -1, _s.detailPage > 0, _s, _z);
        JEI_Arrow(_l.materialNext, 1, _s.detailPage + 1 < _l.detailPages, _s, _z);
        JEI_Label(_x + 190 * _z, _y + 382 * _z, string(_s.detailPage + 1) + " / " + string(_l.detailPages), 1.4 * _z, 5, _ink);
    }
    if (_l.transfer[2] > 0) { JEI_Box(_s, _l.transfer, false, _z); JEI_Label((_l.transfer[0] + _l.transfer[2]) / 2, (_l.transfer[1] + _l.transfer[3]) / 2, "+", 1.8 * _z, 5); }
}

function JEI_ConfigRow(_s, _r, _z, _name, _value, _note = "") {
    var _ink = make_color_rgb(68, 39, 39);
    var _mid = (_r[1] + _r[3]) / 2;
    JEI_Fill(JEI_Rect(_r[0], _r[3] - _z, _r[2] - _r[0], max(1, _z)), make_color_rgb(174, 130, 104));
    var _button = JEI_Rect(_r[2] - 77 * _z, _mid - 15 * _z, 75 * _z, 30 * _z);
    JEI_Fill(_button, make_color_rgb(111, 67, 53));
    JEI_Label(_r[0] + 4 * _z, _mid - (_note == "" ? 0 : 9 * _z), _name, 1.8 * _z, 4, _ink);
    var _noteFit = JEI_FitWidth(_note, 1.33 * _z, 504 * _z);
    if (_noteFit != "") JEI_Label(_r[0] + 4 * _z, _mid + 13 * _z, _noteFit, 1.33 * _z, 4, _ink);
    var _scale = min(1.5 * _z, 69 * _z / max(1, JEI_TextWidth(_value, 1)));
    JEI_Label(_r[2] - 39 * _z, _mid, _value, _scale, 5, c_white);
}

function JEI_DrawConfig(_s, _l, _ink, _muted) {
    var _z = _l.z; var _x = _l.popup[0]; var _y = _l.popup[1];
    JEI_DrawPopupFrame(_s, _l, JEI_Text("config"));
    if (_s.configTab == 0) {
        JEI_ConfigRow(_s, _l.options[0], _z, JEI_Text("auto_pause_short"), JEI_Text(_s.settings.autoPause ? "setting_on" : "setting_off"), JEI_Text("singleplayer_only"));
        JEI_ConfigRow(_s, _l.tabs[1], _z, JEI_Text("shortcuts"), JEI_Text("expand"));
        JEI_ConfigRow(_s, _l.developer, _z, JEI_Text("developer_short"), JEI_Text(_s.developer ? "setting_on" : "setting_off"), JEI_Text("developer_note"));
        return;
    }
    JEI_ConfigRow(_s, _l.tabs[0], _z, JEI_Text("shortcuts"), JEI_Text("collapse"));
    var _names = JEI_BindingNames();
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _n = _names[_i]; var _b = variable_struct_get(_s.settings.bindings, _n);
        JEI_ConfigRow(_s, _l.bindings[_i], _z, JEI_Text("bind_" + _n), _s.binding == _n ? "..." : JEI_BindingText(_b));
    }
    var _tip = _s.bindingNotice != "" ? _s.bindingNotice : (_s.binding != "" ? "press_key" : "bind_tip");
    JEI_Label(_x + 325 * _z, _y + 418 * _z, JEI_Text(_tip), 1.5 * _z, 5, _ink);
}

function JEI_TooltipLayout(_s, _l) {
    var _z = _l.z; var _font = _s.settings.font; var _choice = false;
    for (var _i = 0; _i < array_length(_l.materialSlots); _i++) {
        var _entry = _l.materialSlots[_i];
        if (_entry.alternatives > 1 && JEI_Hit(_entry.rect, _s.pointerX, _s.pointerY)) _choice = true;
    }
    var _key = string(_s.hover) + ":" + string(_z) + ":" + string(_font) + ":" + string(_choice);
    if (!is_undefined(_s.tooltipCache) && _s.tooltipCache.key == _key) return _s.tooltipCache;
    var _doc = variable_struct_get(_s.searchDocs, string(_s.hover));
    var _description = is_struct(_doc) ? _doc.description : "";
    var _origin = is_struct(_doc) ? _doc.origin : "Tinkerlands";
    if (_choice) _description += (_description == "" ? "" : chr(10)) + JEI_Text("choose");
    var _lines = []; var _maxWidth = min(400 * _z, _l.gw - 40 * _z); var _w = 92 * _z; var _y = 10 * _z;
    var _groups = [
        {text:JEI_Name(_s.hover), scale:1.8 * _z * _font, color:make_color_rgb(255,235,205), limit:3},
        {text:_description, scale:1.6 * _z * _font, color:make_color_rgb(198,190,191), limit:12},
        {text:_origin, scale:1.5 * _z * _font, color:make_color_rgb(144,143,230), limit:2}];
    for (var _g = 0; _g < array_length(_groups); _g++) {
        var _group = _groups[_g]; var _wrapped = JEI_WrapText(_group.text, _group.scale, _maxWidth);
        var _count = min(_group.limit, array_length(_wrapped));
        if (_g > 0 && _count > 0) _y += 4 * _z;
        for (var _i = 0; _i < _count; _i++) {
            var _line = _wrapped[_i];
            if (_i + 1 == _count && array_length(_wrapped) > _count) _line = JEI_FitWidth(_line + "..", _group.scale, _maxWidth);
            var _height = (_g == 0 ? 26 : 23) * _z * _font;
            array_push(_lines, {text:_line, scale:_group.scale, color:_group.color, y:_y + _height / 2});
            _w = max(_w, JEI_TextWidth(_line, _group.scale)); _y += _height;
        }
    }
    _s.tooltipCache = {key:_key, lines:_lines, w:_w + 24 * _z, h:_y + 10 * _z};
    return _s.tooltipCache;
}

function JEI_DrawTooltip(_s, _l, _cream, _muted) {
    if (_s.hover < 0) return;
    var _z = _l.z; var _tip = JEI_TooltipLayout(_s, _l);
    var _x = _s.pointerX + 20 * _z;
    if (_x + _tip.w > _l.gw - 4 * _z) _x = _s.pointerX - _tip.w - 12 * _z;
    _x = max(4 * _z, _x);
    var _y = clamp(_s.pointerY + 16 * _z, 4 * _z, max(4 * _z, _l.gh - _tip.h - 4 * _z));
    JEI_Fill(JEI_Rect(_x + 3 * _z, _y + 3 * _z, _tip.w, _tip.h), c_black, 0.35);
    JEI_Fill(JEI_Rect(_x, _y, _tip.w, _tip.h), make_color_rgb(18, 14, 23), 0.97);
    draw_set_color(make_color_rgb(103, 81, 139));
    draw_rectangle(_x, _y, _x + _tip.w, _y + _tip.h, true);
    draw_set_color(make_color_rgb(53, 39, 69));
    draw_rectangle(_x + _z, _y + _z, _x + _tip.w - _z, _y + _tip.h - _z, true);
    for (var _i = 0; _i < array_length(_tip.lines); _i++) {
        var _line = _tip.lines[_i]; JEI_Label(_x + 12 * _z, _y + _line.y, _line.text, _line.scale, 4, _line.color);
    }
    draw_set_color(c_white);
}

function JEI_Draw(_s, _gw = -1, _gh = -1) {
    if (!_s.open) return;
    if (_gw < 0) _gw = display_get_gui_width();
    if (_gh < 0) _gh = display_get_gui_height();
    var _l = JEI_Layout(_s, _gw, _gh);
    var _cream = make_color_rgb(255, 235, 205); var _muted = make_color_rgb(214, 184, 157);
    JEI_DrawCatalog(_s, _l, _cream, _muted);
    var _ink = make_color_rgb(68, 39, 39);
    var _brown = make_color_rgb(110, 70, 53);
    if (_s.configOpen) JEI_DrawConfig(_s, _l, _ink, _brown);
    else if (_s.detailOpen) JEI_DrawRecipe(_s, _l, _ink, _brown);
    if (variable_struct_exists(_l, "hoverSource") && _s.hover < 0) {
        var _source = _l.hoverSource;
        var _name = JEI_FitWidth(_source.name, 1.65 * _l.z, 380 * _l.z);
        var _tx = clamp(_s.pointerX + 18 * _l.z, 4 * _l.z, _gw - 412 * _l.z);
        var _ty = clamp(_s.pointerY + 14 * _l.z, 4 * _l.z, _gh - 64 * _l.z);
        JEI_Fill(JEI_Rect(_tx, _ty, 400 * _l.z, 54 * _l.z), make_color_rgb(30, 23, 32));
        JEI_Label(_tx + 9 * _l.z, _ty + 15 * _l.z, _name, 1.65 * _l.z, 4, _cream);
        JEI_Label(_tx + 9 * _l.z, _ty + 39 * _l.z, JEI_Text(_source.kind), 1.4 * _l.z, 4, _muted);
    }
    if (!_s.configOpen) JEI_DrawTooltip(_s, _l, _cream, _muted);
    draw_set_alpha(1); draw_set_color(c_white);
}

function JEI_DrawPause(_s, _w = -1, _h = -1) {
    if (!_s.pauseOwned) return;
    if (_w < 0) _w = display_get_gui_width();
    if (_h < 0) _h = display_get_gui_height();
    var _z = min(_w / 1920, _h / 1080);
    JEI_Fill(JEI_Rect(_w / 2 - 100 * _z, 12 * _z, 200 * _z, 42 * _z), make_color_rgb(21, 19, 27), 0.9);
    JEI_Label(_w / 2, 33 * _z, JEI_Text("paused"), 2.1 * _z, 5, make_color_rgb(255, 235, 205));
}
