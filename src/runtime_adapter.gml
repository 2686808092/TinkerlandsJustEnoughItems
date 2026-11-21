// All native UI/lifecycle dependencies live here; adapters may be replaced by other mods.
function JEI_NativeFunction(_name) {
    var _id = asset_get_index(_name);
    return _id < 0 ? undefined : method(undefined, _id);
}

function JEI_Runtime() {
    if (!variable_global_exists("__JEI_Runtime")) {
        variable_global_set("__JEI_Runtime", {
            inventoryOpen: JEI_DefaultInventoryOpen, closeInventory: JEI_DefaultCloseInventory, multiplayer: JEI_DefaultMultiplayer,
            setPaused: JEI_DefaultSetPaused, hoveredItem: JEI_DefaultHoveredItem,
            containerOpen: JEI_NativeFunction("container_get_open"),
            connected: JEI_NativeFunction("net_is_connected"),
            pause: JEI_NativeFunction("instance_pause_all"),
            hover: JEI_NativeFunction("container_get_global_hover_item"),
            language: JEI_NativeFunction("lang"), textWidth: JEI_NativeFunction("string_width_scribble"),
            textScale: JEI_NativeFunction("draw_get_text_scale"),
            panelText: JEI_NativeFunction("draw_text_gui_n"), textAlign: JEI_NativeFunction("draw_set_align")});
    }
    return variable_global_get("__JEI_Runtime");
}

function JEI_DefaultInventoryOpen() {
    if (!variable_global_exists("__INVENTORY")) return false;
    var _c = variable_global_get("__INVENTORY");
    if (is_undefined(_c) || !ds_exists(_c, ds_type_map)) return false;
    var _a = JEI_Runtime();
    var _fn = _a.containerOpen;
    return !is_undefined(_fn) && _fn(_c);
}

function JEI_DefaultMultiplayer() {
    var _fn = JEI_Runtime().connected;
    // Unknown networking interfaces leave the world running.
    return is_undefined(_fn) || _fn();
}

function JEI_DefaultCloseInventory() {
    var _fn = JEI_NativeFunction("container_close_all");
    if (!is_undefined(_fn)) _fn();
}

function JEI_DefaultSetPaused(_pause) {
    var _fn = JEI_Runtime().pause;
    if (is_undefined(_fn)) return false;
    _fn(_pause);
    return true;
}

function JEI_DefaultHoveredItem() {
    var _fn = JEI_Runtime().hover;
    if (is_undefined(_fn)) return -1;
    var _item = _fn();
    if (is_undefined(_item) || !ds_exists(_item, ds_type_map)) return -1;
    var _id = Item.GetProperty(_item, E_ITEM_DATA.id);
    var _base = JEI_BlueprintTemplate();
    if (is_array(_base) && _id == _base[0]) {
        var _data = Item.GetProperty(_item, E_ITEM_DATA.data);
        if (!is_struct(_data) || !variable_struct_exists(_data, "recipeID")) return -1;
        var _blueprint = JEI_BlueprintIndex(_data.recipeID);
        return _blueprint >= 0 && is_array(JEI_BlueprintRow(_blueprint)) ? _blueprint : -1;
    }
    return JEI_NativeItemIndex(_id);
}

function JEI_UpdatePause(_s, _inventory, _world, _otherModal, _codex = false) {
    var _a = JEI_Runtime();
    var _online = _a.multiplayer;
    var _set = _a.setPaused;
    var _want = _world && _inventory && !_otherModal && !_codex && _s.settings.autoPause && !_online();
    var _paused = variable_global_exists("__PAUSE_ENTITIES") && variable_global_get("__PAUSE_ENTITIES");
    if (_want && (!_paused || _s.pauseOwned)) {
        if (!_paused && _set(true)) _s.pauseOwned = true;
    } else if (!_want && _s.pauseOwned) {
        // The codex neither acquires nor releases a native pause.
        // Keep the existing handoff for other native modals.
        if (!_otherModal || !_world || _online()) _set(false);
        _s.pauseOwned = false;
    }
}

function JEI_SyncInventory(_s, _inventory) {
    if (!_inventory) {
        JEI_ClosePanel(_s);
        _s.inventoryWasOpen = false;
        return;
    }
    if (!_s.inventoryWasOpen) {
        _s.detailOpen = false;
        _s.configOpen = false;
    }
    _s.inventoryWasOpen = true;
    _s.open = _s.settings.overlayEnabled;
}

function JEI_SearchInputExists(_s) {
    return !is_undefined(_s.textInput) && instance_exists(_s.textInput);
}

function JEI_IMEComposing() {
    return variable_global_exists("__IME_TYPING") && variable_global_get("__IME_TYPING");
}

function JEI_SyncSearch(_s) {
    if (JEI_SearchInputExists(_s)) {
        var _editor = _s.textInput;
        var _prefix = string_copy(string(_editor.text), 1, max(0, 256 - string_length(_s.searchTail)));
        var _text = _prefix + _s.searchTail;
        if (_text != _s.search) _s.searchCaretAt = get_timer();
        _s.search = _text;
        _s.searchCursor = string_length(_prefix);
        JEI_RequestSearch(_s);
    }
}

