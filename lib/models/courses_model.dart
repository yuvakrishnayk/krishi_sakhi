class Course {
  final String title;
  final String instructor;
  final String duration;
  final String language;
  final String imageUrl;
  final double rating;
  final int students;
  final String category;
  final String level;
  final bool isFree;
  final double? price;
  final String description;

  Course({
    required this.title,
    required this.instructor,
    required this.duration,
    required this.language,
    required this.imageUrl,
    required this.rating,
    required this.students,
    required this.category,
    required this.level,
    required this.isFree,
    this.price,
    required this.description,
  });
}
