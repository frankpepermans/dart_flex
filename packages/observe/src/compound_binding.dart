// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of observe;

/** The callback used in the [CompoundBinding.combinator] field. */
typedef Object CompoundBindingCombinator(Map objects);

/**
 * Model-Driven Views contains a helper object which is useful for the
 * implementation of a Custom Syntax.
 *
 *     var binding = new CompoundBinding((values) {
 *       var combinedValue;
 *       // compute combinedValue based on the current values which are provided
 *       return combinedValue;
 *     });
 *     binding.bind('name1', obj1, path1);
 *     binding.bind('name2', obj2, path2);
 *     //...
 *     binding.bind('nameN', objN, pathN);
 *
 * CompoundBinding is an object which knows how to listen to multiple path
 * values (registered via [bind]) and invoke its [combinator] when one or more
 * of the values have changed and set its [value] property to the return value
 * of the function. When any value has changed, all current values are provided
 * to the [combinator] in the single `values` argument.
 */
// TODO(jmesserly): rename to something that indicates it's a computed value?
class CompoundBinding extends ObservableBase {
  CompoundBindingCombinator _combinator;

  // TODO(jmesserly): ideally these would be String keys, but sometimes we
  // use integers.
  Map<dynamic, StreamSubscription> _bindings = new Map();
  Map _values = new Map();
  bool _scheduled = false;
  bool _disposed = false;
  Object _value;

  CompoundBinding([CompoundBindingCombinator combinator]) {
    // TODO(jmesserly): this is a tweak to the original code, it seemed to me
    // that passing the combinator to the constructor should be equivalent to
    // setting it via the property.
    // I also added a null check to the combinator setter.
    this.combinator = combinator;
  }

  CompoundBindingCombinator get combinator => _combinator;

  set combinator(CompoundBindingCombinator combinator) {
    _combinator = combinator;
    if (combinator != null) _scheduleResolve();
  }

  static const _VALUE = const Symbol('value');

  get value => _value;

  void set value(newValue) {
    _value = notifyPropertyChange(_VALUE, _value, newValue);
  }

  void bind(name, model, String path) {
    unbind(name);

    _bindings[name] = new PathObserver(model, path).bindSync((value) {
      _values[name] = value;
      _scheduleResolve();
    });
  }

  void unbind(name, {bool suppressResolve: false}) {
    var binding = _bindings.remove(name);
    if (binding == null) return;

    binding.cancel();
    _values.remove(name);
    if (!suppressResolve) _scheduleResolve();
  }

  // TODO(rafaelw): Is this the right processing model?
  // TODO(rafaelw): Consider having a seperate ChangeSummary for
  // CompoundBindings so to excess dirtyChecks.
  void _scheduleResolve() {
    if (_scheduled) return;
    _scheduled = true;
    queueChangeRecords(resolve);
  }

  void resolve() {
    if (_disposed) return;
    _scheduled = false;

    if (_combinator == null) {
      throw new StateError(
          'CompoundBinding attempted to resolve without a combinator');
    }

    value = _combinator(_values);
  }

  void dispose() {
    for (var binding in _bindings.values) {
      binding.cancel();
    }
    _bindings.clear();
    _values.clear();

    _disposed = true;
    value = null;
  }
}
