# faf-zeph

Loads the ZEPH wasm in this package and calls `score`, `validate`, `tier`, and `find_section`.

```sh
npm install faf-zeph
```

```js
import { load } from "faf-zeph";

const zeph = await load();
const value = zeph.score(fafText);
```

`fafText` is the `.faf` document as a string. `findSection` takes FAFb bytes and a section name. A missing section returns `4294967295`.

The wasm in this package is the same bytes as `docs/cascade.wasm` in [xai-faf-zeph](https://github.com/Wolfe-Jam/xai-faf-zeph).

Contact: team@faf.one
