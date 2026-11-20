// The native player checks container_get_mouse_depth during Step before world interactions.
// A temporary hit container under the captured pointer supplies that check with a depth.
function JEI_NativeInputAdapter() {
    if (!variable_global_exists("__JEI_InputAdapter")) {
        var _adapter = {position: method(undefined, asset_get_index("container_set_pos")),
            border: method(undefined, asset_get_index("container_set_border")),
            scale: method(undefined, asset_get_index("container_set_scale")),
            depth: method(undefined, asset_get_index("container_set_depth")),
            interactable: method(undefined, asset_get_index("container_set_interactable")),
            opened: method(undefined, asset_get_index("container_set_open")),
            destroy: method(undefined, asset_get_index("container_destroy"))};
        variable_global_set("__JEI_InputAdapter", _adapter);
    }
    return variable_global_get("__JEI_InputAdapter");
}

function JEI_GuardExists(_s) {
    var _c = _s.guardContainer;
    return !is_undefined(_c) && ds_exists(_c, ds_type_map) && ds_map_exists(_c, "__jei_input_guard");
}

function JEI_DestroyGuard(_s) {
    if (JEI_GuardExists(_s)) {
        JEI_OpenGuard(_s.guardContainer, false);
        var _adapter = JEI_NativeInputAdapter();
        _adapter.destroy(_s.guardContainer);
    }
    _s.guardContainer = undefined;
}

function JEI_OpenGuard(_container, _open) {
    var _a = JEI_NativeInputAdapter();
    // Native setters take the value first and container last. Register only the
    // hit-test surface; container_open also changes inventory focus and sounds.
    _a.opened(_open, _container);
    var _list = variable_global_get("__CONTAINER__OPEN");
    var _at = ds_list_find_index(_list, _container);
    if (_open && _at < 0) ds_list_add(_list, _container);
    if (!_open && _at >= 0) ds_list_delete(_list, _at);
}

function JEI_SyncGuard(_s, _captured) {
    if (!_captured) {
        if (JEI_GuardExists(_s)) JEI_OpenGuard(_s.guardContainer, false);
        return;
    }
    var _a = JEI_NativeInputAdapter();
    if (!JEI_GuardExists(_s)) {
        _s.guardContainer = Container.Create(1, 1);
        ds_map_add(_s.guardContainer, "__jei_input_guard", true);
        _a.border(0, _s.guardContainer);
        _a.scale(1, _s.guardContainer);
        _a.depth(-1000000, _s.guardContainer);
        _a.interactable(false, _s.guardContainer);
        // container_open_any scans this registry and changes gameplay UI state.
        var _list = variable_global_get("__CONTAINER__LIST");
        var _at = ds_list_find_index(_list, _s.guardContainer);
        if (_at >= 0) ds_list_delete(_list, _at);
    }
    // Center the stock 20px cell under the pointer. The getter subtracts a 12px title offset.
    var _x = variable_global_get("__MOUSE_WINDOW_X__");
    var _y = variable_global_get("__MOUSE_WINDOW_Y__");
    _a.position(_x - 10, _y - 22, _s.guardContainer);
    JEI_OpenGuard(_s.guardContainer, true);
}

function JEI_PointerGameplayKeys() {
    return ["__K_USE_ITEM", "__K_USE_ITEM_PRESSED", "__K_USE_ITEM_RELEASED", "__K_USE_ITEM_ALT", "__K_USE_ITEM_ALT_PRESSED", "__K_USE_ITEM_ALT_RELEASED",
        "__K_INTERACT_PRESSED", "__K_DROP_ITEM_PRESSED", "__K_SELECT_ITEM_LEFT_PRESSED", "__K_SELECT_ITEM_RIGHT_PRESSED",
        "__K_INVENTORY_PICKUP_ITEM_PRESSED", "__K_INVENTORY_PICKUP_ITEM_RELEASED", "__K_INVENTORY_DROP_ITEM_PRESSED"];
}

function JEI_GameplayKeys() {
    return array_concat(JEI_PointerGameplayKeys(), [
        "__K_LEFT", "__K_RIGHT", "__K_UP", "__K_DOWN", "__K_DASH_PRESSED", "__K_HOOK_PRESSED", "__K_MOUNT_PRESSED",
        "__K_QUICK_HEAL_HP_PRESSED", "__K_QUICK_HEAL_MP_PRESSED", "__K_QUICK_BUFF", "__K_QUICK_TORCH_PRESSED"]);
}

