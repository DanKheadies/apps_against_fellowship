enum SfxType {
  card,
  winner,
}

List<String> soundTypeToFilename(SfxType type) => switch (type) {
      SfxType.card => const [
          'card-1.mp3',
          'card-2.mp3',
          'card-3.mp3',
        ],
      SfxType.winner => const [
          'winner.mp3',
        ],
    };

/// Allows control over loudness of different SFX types.
double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.card:
      return 1.0;
    case SfxType.winner:
      return 0.69;
  }
}