function JEI_StopSearch(_s) {
    JEI_SyncSearch(_s);
    if (JEI_SearchInputExists(_s)) instance_destroy(_s.textInput);
    _s.textInput = undefined;
    _s.searchFocused = false;
    _s.searchTail = "";
    _s.searchRepeatKey = -1;
    JEI_RememberSearch(_s);
}

function JEI_SetSearchCaret(_s, _position) {
    if (instance_exists(objGUITextInput) && !JEI_SearchInputExists(_s)) return;
    if (JEI_SearchInputExists(_s)) instance_destroy(_s.textInput);
    _s.searchCursor = clamp(_position, 0, string_length(_s.search));
    _s.searchTail = string_delete(_s.search, 1, _s.searchCursor);
    _s.searchCaretAt = get_timer();
    // The native editor appends Unicode/IME input and handles Backspace/paste.
    // Give it the prefix before the caret, retaining the untouched suffix in JEI.
    // Recreating only our hidden editor seeds the native keyboard buffer safely.
    var _prefix = string_copy(_s.search, 1, _s.searchCursor);
    create_text_input(_prefix, function(_data) {
        var _s = JEI_State();
        var _prefix = string_copy(string(_data.text), 1, max(0, 256 - string_length(_s.searchTail)));
        _s.search = _prefix + _s.searchTail;
        _s.searchCursor = string_length(_prefix);
        _s.searchTail = "";
        _s.searchFocused = false;
        _s.textInput = undefined;
        JEI_RequestSearch(_s);
        JEI_RememberSearch(_s);
    });
    var _editor = instance_find(objGUITextInput, 0);
    if (instance_exists(_editor)) {
        _editor.visible = false;
        _editor.maxLength = max(0, 256 - string_length(_s.searchTail));
        _s.textInput = _editor;
        _s.searchFocused = true;
    }
}

function JEI_StartSearch(_s) {
    if (instance_exists(objGUITextInput) && !JEI_SearchInputExists(_s)) return;
    JEI_IMEWindow(_s);
    _s.nextNameScan = 0;
    JEI_RequestSearch(_s);
    _s.searchViewStart = 0;
    _s.searchRepeatKey = -1;
    JEI_SetSearchCaret(_s, string_length(_s.search));
}

function JEI_SearchEdit(_s, _text) {
    _s.search = string_copy(_text, 1, 256);
    JEI_RequestSearch(_s);
    if (_s.searchFocused) JEI_StartSearch(_s);
}

function JEI_EnsureBackdrop() {
    var _background = ModInstance.Find("jei_backdrop");
    if (!ModInstance.Exists(_background)) {
        _background = ModInstance.Create("jei_backdrop", undefined, undefined, undefined, "JEI_BackdropDraw", "");
    }
    // GUI draw uses depth ordering too. Native HP/mana is painted after this layer.
    _background.depth = 100000;
}

function JEI_BackdropDraw() {
    var _s = JEI_State();
    if (_s.open && JEI_WorldReady()) {
        var _l = JEI_Layout(_s, display_get_gui_width(), display_get_gui_height());
        JEI_DrawBackdrop(_s, _l);
    }
}

// The runner drops fullscreen on WM_IME_STARTCOMPOSITION. A screen-sized,
// undecorated ordinary window avoids that path and keeps IME candidate windows.
// The player's native display preference is read only, never saved by this mod.
function JEI_ApplyIMEWindow(_state) {
    _state.x = window_get_x(); _state.y = window_get_y();
    _state.w = window_get_width(); _state.h = window_get_height();
    window_set_fullscreen(false);
    window_set_showborder(false);
    window_set_rectangle(_state.x, _state.y, _state.w, _state.h);
}

function JEI_IMEWindow(_s) {
    if (!variable_global_exists("__JEI_WindowMode")) variable_global_set("__JEI_WindowMode", {active: false});
    var _state = variable_global_get("__JEI_WindowMode");
    var _options = variable_global_exists("__USER_OPTIONS") ? variable_global_get("__USER_OPTIONS") : undefined;
    if (!is_struct(_options) || !variable_struct_exists(_options, "fullscreen")) return;
    if (_state.active) {
        if (!_s.settings.imeFix || _options.fullscreen != _state.mode) {
            _state.active = false;
            window_set_showborder(_state.border);
            var _restore = JEI_NativeFunction("window_set_fullscreen_ext");
            if (!is_undefined(_restore)) _restore();
            return;
        }
        // Applying native resolution settings may enable runner fullscreen again.
        if (window_get_fullscreen() && window_get_borderless_fullscreen()) JEI_ApplyIMEWindow(_state);
        // Consume only the native IME restore request for our managed window.
        var _controller = instance_find(objInputController, 0);
        if (instance_exists(_controller) && variable_instance_exists(_controller, "imeRestoreFullscreen")) {
            _controller.imeRestoreFullscreen = false;
            _controller.imeWindowWidth = window_get_width();
            _controller.imeWindowHeight = window_get_height();
        }
        return;
    }
    if (!_s.settings.imeFix || !window_get_fullscreen() || !window_get_borderless_fullscreen()) return;
    _state.mode = _options.fullscreen;
    _state.border = window_get_showborder();
    JEI_ApplyIMEWindow(_state);
    _state.active = true;
}
