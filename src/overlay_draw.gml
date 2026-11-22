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

function JEI_CreateBackdrop(_s) {
    var _hud = instance_find(objGUIIngameController, 0);
    var _backdrop = ModInstance.Create("jei_backdrop", undefined, undefined, undefined, "JEI_BackdropDraw", "");
    // Draw after the world has been composited and immediately before the native HUD.
    _backdrop.depth = _hud.depth + 1;
    _s.backdrop = _backdrop;
}

function JEI_BackdropDraw() {
    var _s = JEI_State();
    if (!_s.open || _s.pauseOwned || !JEI_WorldReady()) return;
    var _inventoryOpen = JEI_Runtime().inventoryOpen;
    if (_inventoryOpen()) JEI_DrawBackdrop(_s, display_get_gui_width(), display_get_gui_height());
}

function JEI_DrawBackdrop(_s, _w, _h) {
    // The game already shades the entire world during a single-player pause.
    if (_s.pauseOwned || _w <= 0 || _h <= 0) return;
    var _z = min(_w / 1920, _h / 1080);
    var _side = round(JEI_SidebarWidth(_z));
    JEI_Fill([_side, 0, _w, _h], make_color_rgb(21, 17, 30), 0.26);
    var _rect = [0, 0, _side, _h];
    JEI_Fill(_rect, make_color_rgb(34, 29, 47), _s.settings.opacity);
}

function JEI_DrawCatalog(_s, _l, _cream, _muted) {
    var _z = _l.z;
    var _text = string(_s.page + 1) + " / " + string(_l.pages);
    JEI_Label(_l.w / 2, _l.grid[1] - 21 * _z, _text, 2 * _z * _s.settings.font, 5, _cream);
    JEI_Arrow(_l.previous, -1, _s.page > 0, _s, _z);
    JEI_Arrow(_l.next, 1, _s.page + 1 < _l.pages, _s, _z);
    JEI_DrawCatalogGrid(_s, _l, _cream);
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

function JEI_PanelLabel(_x, _y, _text, _scale, _align = 4, _color = c_white) {
    var _a = JEI_Runtime(); var _draw = _a.panelText; var _alignText = _a.textAlign;
    var _border = {width:0, alpha:0, color:c_black};
    var _shadow = {offset:0, alpha:0, color:c_black};
    if (is_undefined(_draw) || is_undefined(_alignText)) {
        JEI_Label(_x, _y, _text, _scale, _align, _color);
        return;
    }
    _alignText(_align);
    var _fonts = variable_global_get("__FONTS");
    var _font = _fonts.normalString;
    _draw(round(_x), round(_y), _text, _color, 1, _scale, _border, _shadow, _font);
}

function JEI_PanelText(_x, _y, _text, _scale, _width, _limit, _align, _color) {
    var _lines = JEI_WrapText(_text, _scale, _width);
    var _count = min(array_length(_lines), _limit);
    var _step = 10 * _scale;
    for (var _i = 0; _i < _count; _i++) {
        var _line = _lines[_i];
        if (_i + 1 == _count && _count < array_length(_lines)) _line = JEI_FitWidth(_line + "..", _scale, _width);
        JEI_PanelLabel(_x, _y + _i * _step, _line, _scale, _align, _color);
    }
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
        JEI_PanelLabel(_r[2] - 4 * _z, _r[3] - 8 * _z, _count, 1.3 * _z, 6, c_white);
    }
    if (_label) {
        var _scale = 1.75 * _z * _s.settings.font;
        var _suffix = _count == "" ? "" : " x" + _count;
        JEI_PanelText(_cx, _r[3] + 12 * _z, JEI_Name(_entry.id) + _suffix, _scale, 120 * _z, 3, 5, _ink);
    }
}

function JEI_DrawTile(_sprite, _rect) {
    if (!sprite_exists(_sprite)) return;
    var _w = sprite_get_width(_sprite); var _h = sprite_get_height(_sprite);
    draw_sprite_part_ext(_sprite, 0, 0, 0, _w, _h, _rect[0], _rect[1],
        (_rect[2] - _rect[0]) / _w, (_rect[3] - _rect[1]) / _h, c_white, 1);
}

