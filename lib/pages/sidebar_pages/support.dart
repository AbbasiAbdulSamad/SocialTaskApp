import 'package:app/ui/bg_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/button.dart';
import '../../ui/ui_helper.dart';

class SupportPage extends StatelessWidget {
   SupportPage({super.key});

  final _formKey = GlobalKey<FormState>();
  TextEditingController subject = TextEditingController();
   TextEditingController describe = TextEditingController();
  String? selectedCategory;


  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    return Scaffold( backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      appBar: AppBar(title: const Text('Support', style: TextStyle(fontSize: 18)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,),
      ),
      body: Text("data"),


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
                                              value: selectedCategory,
                                              items: const [
                                                DropdownMenuItem(value: "General Inquiry", child: Text('General Inquiry')),
                                                DropdownMenuItem(value: "Payments & Subscriptions", child: Text('Payments & Subscriptions')),
                                                DropdownMenuItem(value: "Technical Support", child: Text('Technical Support')),
                                                DropdownMenuItem(value: "Report a Problem / Bug Report", child: Text('Report a Problem / Bug Report')),
                                                DropdownMenuItem(value: "Other", child: Text('Other')),
                                              ],
                                              // Update the int value
                                              onChanged: (newValue) {
                                                selectedCategory = newValue;},
                                              validator: (selectedValue) {
                                                if (selectedValue == null){
                                                  return 'Select Category';}
                                                return null;},
                                            ),
                                            SizedBox(height: 15,),

                                            Ui.input(context, subject, "Subject", "E.g: Payment not going though", TextInputType.text,
                                                  (value) { // input validiter fun
                                                if (value == null || value.isEmpty) {
                                                  return 'Enter the Subject';}
                                                return null;
                                              },),
                                            SizedBox(height: 15,),

                                            Ui.input(context, describe, "Describe your issue", "", TextInputType.multiline,
                                                    (value) { // input validiter fun
                                                  if (value == null || value.isEmpty) {
                                                    return 'Enter the Subject';}
                                                  return null;
                                                }, minL: 6, maxL: 15),
                                            SizedBox(height: 25,),
                                            SizedBox(width: double.infinity,
                                              child: MyButton(txt: 'Send', ico: Icons.send, fontfamily: '3rdRoboto',
                                                bgColor: theme.surfaceDim, shadowOn: true, borderLineOn: true,
                                                borderRadius: 8, txtSize: 17, txtColor: theme.onPrimaryContainer,
                                                onClick: (){
                                                
                                                },
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
