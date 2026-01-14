# AGENTS.md

## Documentation References

**IMPORTANT**: When working with code in this repository, always refer to these official documentation sources:

### ReScript Language Reference
- **ALWAYS USE THIS FOR RESCRIPT CODE**: https://rescript-lang.org/llms/manual/llms.txt
- **LLM Full Documentation**: https://rescript-lang.org/llms/manual/llm-full.txt
- **Language Manual**: https://rescript-lang.org/docs/manual/introduction
- **Use for**:
  - ReScript syntax and language features
  - Standard library APIs
  - Type system details
  - External bindings and interop patterns
  - Best practices and idioms
- Ensure suggestions match this version. Refer to the indexed ReScript manual and LLM documentation.
- When dealing with promises, prefer using `async/await` syntax.
- Never ever use the `Belt` or `Js` modules, these are legacy.
- Always use the `JSON.t` type for json.
- Module with React components do require a signature file (`.resi`) for Vite HMR to work. Only the React components can be exposed from the javascript.

## Development Tools

### ReScript LSP Integration
- **IF the rescript-lsp plugin is installed and available in Claude Code**, use it to structurally analyze, search, and navigate ReScript code
- When available, prefer LSP features for:
  - Document symbols and structure analysis (viewing modules, types, functions)
  - Go to definition and find references
  - Type information and hover documentation
  - Structural navigation within functors and modules
- LSP-based code exploration is more accurate than text-based search for understanding ReScript module structure

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

## Notes
- Ensure each test has only a single expect statement, using tuples where multiple results need to be tested
- Remember to use conventional commits spec for commit message
- Remember to run tests and make sure all tests passes before committing any changes
