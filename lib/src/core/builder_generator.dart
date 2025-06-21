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
        // Revisar si realmente necesita importar main.dart (solo si hay al menos un campo tipo OBJECT)
        bool needsMainImport = false;
        for (final field in fields) {
          dynamic t = field['type'];
          while (t is Map && (t['kind'] == 'NON_NULL' || t['kind'] == 'LIST')) {
            t = t['ofType'];
          }
          if (t is Map && t['kind'] == 'OBJECT') {
            needsMainImport = true;
            break;
          }
        }
        if (needsMainImport) {
          buffer.writeln("import 'main.dart';");
        }
        buffer.writeln('class ${className}FieldsBuilder {');
        buffer.writeln('  final List<String> _fields = [];');
        for (final field in fields) {
          final fieldName = field['name'];
          final dartField = _dartFieldName(fieldName);
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
        if(!outFile.existsSync()) {
          outFile.writeAsStringSync(buffer.toString());
          print('  + Builder generado: $outPath');
        }
        
        barrelBuffer.writeln("export './${className.toLowerCase()}_fields_builder.dart';");
      }
    }
    // Actualizar barrel file
    final barrelFile = File('$outDir/fields_builders.dart');
    if(!barrelFile.existsSync()){
      barrelFile.writeAsStringSync(barrelBuffer.toString());
      print('  + Barrel actualizado: $outDir/fields_builders.dart');
    }
    

    // --- Generar main.dart (barrel file) para builders ---
    final mainBuffer = StringBuffer();
    mainBuffer.writeln('// GENERATED BARREL FILE. NO EDITAR MANUALMENTE.');
    mainBuffer.writeln('// Exporta todos los builders de selección de campos GraphQL\n');
    final outDirAbs = Directory(outDir);
    if (outDirAbs.existsSync()) {
      final dartFiles = <File>[];
      void collectDartFiles(Directory dir) {
        for (final entity in dir.listSync(recursive: false)) {
          if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('main.dart')) {
            dartFiles.add(entity);
          }
        }
      }
      collectDartFiles(outDirAbs);
      for (final file in dartFiles) {
        final relPath = file.path.replaceFirst(outDirAbs.path + '/', '');
        if (!relPath.endsWith('fields_builders.dart')) {
          mainBuffer.writeln("export './$relPath';");
        }
      }
      final mainFile = File('${outDirAbs.path}/main.dart');
      if (!mainFile.existsSync()) {
        mainFile.writeAsStringSync(mainBuffer.toString());
        print('  + Barrel main.dart generado: ${mainFile.path}');
      }
    }
  }

  String _dartFieldName(String name) {
    if (name.startsWith('_')) {
      return name.replaceFirst('_', '');
    }
    return name;
  }
}
