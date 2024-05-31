import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_events.dart';
import 'game_state.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameInitialState()) {
    on<InitializeGameEvent>(_onInitializeGame);
    on<MovePlayerEvent>(_onMovePlayer);
    on<UpdateBalanceEvent>(_onUpdateBalance);
    on<UpdateTotalBalanceEvent>(_onUpdateTotalBalance);
    on<UpdateDeviceStatusEvent>(_onUpdateDeviceStatus);
    on<ResetGameEvent>(_onResetGame);
  }
  int? previousRow;
  int? previousCol;
  String? _treasure;

  void _onInitializeGame(InitializeGameEvent event, Emitter<GameState> emit) {
    emit(GameLoadingState());

    List<List<String>> grid = List.generate(10, (index) => List.filled(6, 'assets/seaweed.png'));
    List<List<String>> hiddenTreasures = List.generate(10, (index) => List.filled(6, ''));

    grid[0][0] = 'assets/player.png';
    _placeTreasures(hiddenTreasures);

    emit(GameLoadedState(
      grid: grid,
      hiddenTreasures: hiddenTreasures,
      playerRow: 0,
      playerCol: 0,
      currentBalance: 0,
      totalBalance: 100,
      isSpecialCharacter: true,
      isDeviceBroken: false,
    ));
  }

  void _onMovePlayer(MovePlayerEvent event, Emitter<GameState> emit) {
    if (state is GameLoadedState) {
      final currentState = state as GameLoadedState;
      List<List<String>> grid = List.from(currentState.grid);
      List<List<String>> hiddenTreasures = List.from(currentState.hiddenTreasures);
      int playerRow = currentState.playerRow;
      int playerCol = currentState.playerCol;
      int currentBalance = currentState.currentBalance;
      int totalBalance = currentState.totalBalance;
      bool isSpecialCharacter = currentState.isSpecialCharacter;
      bool isDeviceBroken = currentState.isDeviceBroken;


      // Update the previous position to 'assets/visited.png' or the treasure image if found
      if (currentState.playerRow == 0 && currentState.playerCol == 0) {
        grid[currentState.playerRow][currentState.playerCol] = 'assets/start.png';
      } else {
        String previousImage = grid[currentState.playerRow][currentState.playerCol];
        if (hiddenTreasures[currentState.playerRow][currentState.playerCol].isNotEmpty) {
          previousImage = hiddenTreasures[currentState.playerRow][currentState.playerCol];
        }
        grid[currentState.playerRow][currentState.playerCol] = previousImage == 'assets/player.png' ? 'assets/visited.png' : previousImage;
      }

      // Move the player to the new position
      playerRow = event.newRow;
      playerCol = event.newCol;

      String treasure = hiddenTreasures[playerRow][playerCol];
      if (treasure.isNotEmpty) {
        int value = 0;
        switch (treasure) {
          case 'assets/gold.png':
            value = 10;
            break;
          case 'assets/emerald.png':
            value = 15;
            break;
          case 'assets/diamond.png':
            value = 25;
            break;
          case 'assets/lucky_coin.png':
            _showLuckyCoinAnimation(event.context);
            break;
          case 'assets/unlucky_coin.png':
            _showUnluckyCoinAnimation(event.context);
            break;
          case 'assets/worm.png':
            _showWormAnimation(event.context);
            break;
          case 'assets/shark.png':
            _showSharkAnimation(event.context);
            break;
        }
        currentBalance += value;
        hiddenTreasures[playerRow][playerCol] = '';
        if (value > 0) {
          _showTreasureDialog(event.context, treasure);
        }
        // grid[playerRow][playerCol] = treasure; // Ensure player image is on top
        previousRow = playerRow;
        previousCol = playerCol;
        _treasure = treasure;
        grid[playerRow][playerCol] = 'assets/player.png';
      } else {
        if(previousRow != null && previousCol != null && _treasure != null){
          grid[previousRow!][previousCol!] = _treasure!;
          previousRow = null;
          previousCol = null;
          _treasure = null;
        }
        grid[playerRow][playerCol] = 'assets/player.png'; // Set the grid cell to the player image if no treasure
      }

      if (playerRow == 0 && playerCol == 0) {
        _showExitDialog(event.context);
      }

      emit(GameLoadedState(
        grid: grid,
        hiddenTreasures: hiddenTreasures,
        playerRow: playerRow,
        playerCol: playerCol,
        currentBalance: currentBalance,
        totalBalance: totalBalance,
        isSpecialCharacter: isSpecialCharacter,
        isDeviceBroken: isDeviceBroken,
      ));
    }
  }

  void _onUpdateBalance(UpdateBalanceEvent event, Emitter<GameState> emit) {
    if (state is GameLoadedState) {
      final currentState = state as GameLoadedState;
      emit(GameLoadedState(
        grid: currentState.grid,
        hiddenTreasures: currentState.hiddenTreasures,
        playerRow: currentState.playerRow,
        playerCol: currentState.playerCol,
        currentBalance: currentState.currentBalance + event.amount,
        totalBalance: currentState.totalBalance,
        isSpecialCharacter: currentState.isSpecialCharacter,
        isDeviceBroken: currentState.isDeviceBroken,
      ));
    }
  }

  void _onUpdateTotalBalance(UpdateTotalBalanceEvent event, Emitter<GameState> emit) {
    if (state is GameLoadedState) {
      final currentState = state as GameLoadedState;
      emit(GameLoadedState(
        grid: currentState.grid,
        hiddenTreasures: currentState.hiddenTreasures,
        playerRow: currentState.playerRow,
        playerCol: currentState.playerCol,
        currentBalance: currentState.currentBalance,
        totalBalance: currentState.totalBalance + event.amount,
        isSpecialCharacter: currentState.isSpecialCharacter,
        isDeviceBroken: currentState.isDeviceBroken,
      ));
    }
  }

  void _onUpdateDeviceStatus(UpdateDeviceStatusEvent event, Emitter<GameState> emit) {
    if (state is GameLoadedState) {
      final currentState = state as GameLoadedState;
      emit(GameLoadedState(
        grid: currentState.grid,
        hiddenTreasures: currentState.hiddenTreasures,
        playerRow: currentState.playerRow,
        playerCol: currentState.playerCol,
        currentBalance: currentState.currentBalance,
        totalBalance: currentState.totalBalance,
        isSpecialCharacter: currentState.isSpecialCharacter,
        isDeviceBroken: event.isBroken,
      ));
    }
  }

  void _onResetGame(ResetGameEvent event, Emitter<GameState> emit) {
    if (state is GameLoadedState) {
      final currentState = state as GameLoadedState;
      List<List<String>> grid = List.generate(10, (index) => List.filled(6, 'assets/seaweed.png'));
      List<List<String>> hiddenTreasures = List.generate(10, (index) => List.filled(6, ''));

      grid[0][0] = 'assets/player.png';
      _placeTreasures(hiddenTreasures);

      emit(GameLoadedState(
        grid: grid,
        hiddenTreasures: hiddenTreasures,
        playerRow: 0,
        playerCol: 0,
        currentBalance: 0,
        totalBalance: currentState.totalBalance,
        isSpecialCharacter: true,
        isDeviceBroken: false,
      ));
    }
  }

  void _placeTreasures(List<List<String>> hiddenTreasures) {
    Random random = Random();
    _placeTreasure(random, hiddenTreasures, 'assets/gold.png', 5);
    _placeTreasure(random, hiddenTreasures, 'assets/emerald.png', 3);
    _placeTreasure(random, hiddenTreasures, 'assets/diamond.png', 2);
    _placeTreasure(random, hiddenTreasures, 'assets/lucky_coin.png', 1);
    _placeTreasure(random, hiddenTreasures, 'assets/unlucky_coin.png', 1);
    _placeTreasure(random, hiddenTreasures, 'assets/worm.png', 1);
    _placeTreasure(random, hiddenTreasures, 'assets/shark.png', 1);
  }

  void _placeTreasure(Random random, List<List<String>> hiddenTreasures, String treasure, int count) {
    int placed = 0;
    while (placed < count) {
      int row = random.nextInt(10);
      int col = random.nextInt(6);
      if (hiddenTreasures[row][col] == '' && (row != 0 || col != 0)) {
        hiddenTreasures[row][col] = treasure;
        placed++;
      }
    }
  }

  void _showTreasureDialog(BuildContext context, String treasure) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              Image.asset(treasure, width: 200, height: 200),
            ],
          ),
        );
      },
    );
  }

  void _showLuckyCoinAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
          _startJackpotGame(context);
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/lucky_coin.png', width: 200, height: 200),
            ],
          ),
        );
      },
    );
  }

  void _startJackpotGame(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Choose a chest", style: TextStyle(fontSize: 24, color: Colors.white)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _handleJackpotChoice(context, true),
                        child: Image.asset('assets/closed_chest.png', width: 100, height: 100),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => _handleJackpotChoice(context, false),
                        child: Image.asset('assets/closed_chest.png', width: 100, height: 100),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleJackpotChoice(BuildContext context, bool isJackpot) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(isJackpot ? 'assets/jackpot_chest.png' : 'assets/empty_chest.png', width: 200, height: 200),
            ],
          ),
        );
      },
    );
    if (isJackpot) {
      add(UpdateBalanceEvent(100));
    }
  }

  void _showUnluckyCoinAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
          _startAntiJackpotGame(context);
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/unlucky_coin.png', width: 200, height: 200),
            ],
          ),
        );
      },
    );
  }

  void _startAntiJackpotGame(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Choose a chest", style: TextStyle(fontSize: 24, color: Colors.white)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _handleAntiJackpotChoice(context, true),
                        child: Image.asset('assets/closed_chest.png', width: 100, height: 100),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => _handleAntiJackpotChoice(context, false),
                        child: Image.asset('assets/closed_chest.png', width: 100, height: 100),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAntiJackpotChoice(BuildContext context, bool isAntiJackpot) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(isAntiJackpot ? 'assets/empty_chest.png' : 'assets/empty_chest.png', width: 200, height: 200),
            ],
          ),
        );
      },
    );
    if (isAntiJackpot) {
      add(UpdateBalanceEvent(-100));
      add(UpdateTotalBalanceEvent(-(state as GameLoadedState).totalBalance * 0.05.toInt()));
    }
  }

  void _showWormAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
          _handleBrokenDevice();
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/worm.png', width: 200, height: 200),
            ],
          ),
        );
      },
    );
  }

  void _handleBrokenDevice() {
    add(UpdateDeviceStatusEvent(true));
  }

  void _showSharkAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/shark.png', width: 200, height: 200),
            ],
          ),
        );
      },
    );
    add(UpdateBalanceEvent(-20));
    add(UpdateTotalBalanceEvent(-(state as GameLoadedState).totalBalance * 0.05.toInt()));
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/exit.png', width: 300, height: 300),
                  SizedBox(height: 20),
                  Text(
                    "Well done, you got to the surface!\nResult: +${(state as GameLoadedState).currentBalance} coins.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      add(UpdateTotalBalanceEvent((state as GameLoadedState).currentBalance));
                      add(ResetGameEvent());
                    },
                    child: Container(
                      width: 250,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Exit",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
