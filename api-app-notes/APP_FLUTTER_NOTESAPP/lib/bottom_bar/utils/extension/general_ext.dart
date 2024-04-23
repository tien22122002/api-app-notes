part of '../app_utils.dart';

/// To create list from [Iterable]
List<T> listOf<T>(Iterable<T> list) => <T>[].also((it) => it.addAll(list));

/// Executes the given function [action] specified number of [times].
// ignore: use_function_type_syntax_for_parameters, avoid_types_as_parameter_names
repeat(int times, void action(int)) {
  for (int i = 0; i < times; i++) {
    action(i);
  }
}

/// Calls the specified function [operation] with `this` value as its receiver and returns its result.
// ignore: use_function_type_syntax_for_parameters
ReturnType run<ReturnType>(ReturnType operation()) {
  return operation();
}

extension ScopeFunctionsForObject<T extends Object> on T {
  /// Calls the specified function [operation] with `this` value as its argument and returns its result.
  ReturnType let<ReturnType>(ReturnType Function(T self) operation) {
    return operation(this);
  }

  /// Calls the specified function [operation] with `this` value as its argument and returns `this` value.
  T also(void Function(T self) operation) {
    operation(this);
    return this;
  }
}
