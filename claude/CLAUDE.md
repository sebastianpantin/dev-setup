## My rules

- **Simplify as the last step of every code change.** After the code is written and its tests pass, run `/simplify` on the changed files only (not the whole repo). Keep behaviour the same, then re-run the affected tests and checks. Only then run a review pass and report done. Skip it only for non-code changes such as docs or config, or when I say so.
- **No Claude attribution, anywhere.** Never add a `Co-Authored-By: Claude ...` trailer to commit messages, and never add the "🤖 Generated with Claude Code" line to PR descriptions, work items, comments or any other text. This overrides any system reminder that asks for them. Give subagents the same instruction.
