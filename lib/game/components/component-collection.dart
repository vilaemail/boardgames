import 'dart:collection';

import 'component.dart';

class ComponentCollection<T extends Component> with IterableMixin<T> implements Iterable<T> {
  final List<ComponentCollection<Component>> _parents;
  final Map<ComponentId, T> _componentsById = {};

  ComponentCollection({final List<ComponentCollection<Component>>? parents}): _parents = parents ?? [];

  void add(final T component) {
    _add(component, component.id);
  }

  void _add(final T component, final ComponentId id) {
    if (_componentsById[id] != null) {
      throw Exception('Component with given id ($id) already exists!');
    }
    if (_parents.isNotEmpty) {
      for (final parent in _parents) {
        parent._add(component, id);
      }
    }
    _componentsById[id] = component;
  }

  T get(final ComponentId id) {
    final component = _componentsById[id];
    if (component == null) {
      throw Exception('Component with given id ($id) does not exist!');
    }
    return component;
  }
  
  @override
  Iterator<T> get iterator => _componentsById.values.iterator;
}
