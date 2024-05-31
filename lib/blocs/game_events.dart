import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class InitializeGameEvent extends GameEvent {}

class MovePlayerEvent extends GameEvent {
  final int newRow;
  final int newCol;
  final BuildContext context;

  const MovePlayerEvent(this.newRow, this.newCol, this.context);

  @override
  List<Object> get props => [newRow, newCol, context];
}

class UpdateBalanceEvent extends GameEvent {
  final int amount;

  const UpdateBalanceEvent(this.amount);

  @override
  List<Object> get props => [amount];
}

class UpdateTotalBalanceEvent extends GameEvent {
  final int amount;

  const UpdateTotalBalanceEvent(this.amount);

  @override
  List<Object> get props => [amount];
}

class UpdateDeviceStatusEvent extends GameEvent {
  final bool isBroken;

  const UpdateDeviceStatusEvent(this.isBroken);

  @override
  List<Object> get props => [isBroken];
}

class ResetGameEvent extends GameEvent {}
