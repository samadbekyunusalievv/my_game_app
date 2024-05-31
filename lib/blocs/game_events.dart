import 'package:flutter/cupertino.dart';

abstract class GameEvent {}

class InitializeGameEvent extends GameEvent {}

class MovePlayerEvent extends GameEvent {
  final int newRow;
  final int newCol;
  final BuildContext context;

  MovePlayerEvent(this.newRow, this.newCol, this.context);
}

class UpdateBalanceEvent extends GameEvent {
  final int amount;

  UpdateBalanceEvent(this.amount);
}

class UpdateTotalBalanceEvent extends GameEvent {
  final int amount;

  UpdateTotalBalanceEvent(this.amount);
}

class UpdateDeviceStatusEvent extends GameEvent {
  final bool isBroken;

  UpdateDeviceStatusEvent(this.isBroken);
}

class ResetGameEvent extends GameEvent {}
