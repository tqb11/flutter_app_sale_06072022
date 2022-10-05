import 'package:flutter_app_sale_06072022/common/bases/base_repository.dart';

class OrderRepository extends BaseRepository{
  Future getOrder() {
    return apiRequest.getOrder();
  }
}