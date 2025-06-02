class Group {
  final int id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['group_name'],
    );
  }

  @override
  String toString() => '$id: $name';
}