function JEI_ResetCapture(_s) {
    _s.dragTarget = "";
    _s.captureLeft = false;
    _s.captureRight = false;
    _s.frameCapture = false;
}

function JEI_CaptureGameplay(_s, _input, _l) {
    if (!_input.focused) { JEI_ResetCapture(_s); return false; }
    var _inside = JEI_UICaptureArea(_s, _l, _input.x, _input.y);
    var _captured = _inside || _s.searchFocused || _s.binding != "" || _s.dragTarget != "" || _s.captureLeft || _s.captureRight;
    if (_inside && _input.leftPressed) _s.captureLeft = true;
    if (_inside && _input.rightPressed) _s.captureRight = true;
    if (!_input.leftDown) _s.captureLeft = false;
    if (!_input.rightDown) _s.captureRight = false;
    if (_captured) {
        var _keys = JEI_PointerGameplayKeys();
        for (var _i = 0; _i < array_length(_keys); _i++) {
            if (variable_global_exists(_keys[_i])) variable_global_set(_keys[_i], false);
        }
    }
    _s.frameCapture = _captured;
    return _captured;
}

function JEI_BlockEditingKeys() {
    var _keys = array_concat(JEI_GameplayKeys(), ["__K_INVENTORY_PRESSED", "__K_PAUSE_PRESSED", "__K_MAP_PRESSED", "__K_CODEX_PRESSED"]);
    for (var _i = 0; _i < array_length(_keys); _i++) if (variable_global_exists(_keys[_i])) variable_global_set(_keys[_i], false);
}

function JEI_ConsumeKey(_key) { keyboard_clear(_key); JEI_BlockEditingKeys(); }

function JEI_SearchCursorInput(_s, _input) {
    var _keys = [vk_left, vk_right, vk_home, vk_end, vk_delete];
    var _key = -1; var _now = get_timer();
    for (var _i = 0; _i < array_length(_keys); _i++) if (JEI_KeyPressed(_input, _keys[_i])) { _key = _keys[_i]; break; }
    if (_key >= 0) { _s.searchRepeatKey = _key; _s.searchRepeatAt = _now + 350000; }
    else if (_s.searchRepeatKey >= 0 && keyboard_check(_s.searchRepeatKey)) {
        if (_now < _s.searchRepeatAt) return;
        _key = _s.searchRepeatKey; _s.searchRepeatAt = _now + 50000;
    } else { _s.searchRepeatKey = -1; return; }
    var _cursor = _s.searchCursor; var _length = string_length(_s.search);
    if (_key == vk_left) _cursor = max(0, _cursor - 1);
    if (_key == vk_right) _cursor = min(_length, _cursor + 1);
    if (_key == vk_home) _cursor = 0;
    if (_key == vk_end) _cursor = _length;
    if (_key == vk_delete && _cursor < _length) {
        _s.search = string_delete(_s.search, _cursor + 1, 1);
        JEI_RequestSearch(_s); JEI_SetSearchCaret(_s, _cursor);
    } else if (_cursor != _s.searchCursor) JEI_SetSearchCaret(_s, _cursor);
    JEI_BlockEditingKeys();
}

