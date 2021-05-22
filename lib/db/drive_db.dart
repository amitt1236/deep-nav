class Drive {
  final int id;
  final int distance;
  final int how_many;

  Drive({this.id, this.distance, this.how_many});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'distance': distance,
      'how_many': how_many,
    };
  }
}