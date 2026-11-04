# faf-zeph

Loads the ZEPH wasm in this package and calls `score`, `validate`, `tier`, and `find_section`. `cascade.wasm` is the same bytes as `docs/cascade.wasm` in the repository.

This 0.1.0 package is prepared in [xai-faf-zeph](https://github.com/Wolfe-Jam/xai-faf-zeph). It is not on the npm registry.

```js
import { load } from "faf-zeph";

const zeph = await load();
const value = zeph.score(fafText);
```

`fafText` is the `.faf` document as a string. `findSection` takes FAFb bytes and a section name. A missing section returns `4294967295`.

Contact: team@faf.one
