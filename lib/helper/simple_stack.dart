import 'dart:collection';

//reference:
//https://github.com/ammaratef45/dart_stack/blob/master/lib/stack.dart
class SimpleStack<T> {
  final ListQueue<T> _list = ListQueue();

  /// check if the stack is empty.
  bool get isEmpty => _list.isEmpty;

  /// check if the stack is not empty.
  bool get isNotEmpty => _list.isNotEmpty;

  /// push element in top of the stack.
  push(T e) {
    _list.addLast(e);
  }

  /// get the top of the stack and delete it.
  T pop() {
    T res = _list.last;
    _list.removeLast();
    return res;
  }

  /// get the top of the stack without deleting it.
  T top() {
    return _list.last;
  }

  clear() {
    return _list.clear();
  }

  int size() {
    return _list.length;
  }

  removeFirst() {
    try {
      _list.removeFirst();
    } catch (e) {
      //print(e);
    }
  }

  Iterable<T> get iterator => _list;
}
