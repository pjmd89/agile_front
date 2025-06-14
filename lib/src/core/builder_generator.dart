import 'dart:io';

class BuilderGenerator {
  final String libRoot;
  BuilderGenerator({this.libRoot = 'lib'});

  void generateBuildersFromTypes(List types) {
    print('Generando builders de selección de campos GraphQL...');
    final outDir = '$libRoot/src/domain/operation/fields_builders';
    final barrelBuffer = StringBuffer();
    barrelBuffer.writeln('// Barrel file para todos los builders de selección de campos GraphQL');
    barrelBuffer.writeln('// GENERATED. NO EDITAR MANUALMENTE.\n');
    for (final type in types) {
      if (type['kind'] == 'OBJECT' && !type['name'].startsWith('__')) {
        final className = type['name'];
        final fields = type['fields'] ?? [];
        final buffer = StringBuffer();
        buffer.writeln('// GENERATED. NO EDITAR MANUALMENTE.');
        buffer.writeln('class ${className}FieldsBuilder {');
        buffer.writeln('  final List<String> _fields = [];');
        for (final field in fields) {
          final fieldName = field['name'];
          final dartField = fieldName;
          dynamic t = field['type'];
          while (t is Map && (t['kind'] == 'NON_NULL' || t['kind'] == 'LIST')) {
            t = t['ofType'];
          }
          if (t is Map && t['kind'] == 'OBJECT') {
            final typeName = t['name'];
            buffer.writeln('  ${className}FieldsBuilder $dartField(void Function(${typeName}FieldsBuilder) builder) {');
            buffer.writeln('    final child = ${typeName}FieldsBuilder();');
            buffer.writeln('    builder(child);');
            buffer.writeln('    _fields.add("$fieldName { \${child.build()} }");');
            buffer.writeln('    return this;');
            buffer.writeln('  }');
          } else {
            buffer.writeln('  ${className}FieldsBuilder $dartField() { _fields.add("$fieldName"); return this; }');
          }
        }
        buffer.writeln('  String build() => _fields.join(" ");');
        buffer.writeln('}');
        final outPath = '$outDir/${className.toLowerCase()}_fields_builder.dart';
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsStringSync(buffer.toString());
        print('  + Builder generado: $outPath');
        barrelBuffer.writeln("export './${className.toLowerCase()}_fields_builder.dart';");
      }
    }
    // Actualizar barrel file
    final barrelFile = File('$outDir/fields_builders.dart');
    barrelFile.writeAsStringSync(barrelBuffer.toString());
    print('  + Barrel actualizado: $outDir/fields_builders.dart');
  }
}
