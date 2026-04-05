# 🪝 Git Hooks & Validation

To keep our repository history clean and consistent, we enforce branching and commit message conventions automatically using [Husky](https://pub.dev/packages/husky) and Dart scripts.

## How it works

When you first checkout the project or run `dart run husky install`, Husky will automatically install the necessary Git hooks in your `.husky/` directory.

### Commit Message Validation (`commit-msg`)

When you run `git commit`, the `.husky/commit-msg` hook executes the Dart script located at `scripts/verify_commit_msg.dart`. This script checks your commit message against our Conventional Commits specification.

If your message does not match the format:
```
type(scope): description [SCRUM-ID]
```
The commit will be **rejected**.

**Example of a valid commit:** `feat(auth): add login [SCRUM-123]`

**Example of a rejection:**
```
❌ Invalid Commit Message Format!
Your commit message: "fixed login bug"
Error: Does not match basic structure...
```

### Branch Name Validation (`pre-push`)

When you run `git push`, the `.husky/pre-push` hook executes `scripts/verify_branch_name.dart`. 
It ensures you are pushing an approved branch name:
- `main`
- `develop`
- `feat/SCRUM-ID-description`
- `fix/SCRUM-ID-description`
- `hotfix/description`

If your branch name is incorrectly formatted (e.g., `feature/my-new-feature`), the push will be **rejected**.

## Troubleshooting

- **Bypassing hooks**: In rare emergency cases, you can bypass the hooks using the `--no-verify` flag (e.g. `git commit --no-verify`), though this is discouraged.
- **Hooks not running?**: If you don't see the validation running, make sure to run `dart run husky install` inside the project to initialize the hooks on your local machine.
