import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../common/constants/variable_constant.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/model/order_history.dart';
import '../../../data/model/product.dart';
import '../../../data/repositories/product_repository.dart';
import 'order_history_bloc.dart';
import 'order_history_event.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("Danh sách đơn hàng"),
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10, top: 10),
              child: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context,
                      VariableConstant.HOME_ROUTE,
                          (Route<dynamic> route) => false);
                },
              ))
        ],
      ),
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, ProductRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? ProductRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<ProductRepository, OrderBloc>(
          update: (context, repository, bloc) {
            bloc?.updateOrderRepository(repository);
            return bloc ?? OrderBloc()
              ..updateOrderRepository(repository);
          },
        ),
      ],
      child: OrderContainer(),
    );
  }
}

class OrderContainer extends StatefulWidget {
  const OrderContainer({Key? key}) : super(key: key);

  @override
  State<OrderContainer> createState() => _OrderContainerState();
}

class _OrderContainerState extends State<OrderContainer> {
  late OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _orderBloc = context.read<OrderBloc>();
    _orderBloc.eventSink.add(GetHistoryOrder());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Stack(
            children: [
              StreamBuilder<List<Order>>(
                  initialData: const [],
                  stream: _orderBloc.orderController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                        child: Center(child: Text("Data error")),
                      );
                    }
                    if (snapshot.hasData && snapshot.data == []) {
                      return Container();
                    }
                    return ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          return _itemOrder(snapshot.data?[index]);
                        });
                  }),
              LoadingWidget(
                bloc: _orderBloc,
                child: Container(),
              )
            ],
          ),
        ));
  }

  Widget _itemOrder(Order? order) {
    List<Product>? products = order?.products;
    return SizedBox(
      child: Card(
        elevation: 2,
        shadowColor: Colors.blueGrey,
        child: Container(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 2),
                        child: Text(
                            DateFormat('dd/MM/yyyy - HH:mm')
                                .format(DateTime.parse(order!.dateCreated))
                                .toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      Text('Số lượng: ' + order.products.length.toString(),
                          style: TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic)),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Text("Tổng tiền : ", style: TextStyle(fontSize: 12)),
                          Text(
                              NumberFormat("#,###", "en_US")
                                  .format(order.price) +
                                  " đ",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, VariableConstant.ORDER_HISTORY_DETAIL_ROUTE,
                        arguments: order);
                  },
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return const Color.fromARGB(200, 11, 22, 142);
                        } else {
                          return const Color.fromARGB(230, 11, 22, 142);
                        }
                      }),
                      shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(500))))),
                  child: Text("Chi tiết", style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
