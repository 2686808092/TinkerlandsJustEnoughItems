function JEI_SettingsText(_key, _mode) {
    var _t = {
        paused: ["Auto-paused", "自动暂停中", "自動暫停中"],
        uses: ["Uses", "用途", "用途"],
        no_uses: ["No recorded uses", "暂无已记录用途", "暫無已記錄用途"],
        general: ["General", "常规", "一般"],
        shortcuts: ["Key bindings", "快捷键", "快捷鍵"],
        auto_pause_short: ["Auto-pause", "自动暂停"],
        singleplayer_only: ["Single-player only", "仅单人模式"],
        developer_short: ["Developer mode", "开发者模式"],
        developer_note: ["Leave this off if you are unsure what it does.", "如果你不知道这个开关是干什么的，请不要打开它"],
        expand: ["Show", "展开"],
        collapse: ["Hide", "收起"],
        search_help: ["Search", "搜索", "搜尋"],
        auto_pause: ["Pause with inventory (singleplayer)", "人物栏自动暂停（单人）", "人物欄自動暫停（單人）"],
        backdrop: ["Background opacity", "底衬深度", "底襯深度"],
        font_size: ["Text size", "字体大小", "字體大小"],
        ime_fix: ["Keep borderless display while typing", "中文输入保持无边框全屏", "中文輸入保持無邊框全螢幕"],
        reset: ["Restore defaults", "恢复默认设置", "恢復預設設定"],
        bind_recipes: ["Show recipes", "查看配方", "查看配方"],
        bind_uses: ["Show uses", "查看用途", "查看用途"],
        bind_overlay: ["Toggle list (inventory open)", "显示 / 隐藏列表（人物栏内）", "顯示 / 隱藏清單（人物欄內）"],
        bind_search: ["Focus search", "选中搜索框", "選取搜尋框"],
        bind_previous: ["Previous page", "上一页", "上一頁"],
        bind_next: ["Next page", "下一页", "下一頁"],
        press_key: ["Press a key... Esc cancels", "请按快捷键… Esc 取消", "請按快捷鍵… Esc 取消"],
        binding_conflict: ["Already assigned; choose another key", "此快捷键已使用，请换一个", "此快捷鍵已使用，請換一個"],
        binding_reserved: ["Reserved key; choose another", "此按键为保留键，请换一个", "此按鍵為保留鍵，請換一個"],
        bind_tip: ["Click to rebind. Ctrl / Shift / Alt supported.", "点击修改，支持 Ctrl / Shift / Alt 组合", "點擊修改，支援 Ctrl / Shift / Alt 組合"],
        search_tip: ["Right click: clear   Up / Down: history", "右键清空；上 / 下方向键浏览搜索历史", "右鍵清空；上 / 下方向鍵瀏覽搜尋歷史"],
        search_names: ["Words: name or internal key; spaces mean AND", "关键词匹配名称；空格连接多个条件", "關鍵詞比對名稱；空格連接多個條件"],
        search_pinyin: ["Chinese names: full pinyin or initials (fengmi / fm)", "中文名称：fengmi / fm", "中文名稱：fengmi / fm"],
        search_caret: ["Left / Right: caret; Home / End: start / end", "左 / 右移动光标；Home / End 跳到首尾", "左 / 右移動游標；Home / End 跳到首尾"],
        search_or: ["iron|gold   either term", "铁|金   匹配任意一项", "鐵|金   比對任意一項"],
        search_not: ["iron -sword   exclude sword", "铁 -剑   排除包含“剑”的物品", "鐵 -劍   排除包含「劍」的物品"],
        search_quote: ["\"iron sword\"   match a phrase", "\"iron sword\"   匹配完整词组", "\"iron sword\"   比對完整詞組"],
        search_mod: ["@mod   mod name / namespace; @vanilla for base game", "@模组名   按模组筛选；@原版 筛选原版", "@模組名   按模組篩選；@原版 篩選原版"],
        search_tags: ["#Accessories   item tags", "#饰品 / #Accessories   按物品标签搜索"],
        search_tooltip: ["$text   description text", "$文字   匹配物品描述", "$文字   比對物品描述"],
        search_category: ["%category   item category", "%类别   按物品类别筛选", "%類別   按物品類別篩選"],
        search_id: ["id:32 or 32   exact item ID", "id:32 或 32   精确搜索物品 ID"],
        transfer: ["Transfer ingredients", "填入材料", "填入材料"],
        material_page: ["Ingredients", "材料", "材料"]
    };
    return variable_struct_exists(_t, _key) ? variable_struct_get(_t, _key)[_mode] : _key;
}

function JEI_DefaultSettings() {
    return {autoPause: true, overlayEnabled: true, imeFix: true, opacity: 0.79, font: 1, bindings: {
        recipes: {key: 82, ctrl: false, shift: false, alt: false},
        uses: {key: 85, ctrl: false, shift: false, alt: false},
        overlay: {key: 79, ctrl: true, shift: false, alt: false},
        search: {key: 70, ctrl: true, shift: false, alt: false},
        previous: {key: 33, ctrl: false, shift: false, alt: false},
        next: {key: 34, ctrl: false, shift: false, alt: false}}};
}

function JEI_BindingNames() { return ["recipes", "uses", "overlay", "search", "previous", "next"]; }

