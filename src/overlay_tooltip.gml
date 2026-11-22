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
    var _ink = JEI_PanelInk();
    var _secondary = make_color_rgb(211, 199, 226);
    if (_s.configOpen) JEI_DrawConfig(_s, _l, _ink);
    else if (_s.detailOpen) JEI_DrawRecipe(_s, _l, _ink, _secondary);
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