function JEI_Keyboard(_s, _input, _l) {
    if (!_input.focused) { if (_s.searchFocused) JEI_StopSearch(_s); _s.binding = ""; return; }
    if (_s.binding != "") {
        JEI_BlockEditingKeys();
        if (JEI_KeyPressed(_input, vk_escape)) { _s.binding = ""; _s.bindingNotice = ""; JEI_ConsumeKey(vk_escape); return; }
        for (var _key = 8; _key <= 222; _key++) {
            if (_key == 16 || _key == 17 || _key == 18 || _key >= 160 && _key <= 165) continue;
            if (!JEI_KeyPressed(_input, _key)) continue;
            var _b = {key: _key, ctrl: _input.ctrl, shift: _input.shift, alt: _input.alt};
            if (JEI_AssignBinding(_s, _s.binding, _b)) JEI_SaveSettings(_s);
            JEI_ConsumeKey(_key); break;
        }
        return;
    }
    if (_s.searchFocused) {
        JEI_BlockEditingKeys();
        if (JEI_SearchInputExists(_s)) {
            JEI_SyncSearch(_s);
        } else { _s.searchFocused = false; _s.textInput = undefined; }
        // Candidate selection and cancellation belong to the IME while composing.
        if (JEI_IMEComposing()) { _s.searchRepeatKey = -1; return; }
        if (JEI_KeyPressed(_input, vk_escape)) { JEI_StopSearch(_s); _s.detailOpen = false; JEI_ConsumeKey(vk_escape); return; }
        if (JEI_KeyPressed(_input, vk_up) || JEI_KeyPressed(_input, vk_down)) {
            var _delta = JEI_KeyPressed(_input, vk_up) ? -1 : 1;
            var _count = array_length(_s.searchHistory);
            if (_count > 0) {
                _s.searchHistoryAt = clamp(_s.searchHistoryAt + _delta, 0, _count);
                JEI_SearchEdit(_s, _s.searchHistoryAt < _count ? _s.searchHistory[_s.searchHistoryAt] : "");
            }
            JEI_ConsumeKey(_delta < 0 ? vk_up : vk_down);
        }
        JEI_SearchCursorInput(_s, _input);
        return;
    }
    if (_s.configOpen) {
        JEI_BlockEditingKeys();
        if (JEI_KeyPressed(_input, vk_escape)) { _s.configOpen = false; JEI_ConsumeKey(vk_escape); }
        return;
    }
    if (JEI_KeyAction(_s, "overlay", _input)) {
        _s.settings.overlayEnabled = !_s.settings.overlayEnabled;
        _s.open = _s.settings.overlayEnabled;
        if (!_s.open) JEI_ClosePanel(_s);
        JEI_SaveSettings(_s);
        JEI_ConsumeKey(_s.settings.bindings.overlay.key); return;
    }
    if (_s.open && JEI_KeyPressed(_input, vk_escape) && _s.detailOpen) { _s.detailOpen = false; JEI_ConsumeKey(vk_escape); return; }
    if (_s.pauseOwned && (JEI_KeyPressed(_input, vk_escape) || variable_global_exists("__K_INVENTORY_PRESSED") && variable_global_get("__K_INVENTORY_PRESSED"))) {
        var _close = JEI_Runtime().closeInventory; _close();
        JEI_SyncInventory(_s, false); JEI_UpdatePause(_s, false, true, false);
        if (JEI_KeyPressed(_input, vk_escape)) keyboard_clear(vk_escape);
        JEI_BlockEditingKeys(); return;
    }
    if (!_s.open) return;
    if (JEI_KeyAction(_s, "search", _input)) {
        JEI_ConsumeKey(_s.settings.bindings.search.key); JEI_StartSearch(_s); return;
    }
    var _hover = JEI_GridItem(_s, _l, _input.x, _input.y);
    if (_s.detailOpen && JEI_Hit(_l.popup, _input.x, _input.y)) _hover = JEI_MaterialItem(_s, _l, _input.x, _input.y);
    if (_hover < 0 && !JEI_UICaptureArea(_s, _l, _input.x, _input.y)) {
        var _fn = JEI_Runtime().hoveredItem; _hover = _fn();
    }
    if (_hover >= 0 && (JEI_KeyAction(_s, "recipes", _input) || JEI_KeyAction(_s, "uses", _input))) {
        var _uses = JEI_KeyAction(_s, "uses", _input);
        JEI_Select(_s, _hover, _uses ? "uses" : "recipes");
        JEI_ConsumeKey(_uses ? _s.settings.bindings.uses.key : _s.settings.bindings.recipes.key);
    } else if (JEI_KeyAction(_s, "previous", _input) || JEI_KeyAction(_s, "next", _input)) {
        var _prev = JEI_KeyAction(_s, "previous", _input); var _delta = _prev ? -1 : 1;
        if (_s.detailOpen && JEI_Hit(_l.popup, _input.x, _input.y)) JEI_ChangeDetailPage(_s, _l, _delta);
        else _s.page = clamp(_s.page + _delta, 0, _l.pages - 1);
        JEI_ConsumeKey(_prev ? _s.settings.bindings.previous.key : _s.settings.bindings.next.key);
    }
}
