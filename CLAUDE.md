# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Codey** is a gamified programming learning platform (research project testing gamification's effect on student motivation). It's a monorepo with a Flutter frontend and .NET 8 backend deployed on AWS CloudFront + MongoDB Atlas.

## Commands

### Flutter Frontend (`/codey/`)

```bash
cd codey
flutter pub get                                      # Install dependencies
flutter run -d chrome --dart-define ENV=dev         # Run with local backend
flutter run -d chrome                               # Run with deployed backend (default)
flutter build web --dart-define ENV="prod"          # Production build
flutter test                                         # Run all tests
flutter analyze                                      # Lint
```

### .NET Backend (`/backend/`)

```bash
cd backend
dotnet restore                                      # Restore NuGet packages
dotnet build                                        # Build all projects
dotnet run --project CodeyBE.API                    # Run API server (localhost:5052)
dotnet test                                         # Run all tests
```

### Environment Configuration

Two env files in `/codey/`: `.env.dev` (localhost:5052), `.env.prod` (Azure deployed BE).
Selected at build time via `--dart-define ENV=dev|prod`. Default is `prod`.
VS Code launch configs in `.vscode/launch.json` handle this — use the Run & Debug dropdown.

## Architecture

### Backend (.NET 8 — Clean Architecture)

Three-layer separation: `CodeyBE.API` → `CodeyBe.Services` → `CodeyBE.Data.DB`, with contracts in `CodeyBE.Contracts`.

- **API layer** (`/backend/CodeyBE.API/`): Controllers, `Program.cs`, `Startup.cs` (IoC registration)
- **Contracts** (`/backend/CodeyBE.Contracts/`): Entities (BSON-serialized), DTOs, service/repository interfaces
- **Data** (`/backend/CodeyBE.Data.DB/`): MongoDB repository implementations
- **Services** (`/backend/CodeyBe.Services/`): Business logic

Authentication is JWT Bearer with 25120-hour expiry. CORS is fully open (AllowAnyOrigin/Method/Header). Roles: `STUDENT`, `TEACHER`, `CREATOR`, `ADMIN`.

### Frontend (Flutter — Provider + RxDart)

Model-Repository-Service pattern with Provider for DI and RxDart streams for reactive state.

- **`/codey/lib/main.dart`**: App bootstrap — `MultiProvider` registers all services and repositories
- **`/codey/lib/theme/app_theme.dart`**: Centralized theme — light/dark `ThemeData`, color schemes
- **`/codey/lib/auth/authenticated_client.dart`**: HTTP client that auto-injects JWT headers
- **`/codey/lib/models/`**: Dart entities and DTOs mirroring backend contracts
- **`/codey/lib/repositories/`**: API communication (use `AuthenticatedClient`); include caching with RxDart stream-based cache invalidation
- **`/codey/lib/services/`**: Business logic and state; some are intentionally thin delegating to repositories
- **`/codey/lib/widgets/`**: UI split by role: `student/`, `teacher/`, `creator/`, `admin/`, `auth/`

#### State management conventions
- Use **manual StreamSubscription** (subscribe in `initState`, cancel in `dispose`) for `userStream` and similar BehaviorSubjects — they always have a value so StreamBuilder's waiting state is noise
- Use **FutureBuilder** only when the future is stored as a state field (initialized in `initState`), never inline in `build()`
- Use **StreamBuilder** at the root (`main.dart`) where connection states genuinely matter
- Fetched data and stream subscriptions belong in `initState`, never in `build()`

### Database (MongoDB)

Collections: `users`, `exercises`, `lessons`, `lesson_groups`, `roles`, `logs`, `classes`, `courses`

### Exercise Types

Four types defined in `ExerciseType` enum: `MC` (multiple choice), `SA` (short answer), `LA` (long answer), `SCW` (short code writing / gap-fill).

### Gamification System

- **XP**: Awarded on lesson completion via `POST /interaction/end-lesson`
- **Streaks**: Calculated in `ApplicationUser.CalculateStreak()` and `CalculateHighestStreak()`
- **Quests**: Daily challenges (`QuestTypes`: GET_XP, HIGH_ACCURACY, HIGH_SPEED, COMPLETE_LESSON_GROUP, COMPLETE_EXERCISES)
- **A/B Testing**: `GamificationGroup` field on users splits cohorts

## Key File Locations

| Purpose | Path |
|---|---|
| Backend entry point | `backend/CodeyBE.API/Program.cs` |
| IoC / DI registration | `backend/CodeyBE.API/Startup.cs` |
| User XP & streak logic | `backend/CodeyBe.Services/UserService.cs` |
| All backend entities | `backend/CodeyBE.Contracts/Entities/` |
| Flutter app bootstrap | `codey/lib/main.dart` |
| Flutter theme (colors, ThemeData) | `codey/lib/theme/app_theme.dart` |
| JWT auth client | `codey/lib/auth/authenticated_client.dart` |
| All Dart models | `codey/lib/models/entities/` |
| Flutter dependencies | `codey/pubspec.yaml` |
| VS Code launch configs | `.vscode/launch.json` |
| Frontend CI/CD | `.github/workflows/aws-workflow.yml` |
| Backend CI/CD | `.github/workflows/CodeyBEAPI20240227131508.yml` |

## Notes

- UI text is Croatian only.
- Production API base: `https://d3l6qdq14kds7s.cloudfront.net/`
- Flutter targets: Web (primary), Android, iOS, Windows.
- Theme: Material 3, primary color `#389c9a` (teal), secondary `#fedb71` (golden). Defined in `app_theme.dart`.
