# AGENTS.md

## Documentation References

**IMPORTANT**: When working with code in this repository, always refer to these official documentation sources:

### ReScript Language Reference
- **URL**: https://rescript-lang.org/llms/manual/llm-full.txt
- **Use for**:
  - ReScript syntax and language features
  - Standard library APIs
  - Type system details
  - External bindings and interop patterns
  - Best practices and idioms

## Build & Test Commands
- Build: `yarn build` (or `yarn watch` for dev)
- Test all: `yarn test`
- Single test: `yarn mocha __tests__/Test_JsOption.res.mjs`
- Clean: `yarn clean`

## Code Style Guidelines
- **Language**: ReScript v12 with ES modules (`.res.mjs` output)
- **Imports**: Use `open` for commonly used modules (e.g., `open Bastet_Interface`)
- **Naming**: snake_case for functions (`fold_left`, `flat_map`), PascalCase for modules/functors
- **Types**: Parametric types use `t<'a>` syntax; module types are SCREAMING_SNAKE_CASE
- **Infix operators**: Define as escaped strings (e.g., `let \"<." = ...`, `let \"|?" = ...`)
- **Pattern matching**: Prefer exhaustive `switch` over if/else
- **Module structure**: Use module types from `Bastet_Interface`, implement as functors when parameterized
- **Error handling**: Use `option` and `Result` types; avoid exceptions
- **Tests**: Use rescript-mocha with bs-jsverify for property-based testing
- **Formatting**: 2-space indentation, modules include type annotations with `with type`
