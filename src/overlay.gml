function JEI_Rect(_x, _y, _w, _h) { return [_x, _y, _x + _w, _y + _h]; }
function JEI_SurfaceColor() { return make_color_rgb(25, 22, 30); }
function JEI_PanelInk() { return make_color_rgb(252, 240, 224); }
function JEI_SidebarWidth(_z) { return 428 * _z; }

function JEI_Layout(_s, _gw, _gh) {
    var _z = min(_gw / 1920, _gh / 1080);
    var _w = JEI_SidebarWidth(_z);
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
        popup: [0, 0, 0, 0], header: [0, 0, 0, 0],
        category: [0, 0, 0, 0], variant: [0, 0, 0, 0],
        recipePrevious: [0, 0, 0, 0], recipeNext: [0, 0, 0, 0],
        materialPrevious: [0, 0, 0, 0], materialNext: [0, 0, 0, 0],
        transfer: [0, 0, 0, 0], outputSlot: [0, 0, 0, 0], outputItem: -1, detailPages: 1, variants: 0};
    if (!_s.configOpen && !_s.detailOpen) return _l;
    var _pw = 650 * _z;
    var _recipes = _s.configOpen ? [] : JEI_ViewRecipes(_s);
    var _recipeCount = array_length(_recipes);
    var _current = _recipeCount > 0 ? _recipes[clamp(_s.variant, 0, _recipeCount - 1)] : undefined;
    var _compact = _recipeCount > 0 && _current.provider != "cube" && array_length(_current.groups) <= 3;
    var _ph = (_s.configOpen ? (_s.configTab == 0 ? 284 : 444) : (_compact ? 320 : 449)) * _z;
    var _x = _s.positioned ? _s.x : _gw * 0.53 - _pw / 2;
    var _y = _s.positioned ? _s.y : _gh * 0.31 - _ph / 2;
    var _px = clamp(_x, _w + 8 * _z, max(_w + 8 * _z, _gw - _pw - 8 * _z));
    var _py = clamp(_y, 8 * _z, max(8 * _z, _gh - _ph - 8 * _z));
    _l.popup = JEI_Rect(_px, _py, _pw, _ph);
    _l.header = JEI_Rect(_px + 20 * _z, _py + 16 * _z, _pw - 66 * _z, 65 * _z);
    if (_s.configOpen) {
        _l.panel = _l.popup;
        _l.tabs = [JEI_Rect(_px + 25 * _z, _py + 84 * _z, 600 * _z, 42 * _z),
            JEI_Rect(_px + 25 * _z, _py + 146 * _z, 600 * _z, 56 * _z)];
        array_push(_l.options, JEI_Rect(_px + 25 * _z, _py + 89 * _z, 600 * _z, 56 * _z));
        _l.developer = JEI_Rect(_px + 25 * _z, _py + 203 * _z, 600 * _z, 57 * _z);
        for (var _i = 0; _i < array_length(JEI_BindingNames()); _i++) array_push(_l.bindings, JEI_Rect(_px + 25 * _z, _py + (132 + _i * 44) * _z, 600 * _z, 42 * _z));
        return _l;
    }
    _l.category = JEI_Rect(_px + 24 * _z, _py + 86 * _z, 466 * _z, 36 * _z);
    _l.variant = JEI_Rect(_px + 504 * _z, _py + 87 * _z, 119 * _z, 30 * _z);
    _l.recipePrevious = JEI_Rect(_l.variant[0], _l.variant[1], 32 * _z, 30 * _z);
    _l.recipeNext = JEI_Rect(_l.variant[2] - 32 * _z, _l.variant[1], 32 * _z, 30 * _z);
    _l.card = JEI_Rect(_px + 16 * _z, _py + 125 * _z, 618 * _z, _ph - 152 * _z);
    _l.variants = _recipeCount;
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
    _l.recipe = _recipe;
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
        _materialStart = _px + (190 - ((_cols - 1) * 124 + 68) / 2) * _z;
        _materialEnd = _px + (190 + ((_cols - 1) * 124 + 68) / 2) * _z;
        if (_l.detailPages > 1) _flowY -= 14 * _z;
        for (var _i = 0; _i < _visible; _i++) {
            var _g = _groups[_s.detailPage * 6 + _i];
            var _alt = floor(get_timer() / 1500000) mod max(1, array_length(_g.ids));
            var _rowCols = min(3, _visible - floor(_i / 3) * 3);
            var _left = 190 - ((_rowCols - 1) * 124 + 68) / 2;
            var _rowY = _flowY + (_visible <= 3 ? 0 : -55 + floor(_i / 3) * 110) * _z;
            array_push(_l.materialSlots, {rect: JEI_Rect(_px + (_left + (_i mod 3) * 124) * _z, _rowY - 34 * _z, 68 * _z, 68 * _z),
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

function JEI_ReadInput(_s) {
    var _pressed = [];
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
        _s.positioned = true;
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
