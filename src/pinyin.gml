// Transliteration is based on the currently displayed name, including mod edits.
function JEI_Pinyin(_text) {
    if (_text == "") return "";
    if (!variable_global_exists("__JEI_PinyinCache")) variable_global_set("__JEI_PinyinCache", {});
    var _cache = variable_global_get("__JEI_PinyinCache");
    if (variable_struct_exists(_cache, _text)) return variable_struct_get(_cache, _text);
    var _data = JEI_PinyinData();
    if (variable_struct_exists(_data.words, _text)) return variable_struct_get(_data.words, _text);
    var _full = ""; var _initials = ""; var _chinese = false;
    for (var _i = 1; _i <= string_length(_text); _i++) {
        var _c = string_char_at(_text, _i);
        var _p = JEI_PinyinCharacter(_c);
        if (_p != "") {
            _full += _p; _initials += string_char_at(_p, 1); _chinese = true;
        } else if (_c != " " && _c != "-" && _c != "'" && _c != "’") {
            _full += string_lower(_c);
        }
    }
    var _result = _chinese ? _full + " " + _initials : "";
    variable_struct_set(_cache, _text, _result);
    return _result;
}
