# Instructions

General working instructions for any project. Claude Code loads these via a
`CLAUDE.md` that imports this file (`@AGENTS.md`); other agents (Codex, Gemini,
Cursor) read this file natively at the project root.

### Working principles

- **Correctness over speed.** Take the time to verify. Don't generate code from memory when current docs are a tool call away.
- **State assumptions explicitly.** If you're inferring a version, framework choice, or scope, say so before generating.
- **Ask before guessing.** If a request is ambiguous in a way that materially changes the answer, ask a clarifying question rather than picking silently.
- **Surface uncertainty.** "I don't know" or "the sources disagree" is more useful than a confident guess.

### Package Management

- Use UV for all Python package and environment management: `uv add`, `uv run`, `uv sync`.

### Modern Python Best Practices

- Use `pathlib` for file operations instead of built-in `open()`
  - Example: `Path.read_text()`, `Path.write_text()`, `Path.open()`
- Use type hints where they aid clarity, but not everywhere (e.g. function definitions)
- Use context managers for resources
- Use dataclasses or Pydantic models instead of plain dictionaries for structured data
- Use modern approaches over legacy patterns

### Code Quality with Ruff and ty

All code should be checked with Ruff and ty (Astral's type checker) before being considered done.

**Process Order (CRITICAL):**

1. Write the code in `main.py` and other Python files
2. Run `ruff check --fix` to auto-fix issues (includes import sorting)
3. Run `ruff format` to format the code
4. Run `ty check` to check for type errors
5. Review remaining issues from `ruff check` and `ty check`
6. Apply fixes based on decision criteria (see below)

**Where to run Ruff:**

Run Ruff from the project root, not a subdirectory. New projects (created via `proj_init`/`yt_init`) carry a `[tool.ruff]` with `extend` pointing at `~/.config/ruff/ruff.toml`, so the global ruleset loads explicitly; a project with no `[tool.ruff]` at all falls back to that same user-level config automatically. Either way, running from the project root makes first-party imports (`schemas`, `models`, `database`, etc.) resolve correctly.

**Decision Criteria for Ruff Suggestions:**

For each issue:

1. **Look it up** - Check the Ruff documentation if unfamiliar with the rule
2. **Evaluate** - Apply these criteria:
   - Does it improve code quality without overcomplicating?
   - Does it align with modern Python best practices?
3. **Flag for review** - If a rule seems questionable, unclear, or doesn't make sense in the current context, FLAG IT. Don't skip it silently - explain your concern so I can decide.

**Key Ruff Behaviors to Remember:**

- Trailing commas: Formatter will move arguments to separate lines when trailing commas are added. You'll get a warning, but this is fine. I prefer the trailing comma, and then format will format it appropriately.

### CLI Tools Available

Project-specific guidance below. For general usage of well-known tools, use them as you normally would.

#### ripgrep (`rg`)

Use `rg` instead of `grep`. Respects `.gitignore`, faster, cleaner output.

#### fd

Use `fd` instead of `find`. Same reasons.

#### Ruff

Required for Python linting, formatting, and import sorting. The workflow lives in **"Code Quality with Ruff and ty"** above — that section is load-bearing.

Run from the project root so first-party imports resolve correctly.

#### ty

Astral's Python type checker. Run via `ty check` (installed as a uv tool). See **"Code Quality with Ruff and ty"** above for how I want type errors handled.

#### djlint

HTML/Jinja formatter and linter. Run from inside the project directory so it picks up the local `.djlintrc`.

- `djlint --reformat <path>` — format
- `djlint --lint <path>` — lint

#### prettier

JavaScript formatter. Run from inside the project directory so it picks up the local `.prettierrc`.

- `prettier --write <pattern>`

#### uv

All Python package and environment management. See **"Package Management"** above.

#### git

Read-only commands only — `diff`, `log`, `status`. `git diff` is the primary tool for seeing what changed since the last commit. **Do not commit, push, or modify history without an explicit ask.**

#### Homebrew (`brew`)

Available for installing macOS tools. **Always ask me before installing a new tool with brew.** I want to consciously decide what's added to the system.

### Communication and Transparency

#### When You Encounter Issues

- Always tell me immediately if you run into blockers during testing or investigation
  - Examples: "Address already in use", permission errors, missing dependencies, can't access a file
- Ask me to help resolve the issue before continuing
  - Example: "I tried to test X but got error Y. Can you check if Z is running?"
- Don't work around issues silently - let me know so I can help

#### Be Explicit About What You Can/Cannot Verify

- Clearly distinguish between:
  - "I tested this and confirmed X"
  - "I couldn't test this, so I'm inferring X based on Y"
  - "I made an assumption here that might be wrong"
- If you're making an educated guess, say so explicitly
- If you need me to test something on my end, ask me directly

#### Testing and Verification

- If you need specific conditions to test properly (server stopped, port available, etc.), ask me to set them up
- Don't skip verification steps - if you can't verify something, tell me why
- When debugging issues together, share what you attempted and what the results were

### Researching Documentation: WebSearch, Context7, and DeepWiki

You have three documentation tools available. Each surfaces a different angle on "what's correct" — use them together, not interchangeably.

**Use WebSearch for:**

- Modern best practices and industry standards
- Comparing different approaches or frameworks
- Understanding what professionals use in the real world
- Community consensus on tool choices
- Blog posts, tutorials, and real-world usage patterns
- "X considered harmful" critiques and known footguns
- Broader context and comparative analysis

**Use Context7 for:**

- Official documentation and API references
- Recommended learning paths from library maintainers
- Current syntax for specific libraries/frameworks
- Version-specific features and methods
- Verifying what's actually available in the latest releases
- Exact method signatures and parameters
- Catching deprecated APIs and version drift

**Use DeepWiki for:**

- Understanding how a library works internally — design intent, not just API surface
- Canonical usage patterns from the source itself (test suites, `examples/` folders)
- Architectural context: why a piece of code exists and how it fits the whole
- Spotting idiomatic patterns that maintainers themselves use
- Answering "why is it built this way?" questions

### General approach

For non-trivial library/framework questions:

1. **Start with WebSearch** to understand the landscape and what the community considers best practice.
2. **Verify specifics with Context7** — confirm current syntax, check for deprecations, get exact signatures.
3. **Reach for DeepWiki** when teaching _how_ or _why_ something works, or when the tutorial calls for design-intent commentary.
4. **Mention which tool informed your answer** so it can be spot-checked.

### When sources disagree

If WebSearch consensus, Context7's official docs, and DeepWiki's source-code reality diverge on the right way to do something, **don't paper over it — call it out explicitly.** Disagreement between these sources is often where the most valuable teaching content lives:

- Official docs may show one pattern while the test suite uses another
- A library's recommended API may have community-known footguns the docs don't mention
- "The way it's documented" vs "the way maintainers actually use it" is exactly the kind of nuance that separates "this works" from "this is how you should do it and why"

When this happens, surface the divergence and explain the tradeoff rather than picking a side silently.

### Library version handling

Any time you use a library/framework, confirm the version before generating code:

- If a target version isn't specified, use the pinned version in `pyproject.toml` (or equivalent for the language)
- Otherwise, use the latest stable version
- Avoid deprecated APIs — verify against current docs/changelogs via Context7
- If Context7 isn't available for a given library, say so explicitly rather than guessing
- In your answer, confirm the version you decided to use
