import 'dart:io';

class ModelGenerator {
  final String libRoot;
  ModelGenerator({this.libRoot = 'lib'});

  String _dartFieldName(String name) {
    // Convierte nombres inválidos a nombres válidos en Dart
    if (name.startsWith('_')) {
      return name.replaceFirst('_', '');
    }
    // Puedes agregar más reglas aquí si lo necesitas
    return name;
  }

  void generateModelsFromTypes(List types) {
    print('Generando modelos a partir de los tipos del esquema...');
    for (final type in types) {
      if (type['kind'] == 'OBJECT' && !type['name'].startsWith('__')) {
        final className = type['name'];
        final fields = type['fields'] ?? [];
        final buffer = StringBuffer();
        buffer.writeln('import "package:json_annotation/json_annotation.dart";');
        buffer.writeln('part "${className.toLowerCase()}_model.g.dart";');
        buffer.writeln('@JsonSerializable()');
        buffer.writeln('class $className {');
        for (final field in fields) {
          final fieldName = field['name'];
          final dartField = _dartFieldName(fieldName);
          if (fieldName != dartField) {
            buffer.writeln('  @JsonKey(name: "$fieldName")');
          }
          buffer.writeln('  final String? $dartField;');
        }
        buffer.writeln('  $className({');
        for (final field in fields) {
          final dartField = _dartFieldName(field['name']);
          buffer.writeln('    this.$dartField,');
        }
        buffer.writeln('  });');
        buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
        buffer.writeln('  Map<String, dynamic> toJson() => _\$${className}ToJson(this);');
        buffer.writeln('}');
        final outPath = '$libRoot/src/modules/${className.toLowerCase()}/data/models/${className.toLowerCase()}_model.dart';
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsStringSync(buffer.toString());
        print('  + Modelo generado: $outPath');
      }
    }
    for (final type in types) {
      if (type['kind'] == 'ENUM') {
        final enumName = type['name'];
        final values = type['enumValues'] ?? [];
        final buffer = StringBuffer();
        buffer.writeln('enum $enumName {');
        for (final value in values) {
          final originalName = value['name'];
          // Palabras reservadas de Dart
          const reservedWords = [
            'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
            'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
            'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
            'throw', 'true', 'try', 'var', 'void', 'while', 'with', 'abstract', 'as',
            'covariant', 'deferred', 'dynamic', 'export', 'external', 'factory', 'Function',
            'get', 'implements', 'import', 'interface', 'late', 'library', 'mixin', 'operator',
            'part', 'required', 'set', 'static', 'typedef', 'await', 'yield'
          ];
          var dartName = originalName;
          if (reservedWords.contains(originalName)) {
            dartName = '${originalName}_';
            buffer.writeln('  // "$originalName" es palabra reservada, renombrado a "$dartName"');
          }
          buffer.writeln('  $dartName,');
        }
        buffer.writeln('}');
        final outPath = '$libRoot/src/modules/${enumName.toLowerCase()}/data/enums/${enumName.toLowerCase()}_enum.dart';
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsStringSync(buffer.toString());
        print('  + Enum generado: $outPath');
      }
    }
  }
}
