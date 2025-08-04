import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/button.dart';

class BuyTickets extends StatelessWidget {
  BuyTickets({super.key});
  /// List of ticket packages with price, discount, and click actions.
 final List <Map<String, dynamic>> _ticketPrice = [
   {'tickets':'400', 'originalPrice':'1.00', 'discount':'1', 'price':'0.99', 'img':'1xTickets.webp', 'onCLick':(){debugPrint('400 tickets');}},
   {'tickets':'1,000', 'originalPrice':'2.50', 'discount':'2', 'price':'2.45', 'img':'2xTickets.webp', 'onCLick':(){debugPrint('1000 tickets');}},
   {'tickets':'2,000', 'originalPrice':'5.00', 'discount':'5', 'price':'4.75', 'img':'3xTickets.webp', 'onCLick':(){debugPrint('2000 tickets');}},
   {'tickets':'3,000', 'originalPrice':'7.50', 'discount':'10', 'price':'6.75', 'img':'4xTickets.webp', 'onCLick':(){debugPrint('3000 tickets');}},
   {'tickets':'5,000', 'originalPrice':'12.50', 'discount':'15', 'price':'10.63', 'img':'5xTickets.webp', 'onCLick':(){debugPrint('5000 tickets');}},
   {'tickets':'8,000', 'originalPrice':'20.00', 'discount':'20', 'price':'16.00', 'img':'6xTickets.webp', 'onCLick':(){debugPrint('8000 tickets');}},
   {'tickets':'10,000', 'originalPrice':'25.00', 'discount':'25', 'price':'18.75', 'img':'7xTickets.webp', 'onCLick':(){debugPrint('10000 tickets');}},
   {'tickets':'30,000', 'originalPrice':'75.50', 'discount':'30', 'price':'52.50', 'img':'8xTickets.webp', 'onCLick':(){debugPrint('30000 tickets');}},
 ];

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    return Scaffold( backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      appBar: AppBar(title: const Text('Purchase Tickets', style: TextStyle(fontSize: 18)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,),
      ),
      body:SingleChildScrollView(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_ticketPrice.length / 2).ceil(),
          itemBuilder: (context, index) {
            int firstIndex = index * 2;
            int secondIndex = firstIndex + 1;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                SingleChildScrollView( // Horizontal scrolling for the row
                  scrollDirection: Axis.horizontal,
                  child: Row(spacing: 30,
                    children: [
                      /// First ticket box
                      Container(
                        child: _buyTicketBox(
                          context,
                          _ticketPrice[firstIndex]['tickets'],
                          _ticketPrice[firstIndex]['originalPrice'],
                          _ticketPrice[firstIndex]['discount'],
                          _ticketPrice[firstIndex]['price'],
                          _ticketPrice[firstIndex]['img'],
                          _ticketPrice[firstIndex]['onCLick'],
                        ),
                      ),
                      if (secondIndex < _ticketPrice.length) // Check to avoid index error
                      /// Second ticket box if available
                        Container(
                          child: _buyTicketBox(
                            context,
                            _ticketPrice[secondIndex]['tickets'],
                            _ticketPrice[secondIndex]['originalPrice'],
                            _ticketPrice[secondIndex]['discount'],
                            _ticketPrice[secondIndex]['price'],
                            _ticketPrice[secondIndex]['img'],
                            _ticketPrice[secondIndex]['onCLick'],
                          ),
                        )
                      else
                        const SizedBox(width: 160), // Adds a dummy box when no second item
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            );
          },
        ),
      ],
    ),
    ),
    );
  }

  ///🔹Creates a ticket purchase UI with price, discount, and buy button.
  static Widget _buyTicketBox(BuildContext context, String tickets, String originalPrice,
      String discount, String price, String img, VoidCallback onClick,) {
    ColorScheme theme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 150,
      child: Stack(
        children: [
          const SizedBox(width: 140, height: 170),

          //🔹 Background container Transparent
          Positioned(
            top: 30,
            child: Container(
              width: 140,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.yellow.shade200,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.black, width: 1),
                  boxShadow: [BoxShadow(color: theme.onPrimaryFixed, offset: Offset(0, -3), blurRadius: 3, spreadRadius: 3)]
              ),
            ),
          ),

          //🔹 Tickets number background
          Positioned(
            top: 45,
            child: Container(
              width: 140,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                border: Border(left: BorderSide(color: Colors.black, width: 1),
                    bottom: BorderSide(color: Colors.black, width: 1),right: BorderSide(color: Colors.black, width: 1)),
              ),
            ),
          ),

          //🔹 Tickets number text with icon
          Positioned(
            top: 47,
            child: SizedBox(
              width: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payments_outlined, size: 20, color: Colors.black),
                  const SizedBox(width: 5),
                  Text(tickets, style: Theme.of(context).textTheme.labelMedium?.
                  copyWith(fontSize: 22, color: Colors.black,),
                  ),
                ],),
            ),
          ),

          //🔹 Original price
          Positioned(
            top: 87,
            child: SizedBox(
              width: 140,
              height: 20,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow.shade200, Colors.amber, Colors.yellow.shade200],
                  ),
                ),
                child: Text('Price: \$$originalPrice',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16, color: Colors.red,),),
              ),
            ),
          ),

          //🔹Discount text
          Positioned(
            top: 113,
            left: 0,
            right: 0,
            child: Text('Discount $discount%', textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 14, color: Colors.black,),),
          ),

          //🔹Buy Button
          Positioned(
            top: 135,
            child: SizedBox(
              width: 140,
              height: 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: MyButton(
                  ico: Icons.shopping_cart_outlined,
                  txt: 'Buy \$$price',
                  pading: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  bgColor: theme.primaryContainer, borderColor: theme.primaryFixed,
                  borderLineOn: true, borderLineSize: 0.5, txtColor: theme.primaryFixed,
                  borderRadius: 5, icoSize: 16, txtSize: 14, onClick: onClick,
                ),
              ),
            ),
          ),

          //🔹Ticket image
          Positioned(
            top: 0,
            child: SizedBox(
              width: 140,
              child: Align(alignment: Alignment.center,
                child: Image.asset('assets/ico/$img', width: 70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
