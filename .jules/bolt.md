## 2025-05-15 - [Flutter Reader Performance]
**Learning:** Manga applications handle many large images simultaneously. Failing to use `memCacheWidth` in `CachedNetworkImage` leads to high RAM usage because images are decoded at source resolution rather than display resolution. Additionally, $O(n)$ chapter lookups in the `build` method cause unnecessary CPU load during animations and UI toggles.
**Action:** Always use `memCacheWidth` (scaled by `devicePixelRatio`) for full-screen image lists and cache chapter indices in state instead of recalculating them in the render loop.
