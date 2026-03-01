# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Codey** is a gamified programming learning platform (research project testing gamification's effect on student motivation). It's a monorepo with a Flutter frontend and .NET 8 backend deployed on AWS CloudFront + MongoDB Atlas.

## Commands

### Flutter Frontend (`/codey/`)

```bash
cd codey
flutter pub get                                    # Install dependencies
flutter run -d chrome                              # Run in browser (dev)
flutter build web --dart-define ENV="prod"        # Production build
flutter test                                       # Run all tests
flutter test test/widget_test.dart                # Run single test file
flutter analyze                                   # Lint
```

### .NET Backend (`/backend/`)

```bash
cd backend
dotnet restore                                    # Restore NuGet packages
dotnet build                                      # Build all projects
dotnet run --project CodeyBE.API                  # Run API server
dotnet test                                       # Run all tests
```

### Environment Configuration

- **Frontend**: Copy `.env.dev` or `.env.prod` — set `API_BASE` URL
- **Backend**: `appsettings.json` — MongoDB connection string and JWT secret

## Architecture

### Backend (.NET 8 — Clean Architecture)

Three-layer separation: `CodeyBE.API` → `CodeyBe.Services` → `CodeyBE.Data.DB`, with contracts in `CodeyBE.Contracts`.

- **API layer** (`/backend/CodeyBE.API/`): Controllers, `Program.cs`, `Startup.cs` (IoC registration)
- **Contracts** (`/backend/CodeyBE.Contracts/`): Entities (BSON-serialized), DTOs, service/repository interfaces
- **Data** (`/backend/CodeyBE.Data.DB/`): MongoDB repository implementations
- **Services** (`/backend/CodeyBe.Services/`): Business logic

Authentication is JWT Bearer with 25120-hour expiry. CORS is fully open (AllowAnyOrigin/Method/Header). Roles: `STUDENT`, `TEACHER`, `CREATOR`, `ADMIN`.

### Frontend (Flutter — Provider pattern)

Model-Repository-Service pattern with Provider for DI/state.

- **`/codey/lib/main.dart`**: App bootstrap — `MultiProvider` registers all services
- **`/codey/lib/auth/authenticated_client.dart`**: HTTP client that auto-injects JWT headers
- **`/codey/lib/models/`**: Dart entities and DTOs mirroring backend contracts
- **`/codey/lib/repositories/`**: API communication (use `AuthenticatedClient`)
- **`/codey/lib/services/`**: Business logic + state holders (extend `ChangeNotifier`)
- **`/codey/lib/widgets/`**: UI split by role: `student/`, `teacher/`, `creator/`, `admin/`, `auth/`

### Database (MongoDB)

Collections: `users`, `exercises`, `lessons`, `lesson_groups`, `roles`, `logs`, `classes`, `courses`

### Exercise Types

Four types defined in `ExerciseType` enum: `MC` (multiple choice), `SA` (short answer), `LA` (long answer), `SCW` (short code writing / gap-fill).

### Gamification System

- **XP**: Awarded on lesson completion via `POST /interaction/end-lesson`
- **Streaks**: Calculated in `ApplicationUser.CalculateStreak()` and `CalculateHighestStreak()`
- **Quests**: Daily challenges (`QuestTypes`: GET_XP, HIGH_ACCURACY, HIGH_SPEED, COMPLETE_LESSON_GROUP, COMPLETE_EXERCISES)
- **A/B Testing**: `GamificationGroup` field on users splits cohorts

### Course Hierarchy (current branch: `feature/course-hierarchy`)

`courseId` has been added to Exercise, Lesson, LessonGroup, and ApplicationUser. Repositories filter by courseId. **Still needed**: course switching UI, dynamic course fetching, and full testing.

## Key File Locations

| Purpose | Path |
|---|---|
| Backend entry point | `backend/CodeyBE.API/Program.cs` |
| IoC / DI registration | `backend/CodeyBE.API/Startup.cs` |
| User XP & streak logic | `backend/CodeyBe.Services/UserService.cs` |
| All backend entities | `backend/CodeyBE.Contracts/Entities/` |
| Flutter app bootstrap | `codey/lib/main.dart` |
| JWT auth client | `codey/lib/auth/authenticated_client.dart` |
| All Dart models | `codey/lib/models/entities/` |
| Flutter dependencies | `codey/pubspec.yaml` |
| Frontend CI/CD | `.github/workflows/aws-workflow.yml` |
| Backend CI/CD | `azure-pipelines.yml` |

## Notes

- UI text is Croatian only.
- Production API base: `https://d3l6qdq14kds7s.cloudfront.net/`
- Flutter targets: Web (primary), Android, iOS, Windows.
- Theme: Material 3, primary color `#389c9a` (teal), secondary `#fedb71` (golden).
