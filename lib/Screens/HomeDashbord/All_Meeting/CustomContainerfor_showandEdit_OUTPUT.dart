import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'package:pratilekh/Utils/Utils.dart';

class CustomContainer extends StatelessWidget {
  final Map<String, dynamic>? data;
  final void Function(int, String, String) onMessageChanged;

  CustomContainer({required this.data, required this.onMessageChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
        decoration: BoxDecoration(
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
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Utils.isloading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : data == null
                    ? const Center(child: Text('No records'))
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            if (data!['messages'] != null)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: ListView.builder(
                                  itemCount: data!['messages'].length,
                                  itemBuilder: (context, index) {
                                    final message = data!['messages'][index];
                                    final String audioPathString =
                                        message['audio_path'];
                                    final textController =
                                        TextEditingController(
                                            text: message['text']);

                                    return FutureBuilder<bool>(
                                      future: Future.value(
                                          File(audioPathString).exists()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'),
                                          );
                                        }

                                        if (!snapshot.hasData ||
                                            !snapshot.data!) {
                                          return Container(); // Do not show player if the file does not exist
                                        }

                                        return RepaintBoundary(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  flex: 7,
                                                  child: ListTile(
                                                    dense:
                                                        true, // Reduces vertical space
                                                    title: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 13,
                                                          backgroundColor:
                                                              Colors.green,
                                                          child: Text(
                                                            (index + 1)
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          '${message['speaker']} (${message['start_time']})',
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                17, // Adjust the font size for title
                                                            fontWeight: FontWeight
                                                                .bold, // Add other styling if needed
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: 40.0,
                                                          top: 0.0,
                                                          bottom:
                                                              0.0), // Adjust padding to reduce space
                                                      child: TextFormField(
                                                        controller:
                                                            textController,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide: BorderSide
                                                                .none, // Removes default border
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.grey[200],
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                              width: 2.0,
                                                            ), // Customize underline color when focused
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0,
                                                            ), // Customize underline color when not focused
                                                          ),
                                                        ),
                                                        minLines: 1,
                                                        maxLines: null,
                                                        onChanged: (newValue) {
                                                          onMessageChanged(
                                                              index,
                                                              message[
                                                                  'speaker'],
                                                              newValue);
                                                        },
                                                      ),
                                                    ),
                                                  )),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 25),
                                                  child:
                                                      CustomPlayerForPlayOnly(
                                                    source: audioPathString,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            if (data!['result'] != null)
                              Container(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Text(
                                        '${data!['result'].replaceAll('[', '').replaceAll(']', '')}'),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

class CustomPlayerForPlayOnly extends StatefulWidget {
  final String source;

  CustomPlayerForPlayOnly({required this.source});

  @override
  _CustomPlayerForPlayOnlyState createState() =>
      _CustomPlayerForPlayOnlyState();
}

class _CustomPlayerForPlayOnlyState extends State<CustomPlayerForPlayOnly> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isCompleted = false; // Track if playback is completed

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          isPlaying = false;
          isCompleted = true; // Set completion flag
        } else {
          isCompleted = false;
        }
      });
    });

    // Listen to playback position changes (if available)
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (duration == Duration.zero) {
        setState(() {
          isCompleted = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else if (isCompleted) {
      _audioPlayer.seek(Duration.zero); // Reset to start if completed
      _audioPlayer.play(DeviceFileSource(widget.source)); // Play again
    } else {
      _audioPlayer.play(DeviceFileSource(widget.source));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: _togglePlayPause,
    );
  }
}
