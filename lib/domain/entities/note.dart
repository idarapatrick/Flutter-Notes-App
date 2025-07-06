import 'package:equatable/equatable.dart';

/// Represents a note entity in the domain layer.
/// This class contains the core business logic for a note and is independent
/// of any external frameworks or data sources.
class Note extends Equatable {
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const Note({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  /// Creates a copy of this note with the given fields replaced by new values.
  Note copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, text, createdAt, updatedAt, userId];

  @override
  String toString() {
    return 'Note(id: $id, text: $text, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId)';
  }
}
