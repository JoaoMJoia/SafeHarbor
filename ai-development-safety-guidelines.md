# AI Development Safety Guidelines

- Keep `if` statements to 1 level of nesting (avoid deep conditionals)
- Use consistent naming:
  - `camelCase` for variables, functions, and hooks
  - `PascalCase` for React components
  - `UPPER_SNAKE_CASE` for constants and configuration objects
- Prefer **arrow functions** over `function` declarations
- Check for `any` types (avoid them unless strictly necessary)
- Remove `//` and `{* *}` comments before finalizing code
- Use **named exports** (avoid `default export`)
- Avoid single-letter constants (use meaningful names)
- Add a blank line before every `return`
- Replace `React.*` patterns with direct imports (e.g. `useState` instead of `React.useState`)
- Remove unused code (imports, variables, dead logic)
- In unit tests, prefer `data-testid` over CSS selectors or container-based queries
- Make tests resilient to refactors by avoiding implementation-coupled mocks
- Prefer return empty fragment (`<></>`) over an `null`
- Deduplicate constants (avoid repeated literal values)
- Replace template literal className merging with the `cn()` utility
