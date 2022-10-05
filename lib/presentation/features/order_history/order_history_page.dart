import 'package:flutter/material.dart';
import 'package:flutter_app_sale_06072022/common/constants/api_constant.dart';
import 'package:flutter_app_sale_06072022/common/widgets/loading_widget.dart';
import 'package:flutter_app_sale_06072022/data/model/order_history.dart';
import 'package:flutter_app_sale_06072022/data/repositories/order_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/order_history/order_history_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../common/bases/base_widget.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/model/product.dart';
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
        title: const Text("Lịch sử đơn hàng"),
      ),
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, OrderRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? OrderRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<OrderRepository, OrderBloc>(
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
    _orderBloc.eventSink.add(GetHistoryOrderEvent());
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
                        }
                    );
                  }
              ),
              LoadingWidget(
                bloc: _orderBloc,
                child: Container(),
              )
            ],
          ),
        )
    );
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
              Padding(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), topLeft: Radius.circular(5)),
                  child: Image.network(
                      ApiConstant.BASE_URL + (products?.first.img).toString(),
                      width: 100,
                      height: 80,
                      fit: BoxFit.fill),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text( "#${order?.id}",
                          style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
                      Container(
                        margin: const EdgeInsets.only(top:5,bottom: 2),
                        child: Text(DateFormat('HH:mm - dd/MM/yyyy')
                            .format(DateTime.parse(order!.dateCreated))
                            .toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      Text( '( ' + order.products.length.toString() + " món )",
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      SizedBox(height: 2,),
                      Row(
                        children: [
                          Text(
                              "Tổng tiền : ",
                              style: TextStyle(fontSize: 12)),
                          Text( NumberFormat("#,###", "en_US")
                              .format(order.price) +
                              " đ",
                              style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}