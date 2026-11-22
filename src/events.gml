// Input capture and drawing callbacks.
function JEI_WorldReady() {
    return instance_exists(objGUIIngameController) && instance_exists(MY_PLAYER);
}

function JEI_OtherModalOpen() {
    var _names = ["objGUIMenuController", "objGUICubeRecipe", "objGUICube", "objGUINPCController",
        "objGUINPCGiftController", "objGUINPCStorageController", "objGUIShopController", "objGUICraftingController",
        "objGUICommunityController", "objGUIGuideController", "objGUIBank", "objGUIEnchant",
        "objGUIReforgeController", "objGUIRecyclerController", "objGUIShipNavigationController",
        "objCookingMinigameController", "objFishingMinigameController", "objReportHelper", "objTicketReportTool", "objGUIMapChartController"];
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _obj = asset_get_index(_names[_i]);
        if (_obj != -1 && instance_exists(_obj)) return true;
    }
    return false;
}

OnModUpdate(function() {
    var _s = JEI_State();
    JEI_ReleaseFrame(_s);
    JEI_IMEWindow(_s);
    var _world = JEI_WorldReady();
    var _inventoryFn = JEI_Runtime().inventoryOpen;
    var _inventory = _world && _inventoryFn();
    var _modal = _world && JEI_OtherModalOpen();
    var _codex = _world && instance_exists(objGUICodexController);
    JEI_UpdatePause(_s, _inventory, _world, _modal, _codex);
    if (!_world) {
        JEI_SyncInventory(_s, false);
        if (_s.developer) JEI_ToggleDeveloper(_s);
        _s.cheat = false;
        JEI_ResetCapture(_s); JEI_SyncGuard(_s, false);
        if (JEI_CubeFingerprint() > 0) JEI_BackgroundCatalog(_s, 8000);
        if (_s.catalogReady) JEI_SearchNamesTick(_s, 1200, false);
        return;
    }
    JEI_BackgroundCatalog(_s, _s.pauseOwned ? 8000 : 2500);
    if (_inventory) JEI_SearchWork(_s);
    JEI_SyncInventory(_s, _inventory);
    if (_modal || _codex || instance_exists(objGUITextInput) && !JEI_SearchInputExists(_s)) {
        JEI_ClosePanel(_s); JEI_ResetCapture(_s); JEI_SyncGuard(_s, false); return;
    }
    if (_s.open && !instance_exists(_s.backdrop)) _s.backdrop = JEI_EnsureBackdrop();
    if (!_inventory && !_s.captureLeft && !_s.captureRight) { _s.frameCapture = false; JEI_SyncGuard(_s, false); return; }
    var _input = JEI_ReadInput(_s);
    var _gw = display_get_gui_width(); var _gh = display_get_gui_height();
    var _l = JEI_Layout(_s, _gw, _gh);
    if (_inventory) JEI_Keyboard(_s, _input, _l);
    if (!_s.open && !_s.captureLeft && !_s.captureRight) { _s.frameCapture = false; JEI_SyncGuard(_s, false); return; }
    _l = JEI_Layout(_s, _gw, _gh);
    JEI_CaptureGameplay(_s, _input, _l);
    var _action = JEI_Frame(_s, _input, _gw, _gh, _l);
    _s.frameCapture = _input.focused && (_s.frameCapture || _action.capture);
    JEI_SyncGuard(_s, _s.frameCapture);
    if (_action.search) JEI_StartSearch(_s);
    if (_s.searchFocused || _s.configOpen) JEI_BlockEditingKeys();
    if (_action.give >= 0 && JEI_CanGive(_s, _action.give)) {
        if (JEI_IsBlueprint(_action.give)) {
            var _recipe = JEI_BlueprintRecipe(_action.give);
            Item.CreateRecipe(MY_PLAYER.x, MY_PLAYER.y, _recipe[0], _action.amount);
        } else {
            var _row = JEI_ItemRow(_action.give);
            Item.Create(MY_PLAYER.x, MY_PLAYER.y, _row[0], _action.amount);
        }
    }
    if (_action.transfer) {
        var _transfer = JEI_API().transferRecipe;
        var _recipes = JEI_ViewRecipes(_s);
        if (!is_undefined(_transfer) && array_length(_recipes) > 0) _transfer(_s, _recipes[_s.variant], _input.shift);
    }
});

OnModDrawEnd(function() {
    var _s = JEI_State();
    JEI_SyncGuard(_s, false);
    if (_s.frameCapture) JEI_BlockNative(_s);
});

OnModDrawGUIEnd(function() {
    var _s = JEI_State();
    if (_s.open && JEI_WorldReady()) {
        var _fn = JEI_Runtime().inventoryOpen;
        if (!_fn()) {
            JEI_SyncInventory(_s, false);
            JEI_UpdatePause(_s, false, true, JEI_OtherModalOpen(), instance_exists(objGUICodexController));
        }
    }
    JEI_Draw(_s);
    JEI_DrawPause(_s);
});
