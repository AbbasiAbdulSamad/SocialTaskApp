import 'package:app/ui/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../server_model/internet_provider.dart';
import '../../server_model/provider/support_APIs.dart';
import '../../ui/button.dart';
import '../../ui/pop_alert.dart';
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
    loadTickets().then((_){
      if (mounted && tickets.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _supportFormOpen();
        });
      }
    });
  }

  String formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal(); // local timezone
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return isoString;
    }
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
       await loadTickets();
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
  void dispose() {
    _subjectController.clear();
    _messageController.clear();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final internetProvider = context.watch<InternetProvider>();
    final isConnected = internetProvider.isConnected;
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    User? user = _auth.currentUser;

    // 🟢 CASE 1: Still loading tickets
    if (tickets.isEmpty && _isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Ui.loading(context),
      );
    }

    // 🔴 CASE 2: No internet connection
    if (!isConnected) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Center(
          child: Ui.buildNoInternetUI(
            theme,
            textTheme,
            false,
            'No Internet Connection',
            'We’re having trouble connecting right now.\nPlease check your network and try again.',
            Icons.wifi_off,
                () async {
              setState(() => _isLoading = true);
              await loadTickets(); // Retry loading tickets
            },
          ),
        ),
      );
    }

    // 🟡 CASE 3: No tickets available (but connected)
    if (tickets.isEmpty && !_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Center(child: _addSupportButton()),
      );
    }

    // 🟢 CASE 4: Normal loaded state
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      appBar: AppBar(
        title: const Text('Support'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: RefreshIndicator(
        color: theme.onPrimaryContainer,
        onRefresh: () async => await loadTickets(),
        child: ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
          final support = tickets[index];
          return Column(children: [
            SizedBox(height: 25,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 50,),
                      Expanded(
                      child: Container(
                        margin:const EdgeInsets.only(right: 5, top: 28),
                        decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius:const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12))
                      )
                        ,child: Column(
                          children: [
                            Container(
                              padding:const EdgeInsets.only(top: 5, bottom: 1, left: 15, right: 5),
                              decoration: BoxDecoration(
                                  color: theme.surfaceTint,
                                  borderRadius:const BorderRadius.only(topLeft: Radius.circular(12),)
                              ),
                              width: double.infinity,
                              child: Text("${support["subject"] ?? ""}", style: textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 16),
                                maxLines: 1, overflow: TextOverflow.ellipsis,),),
                            Container(
                              padding: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                border:const Border(bottom: BorderSide(color: Colors.black, width: 1))
                              ),
                              child: Text("${support["category"] ?? ""}", textAlign: TextAlign.center, style: textTheme.labelSmall?.
                              copyWith(color: Color(0xFF8B0E16), fontSize: 14),),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                              child: Align(alignment: Alignment.centerLeft, child: Text("${support["message"] ?? ""}", style: textTheme.displaySmall?.copyWith(color: Colors.black),)),
                            ),

                            Container(
                              padding:const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                  borderRadius:const BorderRadius.only( bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12))
                              ),
                              width: double.infinity,
                              child: Row( spacing: 5,
                                children: [
                                  Icon(support["status"]=="Processing"?Icons.support_agent:Icons.done_outline, color: support["status"]=="Processing"?
                                  Colors.red:Color(0xFF006506), size: 18,),
                                  Text(support["status"], style: TextStyle(color: support["status"]=="Processing"?
                                  Colors.red:Color(0xFF006506), fontSize: 12, fontWeight: FontWeight.bold),),
                                  const Expanded(child: SizedBox()),
                                  Text(formatDate(support["createdAt"]), style: textTheme.displaySmall?.copyWith(color: Colors.black, fontSize: 12),),
                                  const SizedBox(width: 10,),
                                  InkWell(child: const Icon(Icons.delete, size: 18, color: Colors.black,),
                                  onTap: (){
                                    if (internetProvider.isConnected) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return pop.backAlert(
                                            context: context,
                                            icon: Icons.delete,
                                            title: 'Confirm Delete',
                                            bodyTxt: 'Are you sure you want to delete this support request?',
                                            confirm: 'Delete',
                                            onConfirm: () async {
                                              // 🧾 Call delete API
                                              final result = await SupportService.deleteTicket(support['_id']);
                                              // 🔐 Close dialog
                                              Navigator.pop(context);
                                              // 🧠 Check result and show feedback
                                              if (result['success'] == true) {
                                                AlertMessage.snackMsg(context: context, message: 'Support ticket deleted successfully', time: 3,);

                                                // 🔄 Optional: refresh list (if function exists)
                                                if (mounted && tickets != null) {await loadTickets();}
                                              } else {
                                                AlertMessage.snackMsg(
                                                  context: context, message: result['error'] ?? 'Failed to delete ticket', time: 3,);
                                              }
                                            },
                                          );
                                        },
                                      );
                                    } else {
                                      AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3,);
                                    }

                                  },)
                                ],
                              ),),
                          ],
                        ),
                      ),
                    ),
                  ],),

                  // User Profile
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: theme.onPrimaryContainer, width: 1.0),),
                      child: ClipOval(
                        child: user?.photoURL != null
                            ? Ui.networkImage(context, user!.photoURL!, 'assets/ico/user_profile.webp', 40, 40)
                            : Image.asset('assets/ico/user_profile.webp'),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            // Replay Admin
            (support['adminReply']=="")? SizedBox()
             : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          margin:const EdgeInsets.only(left: 2, top: 7),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              borderRadius:const BorderRadius.only(bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12), topLeft: Radius.circular(10))
                          )
                          ,child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                              child: Align(alignment: Alignment.centerLeft, child: Text("           ${support["adminReply"] ?? ""}", style: textTheme.displaySmall?.copyWith(color: Colors.black),)),
                            ),

                            Container(
                              padding:const EdgeInsets.symmetric(vertical: 1, horizontal: 25),
                              decoration: BoxDecoration(
                                  color: theme.surfaceTint,
                                  borderRadius:const BorderRadius.only( bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12))
                              ),
                              width: double.infinity,
                              child: Text(support["replyAt"], textAlign: TextAlign.start, style: textTheme.displaySmall?.copyWith(color: Colors.white, fontSize: 10),)),
                          ],
                        ),
                        ),
                      ),
                      const SizedBox(width: 50,),
                    ],),

                  // User Profile
                  Positioned(
                    left: 0, top: 0,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: theme.onPrimaryContainer, width: 1.0),),
                      child: ClipOval(
                        child: Image.asset('assets/ico/support.webp'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            if(tickets.length>1)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 5, color: theme.shadow),),
                boxShadow: [BoxShadow(
                  blurRadius: 10, spreadRadius: 3, color: theme.shadow, offset: Offset(0, 10)
                )]
              ),
            )

          ],);
        },
      ),
      ),

      // 🟢 Bottom Navigation Button
        bottomNavigationBar: (tickets.isNotEmpty)? Container(color: theme.primaryFixed,
        child: _addSupportButton()
      ):const SizedBox(),
    );
  }



  Widget _addSupportButton(){
    ColorScheme theme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 40, left: 60, right: 60),
      child: MyButton(
        txt: 'Add Support Request',
        onClick: _supportFormOpen,
        ico: Icons.add,
        icoSize: 23,
        txtSpace: 10,
        shadowOn: true,
        shadowColor: theme.primaryFixed,
        borderLineOn: true,
        borderColor: theme.secondary,
        borderLineSize: 1,
        txtColor: theme.onPrimaryContainer,
        borderRadius: 20,
        bgColor: theme.surfaceDim,
      ),
    );
  }


  _supportFormOpen(){
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    ColorScheme theme = Theme.of(context).colorScheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 👈 important (for full-screen)
      backgroundColor: theme.primaryFixed,
      shape: const RoundedRectangleBorder(
        borderRadius:const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
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
                    borderRadius:const BorderRadius.vertical(top: Radius.circular(20)),
                    color: theme.secondaryContainer,
                    boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2),),],),
                  child: Row(spacing: 8,
                    children: [
                      const Icon(Icons.support_agent, color: Colors.white, size: 28,),
                      Text('Create Support Request', style: Theme.of(context).textTheme.labelMedium?.
                      copyWith(color: Colors.white, fontSize: 22),),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                    child: Column(
                      children: [
                        Text("Your request matters to us! Our support team is dedicated to resolving your issue quickly — expect a response within 24 hours.",
                          style: Theme.of(context).textTheme.displaySmall,),
                        const SizedBox(height: 30,),
                        Expanded(
                          child: SingleChildScrollView(
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
                                    DropdownMenuItem(value: "Technical Support", child: Text('Technical Support')),
                                    DropdownMenuItem(value: "Payments & Subscriptions", child: Text('Payments & Subscriptions')),
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
                                const SizedBox(height: 15,),

                                Ui.input(context, _subjectController, "Subject", "E.g: Payment not going though", TextInputType.text,
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please write subject';
                                        } else if (value.length < 10) {
                                          return 'Explain the full subject';
                                        } else if (value.length > 100) {
                                          return 'Long subject are not allowed.';
                                        }
                                        return null;
                                      },),
                                const SizedBox(height: 15,),

                                Ui.input(context, _messageController, "Describe your issue", "", TextInputType.multiline,
                                        (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Describe your issue';
                                          } else if (value.length < 20) {
                                            return 'Explain more...';
                                          } else if (value.length > 1000) {
                                            return 'Maximum Characters Allowed 1000/${value.length}';
                                          }
                                          return null;
                                        }, minL: 3, maxL: 10),
                                const SizedBox(height: 25,),
                                SizedBox(width: double.infinity,
                                  child:  _isLoading
                                      ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimaryContainer,)
                                      :MyButton(txt: 'Send', ico: Icons.send, fontfamily: '3rdRoboto',
                                    bgColor: theme.surfaceDim, shadowOn: true, borderLineOn: true,
                                    borderRadius: 8, txtSize: 17, txtColor: theme.onPrimaryContainer,
                                    onClick: (){
                                      if (internetProvider.isConnected){
                                        _sendTicket();
                                      }else {
                                        Navigator.pop(context);
                                        AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3,);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 100,)
                              ],
                              ),
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}