# Bastet Missing Feature List

No original public Bastet module family is unintentionally missing from the ReScript port.

Some original JS-specific module names are intentionally mapped into idiomatic ReScript modules instead of being exposed as separate top-level names.

The audit maps the original core and JS-specific modules to the ReScript aggregate as follows:

- Core modules keep their ReScript-prefixed implementation files and are re-exported from `Bastet.res`.
- `bastet_js/src/JsArray.ml` is represented by `Bastet_Array` and `Bastet_ArrayF`.
- `bastet_js/src/JsFloat.ml` is intentionally represented by `Bastet_Float.Show`; the port exposes one ReScript-native `Float` module rather than separate core/JS float modules.
- `bastet_js/src/Date.ml`, `Dict.ml`, and `Promise.ml` are represented by `Bastet_Date`, `Bastet_Dict`, and `Bastet_Promise`.

Intentional public-name mappings:

- `JsArray` has no separate `Bastet.JsArray` export; use `Bastet.Array` / `Bastet.ArrayF`.
- `JsFloat` has no separate `Bastet.JsFloat` export; use `Bastet.Float.Show`, which follows ReScript/JavaScript `Float.toString` formatting.

Intentional non-source exclusions:

- `bastet/src/index.mld.template` is documentation generation input and is not ported as runtime API.
- Generated build output, generated docs, and `node_modules` were excluded from the audit.

Port-only source files:

- `src/Bastet.res` is the ReScript aggregate namespace and re-exports every mapped module family.
- `src/BsBastet.res` is a compatibility namespace alias that includes `Bastet`; it adds no behavior.
- `src/Demo.res` is an example/demo module with no original API equivalent. It is not re-exported by `Bastet.res` and no production module depends on it.
