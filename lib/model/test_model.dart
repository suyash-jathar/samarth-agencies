class Test {
  final String id;
  final String name;
  final double price;

  Test({required this.id, required this.name, required this.price});

  factory Test.fromJson(String id, Map<String, dynamic> json) {
    return Test(
      id: id,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}