import 'dart:collection';

class FixedQueue<T> {
  final int maxSize;
  final Queue<T> _queue = Queue<T>();

  FixedQueue(this.maxSize);

  void add(T value) {
    if (_queue.length >= maxSize) {
      _queue.removeFirst();
    }
    _queue.addLast(value);
  }

  Iterable<T> get items => _queue;
}
