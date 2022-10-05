import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_bloc.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_event.dart';
import 'package:flutter_app_sale_06072022/data/model/order_history.dart';
import 'package:flutter_app_sale_06072022/data/repositories/order_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/order_history/order_history_event.dart';
import '../../../data/datasources/remote/app_response.dart';
import '../../../data/datasources/remote/dto/order_history_dto.dart';
import '../../../data/model/product.dart';



class OrderBloc extends BaseBloc{
  StreamController<List<Order>> orderController = StreamController();
  late OrderRepository _repository;

  void updateOrderRepository(OrderRepository orderRepository) {
    _repository = orderRepository;
  }

  @override
  void dispatch(BaseEvent event) {
    switch(event.runtimeType) {
      case GetHistoryOrderEvent:
        _getHistoryOrder();
        break;
    }
  }
  void _getHistoryOrder() async {
    loadingSink.add(true);
    try{
      //Response response = await _repository.getOrder();
      // final Map<String, dynamic> responseJson = json.decode(response.toString());
      // if (responseJson["result"] > 0) {
      //   List orders = responseJson['data'];
      //   final result = orders
      //       .map<OrderDto>((json) => OrderDto.fromJson(json))
      //       .toList();
      //   // print(result);
      //   orderController.sink.add(result);
      // }

      Response response = await _repository.getOrder();
      AppResponse<List<OrderDto>> orderResponse = AppResponse.fromJson(response.data, OrderDto.convertJson);

      List<Order> orders = [];
      orderResponse.data?.forEach((item) {
        Order order = Order(
          item.id,
          item.products?.map((dto){
            return Product(dto.id, dto.name, dto.address, dto.price, dto.img, dto.quantity, dto.gallery);
          }).toList(),
          item.idUser,
          item.price,
          item.status,
          item.dateCreated,
        );
        orders.add(order);
      });

      orderController.sink.add(orders);
    } on DioError catch (e) {
      orderController.sink.addError(e.response?.data["message"]);
      messageSink.add(e.response?.data["message"]);
    } catch (e) {
      messageSink.add(e.toString());
    }
    loadingSink.add(false);
  }
}