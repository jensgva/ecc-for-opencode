# ECC for OpenCode (Windows)

Installs [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) (ECC) into OpenCode. You get ready-made commands, skills and agents for planning, test-driven development, code review and verification.

## 1. Install

### Requirements
- [Git](https://git-scm.com/download/win)
- [Node.js LTS](https://nodejs.org)
- [OpenCode](https://opencode.ai)

### Run the script
1. Close OpenCode.
2. Open PowerShell in the folder containing `install-ecc-opencode.ps1`.
3. Run:
   ```
   powershell -ExecutionPolicy Bypass -File .\install-ecc-opencode.ps1
   ```

What it does:
- Backs up any existing OpenCode config.
- Downloads ECC to `%USERPROFILE%\ecc`.
- Builds ECC and installs it into `%USERPROFILE%\.config\opencode`.
- Turns off ECC's hook plugins, which don't work with the current OpenCode plugin format yet.

### Check it worked
1. Open a project folder in PowerShell and run `opencode`.
2. Type `/` and you should see commands like `/plan`, `/tdd`, `/code-review` and `/verify`.
3. Type `@` to see the available subagents.
4. There should be no plugin errors. If you see one, check `/plugins`.

## 2. Core idea

ECC makes the AI work like a disciplined engineer:
- **Plan first.** Agree on the approach before any code is written.
- **Test first.** Write tests, then the code that makes them pass.
- **Review.** A separate reviewer checks quality and security.
- **Verify.** Prove that the build, lint and tests pass instead of trusting "done".

## 3. Commands you'll use most

| Command | What it does |
|---|---|
| `/plan <feature>` | Writes an implementation plan. No code yet. |
| `/tdd <feature>` | Builds the feature test-first: failing test, then code, then refactor. |
| `/code-review` | Reviews your current changes for bugs, quality and security. |
| `/build-fix` | Fixes build or type errors one at a time. |
| `/verify` | Runs the build, types, lint and tests, and reports what passes. |
| `/checkpoint` | Saves the current verified state. |
| `/e2e` | Generates end-to-end tests with Playwright. |
| `/refactor-clean` | Finds and removes dead code. |
| `/learn` | Saves useful patterns from the session for reuse. |

Type `/` inside OpenCode to see the full list with descriptions.

## 4. Tutorials

### Tutorial 1: Build a new feature
1. `/plan add a contact form with name, email and message, saved to the database`
2. Read the plan. Correct anything that's wrong, for example: "use Postgres, not SQLite".
3. `/tdd implement the plan`
4. `/code-review`
5. Fix what the review flags, or ask: "fix the issues from the review".
6. `/verify`
7. Commit.

### Tutorial 2: Fix a broken build
1. `/build-fix`
2. When it's done, run `/verify` to confirm everything passes.

### Tutorial 3: Review before you push
1. `/code-review`
2. Ask for a security check, for example: `@security-reviewer check the auth code`
3. `/verify`

### Tutorial 4: Clean up an old project
1. `/refactor-clean`
2. `/verify` to make sure nothing broke.

### Tutorial 5: Use a specialist agent directly
Type `@` and the agent name, then the task:
```
@planner design how to add user roles
@code-reviewer review src/api/users.ts
@tdd-guide write tests for the payment module
```

## 5. Writing good prompts

Be specific. Say what to change, where, and what counts as done.

- Bad: `make login better`
- Good: `add rate limiting to /api/login: max 5 attempts per minute per IP, return 429, with tests`

Other habits:
- Start a new session for each feature. Long sessions get worse results.
- If a session gets long, run `/compact`.
- If the right agent or skill isn't used automatically, name it: "use the tdd-workflow skill".

## 6. Good to know

- **Hooks are disabled.** You lose automatic console.log warnings, auto-format and context saving during compaction. Everything else works.
- **Some skills need Bash or Python.** Skills such as continuous-learning-v2 and skill-stocktake run `.sh` or Python scripts. They need Git Bash or WSL and Python.
- **MCP servers.** Enable only the one or two you actually use. Each one takes up context space.

## 7. Updating

Close OpenCode and run the script again. It updates ECC and reinstalls, backing up your current config first.

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| "Access denied" when the script renames the config | OpenCode is still running. Close it, or restart the PC, and run the script again. |
| `git`, `node` or `npm` not found | Install it, reopen PowerShell, and run the script again. |
| Script says it couldn't edit `opencode.json` | Run `notepad $HOME\.config\opencode\opencode.json` and delete the `"plugin": [ ... ]` block, including its trailing comma. |
| Plugin errors in OpenCode | Make sure `%USERPROFILE%\.config\opencode\plugins` no longer exists. The script renames it to `plugins.disabled`. |
| Commands missing when typing `/` | Run the script again and check its output for errors. |
| No agents when typing `@` | The installed modules may not include agents. Rerun ECC's installer from `%USERPROFILE%\ecc` with `agents-core` added to the `--modules` list. |

## Credits

ECC was created by [@affaanmustafa](https://x.com/affaanmustafa) and is MIT licensed. This script only installs it.
