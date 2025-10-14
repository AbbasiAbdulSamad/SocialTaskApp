import 'package:app/ui/bg_box.dart';
import 'package:app/ui/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../server_model/provider/support_APIs.dart';
import '../../ui/button.dart';
import '../../ui/ui_helper.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List tickets = [];
  String? _selectedCategory;
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    final result = await SupportService.getUserTickets();
    if (result["success"] == true) {
      setState(() {
        tickets = result["tickets"];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["error"] ?? "Failed to load tickets")),
      );
    }
  }


   Future<void> _sendTicket() async {
     if (!_formKey.currentState!.validate()) return;
     setState(() => _isLoading = true);
     final response = await SupportService.createTicket(
       category: _selectedCategory.toString(),
       subject: _subjectController.text.trim(),
       message: _messageController.text.trim(),
     );

     setState(() => _isLoading = false);
     if (response["success"]) {
       Navigator.pop(context);
       AlertMessage.snackMsg(context: context, message: "Support Request sent successfully", time: 5);
       _subjectController.clear();
       _messageController.clear();
     } else {
       debugPrint(response["error"]);
       Navigator.pop(context);
       AlertMessage.errorMsg(context, "${response["error"]}", "Opps !");
     }
   }

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    User? user = _auth.currentUser;

    return Scaffold( backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      appBar: AppBar(title: const Text('Support', style: TextStyle(fontSize: 18)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,),
      ),
      body: _isLoading
          ? Ui.loading(context)
          : tickets.isEmpty
          ? const Center(child: Text("No tickets found"))
          : ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final t = tickets[index];
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Stack(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 50,),
                      Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 25, top: 20),
                        decoration: BoxDecoration(
                        color: Colors.orange.shade200,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))
                      )
                        ,child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),)
                              ),
                              width: double.infinity,
                              child: Text("data"),),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                              child: Text("${t["message"] ?? "-"}", style: TextStyle(color: Colors.black),),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: theme.primaryContainer,
                                  borderRadius: BorderRadius.only( bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15))
                              ),
                              width: double.infinity,
                              child: Text("data"),),
                          ],
                        ),
                      ),
                    ),
                  ],),

                  // User Profile
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: theme.onPrimaryContainer, width: 1.0),),
                      child: ClipOval(
                        child: user?.photoURL != null
                            ? Ui.networkImage(context, user!.photoURL!, 'assets/ico/user_profile.webp', 30, 30)
                            : Image.asset('assets/ico/user_profile.webp'),
                      ),
                    ),
                  ),
                ],
              ),
            )

          ],);
        },
      ),


      // 🟢 Bottom Navigation Button
      bottomNavigationBar: Container(color: theme.primaryFixed,
        child: Container(
          margin: const EdgeInsets.only(bottom: 40, left: 60, right: 60),
          child: MyButton(
            txt: 'Add Support Request',
            onClick: () {

              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // 👈 important (for full-screen)
                backgroundColor: theme.primaryFixed,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return DraggableScrollableSheet(
                    expand: false, // 👈 allows dragging to close
                    initialChildSize: 0.9, // 👈 default height (0.0 - 1.0)
                    minChildSize: 0.4,     // 👈 minimum drag height
                    maxChildSize: 1.0,     // 👈 full screen height
                    builder: (context, scrollController) {
                      return Column(
                        children: [
                      Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      color: theme.secondaryContainer,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2),),],),
                      child: Row(spacing: 8,
                        children: [
                          Icon(Icons.support_agent, color: Colors.white, size: 28,),
                          Text('Create Support Request', style: Theme.of(context).textTheme.labelMedium?.
                            copyWith(color: Colors.white, fontSize: 22),),
                        ],
                      ),
                      ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                            child: Column(
                                  children: [
                                    Text("Your request matters to us! Our support team is dedicated to resolving your issue quickly — expect a response within 24 hours.",
                                      style: Theme.of(context).textTheme.displaySmall,),
                                    SizedBox(height: 30,),
                                    SingleChildScrollView(
                                        controller: scrollController,
                                        child: Form(
                                          key: _formKey,
                                          child: Column(children: [
                                            DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.errorContainer, width: 1)),
                                                border: OutlineInputBorder(borderSide: BorderSide(color: theme.onPrimaryFixed, width: 0.5),
                                                    borderRadius: BorderRadius.circular(8)),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                              ),
                                              hint: Text('Select Category', style: TextStyle(color: theme.onPrimaryContainer),),
                                              value: _selectedCategory,
                                              items: const [
                                                DropdownMenuItem(value: "General Inquiry", child: Text('General Inquiry')),
                                                DropdownMenuItem(value: "Payments & Subscriptions", child: Text('Payments & Subscriptions')),
                                                DropdownMenuItem(value: "Technical Support", child: Text('Technical Support')),
                                                DropdownMenuItem(value: "Report a Problem / Bug Report", child: Text('Report a Problem / Bug Report')),
                                                DropdownMenuItem(value: "Other", child: Text('Other')),
                                              ],
                                              // Update the int value
                                              onChanged: (newValue) {
                                                _selectedCategory = newValue;},
                                              validator: (selectedValue) {
                                                if (selectedValue == null){
                                                  return 'Select Category';}
                                                return null;},
                                            ),
                                            SizedBox(height: 15,),

                                            Ui.input(context, _subjectController, "Subject", "E.g: Payment not going though", TextInputType.text,
                                                  (value) { // input validiter fun
                                                if (value == null || value.isEmpty) {
                                                  return 'Enter the Subject';}
                                                return null;
                                              },),
                                            SizedBox(height: 15,),

                                            Ui.input(context, _messageController, "Describe your issue", "", TextInputType.multiline,
                                                    (value) { // input validiter fun
                                                  if (value == null || value.isEmpty) {
                                                    return 'Enter the Subject';}
                                                  return null;
                                                }, minL: 6, maxL: 15),
                                            SizedBox(height: 25,),
                                            SizedBox(width: double.infinity,
                                              child:  _isLoading
                                                  ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimaryContainer,)
                                                  :MyButton(txt: 'Send', ico: Icons.send, fontfamily: '3rdRoboto',
                                                bgColor: theme.surfaceDim, shadowOn: true, borderLineOn: true,
                                                borderRadius: 8, txtSize: 17, txtColor: theme.onPrimaryContainer,
                                                onClick: _sendTicket,
                                              ),
                                            ),
                                          ],
                                          ),
                                        )
                                    ),

                                  ],
                                ),
                          )
                        ],
                      );
                    },
                  );
                },
              );

            },
            ico: Icons.add,
            icoSize: 23,
            txtSpace: 10,
            shadowColor: theme.onPrimaryContainer,
            borderLineOn: true,
            borderColor: theme.secondary,
            borderLineSize: 1,
            txtColor: theme.onPrimaryContainer,
            borderRadius: 20,
            bgColor: theme.surfaceDim,
          ),
        ),
      ),
    );
  }
}
