import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Controller with ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  OnAudioQuery query = OnAudioQuery();
  Duration duration = Duration();
  int currentIndex = 0;
  String? currentArtist;
  String? currentSongTitle;
  String? title;
  int? currentId;

  var position;
  SongModel? songModel;

  List<SongModel> songsList = [];

  void getSong() async {
    songsList = await query.querySongs();
    notifyListeners();
  }

  List<SongModel> get songs {
    return [...songsList];
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  Future<List<SongModel>> songQuery() {
    return query.querySongs(
        uriType: UriType.EXTERNAL,
        orderType: OrderType.ASC_OR_SMALLER,
        ignoreCase: true,
        sortType: SongSortType.TITLE);
  }

  SongModel newModel(String artist, String displayName, int id, String title) {
    return SongModel(
        {'_display_name_wo_ext': displayName, "artist": artist, '_id': id, 'title': title});
  }

  playSong() async {
    try {
      player.setAudioSource(createPlaylist(songs));
      player.play();
      notifyListeners();
    } on Exception catch (e) {
      log('Error Found');
    }
  }

  void _updateCurrentPlayingSongDetails(int index) {
    if (songs.isNotEmpty) {
      currentSongTitle = songsList[index].title;
      currentIndex = index;
      currentArtist = songsList[index].artist;
      currentId = songsList[index].id;
      title = songsList[index].title;
    }
    notifyListeners();
  }
}

class DurationState {
  Duration position, total;
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
}
