// Not annotating dynamic fails build
// ignore: avoid_annotating_with_dynamic
List<T> dynamicListToList<T>(final List<dynamic> list, final T Function(dynamic el) convertor) => list.map(convertor).toList();

List<String> dynamicListToStringList(final List<dynamic> list) => dynamicListToList(list, (final el) => el.toString());
