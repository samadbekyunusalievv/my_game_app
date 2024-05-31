import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/game_bloc.dart';
import '../blocs/game_events.dart';
import '../blocs/game_state.dart';
import '../widgets/grid_widgets.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameInitialState || state is GameLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GameLoadedState) {
            return _buildGameUI(context, state);
          } else {
            return Center(child: Text('Error loading game', style: TextStyle(fontWeight: FontWeight.bold)));
          }
        },
      ),
    );
  }

  Widget _buildGameUI(BuildContext context, GameLoadedState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C4C4), Color(0xFF0066C5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, state.currentBalance),
          _buildGrid(context, state),
          _buildFooter(context, state.totalBalance),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int currentBalance) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$currentBalance', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  Image.asset('assets/money_icon.png', width: 30, height: 30),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Image.asset('assets/info_icon.png', width: 30, height: 30),
              onPressed: () {},
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Image.asset('assets/close_icon.png', width: 30, height: 30),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, GameLoadedState state) {
    return Flexible(
      child: Center(
        child: AspectRatio(
          aspectRatio: 6 / 10,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double itemWidth = constraints.maxWidth / 6;
              double itemHeight = constraints.maxHeight / 10;
              return Padding(
                padding: const EdgeInsets.only(top: 0, right: 20, left: 20, bottom: 10),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: itemWidth / itemHeight,
                  ),
                  itemCount: 60,
                  itemBuilder: (context, index) {
                    int row = index ~/ 6;
                    int col = index % 6;
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if ((row == state.playerRow && (col == state.playerCol + 1 || col == state.playerCol - 1)) ||
                                (col == state.playerCol && (row == state.playerRow + 1 || row == state.playerRow - 1))) {
                              context.read<GameBloc>().add(MovePlayerEvent(row, col, context));
                            }
                          },
                          child: GridItem(image: state.grid[row][col]),
                        ),
                        if (row == state.playerRow && col == state.playerCol + 1)
                          Positioned(
                            top: itemHeight / 2 - 15,
                            left: itemWidth - 65,
                            child: Image.asset('assets/arrow_right.png', width: 30, height: 30),
                          ),
                        if (row == state.playerRow && col == state.playerCol - 1)
                          Positioned(
                            top: itemHeight / 2 - 15,
                            left: 30,
                            child: Image.asset('assets/arrow_left.png', width: 30, height: 30),
                          ),
                        if (row == state.playerRow + 1 && col == state.playerCol)
                          Positioned(
                            top: itemHeight - 65,
                            left: itemWidth / 2 - 15,
                            child: Image.asset('assets/arrow_down.png', width: 30, height: 30),
                          ),
                        if (row == state.playerRow - 1 && col == state.playerCol)
                          Positioned(
                            top: 30,
                            left: itemWidth / 2 - 15,
                            child: Image.asset('assets/arrow_up.png', width: 30, height: 30),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, int totalBalance) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$totalBalance', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(width: 5),
              Image.asset('assets/total_balance_icon.png', width: 30, height: 30),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text('Total balance', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/game.png', width: 24, height: 24),
          label: 'Game',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/store.png', width: 24, height: 24, color: Colors.white54),
          label: 'Store',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/settings.png', width: 24, height: 24, color: Colors.white54),
          label: 'Settings',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      onTap: (index) {},
    );
  }
}
