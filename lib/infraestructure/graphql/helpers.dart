class Directive {
  final String name;
  final Map<String, dynamic>? args;
  Directive(this.name, [this.args]);

  String format() {
    if (args == null || args!.isEmpty) return '@$name';
    return '@$name(${formatArgs(args!)})';
  }
}

class GqlVar {
  final String name;
  GqlVar(this.name);
  @override
  String toString() => ' VAR: $name';
}

/// Representa un enum GraphQL
class GqlEnum {
  final String value;
  GqlEnum(this.value);
  @override
  String toString() => '\u0000ENUM:\u0000$value';
}

String formatArgs(Map<String, dynamic> args) {
  return args.entries.map((e) =>
    '${e.key}: ${_formatArgValue(e.value)}'
  ).join(', ');
}

String _formatArgValue(dynamic value) {
  if (value == null) return 'null';
  if (value is GqlVar) {
    // Renderiza la variable GraphQL con el símbolo $
    return '\$' + value.name;
  }
  if (value is GqlEnum) {
    return value.value;
  }
  if (value is String && value.startsWith('\u0000VAR:')) {
    // Elimina el marcador y antepone sólo el símbolo $
    return '\$' + value.substring(8);
  }
  if (value is String && value.startsWith('\u0000ENUM:')) {
    return value.substring(9);
  }
  if (value is String && value.startsWith('\u0000')) {
    // Elimina cualquier marcador NUL y antepone sólo el símbolo $
    return '\$' + value.substring(1);
  }
  if (value is String) {
    return '"${value.replaceAll('"', '\"')}"';
  }
  if (value is bool || value is num) return value.toString();
  if (value is List) {
    return '[${value.map(_formatArgValue).join(', ')}]';
  }
  if (value is Map) {
    return '{${value.entries.map((e) => '${e.key}: ${_formatArgValue(e.value)}').join(', ')}}';
  }
  return value.toString();
}

String formatField(String name, {String? alias, Map<String, dynamic>? args, List<Directive>? directives, String? selection}) {
  final buf = StringBuffer();
  if (alias != null && alias.isNotEmpty) buf.write('$alias: ');
  buf.write(name);
  if (args != null && args.isNotEmpty) {
    buf.write('(');
    buf.write(formatArgs(args));
    buf.write(')');
  }
  if (directives != null && directives.isNotEmpty) {
    for (final d in directives) {
      buf.write(' ');
      buf.write(d.format());
    }
  }
  if (selection != null && selection.isNotEmpty) {
    buf.write(' { $selection }');
  }
  return buf.toString();
}