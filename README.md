# Cursor Constitution

Переносимый набор **правил для AI-агента в Cursor**: поведение, workflow, безопасность, git, тестирование и code style.

Цель репозитория — один раз зафиксировать контракт, а потом **копировать в любой проект** с минимальными правками. Агент читает эти файлы через `.cursor/rules/` и следует им в каждой сессии.

---

## Что внутри

| Файл | Роль в проекте | Когда применяется |
| --- | --- | --- |
| [`constitution.mdc`](constitution.mdc) | Конституция: поведение агента, workflow, security, tests, git | **Всегда** (`alwaysApply: true`) |
| [`example-code-style.mdc`](example-code-style.mdc) | Пример `code-style.mdc`: форма кода, lint/format, tooling | При работе с исходниками (`globs`) |

> **Важно:** `example-code-style.mdc` — это обычный наш `code-style.mdc`, переименованный только в этом репозитории, чтобы в README было ясно, что это шаблон. В реальном проекте файл должен называться **`code-style.mdc`**.

Два файла — **одна связка**:

- **Constitution** = *как агент себя ведёт*
- **Code style** = *как должен выглядеть код и чем это enforced*

Конституция прямо ссылается на `code-style.mdc` (§6). Нельзя держать противоречащие правила в двух файлах.

---

## Быстрый старт: подключить к проекту

### 1. Скопировать правила

В корне целевого проекта:

```text
.cursor/
  rules/
    constitution.mdc
    code-style.mdc
```

```bash
# из корня целевого проекта
mkdir -p .cursor/rules
cp /path/to/Cursor-Constitution/constitution.mdc .cursor/rules/
cp /path/to/Cursor-Constitution/example-code-style.mdc .cursor/rules/code-style.mdc
```

На Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force -Path .cursor\rules | Out-Null
Copy-Item "C:\path\to\Cursor Constitution\constitution.mdc" .cursor\rules\
Copy-Item "C:\path\to\Cursor Constitution\example-code-style.mdc" .cursor\rules\code-style.mdc
```

### 2. Минимальные правки под проект

Обычно **constitution менять не нужно** — он stack-agnostic.

В `code-style.mdc` при необходимости подправьте только:

1. **`globs`** во frontmatter — если стек не JS/TS (например, добавить `**/*.{py,go}` или сузить до `src/**/*.{ts,tsx}`).
2. **Стили / линтер** — если проект уже на ESLint/oxlint/Biome и т.д.: оставьте intents, маппите на ваши rule id.
3. **Formatting** — если команда договорилась иначе (ширина строки, кавычки, indent). Тогда же синхронизируйте Prettier / `.editorconfig` / `.vscode/settings.json`.
4. **Baseline ESLint** в конце файла — стартовая точка для новых ESLint-проектов; в существующем проекте не копируйте слепо поверх своей конфиги.

### 3. Проверить в Cursor

1. Откройте проект в Cursor.
2. Settings → Rules (или Project Rules) — оба `.mdc` должны быть видны.
3. `constitution` — Always Apply.
4. `code-style` — по globs / когда открыты matching-файлы.

### 4. Опционально: `AGENTS.md` для других инструментов

Тело `constitution.mdc` **без YAML frontmatter** можно положить в корневой `AGENTS.md` — тогда тот же контракт читают Claude Code, Copilot и др. `code-style` при этом лучше держать рядом как отдельный файл или секцию.

---

## Как устроены Cursor Rules (кратко)

Файлы в `.cursor/rules/*.mdc` с YAML frontmatter:

```yaml
---
description: Кратко, что делает правило (видно в picker)
globs: '**/*.{ts,tsx}'   # опционально: только для matching-файлов
alwaysApply: true         # true = в каждой сессии
---

