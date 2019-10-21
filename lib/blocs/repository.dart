import 'package:share_a_pic/api.dart';
import 'package:share_a_pic/models/image_model.dart';

class Repository {
  final api = FireBaseAPi();

  Future<List<ImageModel>> getImages() => api.getImages();
}
