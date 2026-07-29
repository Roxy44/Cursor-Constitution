# Baseline ESLint config

**Not the default linter.** Open only when the user chose ESLint in onboarding (or
explicitly asked to bootstrap it). For Biome, oxlint, Ruff, or another tool, ignore this
file and use that tool's docs instead.

On a live project that already has a linter, treat this as an intent checklist — not a
file to overwrite on top.

Intent → rule mapping lives in `code-style.mdc` ("Linter intents"). Values below match
that file's formatting (4 spaces, single quotes, semicolons, ~130 chars).

## Classic config (`.eslintrc.json`)

```json
{
    "extends": ["react-app", "react-app/jest"],
    "rules": {
        "eqeqeq": "error",
        "no-unused-vars": "warn",
        "no-console": "warn",
        "no-duplicate-imports": "error",
        "quotes": ["warn", "single"],
        "jsx-quotes": ["error", "prefer-single"],
        "prefer-const": "error",
        "indent": ["error", 4],
        "semi": ["warn", "always"],
        "no-magic-numbers": [
            "warn",
            {
                "ignore": [-1, 0, 1, 2],
                "ignoreArrayIndexes": true,
                "ignoreDefaultValues": true
            }
        ],
        "no-empty": ["error", { "allowEmptyCatch": false }],
        "import/no-duplicates": "error",
        "import/newline-after-import": "warn",
        "import/no-cycle": "error",
        "react-hooks/exhaustive-deps": "warn",
        "react/jsx-key": "error",
        "react/self-closing-comp": "warn"
    }
}
```

## Notes

- Formatting rules (`indent`, `quotes`, `semi`) in ESLint conflict with Prettier. If
  Prettier is present, leave formatting to it and drop those ESLint rules — two sources of
  truth fight forever.
- Rules with the `import/` prefix need `eslint-plugin-import`; `react-hooks/` needs
  `eslint-plugin-react-hooks`. Install only with approval (**W-6**).
- A TypeScript project also adds `@typescript-eslint` and replaces `no-unused-vars` with
  `@typescript-eslint/no-unused-vars`.
- Modern ESLint prefers flat config (`eslint.config.js`). The rule set is the same; only
  the file shape changes.
