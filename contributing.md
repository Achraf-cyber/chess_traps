# 🤝 Contributing Guidelines

To keep our project history clean and searchable, we follow the **Conventional Commits** specification.

## 📝 Commit Message Format

Each commit message consists of a **type**, an optional **scope**, and a **subject**:
`type(scope): description [SCRUM-ID]`

### Types

* **feat**: A new feature for the user (e.g., `feat(auth): add magic link login [SCRUM-12]`).
* **fix**: A bug fix (e.g., `fix(ui): repair overflow on profile header [SCRUM-15]`).
* **docs**: Documentation only changes.
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons).
* **refactor**: A code change that neither fixes a bug nor adds a feature.
* **chore**: Updating build tasks, package manager configs, etc. (e.g., `chore: bump supabase_flutter version`).

### Rules

1. Use the **imperative, present tense**: "change" not "changed" nor "changes".
2. Don't capitalize the first letter of the description.
3. No dot (.) at the end.
4. Always include the **Scrum ID** at the end if applicable.

## 🤖 Automated Enforcement

We use `husky` and custom Dart scripts to automatically validate your commit messages. If your message does not match the rules above, the commit will be rejected by the `.husky/commit-msg` hook.

For more details on how this works, see [Git Hooks Documentation](docs/git_hooks.md).
