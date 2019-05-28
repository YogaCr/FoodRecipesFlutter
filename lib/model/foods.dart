class Foods {
  final String id;
  final String img;
  final String name;
  final String category;

  Foods(this.id, this.name, this.img, this.category);

  factory Foods.fromJson(Map<String, dynamic> json) {
    return Foods(json["idMeal"], json["strMeal"], json["strMealThumb"],
        json["strCategory"]);
  }

  Map<String, dynamic> toMap() => {
        "idMeal": id,
        "strMeal": name,
        "strMealThumb": img,
        "strCategory": category
      };
}
