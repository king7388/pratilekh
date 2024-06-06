import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Screens/HomeDashbord/Voice_Transcretion_Screen/Live_Transcreption_Page.dart';
import 'Contants.dart';
import 'Utils.dart';

class UI_Componenet {
  static Widget Costom_Container_output(
      BuildContext context, Map<String, dynamic>? Data) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the container
          borderRadius: BorderRadius.circular(
              10), // Optional: Add border radius to the container
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 5, // Spread radius
              blurRadius: 10, // Blur radius
              offset: const Offset(0, 2), // Offset in the y-axis
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Utils.isloading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : Data != null
                ? SingleChildScrollView(
              child: Column(
                children: [
                  if (Data['messages'] != null)
                    SizedBox(
                      height:
                      MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        itemCount: Data['messages'].length,
                        itemBuilder: (context, index) {
                          final message = Data['messages'][index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            ),
                            title: Text(
                              '${message['speaker']} (${message['time']})',
                              style: const TextStyle(
                                fontSize:
                                16, // Adjust the font size for title
                                fontWeight: FontWeight
                                    .bold, // Add other styling if needed
                              ),
                            ),
                            subtitle: Text(
                              message['text']!,
                              style: const TextStyle(
                                fontSize:
                                14, // Adjust the font size for subtitle
                                // Add other styling if needed
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (Data['result'] != null)
                    Container(
                      child: Center(
                          child: SingleChildScrollView(
                              child: Text('${Data['result'].replaceAll('[', '').replaceAll(']', '')}'))),
                    )
                ],
              ),
            )
                : const Center(
              child: Text('No records'),
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Select CheckBox'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showAudio(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Select Audio file'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void scrollToBottom(ScrollController controller) {
    print("Scrolling to bottom");
    if (controller.hasClients) {
      print("Controller has clients");
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      print("Controller has no clients");
    }
  }

  static Widget Costom_Webshocekt_Ui(BuildContext context, String? text) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the container
          borderRadius: BorderRadius.circular(
              10), // Optional: Add border radius to the container
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 5, // Spread radius
              blurRadius: 10, // Blur radius
              offset: const Offset(0, 2), // Offset in the y-axis
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Utils.isloading
                ? const Center(
                    child: Text(
                      'Model is Loading please wait...',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat-Regular"),
                    ),
                  )
                : text != null
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            if (text != null)
                              Container(
                                child: Center(
                                    child: SingleChildScrollView(
                                        child: Text(text))),
                              ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text('No records'),
                      ),
          ),
        ),
      ),
    );
  }

  static void Showloading(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 50,
              ),
              Text(message),
            ],
          ),
        );
      },
    );
  }
  static void Showloadingpop(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Row(
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
              SizedBox(
                width: 40,
              ),
              Text('Loading'),
            ],
          ),
        );
      },
    );
  }

}

BoxDecoration containerDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 5,
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ],
);
BoxDecoration containerDecorationgrayoutline = BoxDecoration(
  borderRadius: BorderRadius.circular(10),
  border: Border.all(color: Colors.grey.withOpacity(0.5)), // Outline border
);
class SnackBarHelper {
  static void showFailedInsertionSnackbar(BuildContext context,String message) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
// class Custom_TextFormFields {
//   static Widget CustomTextFormField(
//       BuildContext context,
//       TextEditingController controller,
//       String text,
//       bool toHide,
//       String? labelText) {
//     return Container(
//       decoration: containerDecorationgrayoutline,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: TextFormField(
//           controller: controller,
//           obscureText: toHide,
//           decoration: const InputDecoration(
//             border:
//                 InputBorder.none, // Remove underline border from TextFormField
//           ),
//         ),
//       ),
//     );
//   }
//
//   static bool tohode = true; // Declare outside the method to preserve its value
// }
