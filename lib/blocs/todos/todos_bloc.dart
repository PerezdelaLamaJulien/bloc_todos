import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_todos/blocs/todos/todos_event.dart';
import 'package:bloc_todos/blocs/todos/todos_state.dart';
import 'package:meta/meta.dart';
import 'package:bloc_todos/models/models.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepositoryFlutter todosRepository;

  TodosBloc({@required this.todosRepository}) : super(TodosLoadInProgress());

  @override
  Stream<TodosState> mapEventToState(TodosEvent event) async* {
    if (event is TodosLoadSuccess) {
      yield* _mapTodosLoadedToState();
    } else if (event is TodoAdded) {
      yield* _mapTodoAddedToState(event);
    } else if (event is TodoUpdated) {
      yield* _mapTodoUpdatedToState(event);
    } else if (event is TodoDeleted) {
      yield* _mapTodoDeletedToState(event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState();
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    }
  }

  Stream<TodosState> _mapTodosLoadedToState() async* {
    try {
      final todos = await this.todosRepository.loadTodos();

      yield TodosLoadSuccessed(
        todos.map(Todo.fromEntity).toList(),
      );
    } catch (_) {
      yield TodosLoadFailure();
    }
  }

  Stream<TodosState> _mapTodoAddedToState(TodoAdded event) async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
          List.from((state as TodosLoadSuccessed).todos)..add(event.todo);
      yield TodosLoadSuccessed(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodoUpdatedToState(TodoUpdated event) async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
          (state as TodosLoadSuccessed).todos.map((todo) {
        return todo.id == event.todo.id ? event.todo : todo;
      }).toList();
      yield TodosLoadSuccessed(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodoDeletedToState(TodoDeleted event) async* {
    if (state is TodosLoadSuccess) {
      final updatedTodos = (state as TodosLoadSuccessed)
          .todos
          .where((todo) => todo.id != event.todo.id)
          .toList();
      yield TodosLoadSuccessed(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapToggleAllToState() async* {
    if (state is TodosLoadSuccess) {
      final allComplete =
          (state as TodosLoadSuccessed).todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = (state as TodosLoadSuccessed)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodosLoadSuccessed(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapClearCompletedToState() async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = (state as TodosLoadSuccessed)
          .todos
          .where((todo) => !todo.complete)
          .toList();
      yield TodosLoadSuccessed(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Future _saveTodos(List<Todo> todos) {
    return todosRepository.saveTodos(
      todos.map((todo) => todo.toEntity()).toList(),
    );
  }
}
