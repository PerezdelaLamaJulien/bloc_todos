import 'package:equatable/equatable.dart';
import 'package:bloc_todos/models/models.dart';

abstract class TodosState extends Equatable {
  const TodosState();

  @override
  List<Object> get props => [];
}

class TodosLoadInProgress extends TodosState {}

class TodosLoadSuccessed extends TodosState {
  final List<Todo> todos;

  const TodosLoadSuccessed([this.todos = const []]);

  @override
  List<Object> get props => [todos];

  @override
  String toString() => "TodosLoadSuccess {todos : $todos}";
}

class TodosLoadFailure extends TodosState {}
