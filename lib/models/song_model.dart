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
    'aaf-ch-agogo.mp3',
    'Concerning Go Dog Go',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-atmosphere.mp3',
    'Concerning Atmosphere',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-bird-tweet.mp3',
    'Concerning Birds',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-brightness.mp3',
    'Concerning Your Brightness',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-celesta.mp3',
    'Concerning Celesta',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-chipwave.mp3',
    'Concerning Chipwave Hobbits',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-choir-soprano.mp3',
    'Concerning The Sopranos',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-crystal.mp3',
    'Concerning Crystal',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-dark-choir.mp3',
    'Concerning DeDarkness',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-dark-strike.mp3',
    'Concerning Dark Strike',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-flute.mp3',
    'Concerning The Classics',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-flutter-pad.mp3',
    'Concerning Flutter',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-goblins.mp3',
    'Concerning Joblins',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-muted-guitar.mp3',
    'Concerning Wayne & Garth',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-new-age-pad.mp3',
    'Concerning the Future',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-oboe.mp3',
    'Concerning Obi',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-ocarina.mp3',
    'Concerning Ocarinas of Time',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-orchestra-hit-2.mp3',
    'Concerning Us All',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-overdrive-guitar.mp3',
    'Concerning Bill & Ted',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-pizzicato-strings.mp3',
    'Concerning King Piccolo',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-violin.mp3',
    'Concerning Violence',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-voice-ooh.mp3',
    'Concerning Voices',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-warm-pad.mp3',
    'Concerning the Fireplace',
    artist: 'Dan Kheadies',
  ),
  Song(
    'aaf-ch-whistle.mp3',
    'Concerning The Thrill',
    artist: 'Dan Kheadies',
  ),
};
