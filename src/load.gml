// World lifecycle callbacks.
OnModLoad(function() {
    JEI_RegisterRecipeProvider("native_cube_v1", JEI_LoadCubeRecipes);
    JEI_State();
    show_debug_message("JustEnoughItems: loaded @VERSION@");
});

OnWorldGenerationEnd(function() {
    var _s = JEI_State();
    JEI_UpdatePause(_s, false, false, false);
    if (_s.searchFocused) JEI_StopSearch(_s);
    JEI_ReleaseFrame(_s);
    JEI_DestroyGuard(_s);
    JEI_ResetWorldSession(_s);
});
