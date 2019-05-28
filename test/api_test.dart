import 'package:flutter_test/flutter_test.dart';
import 'package:foodrecipes/api.dart';

void main() {
  int resCode = 0;
  test('Should get the data from api', () {
    final api = Api();
    api
        .getData(
            "https://themealdb.com/api/json/v1/1/search.php?s=Chinon%20%Apple%20%Tarts")
        .then((response) {
      resCode = response.statusCode;
      expect(resCode, 200);
    });
  });
}
