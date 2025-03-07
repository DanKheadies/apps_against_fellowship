class Song {
  final String filename;
  final String name;
  final String? artist;

  const Song(
    this.filename,
    this.name, {
    this.artist,
  });

  @override
  String toString() => 'Song<$filename>';
}

const Set<Song> songs = {
  // Filenames with whitespace break package:audioplayers on iOS
  // (as of February 2022), so we use no whitespace.
  Song(
    'aaf-ch-celesta.mp3',
    'Concerning Celesta Hobbits',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-chipwave.mp3',
    'Concerning Chipwave Hobbits',
    artist: 'Dan Kheadies',
  ),
};
