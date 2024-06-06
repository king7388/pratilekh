import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import 'Screens/HomeDashbord/Dashbord_Screen.dart';
import 'Screens/HomeDashbord/Voice_Transcretion_Screen/Live_Transcreption_Page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  List<String> messages = [];
  var responseData;
  @override
  void initState() {
    super.initState();
    fetchDatafirsttime();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      fetchData();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopTimer(); // Cancel the timer when the widget is disposed
    super.dispose();
  }



  Future<void> openMyProgram() async {
    final executablePath = r'C:\Program Files (x86)\Pratilekh\kunal.exe';

    // Check if the process is already running
    final processList = await Process.run('tasklist', []);
    print(processList.stdout);
    if (processList.stdout.toString().contains('kunal.exe')) {
      print('My Program is already running');
      return;
    }else{
      try {
        await Process.run(executablePath, []);
        print('My Program launched successfully.');
      } catch (e) {
        print('Error launching My Program: $e');
      }
    }
  }


  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/backend_started'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (!mounted) return; // Check if the widget is still mounted

        setState(() {
          responseData = data['message'];
        });

        if (responseData == 'True') {
          // _isLoading=false;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashBoard_Screen()));
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchDatafirsttime() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/backend_started'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (!mounted) return; // Check if the widget is still mounted

        setState(() {
          responseData = data['message'];
        });

        if (responseData == 'True') {
          // _isLoading=false;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashBoard_Screen()));
        }
      } else {
        // openMyProgram();
        // _startTimer();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      openMyProgram();
      _startTimer();
      print('Error: $e');
    }
  }

  Future<void> Apiforcloseexe() async {
    var request = http.Request('POST', Uri.parse('http://127.0.0.1:5000/shutdown?secret=1234'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      openMyProgram();
      _startTimer();
      print(await response.stream.bytesToString());
    }
    else {
      openMyProgram();
      _startTimer();
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body:Center(
        child: LoadingAnimationWidget.flickr(
            leftDotColor: Colors.red,
            rightDotColor: Colors.blue,
            size: 80),
      )
      //
      // Center(
      //   child: Image.asset(
      //     'assets/images/img.png', // Replace with the path to your animation file
      //     alignment: Alignment.center,
      //     fit: BoxFit.contain,
      //     //animation: 'splash', // Replace with the animation name
      //   ),
      // ),
    );
  }
}
