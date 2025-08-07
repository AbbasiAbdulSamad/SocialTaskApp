import 'package:app/config/config.dart';
import 'package:app/server_model/functions_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../ui/button.dart';

class BuyTickets extends StatefulWidget {
  const BuyTickets({super.key});

  @override
  State<BuyTickets> createState() => _BuyTicketsState();
}

class _BuyTicketsState extends State<BuyTickets> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];

  final List<Map<String, dynamic>> _ticketPrice = [
    {'tickets': '500', 'discount': '1', 'img': '1xTickets.webp', 'id': 'tickets_500'},
    {'tickets': '1,000', 'discount': '2', 'img': '2xTickets.webp', 'id': '1000_tickets'},
    {'tickets': '2,000', 'discount': '5', 'img': '3xTickets.webp', 'id': 'tickets_2000'},
    {'tickets': '3,000', 'discount': '10', 'img': '4xTickets.webp', 'id': 'tickets_3000'},
    {'tickets': '5,000', 'discount': '15', 'img': '5xTickets.webp', 'id': '5000_tickets'},
    {'tickets': '10,000', 'discount': '20', 'img': '6xTickets.webp', 'id': 'tickets_10000'},
    // {'tickets': '25,000', 'discount': '30', 'img': '7xTickets.webp', 'id': 'tickets_25000'},
    // {'tickets': '50,000', 'discount': '50', 'img': '8xTickets.webp', 'id': 'tickets_50000'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    _iap.purchaseStream.listen(_onPurchaseUpdate);
  }

  Future<void> _initializeIAP() async {
    _available = await _iap.isAvailable();
    if (!_available) return;

    final ids = _ticketPrice.map((e) => e['id'].toString()).toSet();
    final response = await _iap.queryProductDetails(ids);

    if (response.error != null) {
      debugPrint("IAP Error: ${response.error}");
      return;
    }

    setState(() {
      _products = response.productDetails;
    });
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    String? userEmail = await Helper.getFirebaseEmail();

    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        try {
          final response = await http.post(
            Uri.parse(ApiPoints.buyTickets),
            body: {
              "productId": purchase.productID,
              "purchaseToken": purchase.verificationData.serverVerificationData,
              "userEmail": userEmail,
            },
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tickets Purchased successfully!")),
            );
            await _iap.completePurchase(purchase); // confirm the purchase
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ Verification failed: ${response.body}")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error: $e")),
          );
        }
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Purchase failed")),
        );
      }
    }
  }



  void _buyProduct(String productId) {
    final product = _products.firstWhere((p) => p.id == productId, orElse: () => throw Exception("Product not found"));
    final param = PurchaseParam(productDetails: product);
    _iap.buyConsumable(purchaseParam: param);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: theme.primaryFixed,
      appBar: AppBar(
        title: const Text('Purchase Tickets', style: TextStyle(fontSize: 18)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: _available
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 50,
            children: _ticketPrice.map((ticket) {
              return _buyTicketBox(context, ticket, _getPrice(ticket['id']));
            }).toList(),
          ),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  String _getPrice(String productId) {
    try {
      return _products.firstWhere((e) => e.id == productId).price;
    } catch (e) {
      return "loading...";
    }
  }


  Widget _buyTicketBox(BuildContext context, Map<String, dynamic> data, String livePrice) {
    ColorScheme theme = Theme.of(context).colorScheme;
    final tickets = data['tickets'];
    final original = data['originalPrice'];
    final discount = data['discount'];
    final img = data['img'];
    final id = data['id'];

    return SizedBox(
      width: 150,
      child: Stack(
        children: [
          const SizedBox(width: 140, height: 170),
          Positioned(
            top: 30,
            child: Container(
              width: 140,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.yellow.shade200,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: [BoxShadow(color: theme.onPrimaryFixed, offset: const Offset(0, 7), blurRadius: 10, spreadRadius: 2)],
              ),
            ),
          ),
          Positioned(
            top: 45,
            child: Container(
              width: 140,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                border: Border(
                  left: BorderSide(color: Colors.black, width: 1),
                  bottom: BorderSide(color: Colors.black, width: 1),
                  right: BorderSide(color: Colors.black, width: 1),
                ),
              ),
            ),
          ),
          Positioned(
            top: 47,
            child: SizedBox(
              width: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payments_outlined, size: 20, color: Colors.black),
                  const SizedBox(width: 5),
                  Text(tickets, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 22, color: Colors.black)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 87,
            child: SizedBox(
              width: 140,
              height: 24,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow.shade200, Colors.amber, Colors.yellow.shade200],
                  ),
                ),
                child: Text('$livePrice', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20, color: Color(0xFF006506))),
              ),
            ),
          ),
          Positioned(
            top: 114,
            left: 0,
            right: 0,
            child: Text('Discount $discount%', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          Positioned(
            top: 135,
            child: SizedBox(
              width: 140,
              height: 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: MyButton(
                  ico: Icons.shopping_cart_outlined,
                  txt: 'Buy Now',
                  pading: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  bgColor: theme.primaryContainer,
                  borderColor: theme.primaryFixed,
                  borderLineOn: true,
                  borderLineSize: 0.5,
                  txtColor: theme.primaryFixed,
                  borderRadius: 5,
                  icoSize: 16,
                  txtSize: 14,
                  onClick: () => _buyProduct(id),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: SizedBox(
              width: 140,
              child: Align(
                alignment: Alignment.center,
                child: Image.asset('assets/ico/$img', width: 70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