function JEI_Settings() {
    if (variable_global_exists("__JEI_Settings")) return variable_global_get("__JEI_Settings");
    var _c = JEI_DefaultSettings();
    ini_open("jei.ini");
    _c.autoPause = ini_read_real("ui", "autoPause", 1) != 0;
    _c.overlayEnabled = ini_read_real("ui", "overlayEnabled", 1) != 0;
    _c.imeFix = ini_read_real("ui", "imeFix", 1) != 0;
    _c.opacity = clamp(ini_read_real("ui", "opacity", 0.79), 0.6, 0.97);
    if (ini_read_real("ui", "styleRevision", 0) < 2 && (abs(_c.opacity - 0.90) < 0.001 || abs(_c.opacity - 0.82) < 0.001)) _c.opacity = 0.79;
    _c.font = clamp(ini_read_real("ui", "font", 1), 0.9, 1.2);
    var _names = JEI_BindingNames();
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _n = _names[_i];
        var _b = variable_struct_get(_c.bindings, _n);
        var _key = ini_read_real(_n, "key", _b.key);
        if (_key >= 8 && _key <= 222 && _key != 27 && _key != 16 && _key != 17 && _key != 18) _b.key = floor(_key);
        _b.ctrl = ini_read_real(_n, "ctrl", _b.ctrl) != 0;
        _b.shift = ini_read_real(_n, "shift", _b.shift) != 0;
        _b.alt = ini_read_real(_n, "alt", _b.alt) != 0;
        variable_struct_set(_c.bindings, _n, _b);
    }
    ini_close();
    variable_global_set("__JEI_Settings", _c);
    return _c;
}

function JEI_SaveSettings(_s) {
    var _c = _s.settings;
    variable_global_set("__JEI_Settings", _c);
    ini_open("jei.ini");
    ini_write_real("ui", "autoPause", _c.autoPause);
    ini_write_real("ui", "overlayEnabled", _c.overlayEnabled);
    ini_write_real("ui", "imeFix", _c.imeFix);
    ini_write_real("ui", "opacity", _c.opacity);
    ini_write_real("ui", "styleRevision", 2);
    ini_write_real("ui", "font", _c.font);
    var _names = JEI_BindingNames();
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _n = _names[_i];
        var _b = variable_struct_get(_c.bindings, _n);
        ini_write_real(_n, "key", _b.key);
        ini_write_real(_n, "ctrl", _b.ctrl);
        ini_write_real(_n, "shift", _b.shift);
        ini_write_real(_n, "alt", _b.alt);
    }
    ini_close();
}

function JEI_KeyName(_key) {
    if (_key == 8) return "Backspace";
    if (_key == 13) return "Enter";
    if (_key == 32) return "Space";
    if (_key == 33) return "Page Up";
    if (_key == 34) return "Page Down";
    if (_key == 37) return "Left";
    if (_key == 38) return "Up";
    if (_key == 39) return "Right";
    if (_key == 40) return "Down";
    if (_key >= 112 && _key <= 123) return "F" + string(_key - 111);
    if (_key >= 48 && _key <= 90) return chr(_key);
    return "Key " + string(_key);
}

function JEI_BindingText(_b) {
    return (_b.ctrl ? "Ctrl + " : "") + (_b.shift ? "Shift + " : "") + (_b.alt ? "Alt + " : "") + JEI_KeyName(_b.key);
}

function JEI_KeyAction(_s, _name, _input) {
    var _b = variable_struct_get(_s.settings.bindings, _name);
    return _input.ctrl == _b.ctrl && _input.shift == _b.shift && _input.alt == _b.alt && JEI_KeyPressed(_input, _b.key);
}

function JEI_AssignBinding(_s, _name, _b) {
    if (_b.key == 27 || _b.key == 16 || _b.key == 17 || _b.key == 18 || _b.key < 8) {
        _s.bindingNotice = "binding_reserved"; return false;
    }
    var _names = JEI_BindingNames();
    for (var _i = 0; _i < array_length(_names); _i++) {
        if (_names[_i] == _name) continue;
        var _other = variable_struct_get(_s.settings.bindings, _names[_i]);
        if (_other.key == _b.key && _other.ctrl == _b.ctrl && _other.shift == _b.shift && _other.alt == _b.alt) {
            _s.bindingNotice = "binding_conflict"; return false;
        }
    }
    variable_struct_set(_s.settings.bindings, _name, _b);
    _s.binding = "";
    _s.bindingNotice = "";
    return true;
}

function JEI_ConfigClick(_s, _l, _input) {
    if (!_input.leftPressed) return;
    if (_s.configTab == 0) {
        if (JEI_Hit(_l.tabs[1], _input.x, _input.y)) { _s.configTab = 1; _s.bindingNotice = ""; }
        else if (JEI_Hit(_l.options[0], _input.x, _input.y)) { _s.settings.autoPause = !_s.settings.autoPause; JEI_SaveSettings(_s); }
        else if (JEI_Hit(_l.developer, _input.x, _input.y)) JEI_ToggleDeveloper(_s);
        return;
    }
    if (JEI_Hit(_l.tabs[0], _input.x, _input.y)) { _s.configTab = 0; _s.binding = ""; return; }
    var _names = JEI_BindingNames();
    for (var _i = 0; _i < array_length(_names); _i++) {
        if (JEI_Hit(_l.bindings[_i], _input.x, _input.y)) { _s.binding = _names[_i]; _s.bindingNotice = ""; return; }
    }
}
