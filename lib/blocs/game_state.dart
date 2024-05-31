abstract class GameState {}

class GameInitialState extends GameState {}

class GameLoadingState extends GameState {}

class GameLoadedState extends GameState {
  final List<List<String>> grid;
  final List<List<String>> hiddenTreasures;
  final int playerRow;
  final int playerCol;
  final int currentBalance;
  final int totalBalance;
  final bool isSpecialCharacter;
  final bool isDeviceBroken;

  GameLoadedState({
    required this.grid,
    required this.hiddenTreasures,
    required this.playerRow,
    required this.playerCol,
    required this.currentBalance,
    required this.totalBalance,
    required this.isSpecialCharacter,
    required this.isDeviceBroken,
  });

  GameLoadedState copyWith({
    List<List<String>>? grid,
    List<List<String>>? hiddenTreasures,
    int? playerRow,
    int? playerCol,
    int? currentBalance,
    int? totalBalance,
    bool? isSpecialCharacter,
    bool? isDeviceBroken,
  }) {
    return GameLoadedState(
      grid: grid ?? this.grid,
      hiddenTreasures: hiddenTreasures ?? this.hiddenTreasures,
      playerRow: playerRow ?? this.playerRow,
      playerCol: playerCol ?? this.playerCol,
      currentBalance: currentBalance ?? this.currentBalance,
      totalBalance: totalBalance ?? this.totalBalance,
      isSpecialCharacter: isSpecialCharacter ?? this.isSpecialCharacter,
      isDeviceBroken: isDeviceBroken ?? this.isDeviceBroken,
    );
  }
}
