// Measure with the same Scribble font and scale conversion as native GUI.DrawText.
function JEI_TextWidth(_text, _scale) {
    var _a = JEI_Runtime(); var _measure = _a.textWidth; var _convert = _a.textScale;
    var _fonts = variable_global_get("__FONTS");
    return _measure("[" + _fonts.normalString + "]" + _text) * _convert(_scale);
}

function JEI_FitWidth(_text, _scale, _width) {
    if (JEI_TextWidth(_text, _scale) <= _width) return _text;
    while (string_length(_text) > 0 && JEI_TextWidth(_text + "..", _scale) > _width) _text = string_delete(_text, string_length(_text), 1);
    return _text + "..";
}

function JEI_WrapText(_text, _scale, _width) {
    var _lines = []; var _line = "";
    for (var _i = 1; _i <= string_length(_text); _i++) {
        var _c = string_char_at(_text, _i);
        if (_c == chr(13)) continue;
        if (_c == chr(10)) { array_push(_lines, string_trim(_line)); _line = ""; continue; }
        if (_line != "" && JEI_TextWidth(_line + _c, _scale) > _width) {
            var _space = 0;
            for (var _j = string_length(_line); _j > 0; _j--) if (string_char_at(_line, _j) == " ") { _space = _j; break; }
            if (_space > 0) {
                array_push(_lines, string_copy(_line, 1, _space - 1));
                _line = string_delete(_line, 1, _space);
            } else { array_push(_lines, _line); _line = ""; }
        }
        _line += _c;
    }
    if (_line != "") array_push(_lines, string_trim(_line));
    return _lines;
}

function JEI_Description(_value) {
    if (is_array(_value)) {
        var _parts = "";
        for (var _i = 0; _i < array_length(_value); _i++) _parts += (_i == 0 ? "" : chr(10)) + JEI_Description(_value[_i]);
        return _parts;
    }
    if (JEI_Number(_value)) {
        if (_value <= 0) return "";
        var _lang = JEI_Runtime().language; _value = _lang(_value);
    }
    if (!is_string(_value)) return "";
    // Expand explicit item references without running reward or gameplay callbacks.
    while (string_pos("||Item:", _value) > 0) {
        var _at = string_pos("||Item:", _value);
        var _tail = string_delete(_value, 1, _at + 6);
        var _end = string_pos("||", _tail);
        if (_end == 0) break;
        var _key = string_copy(_tail, 1, _end - 1);
        var _id = JEI_NativeItemIndex(_key);
        if (_id < 0 && string_digits(_key) == _key && _key != "") _id = JEI_NativeItemIndex(real(_key));
        var _name = _id >= 0 ? JEI_Name(_id) : _key;
        _value = string_copy(_value, 1, _at - 1) + _name + string_delete(_tail, 1, _end + 1);
    }
    // Tooltip colors belong to JEI. Native input prompts are separate from item effects.
    var _out = ""; var _line = ""; var _tag = false;
    for (var _i = 1; _i <= string_length(_value) + 1; _i++) {
        var _c = _i <= string_length(_value) ? string_char_at(_value, _i) : chr(10);
        if (_c == "[") { _tag = true; continue; }
        if (_c == "]" && _tag) { _tag = false; continue; }
        if (_tag || _c == chr(13)) continue;
        if (_c == chr(10)) {
            _line = string_trim(_line);
            if (_line != "" && string_pos("%verb_", _line) == 0) _out += (_out == "" ? "" : chr(10)) + _line;
            _line = "";
        } else if (_c != "<" && _c != ">") _line += _c;
    }
    return _out;
}
