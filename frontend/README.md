# RH Plus App

A Flutter-based Human Resources Management application.

## Modules

- User Management
- Training
- Performance Evaluation
- Payroll
- Recruitment
- Employee Profile

## Recent Fixes (May 2025)

### Training Module
- Fixed AppColors constants (textPrimaryColor, textSecondaryColor, borderColor)
- Fixed TrainingProvider initialization with token parameter
- Updated model property references to match actual model definitions:
  - Replaced `title` with `programName`
  - Replaced `startDate` with `sessionDate`
  - Replaced `duration` with `durationHours`
  - Replaced `status` with `isActive` for program status
- Fixed totalHours calculation in reporting screen
- Added placeholder views for Employee and User training views
- Fixed method name references (fetchTrainingPrograms, fetchUpcomingSessions)

## Getting Started

This project is a starting point for a Flutter application.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
