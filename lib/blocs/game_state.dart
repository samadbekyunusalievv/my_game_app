import 'package:equatable/equatable.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object> get props => [];
}

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

  const GameLoadedState({
    required this.grid,
    required this.hiddenTreasures,
    required this.playerRow,
    required this.playerCol,
    required this.currentBalance,
    required this.totalBalance,
    required this.isSpecialCharacter,
    required this.isDeviceBroken,
  });

  @override
  List<Object> get props => [
    grid,
    hiddenTreasures,
    playerRow,
    playerCol,
    currentBalance,
    totalBalance,
    isSpecialCharacter,
    isDeviceBroken,
  ];
}