# Заголовок
Текст правила...
```

| Режим | Когда использовать |
| --- | --- |
| `alwaysApply: true` | Конституция, универсальные запреты |
| `globs` + `alwaysApply: false` | Code style, React/API-конвенции |

Рекомендации Cursor: одно правило — одна тема; конкретика и примеры; не раздувать до сотен строк без нужды. Наша связка специально разделена на **behavior** и **form**.

---

## Блок 1 — Constitution (`constitution.mdc`)

**Назначение:** non-negotiable принципы для любого агента в репозитории. Читать **до** любой задачи. Уровни в духе RFC 2119: **MUST** / **SHOULD** / **MAY**.

### Frontmatter

```yaml
description: Project Constitution — …
alwaysApply: true
```

Всегда в контексте. Не зависит от открытого файла.

### §1 Core Principles (P-1 … P-5)

| ID | Суть |
| --- | --- |
| **P-1** | Сначала контекст: читать файлы и паттерны, не угадывать API |
| **P-2** | Следовать `code-style.mdc`; если там тихо — копировать окружение |
| **P-3** | Только нужные изменения; без рефакторинга «заодно» |
| **P-4** | Разросшийся scope — озвучить и подтвердить |
| **P-5** | Не оставлять проект сломанным (build / lint / half-edits) |

### §2 Workflow (W-1 … W-6)

| ID | Суть |
| --- | --- |
| **W-1** | Спрашивать, когда решение за пользователем; иначе — разумный default |
| **W-2** | При неоднозначности явно сказать, как интерпретируешь запрос |
| **W-3** | Делать запрошенное; альтернативу предлагать, не внедрять молча |
| **W-4** | Для 3+ шагов — видимый task list |
| **W-5** | Честный отчёт: что сделано / не сделано / ограничения |
| **W-6** | **Спрашивать перед установкой** пакетов, линтеров, форматтеров, расширений |

**W-6** — ключевой мост к code-style: агент не «допиливаёт» toolchain сам.

### §3 Security (S-1 … S-4)

| ID | Суть |
| --- | --- |
| **S-1** | Не коммитить секреты; `.env` — с предупреждением |
| **S-2** | Внешний ввод — untrusted, валидировать |
| **S-3** | Запрет опасных паттернов (`eval`, грязный HTML, SQL/shell из сырого ввода) |
| **S-4** | Зависимости — только с обоснованием; pin версий; tooling → W-6 |

### §4 Testing & Verification (T-1 … T-3)

| ID | Суть |
| --- | --- |
| **T-1** | Перед «готово»: lint / build / format:check *если уже есть в проекте* |
| **T-2** | Чиннить то, что сломал сам; чужие старые падения — репортить |
| **T-3** | Тесты на meaningful logic, не зеркало реализации |

Отсутствие Prettier **не** повод ставить его ради галочки (снова W-6).

### §5 Git & Commits (G-1 … G-4)

| ID | Суть |
| --- | --- |
| **G-1** | Коммит **только по явной просьбе** |
| **G-2** | Conventional Commits: `type(scope): summary` |
| **G-3** | В теле коммита — *why*, не пересказ diff |
| **G-4** | Без force-push / rewrite / skip hooks без явного запроса |

### §6 Code Style companion (C-1 … C-3)

| ID | Суть |
| --- | --- |
| **C-1** | Писать/править код по `code-style.mdc` |
| **C-2** | Не дублировать и не противоречить style в чате/конституции |
| **C-3** | Style должен быть enforceable; недостающий tooling — спросить (W-6), потом провода editor + scripts |

### §7 Avoid / Code quality (A-1 … A-3)

То, что линтер часто не ловит полностью:

| ID | Суть |
| --- | --- |
| **A-1** | Не хардкодить env/API surface «насовсем»; временный hardcode — warn + follow-up |
| **A-2** | Именованные константы вместо magic numbers (`no-magic-numbers`) |
| **A-3** | Нет пустых `try/catch` / empty blocks (`no-empty`) |

---

## Блок 2 — Code Style (`example-code-style.mdc` → `code-style.mdc`)

**Назначение:** конкретный контракт формы кода + как его enforce через editor / Prettier / linter.

### Frontmatter (как в шаблоне)

```yaml
description: Code style, formatting, and linter conventions…
globs: ['**/*.{ts,tsx,js,jsx,css,scss,sass,less}']
alwaysApply: false
```

Срабатывает при работе с matching-файлами. Конституция при этом всё равно always-on и требует подчиняться style-файлу.

### Stack awareness

- Смотреть `package.json` и конфиги проекта.
- Не предполагать версии наугад — актуальные non-deprecated API зависимостей.
- Не тащить лишний boilerplate (например, старый JSX transform, если runtime уже есть).

### Tooling enforcement

Самый важный операционный раздел:

1. Правила **SHOULD** быть enforceable, не только «на бумаге».
2. Нет пакета/плагина/расширения → **спросить**, не ставить самому.
3. Предпочитать уже существующий toolchain проекта.
4. После апрува — скрипты в `package.json` (`lint`, `format`, `format:check`).
5. Editor wiring:
   - проверить расширение (для Prettier: `esbenp.prettier-vscode`);
   - `.vscode/extensions.json` — recommendations;
   - `.vscode/settings.json` — format on save, rulers, indent, Prettier overrides;
   - **workspace-local** `prettier.configPath` / `prettier.ignorePath` / `prettier.requireConfig: true`, чтобы user-level путь к другому проекту не ломал репо;
   - `.editorconfig` + Prettier = Formatting section.

### Formatting

| Правило | Значение | Enforce |
| --- | --- | --- |
| Indent | 4 spaces, no tabs | EditorConfig / Prettier / VS Code |
| Quotes | single `'...'` (в т.ч. JSX) | Prettier |
| Semicolons | always | Prettier |
| Line length | ~130 | Prettier `printWidth`, ruler `[130]` |
| Blank lines | одна между блоками, не больше одной подряд | style + review |

Длинные строки правятся format/save, не обязательно красятся как oxlint/ESLint errors.

### Imports

Порядок групп (между группами — пустая строка), внутри — alphabetically:

1. Node / stdlib  
2. External packages  
3. Internal aliases / absolute  
4. Relative (`../` перед `./`)  
5. Styles / assets  

Unused imports — линтер MUST ловить.

### Naming

| Сущность | Стиль | Пример |
| --- | --- | --- |
| Components / component files | `PascalCase` | `Header.tsx` |
| Hooks | `use` + camelCase | `useIsMobile` |
| vars / functions / non-component files | `camelCase` | `publicAsset.ts` |
| Types / interfaces | `PascalCase` | `ContentBlock` |
| True constants | `UPPER_SNAKE_CASE` по ясности | `MAX_RETRY` |

### TypeScript

- `import type` где ожидает/требует TS-конфиг  
- `const` по умолчанию; `let` только при reassignment; никогда `var`  
- Избегать `any`; для неизвестного — `unknown` + narrowing  
- Unused locals/params — **warn** (`no-unused-vars`), не обязательно fail compile  
- `switch`: все case или `default`, без fallthrough  

### React

- Только function components  
- Rules of Hooks  
- `react/only-export-components`: не мешать в одном файле компонент и несвязанные utils — выносить в `utils.ts`  
- Композиция и маленькие компоненты вместо монолитов  

### Styling

- Определить подход проекта (Tailwind / SCSS / CSS Modules / …) и **не** вводить второй без спроса  
- Inline `style` — только динамика, которую нельзя выразить классами/токенами  
- CSS Modules — через module object, не хардкод сгенерированных строк  

### Comments

- Короткие `//` про *why*  
- `// TODO:` / `// FIXME:`  
- Не пересказывать очевидное «что делает строка»  