function JEI_DrawPopupFrame(_s, _l, _title, _item = -1) {
    var _r = _l.popup; var _z = _l.z;
    var _left = round(_r[0]); var _top = round(_r[1]);
    var _right = round(_r[2]) - 1; var _bottom = round(_r[3]) - 1;
    var _black = make_color_rgb(27, 9, 25);
    // Recess the frame rails slightly so the corner caps sit over both edges.
    var _colors = [_black, make_color_rgb(77, 67, 105), make_color_rgb(50, 33, 63),
        make_color_rgb(32, 18, 38), make_color_rgb(50, 33, 63), make_color_rgb(63, 49, 82)];
    var _steps = [3, 6, 9, 12, 15, 22];
    for (var _i = 0; _i < array_length(_steps); _i++) {
        var _inset = round(_steps[_i] * _z);
        JEI_Fill([_left + _inset, _top + _inset, _right - _inset, _bottom - _inset], _colors[_i]);
    }
    // Each native cap spans 12 pixels along both edges. Its inner 4x4 area
    // belongs to the equipment panel's tan backing, so cut the cap in two strips.
    var _sprite = asset_get_index("sprGUIIngameEquipmentContainer");
    if (sprite_exists(_sprite)) {
        var _size = 12; var _band = 8; var _wing = _size - _band;
        var _corner = max(6, round(36 * _z));
        var _bandSize = round(_corner * _band / _size);
        var _sourceWidth = sprite_get_width(_sprite);
        var _sourceHeight = min(145, sprite_get_height(_sprite));
        for (var _column = 0; _column < 2; _column++) for (var _row = 0; _row < 2; _row++) {
            var _srcX = _column == 0 ? 0 : _sourceWidth - _size;
            var _dstX = _column == 0 ? _left : _right + 1 - _corner;
            var _srcY = _row == 0 ? 0 : _sourceHeight - _band;
            var _dstY = _row == 0 ? _top : _bottom + 1 - _bandSize;
            draw_sprite_part_ext(_sprite, 0, _srcX, _srcY, _size, _band, _dstX, _dstY,
                _corner / _size, _bandSize / _band, c_white, 1);
            _srcX = _column == 0 ? 0 : _sourceWidth - _band;
            _dstX = _column == 0 ? _left : _right + 1 - _bandSize;
            _srcY = _row == 0 ? _band : _sourceHeight - _size;
            _dstY = _row == 0 ? _top + _bandSize : _bottom + 1 - _corner;
            draw_sprite_part_ext(_sprite, 0, _srcX, _srcY, _band, _wing, _dstX, _dstY,
                _bandSize / _band, (_corner - _bandSize) / _wing, c_white, 1);
        }
    }
    var _ink = JEI_PanelInk();
    var _titleX = _left + 26 * _z;
    if (_item >= 0) {
        JEI_Icon(_item, _left + 44 * _z, _top + 46 * _z, 38 * _z);
        _titleX += 46 * _z;
    }
    var _scale = 2.25 * _z * _s.settings.font;
    var _titleWidth = _r[2] - _titleX - 38 * _z;
    var _twoLines = _item >= 0 && JEI_TextWidth(_title, _scale) > _titleWidth;
    JEI_PanelText(_titleX, _top + (_item < 0 ? 45 : (_twoLines ? 28 : 36)) * _z,
        _title, _scale, _titleWidth, _item >= 0 ? 2 : 1, 4, _ink);
    if (_item >= 0) {
        var _doc = variable_struct_get(_s.searchDocs, string(_item));
        var _origin = is_struct(_doc) ? _doc.origin : "Tinkerlands";
        JEI_PanelLabel(_titleX, _top + (_twoLines ? 70 : 61) * _z, _origin, 1.5 * _z, 4, make_color_rgb(211, 199, 226));
    }
    JEI_Fill(JEI_Rect(_left + 24 * _z, _top + 79 * _z, _right + 1 - _left - 48 * _z, max(1, _z)), make_color_rgb(121, 105, 143));
}

function JEI_StationItem(_recipe) {
    if (_recipe.provider == "cube") return JEI_NativeItemIndex("transmute_cube");
    var _db = JEI_AcquisitionDB("INTERACTABLE");
    var _row = JEI_AcquisitionRecord(_db, _recipe.station);
    return JEI_NativeItemIndex(JEI_AcquisitionField(_db, _row, "item"));
}

