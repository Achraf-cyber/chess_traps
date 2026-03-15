# 🚀 Development Workflow & Branching

We use a simplified **GitHub Flow** to manage our Flutter + Supabase environments.

## 🌿 Branch Naming Convention

* **main**: Production-only. Matches the `Supabase Production` project.
* **develop**: Integration branch. Matches the `Supabase Dev` project.
* **Feature Branches**: `feat/SCRUM-ID-description` (e.g., `feat/SCRUM-10-setup-flavors`).
* **Bug Fixes**: `fix/SCRUM-ID-description`.
* **Hotfixes**: `hotfix/description` (only for immediate production patches).

## 🛠 Environment Separation

We use **Flutter Flavors** to switch between Supabase instances.

| Environment | Branch | Supabase Project | Command |
| :--- | :--- | :--- | :--- |
| **Development** | `develop` | `app-dev` | `flutter run --flavor dev` |
| **Production** | `main` | `app-prod` | `flutter run --flavor prod` |

## 🔄 Database Changes (Supabase)

1. **Never** make schema changes directly in the Dashboard for Dev or Prod.
2. Make changes in your **Local Docker Supabase** instance.
3. Generate a migration: `supabase db diff -f your_feature_name`.
4. Commit the `.sql` file in the `supabase/migrations` folder.
5. Merging to `develop` will automatically trigger the migration push to the Dev Project.