### Linter — таблица intents

Агент маппит intent → ближайший rule id выбранного линтера:

| Intent | Typical rule | Level |
| --- | --- | --- |
| Strict equality | `eqeqeq` | error |
| Unused vars | `no-unused-vars` | warn |
| No `console` leftovers | `no-console` | warn |
| Prefer `const` | `prefer-const` | error |
| No magic numbers | `no-magic-numbers` | warn |
| No empty blocks | `no-empty` | error |
| No duplicate imports | `no-duplicate-imports` / `import/no-duplicates` | error |
| Blank line after imports | `import/newline-after-import` | warn |
| No circular imports | `import/no-cycle` | error |
| Rules of Hooks | `react-hooks/rules-of-hooks` | error |
| Exhaustive deps | `react-hooks/exhaustive-deps` | warn |
| List `key` | `react/jsx-key` | error |
| Self-closing tags | `react/self-closing-comp` | warn |
| Clean Fast Refresh exports | `react/only-export-components` | warn |

Нет правила в текущем сетапе → репорт + спросить про плагин; не изобретать самодельный substitute и не ставить без подтверждения.

### Baseline ESLint (в конце файла)

JSON-блок — **portable starting point** для нового ESLint + React App проекта. В живом репо с Biome/oxlint/уже настроенным ESLint — использовать как чеклист intents, а не как drop-in overwrite.

