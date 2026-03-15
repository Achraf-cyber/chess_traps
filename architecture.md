# 🏗️ schoolger: Project Architecture Guide

This document defines the structural rules and coding standards for the schoolger Flutter project. All team members must follow these conventions to ensure a scalable and maintainable codebase.

---

## 1. Global Configuration (`lib/`)

The root of the `lib` folder is reserved for files that configure the **entire** application context.

- **`main_*.dart`**: Environment-specific entry points (Dev/Prod/Staging).
- **`app.dart`**: The root Widget that initializes `MaterialApp.router`, Themes, and Locales.
- **`router.dart`**: Centralized navigation logic using GoRouter.
- **`theme/`**: Global styling, color schemes, and design constants.
- **`l10n/`**: Localization setup and `.arb` translation files.

## 2. Shared Components (`lib/widgets/`)

The global `widgets` folder contains **Atomic Components** used across multiple features.

- **Rule:** Only place a widget here if it is used in **two or more** distinct features (e.g., `GButton`, `GTextField`, `GCurrencyInput`).
- If a widget is only used within one specific feature, it must remain inside that feature's `widgets/` subfolder.

## 3. Feature-First Modularization (`lib/features/`)

We organize code by **User Features**, not by technical function. Each feature lives in `lib/features/<feature_name>/`.

| Folder          | Responsibility                                            |
| :-------------- | :-------------------------------------------------------- |
| **`view/`**     | The main Screen widget and its complex sub-screens.       |
| **`widgets/`**  | UI components used **exclusively** within this feature.   |
| **`data/`**     | Feature-specific Models (DTOs) and Supabase Repositories. |
| **`provider/`** | Riverpod providers, StateNotifiers, and business logic.   |

## 4. Strict Feature Isolation

To prevent technical debt and "spaghetti code," we enforce strict boundaries:

- **Dependency Rule:** Code in `features/foo` must **never** import or directly call code from `features/bar`.
- **Inter-feature Communication:** Interaction occurs **exclusively** through the **Routing System**. If Screen A needs to open Screen B, it uses a route path/name defined in `router.dart`.

## 5. Localization & Strings (i18n)

**Zero Hard-Coding Policy:** User-facing text must never be hard-coded in Dart files.

- **Primary File:** Add all keys to `lib/l10n/intl_fr.arb`.
- **Advanced Usage:** Utilize `.arb` support for **Plurals** and **Dates**.
- **Implementation:** Always check the current locale context using `AppLocalizations.of(context)!`.

## 6. Utilities (`lib/utils/` or `lib/core/`)

Global helpers with no UI logic live here.

- Examples: `currency_formatter.dart`, `input_validators.dart`, `supabase_client_extension.dart`.

---

## ✅ New Feature Checklist

- [ ] Create folder: `lib/features/my_new_feature`

- [ ] Define routes in `lib/router.dart`
- [ ] Move reusable UI elements to `lib/widgets/`
- [ ] Add all new strings to `intl_fr.arb`
- [ ] Ensure no direct imports from other feature folders
