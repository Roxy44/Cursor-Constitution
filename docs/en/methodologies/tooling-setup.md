# Wiring tooling after approval

Open when the user **already agreed** to add a linter, formatter, or extension
(constitution **W-6**). Before agreement — proposal only.

## Order

1. Check what already covers the need. Prefer configuring the existing tool over replacing
   it.
2. Install packages with the manager from `project/stack.mdc`, pinned versions.
3. Add scripts so agent and human verify the same way: `lint`, `lint:fix`, `format`,
   `format:check`, `typecheck`, `test`.
4. Keep tool config in the repo, not in global user settings.
5. Wire the editor (below) so rules apply without manual developer setup.
6. Update `project/stack.mdc`: what verifies and with which command.

## Editor (VS Code / Cursor)

`.vscode/extensions.json` — recommendations for newcomers:

```json
{
    "recommendations": ["esbenp.prettier-vscode", "dbaeumer.vscode-eslint", "editorconfig.editorconfig"]
}
```

`.vscode/settings.json` — minimum that actually enables the rules:

```json
{
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.rulers": [130],
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "prettier.configPath": ".prettierrc",
    "prettier.ignorePath": ".prettierignore",
    "prettier.requireConfig": true
}
```

The last three keys are mandatory: without them a user-level Prettier path pointed at
another project breaks formatting here.

Confirm the required extension is installed. If not, ask the user to install it — do not
assume it is present.

## `.editorconfig`

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

Values must match the Formatting section in `code-style.mdc` and the Prettier config.
Three disagreeing sources of truth are worse than one missing source.

## Prettier

```json
{
    "printWidth": 130,
    "tabWidth": 4,
    "useTabs": false,
    "singleQuote": true,
    "jsxSingleQuote": true,
    "semi": true,
    "trailingComma": "all",
    "arrowParens": "always",
    "endOfLine": "lf"
}
```

## Pre-commit hooks

Only on an explicit ask: they slow commits and surprise people who did not expect them.
If added, run on changed files (`lint-staged`), not the whole repo, and never run the full
test suite in `pre-commit`.

## After setup

Run `format` and `lint` once and commit the mass reformat **separately** from logic —
mixing them makes review impossible.