---

## Чеклист переноса в новый проект

- [ ] `.cursor/rules/constitution.mdc` скопирован (`alwaysApply: true`)
- [ ] `.cursor/rules/code-style.mdc` скопирован из `example-code-style.mdc`
- [ ] Ссылки внутри файлов указывают на `code-style.mdc` / `constitution.mdc` (как в шаблонах)
- [ ] `globs` в code-style соответствуют языкам репо
- [ ] Formatting (4 spaces / single quotes / semis / ~130) согласован с командой
- [ ] Если есть Prettier/ESLint — intents из таблицы отражены в конфиге (или зафиксирован осознанный gap)
- [ ] При апруве tooling: scripts + `.vscode/*` + `.editorconfig` согласованы
- [ ] Опционально: `AGENTS.md` из тела constitution без frontmatter
- [ ] В Cursor видно оба правила; агент в тестовом запросе ссылается на P-/W-/C- и style

---

## Типичные сценарии

### Новый greenfield (Vite/React/TS)

1. Скопировать оба rule-файла.  
2. Спросить пользователя про Prettier + ESLint (W-6).  
3. После «да» — конфиги по Formatting + Baseline ESLint (+ React/import plugins).  
4. Провода `.vscode` и scripts.

### Уже живой проект со своим линтером

1. Constitution as-is.  
2. Code-style: оставить intents, подстроить wording под oxlint/Biome/ESLint flat config.  
3. Не ломать существующие scripts; донастроить только недостающие intents после апрува.

### Не JS-проект (Python, Go, …)

1. Constitution почти без изменений (P/W/S/T/G/A универсальны).  
2. Code-style: переписать Formatting/Naming/Linter под язык **или** завести отдельный `code-style-<lang>.mdc` с globs; C-1/C-2 в constitution обновить на актуальное имя файла.

---

## Структура репозитория

```text
Cursor Constitution/
├── README.md                 ← этот файл
├── constitution.mdc          ← always-on конституция (копировать как есть)
└── example-code-style.mdc    ← шаблон → в проекте переименовать в code-style.mdc
```

---

## Принцип поддержки

1. **Поведение** меняем в `constitution.mdc`.  
2. **Форму кода / lint intents / tooling** — в `code-style.mdc`.  
3. После изменения style — синхронизировать Prettier, EditorConfig, linter, `.vscode`.  
4. Не размазывать одни и те же правила по user rules Cursor и project rules без нужды: project `.mdc` — source of truth для репо.

---

## Краткий TL;DR

| Действие | Файл |
| --- | --- |
| Скопировать в `.cursor/rules/` | `constitution.mdc` + `code-style.mdc` (из example) |
| Почти не трогать | constitution |
| Чуть подкрутить под стек | globs, linter mapping, formatting если команда иначе |
| Агент всегда | читает context → минимальный diff → спрашивает перед tooling → не коммитит сам → оставляет проект рабочим |
| Style | 4 spaces, single quotes, semis, ~130, import groups, TS/React intents из таблицы |

Скопировал → переименовал example → открыл в Cursor → работаешь по одним правилам в любом проекте.
