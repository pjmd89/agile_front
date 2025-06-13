import 'dart:io';

class ModelGenerator {
  final String libRoot;
  ModelGenerator({this.libRoot = 'lib'});

  void generateModelsFromTypes(List types) {
    print('Generando modelos a partir de los tipos del esquema...');
    for (final type in types) {
      if (type['kind'] == 'OBJECT' && !type['name'].startsWith('__')) {
        final className = type['name'];
        final fields = type['fields'] ?? [];
        final buffer = StringBuffer();
        buffer.writeln('class $className {');
        for (final field in fields) {
          final fieldName = field['name'];
          buffer.writeln('  final String $fieldName;');
        }
        buffer.writeln('  $className({');
        for (final field in fields) {
          buffer.writeln('    required this.${field['name']},');
        }
        buffer.writeln('  });');
        buffer.writeln('}');
        final outPath =
            '$libRoot/src/modules/${className.toLowerCase()}/data/models/${className.toLowerCase()}_model.dart';
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsStringSync(buffer.toString());
        print('  + Modelo generado: $outPath');
      }
      if (type['kind'] == 'ENUM') {
        final enumName = type['name'];
        final values = type['enumValues'] ?? [];
        final buffer = StringBuffer();
        buffer.writeln('enum $enumName {');
        for (final value in values) {
          buffer.writeln('  ${value['name']},');
        }
        buffer.writeln('}');
        final outPath =
            '$libRoot/src/modules/${enumName.toLowerCase()}/data/models/${enumName.toLowerCase()}_enum.dart';
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsStringSync(buffer.toString());
        print('  + Enum generado: $outPath');
      }
    }
  }
}
