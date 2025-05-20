import 'package:codey/models/exceptions/invalid_data_exception.dart';

abstract class Quest {
  final String type;
  final int? constraint;
  final int progress;
  final int? nLessons;
  final bool isCompleted;

  Quest({
    required this.type,
    this.constraint,
    required this.progress,
    this.nLessons,
    required this.isCompleted,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case questGetXp:
        return QuestGetXp.fromJson(json);
      case questHighAccuracy:
        return QuestHighAccuracy.fromJson(json);
      case questHighSpeed:
        return QuestHighSpeed.fromJson(json);
      case questCompleteLessonGroup:
        return QuestCompleteLessonGroup.fromJson(json);
      case questCompleteExercises:
        return QuestCompleteExercises.fromJson(json);
      default:
        throw InvalidDataException("Invalid quest type");
    }
  }

  static const String questGetXp = "GET_XP";
  static const String questHighAccuracy = "HIGH_ACCURACY";
  static const String questHighSpeed = "HIGH_SPEED";
  static const String questCompleteLessonGroup = "COMPLETE_LESSON_GROUP";
  static const String questCompleteExercises = "COMPLETE_EXERCISES";
}

class QuestGetXp extends Quest {
  QuestGetXp({
    required int progress,
    required int constraint,
    required bool isCompleted,
  }) : super(
          type: Quest.questGetXp,
          progress: progress,
          constraint: constraint,
          isCompleted: isCompleted,
        );

  factory QuestGetXp.fromJson(Map<String, dynamic> json) {
    return QuestGetXp(
      progress: json['progress'],
      constraint: json['constraint'],
      isCompleted: json['isCompleted'],
    );
  }
}

class QuestHighAccuracy extends Quest {
  QuestHighAccuracy({
    required int progress,
    required int constraint,
    required int nLessons,
    required bool isCompleted,
  }) : super(
          type: Quest.questHighAccuracy,
          progress: progress,
          constraint: constraint,
          nLessons: nLessons,
          isCompleted: isCompleted,
        );

  factory QuestHighAccuracy.fromJson(Map<String, dynamic> json) {
    return QuestHighAccuracy(
      progress: json['progress'],
      constraint: json['constraint'],
      nLessons: json['nLessons'],
      isCompleted: json['isCompleted'],
    );
  }
}

class QuestHighSpeed extends Quest {
  QuestHighSpeed({
    required int progress,
    required int constraint,
    required int nLessons,
    required bool isCompleted,
  }) : super(
          type: Quest.questHighSpeed,
          progress: progress,
          constraint: constraint,
          nLessons: nLessons,
          isCompleted: isCompleted,
        );

  factory QuestHighSpeed.fromJson(Map<String, dynamic> json) {
    return QuestHighSpeed(
      progress: json['progress'],
      constraint: json['constraint'],
      nLessons: json['nLessons'],
      isCompleted: json['isCompleted'],
    );
  }
}

class QuestCompleteLessonGroup extends Quest {
  QuestCompleteLessonGroup({
    required int progress,
    required bool isCompleted,
  }) : super(
          type: Quest.questCompleteLessonGroup,
          progress: progress,
          isCompleted: isCompleted,
        );

  factory QuestCompleteLessonGroup.fromJson(Map<String, dynamic> json) {
    return QuestCompleteLessonGroup(
      progress: json['progress'],
      isCompleted: json['isCompleted'],
    );
  }
}

class QuestCompleteExercises extends Quest {
  QuestCompleteExercises({
    required int progress,
    required int constraint,
    required bool isCompleted,
  }) : super(
          type: Quest.questCompleteExercises,
          progress: progress,
          constraint: constraint,
          isCompleted: isCompleted,
        );

  factory QuestCompleteExercises.fromJson(Map<String, dynamic> json) {
    return QuestCompleteExercises(
      progress: json['progress'],
      constraint: json['constraint'],
      isCompleted: json['isCompleted'],
    );
  }
}