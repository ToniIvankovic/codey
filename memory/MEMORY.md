# Project Memory: Codey (Diplomski)

## Project Type
Gamified programming learning platform — Flutter frontend + .NET 8 backend + MongoDB Atlas, deployed on AWS CloudFront.

## Key Architecture
- Backend: Clean architecture — CodeyBE.API / CodeyBe.Services / CodeyBE.Data.DB / CodeyBE.Contracts
- Frontend: Flutter with Provider state management, Model-Repository-Service pattern
- Current feature branch: `feature/course-hierarchy` — adding multi-course support (courseId on all entities)

## Important Files
- Backend entry: `backend/CodeyBE.API/Program.cs`, IoC: `Startup.cs`
- Frontend entry: `codey/lib/main.dart`
- JWT client: `codey/lib/auth/authenticated_client.dart`

## Git Workflow
- Always use `--no-ff` when merging branches — never allow fast-forward merges, even when possible

## User Preferences
- No specific preferences recorded yet.
