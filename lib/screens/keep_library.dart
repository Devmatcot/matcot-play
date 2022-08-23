import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_app/screens/now_playing.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:volume_controller/volume_controller.dart';

import '../constants.dart';
import '../widget/song_tile.dart';
import 'controller.dart';

class KeepLibrary extends StatefulWidget {
  @override
  State<KeepLibrary> createState() => _KeepLibraryState();
}

class _KeepLibraryState extends State<KeepLibrary> {
  //Now we will create a template for Song List

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    requestPermision();
    getSong();
    player.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
    VolumeController().getVolume().then((volume) => volumeValue = volume);
    VolumeController().listener((value) => value = volumeValue);
  }

  void requestPermision() async {
    Permission.storage.request();
    bool permissionStatus = await query.permissionsStatus();
    if (!permissionStatus) {
      await query.permissionsRequest();
    }
    setState(() {});
  }

  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songsLists[index].title;
        currentIndex = index;
        currentArtist = songsLists[index].artist;
        currentId = songsLists[index].id;
        title = songsLists[index].title;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  List<SongModel> songsLists = [];

  void getSong() async {
    List<SongModel> songsList = await query.querySongs();
    setState(() {
      songsLists = songsList;
    });
  }

  void _changePlayerViewVisibility() {
    setState(() {
      isPlayerViewVisible = !isPlayerViewVisible;
    });
  }

  void changeToseconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    player.seek(duration);
  }

  AudioPlayer player = AudioPlayer();
  OnAudioQuery query = OnAudioQuery();
  bool showFloat = false;
  String? title;
  String? currentArtist;
  int? currentId;
  bool isPlaying = true;
  int currentIndex = 0;
  String? currentSongTitle;
  bool isPlayerViewVisible = false;
  double sliderValue = 0.0;
  double volumeValue = 0.0;

  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: song.id.toString(),
          // Metadata to display in the notification:
          // album: song.album,
          title: song.title,
          artist: song.artist,
          artUri: Uri.parse(song.uri!),
        ),
      ));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          player.positionStream,
          player.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Controller>(context);
    if (isPlayerViewVisible) {
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
                  onTap: _changePlayerViewVisibility,
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
                    future: query.queryArtwork(currentId!, ArtworkType.AUDIO),
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
                                    height: 90, width: 90),
                                // Text('Matcot Play', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      }
                      return Container(
                        height: 40,
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 30),
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
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    // alignment: Alignment.center,
                    child: Text(
                      currentSongTitle!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: cblue),
                    ),
                  ),
                  Text(
                    currentArtist!,
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
                            if (player.hasPrevious) {
                              player.seekToPrevious();
                            }
                          },
                          child: cbutton(previous)),
                      GestureDetector(
                          onTap: () {
                            if (player.playing) {
                              player.pause();
                            } else {
                              if (player.currentIndex != null) {
                                player.play();
                              }
                            }
                          },
                          child: StreamBuilder<bool>(
                            stream: player.playingStream,
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
                            if (player.hasNext) {
                              player.seekToNext();
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
                        final progress =
                            durationState?.position ?? Duration.zero;
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
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 20),
                                      trackHeight: 1),
                                  child: Slider(
                                      activeColor: cblue,
                                      onChanged: ((value) {
                                        volumeValue = value;
                                        VolumeController()
                                            .setVolume(volumeValue);
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
    }
    // Library Scaffold
    return Scaffold(
      backgroundColor: cwhite,
      body: SafeArea(
        // top: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 18.0, bottom: 8),
              child: Text(
                'LIBRARY',
                style: TextStyle(
                    letterSpacing: 2,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: cblue),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(10, 45, 10, 10),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(scard), fit: BoxFit.fitHeight),
                ),
                child: FutureBuilder<List<SongModel>>(
                    future: query.querySongs(
                      orderType: OrderType.ASC_OR_SMALLER,
                      uriType: UriType.EXTERNAL,
                      ignoreCase: true,
                    ),
                    builder: (_, item) {
                      if (item.data == null) {
                        return const Center(
                          child: CircularProgressIndicator(color: cblue),
                        );
                      }
                      if (item.data!.isEmpty) {
                        return Center(
                          child: Center(
                            child: TextButton(
                              child: const Text(
                                'Click To Refresh It',
                                style: TextStyle(fontSize: 25, color: cblue),
                              ),
                              onPressed: () {
                                //  RefreshIndicator(child: child, onRefresh: onRefresh)
                                Navigator.pushReplacementNamed(context, '/');
                              },
                            ),
                          ),
                        );
                      }
                      songsLists.clear();
                      songsLists = item.data!;
                      return ListView.builder(
                          itemCount: songsLists.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, index) {
                            final data = item.data![index];
                            return SongTile(
                              no: index + 1,
                              img: QueryArtworkWidget(
                                  id: songsLists[index].id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Container(
                                      height: 50,
                                      width: 50,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle, color: cblue),
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                      ))),
                              title: data.title,
                              artist: data.artist,
                              pressed: () async {
                                try {
                                  setState(() {
                                    showFloat = true;
                                  });
                                  // _changePlayerViewVisibility();

                                  await player.setAudioSource(
                                    createPlaylist(item.data!),
                                    initialIndex: index,
                                  );
                                  await player.play();
                                  title = data.title;
                                  currentArtist = data.artist!;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => NowPlaying(
                                          player: player,
                                          songModel: provider.newModel(
                                              currentArtist!,
                                              title!,
                                              currentId!,
                                              currentSongTitle!),
                                          update: () {
                                            player.currentIndexStream
                                                .listen((index) {
                                              if (index != null) {
                                                _updateCurrentPlayingSongDetails(
                                                    index);
                                              }
                                            });
                                          }),
                                    ),
                                  );
                                } catch (e) {
                                  print(e);
                                }
                              },
                            );
                          });
                    }),
              ),
            ),
            if (showFloat)
              GestureDetector(
                // onTap: _changePlayerViewVisibility,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NowPlaying(
                          player: player,
                          songModel: provider.newModel(currentArtist!, title!,
                              currentId!, currentSongTitle!),
                          update: () {
                            player.currentIndexStream.listen((index) {
                              if (index != null) {
                                _updateCurrentPlayingSongDetails(index);
                              }
                            });
                          }),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: cblue,
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            FutureBuilder<Uint8List?>(
                                future: query.queryArtwork(
                                    currentId!, ArtworkType.AUDIO),
                                builder: (_, snap) {
                                  if (snap.data == null) {
                                    return Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.blueGrey),
                                      child: const Center(
                                          child: Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        // size: 30,
                                      )),
                                    );
                                  }
                                  return Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.blueGrey,
                                        border: Border.all(color: cwhite),
                                        image: DecorationImage(
                                            image: MemoryImage(snap.data!),
                                            fit: BoxFit.cover)),
                                  );
                                }),
                            const SizedBox(
                              width: 15,
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSongTitle!,
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    currentArtist!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: (() {
                          if (player.playing) {
                            player.pause();
                          } else {
                            player.play();
                          }
                        }),
                        child: StreamBuilder<bool>(
                          stream: player.playingStream,
                          builder: (context, snapshot) {
                            bool? playingState = snapshot.data;
                            if (playingState != null && playingState) {
                              return const ControllButton(
                                  icon: Icons.pause_circle_rounded);
                            }
                            return const ControllButton(
                                icon: Icons.play_circle_rounded);
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class ControllButton extends StatelessWidget {
  final IconData icon;
  const ControllButton({
    Key? key,
    required this.icon,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: Colors.white,
      size: 40,
    );
  }
}

//duration class
class DurationState {
  Duration position, total;
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
}
