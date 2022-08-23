import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:volume_controller/volume_controller.dart';
import '../constants.dart';
import 'controller.dart';

class NowPlaying extends StatefulWidget {
  final AudioPlayer player;
  final SongModel songModel;
  final Function update;
  const NowPlaying({
    Key? key,
    required this.player,
    required this.songModel,
    required this.update
  }) : super(key: key);

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  double sliderValue = 0.0;
  double volumeValue = 0.0;
  String? currentArtist;
  int? currentId;
  String? currentSongTitle;
  OnAudioQuery query = OnAudioQuery();
  void changeToseconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.player.seek(duration);
  }

  @override
  void initState() {
    VolumeController().getVolume().then((volume) => volumeValue = volume);
    VolumeController().listener((value) => value = volumeValue);
    widget.update;
    super.initState();
  }
   Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          widget.player.positionStream,
          widget.player.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));
      

  @override
  Widget build(BuildContext context) {
      final provider = Provider.of<Controller>(context);
      currentId = provider.currentId;
      currentSongTitle = provider.currentSongTitle;
      currentArtist = provider.currentArtist;
    return Scaffold(
      backgroundColor: cwhite,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          //Now we will create Navigation Buttons
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                child: cbutton(back),
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
              Spacer(flex: 1),
              const Text(
                'NOW PLAYING',
                style: TextStyle(
                    color: cblue, fontSize: 17, fontWeight: FontWeight.w400),
              ),
              Spacer(flex: 2),
            ],
          ),
          // Spacer(),
          Expanded(
              child: FutureBuilder<Uint8List?>(
                  future: query.queryArtwork(widget.songModel.id, ArtworkType.AUDIO),
                  builder: (_, snap) {
                    if (snap.data == null) {
                      return Container(
                        height: 40,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: cblue,
                          boxShadow: const [
                            BoxShadow(
                                blurRadius: 6,
                                offset: Offset(0, 2),
                                color: Colors.black26)
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/logow.png',
                                  height: 150, width: 150),
                              const Text('Matcot Play',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container(
                      height: 40,
                      width: double.infinity,
                      margin:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blueGrey,
                          boxShadow: const [
                            BoxShadow(
                                blurRadius: 6,
                                offset: Offset(0, 2),
                                color: Colors.black26)
                          ],
                          image: DecorationImage(
                              image: MemoryImage(snap.data!),
                              fit: BoxFit.cover)),
                    );
                  })),

          ///[2nd expanded widget]
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  // alignment: Alignment.center,
                  child: Text(
                    widget.songModel.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: cblue),
                  ),
                ),
                Text(
                  widget.songModel.artist!,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w300),
                ),
                //stream builder i.e positon
                StreamBuilder<DurationState>(
                  stream: _durationStateStream,
                  builder: (_, snapshot) {
                    final durationState = snapshot.data;
                    final progress = durationState?.position ?? Duration.zero;
                    final total = durationState?.total ?? Duration.zero;
                    return Slider(
                        min: Duration.zero.inSeconds.toDouble(),
                        max: total.inSeconds.toDouble(),
                        value: progress.inSeconds.toDouble(),
                        activeColor: Color.fromARGB(255, 6, 80, 141),
                        thumbColor: cblue,
                        inactiveColor: cblue.withOpacity(0.3),
                        onChanged: (value) {
                          setState(() {
                            changeToseconds(value.toInt());
                            value = value;
                          });
                        });
                  },
                ),
                //Now we will create Music Controller Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //The buttons are called passing its above symbol
                    GestureDetector(
                        onTap: () {
                          if (widget.player.hasPrevious) {
                            widget.player.seekToPrevious();
                          }
                        },
                        child: cbutton(previous)),
                    GestureDetector(
                        onTap: () {
                          if (widget.player.playing) {
                            widget.player.pause();
                          } else {
                            if (widget.player.currentIndex != null) {
                              widget.player.play();
                            }
                          }
                        },
                        child: StreamBuilder<bool>(
                          stream: widget.player.playingStream,
                          builder: (_, snapshot) {
                            bool? playingState = snapshot.data;
                            if (playingState != null && playingState) {
                              return playButton(pause);
                            }
                            return playButton(play);
                          },
                        )),
                    GestureDetector(
                        onTap: () {
                          if (widget.player.hasNext) {
                            widget.player.seekToNext();
                          }
                        },
                        child: cbutton(next)),
                  ],
                ),
                //Time Stamp
                StreamBuilder<DurationState>(
                    stream: _durationStateStream,
                    builder: (_, snapshot) {
                      final durationState = snapshot.data;
                      final progress = durationState?.position ?? Duration.zero;
                      final total = durationState?.total ?? Duration.zero;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            progress.toString().split('.').first,
                            style: const TextStyle(
                                color: cblue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Container(
                              height: 15,
                              width: 3,
                              color: cblue,
                            ),
                          ),
                          Text(
                            total.toString().split('.').first,
                            style: TextStyle(
                                color: cblue.withAlpha(100),
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          //volume controller
                        ],
                      );
                    }),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(
                              Icons.volume_down,
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 5),
                                    overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 20),
                                    trackHeight: 1),
                                child: Slider(
                                    activeColor: cblue,
                                    onChanged: ((value) {
                                      volumeValue = value;
                                      VolumeController().setVolume(volumeValue);
                                      setState(() {});
                                    }),
                                    value: volumeValue),
                              ),
                            ),
                            Icon(Icons.volume_up),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Spacer()
        ],
      ),
    );
    ;
  }
}
