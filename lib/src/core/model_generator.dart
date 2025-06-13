import 'dart:io';

class ModelGenerator {
  final String libRoot;
  ModelGenerator({this.libRoot = 'lib'});

  static const List<String> _reservedWords = [
    'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
    'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
    'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
    'throw', 'true', 'try', 'var', 'void', 'while', 'with', 'abstract', 'as',
    'covariant', 'deferred', 'dynamic', 'export', 'external', 'factory', 'Function',
    'get', 'implements', 'import', 'interface', 'late', 'library', 'mixin', 'operator',
    'part', 'required', 'set', 'static', 'typedef', 'await', 'yield'
  ];

  String _dartFieldName(String name) {
    // Convierte nombres inválidos a nombres válidos en Dart
    if (name.startsWith('_')) {
      return name.replaceFirst('_', '');
    }
    // Puedes agregar más reglas aquí si lo necesitas
    return name;
  }

  bool _isReserved(String name) => _reservedWords.contains(name);

  // Mapea tipos GraphQL a Dart
  String _mapGraphQLTypeToDart(Map? type) {
    if (type == null) return 'String?';
    // Desenrollar listas y nullability
    bool isList = false;
    bool isNonNull = false;
    dynamic t = type;
    // Proteger desenrollado si t puede ser null
    while (t is Map && (t['kind'] == 'NON_NULL' || t['kind'] == 'LIST')) {
      if (t['kind'] == 'NON_NULL') {
        isNonNull = true;
        t = t['ofType'];
      } else if (t['kind'] == 'LIST') {
        isList = true;
        t = t['ofType'];
      }
    }
    String baseType;
    if (t is! Map) {
      baseType = 'String';
    } else {
      switch (t['kind']) {
        case 'SCALAR':
          switch (t['name']) {
            case 'String':
              baseType = 'String';
              break;
            case 'Int':
              baseType = 'int';
              break;
            case 'Float':
              baseType = 'double';
              break;
            case 'Boolean':
              baseType = 'bool';
              break;
            case 'ID':
              baseType = 'String';
              break;
            default:
              baseType = 'String';
          }
          break;
        case 'ENUM':
          baseType = t['name'];
          break;
        case 'OBJECT':
        case 'INPUT_OBJECT':
          baseType = t['name'];
          break;
        default:
          baseType = 'String';
      }
    }
    String typeStr = baseType;
    if (isList) {
      typeStr = 'List<$baseType>';
    }
    if (!isNonNull) {
      typeStr += '?';
    }
    return typeStr;
  }

  void generateModelsFromTypes(List types) {
    print('Generando modelos a partir de los tipos del esquema...');
    for (final type in types) {
      if (type['kind'] == 'OBJECT' && !type['name'].startsWith('__')) {
        final className = type['name'];
        final fields = type['fields'] ?? [];
        final buffer = StringBuffer();
        // Recolectar tipos personalizados usados en los campos
        final Set<String> customTypes = {};
        for (final field in fields) {
          final fieldType = field['type'];
          final typeName = _extractCustomTypeName(fieldType);
          if (typeName != null && typeName != className) {
            customTypes.add(typeName);
          }
        }
        // Importar modelos relacionados
        for (final typeName in customTypes) {
          buffer.writeln('import "../${typeName.toLowerCase()}_model.dart";');
        }
        buffer.writeln('import "package:json_annotation/json_annotation.dart";');
        buffer.writeln('part "${className.toLowerCase()}_model.g.dart";');
        buffer.writeln('@JsonSerializable()');
        buffer.writeln('class $className {');
        for (final field in fields) {
          final fieldName = field['name'];
          var dartField = _dartFieldName(fieldName);
          if (_isReserved(dartField)) {
            dartField = '${dartField}_';
            buffer.writeln('  // "$fieldName" es palabra reservada, renombrado a "$dartField"');
          }
          if (fieldName != dartField) {
            buffer.writeln('  @JsonKey(name: "$fieldName")');
          }
          // Mapeo de tipos GraphQL a Dart
          String dartType = 'String?';
          if (field['type'] != null) {
            dartType = _mapGraphQLTypeToDart(field['type']);
          }
          buffer.writeln('  final $dartType $dartField;');
        }
        buffer.writeln('  $className({');
        for (final field in fields) {
          var dartField = _dartFieldName(field['name']);
          if (_isReserved(dartField)) {
            dartField = '${dartField}_';
          }
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
          var dartName = originalName;
          if (_isReserved(dartName)) {
            dartName = '${dartName}_';
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
    // Generar modelos para INPUT_OBJECT
    for (final type in types) {
      if (type['kind'] == 'INPUT_OBJECT' && !type['name'].startsWith('__')) {
        final className = type['name'];
        final fields = type['inputFields'] ?? [];
        final buffer = StringBuffer();
        buffer.writeln('import "package:flutter/foundation.dart";');
        buffer.writeln('import "package:json_annotation/json_annotation.dart";');
        buffer.writeln('part "${className.toLowerCase()}_input.g.dart";');
        buffer.writeln('@JsonSerializable()');
        buffer.writeln('class $className extends ChangeNotifier {');
        for (final field in fields) {
          final fieldName = field['name'];
          var dartField = _dartFieldName(fieldName);
          if (_isReserved(dartField)) {
            dartField = '${dartField}_';
            buffer.writeln('  // "$fieldName" es palabra reservada, renombrado a "$dartField"');
          }
          if (fieldName != dartField) {
            buffer.writeln('  @JsonKey(name: "$fieldName")');
          }
          buffer.writeln('  String? _$dartField;');
          buffer.writeln('  String? get $dartField => _$dartField;');
          buffer.writeln('  set $dartField(String? value) {');
          buffer.writeln('    _$dartField = value;');
          buffer.writeln('    notifyListeners();');
          buffer.writeln('  }');
        }
        buffer.writeln('  $className({');
        for (final field in fields) {
          var dartField = _dartFieldName(field['name']);
          if (_isReserved(dartField)) {
            dartField = '${dartField}_';
          }
          buffer.writeln('    String? $dartField,');
        }
        buffer.writeln('  }) {');
        for (final field in fields) {
          var dartField = _dartFieldName(field['name']);
          if (_isReserved(dartField)) {
            dartField = '${dartField}_';
          }
          buffer.writeln('    this.$dartField = $dartField;');
        }
        buffer.writeln('  }');
        buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
        buffer.writeln('  Map<String, dynamic> toJson() => _\$${className}ToJson(this);');
        buffer.writeln('}');
        final outPath = '$libRoot/src/modules/${className.toLowerCase()}/data/inputs/${className.toLowerCase()}_input.dart';
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsStringSync(buffer.toString());
        print('  + Input generado: $outPath');
      }
    }
  }
}

// Función auxiliar para extraer el nombre de tipo personalizado
String? _extractCustomTypeName(Map? type) {
  if (type == null) return null;
  dynamic t = type;
  while (t is Map && (t['kind'] == 'NON_NULL' || t['kind'] == 'LIST')) {
    t = t['ofType'];
  }
  if (t is Map && (t['kind'] == 'OBJECT' || t['kind'] == 'INPUT_OBJECT' || t['kind'] == 'ENUM')) {
    return t['name'];
  }
  return null;
}