function JEI_DrawRecipe(_s, _l, _ink, _muted) {
    var _z = _l.z; var _x = _l.popup[0]; var _y = _l.popup[1];
    var _has = _l.variants > 0;
    var _uses = _s.viewMode == "uses";
    JEI_DrawPopupFrame(_s, _l, JEI_Name(_s.selected), _s.selected);
    if (_has) {
        var _r = _l.recipe;
        var _station = JEI_StationItem(_r);
        var _label = JEI_StationName(_r);
        if (_uses) _label = JEI_Text("uses") + " · " + _label;
        if (_station >= 0) JEI_Icon(_station, _x + 44 * _z, _y + 103 * _z, 34 * _z);
        var _size = 2.12 * _z * _s.settings.font;
        var _stationX = _station >= 0 ? 68 : 27;
        var _fit = JEI_FitWidth(_label, _size, (490 - _stationX) * _z);
        JEI_PanelLabel(_x + _stationX * _z, _y + 103 * _z, _fit, _size, 4, _ink);
    } else {
        var _count = _uses ? 0 : array_length(JEI_Acquisitions(_s, _s.selected));
        if (_count > 0) {
            var _label = JEI_Text("acquisition") + " (" + string(_count) + ")";
            JEI_PanelLabel(_x + 25 * _z, _y + 103 * _z, _label, 1.8 * _z, 4, _ink);
        }
    }
    var _page = _has ? _s.variant : _s.detailPage;
    var _pages = _has ? _l.variants : _l.detailPages;
    if (_pages > 1) {
        var _pageText = string(_page + 1) + " / " + string(_pages);
        JEI_PanelLabel(_x + 564 * _z, _y + 103 * _z, _pageText, 1.5 * _z, 5, _ink);
        JEI_Arrow(_l.recipePrevious, -1, _page > 0, _s, _z);
        JEI_Arrow(_l.recipeNext, 1, _page + 1 < _pages, _s, _z);
    }
    if (!_has) {
        if (!_uses && !_s.acquisitionsReady && array_length(_l.sourceSlots) == 0) JEI_PanelLabel(_x + 325 * _z, _y + 220 * _z, JEI_Text("loading"), 1.8 * _z, 5, _muted);
        for (var _i = 0; _i < array_length(_l.sourceGroups); _i++) {
            var _group = _l.sourceGroups[_i]; var _gr = _group.rect;
            var _arrow = asset_get_index(_group.collapsed ? "sprGUIIngameArrowRight" : "sprGUIIngameArrowDown");
            JEI_Fill(_gr, make_color_rgb(117, 99, 139), JEI_Hit(_gr, _s.pointerX, _s.pointerY) ? 0.64 : 0.28);
            JEI_SpriteIcon(_arrow, _gr[0] + 16 * _z, _gr[1] + 24 * _z, 15 * _z);
            JEI_PanelLabel(_gr[0] + 33 * _z, _gr[1] + 24 * _z, JEI_Text(_group.kind), 1.65 * _z, 4, _ink);
            JEI_PanelLabel(_gr[2] - 12 * _z, _gr[1] + 24 * _z, string(_group.count), 1.5 * _z, 6, _ink);
        }
        for (var _i = 0; _i < array_length(_l.sourceSlots); _i++) {
            var _entry = _l.sourceSlots[_i]; var _source = _entry.source; var _sr = _entry.rect;
            JEI_Fill(JEI_Rect(_sr[0], _sr[3] - _z, _sr[2] - _sr[0], max(1, _z)), make_color_rgb(121, 105, 143));
            JEI_SpriteIcon(_source.sprite, _sr[0] + 22 * _z, _sr[1] + 25 * _z, 34 * _z);
            var _sourceScale = 1.7 * _z * _s.settings.font;
            var _sourceWidth = _sr[2] - _sr[0] - 64 * _z;
            var _sourceY = JEI_TextWidth(_source.name, _sourceScale) > _sourceWidth ? 15 : 25;
            JEI_PanelText(_sr[0] + 52 * _z, _sr[1] + _sourceY * _z, _source.name, _sourceScale, _sourceWidth, 2, 4, _ink);
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
    if (_cube && _l.outputAmount > 1) JEI_PanelLabel(_l.outputSlot[2] - 4 * _z, _l.outputSlot[3] - 8 * _z, string(_l.outputAmount), 1.3 * _z, 6, _ink);
    if (_l.detailPages > 1) {
        JEI_Arrow(_l.materialPrevious, -1, _s.detailPage > 0, _s, _z);
        JEI_Arrow(_l.materialNext, 1, _s.detailPage + 1 < _l.detailPages, _s, _z);
        JEI_PanelLabel(_x + 190 * _z, _y + 382 * _z, string(_s.detailPage + 1) + " / " + string(_l.detailPages), 1.4 * _z, 5, _ink);
    }
    if (_l.transfer[2] > 0) { JEI_Box(_s, _l.transfer, false, _z); JEI_PanelLabel((_l.transfer[0] + _l.transfer[2]) / 2, (_l.transfer[1] + _l.transfer[3]) / 2, "+", 1.8 * _z, 5); }
}

function JEI_ConfigRow(_s, _r, _z, _name, _value, _note = "") {
    var _ink = JEI_PanelInk();
    var _mid = (_r[1] + _r[3]) / 2;
    JEI_Fill(JEI_Rect(_r[0], _r[3] - _z, _r[2] - _r[0], max(1, _z)), make_color_rgb(121, 105, 143));
    var _button = JEI_Rect(_r[2] - 77 * _z, _mid - 15 * _z, 75 * _z, 30 * _z);
    JEI_Fill(_button, make_color_rgb(42, 34, 59));
    JEI_PanelLabel(_r[0] + 4 * _z, _mid - (_note == "" ? 0 : 9 * _z), _name, 2 * _z, 4, _ink);
    var _noteScale = min(1.6 * _z, 504 * _z / max(1, JEI_TextWidth(_note, 1)));
    if (_note != "") JEI_PanelLabel(_r[0] + 4 * _z, _mid + 14 * _z, _note, _noteScale, 4, make_color_rgb(211, 199, 226));
    var _scale = min(1.5 * _z, 69 * _z / max(1, JEI_TextWidth(_value, 1)));
    JEI_PanelLabel(_r[2] - 39 * _z, _mid, _value, _scale, 5, c_white);
}

function JEI_DrawConfig(_s, _l, _ink) {
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
    JEI_PanelLabel(_x + 325 * _z, _y + 418 * _z, JEI_Text(_tip), 1.5 * _z, 5, _ink);
}
