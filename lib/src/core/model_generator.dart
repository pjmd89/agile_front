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

  // Mapea tipos GraphQL a Dart de forma precisa
  String _mapGraphQLTypeToDart(Map? type) {
    if (type == null) return 'String?';
    // Si es NON_NULL, mapear el tipo interno recursivamente y quitar el null safety
    if (type['kind'] == 'NON_NULL') {
      String baseType = _mapGraphQLTypeToDart(type['ofType']);
      if (baseType.endsWith('?')) {
        baseType = baseType.substring(0, baseType.length - 1);
      }
      return baseType;
    }
    // Si es LIST, mapear el tipo interno recursivamente y aplicar null safety solo al List
    if (type['kind'] == 'LIST') {
      String innerType = _mapGraphQLTypeToDart(type['ofType']);
      // El tipo interno nunca debe ser nullable dentro de la lista
      if (innerType.endsWith('?')) {
        innerType = innerType.substring(0, innerType.length - 1);
      }
      return 'List<$innerType>?';
    }
    // Si es SCALAR, ENUM, OBJECT, INPUT_OBJECT, mapear normalmente
    if (type['kind'] == 'SCALAR') {
      switch (type['name']) {
        case 'String':
          return 'String?';
        case 'Int':
        case 'Float':
          return 'num?';
        case 'Boolean':
          return 'bool?';
        case 'ID':
          return 'String?';
        default:
          return 'String?';
      }
    }
    if (type['kind'] == 'ENUM' || type['kind'] == 'OBJECT' || type['kind'] == 'INPUT_OBJECT') {
      return type['name'] + '?';
    }
    // Por defecto, String nullable
    return 'String?';
  }

  void generateModelsFromTypes(List types) {
    print('Generando modelos a partir de los tipos del esquema...');
    for (final type in types) {
      if (type['kind'] == 'OBJECT' && !type['name'].startsWith('__')) {
        final className = type['name'];
        final fields = type['fields'] ?? [];
        final buffer = StringBuffer();
        // Recolectar tipos personalizados usados en los campos, solo OBJECT o INPUT_OBJECT
        final Set<String> customTypes = {};
        final Set<String> enumTypes = {};
        for (final field in fields) {
          final fieldType = field['type'];
          final typeName = _extractCustomTypeName(fieldType);
          if (typeName != null && typeName != className) {
            final relatedType = types.firstWhere(
              (t) => t['name'] == typeName,
              orElse: () => null,
            );
            if (relatedType != null) {
              if (relatedType['kind'] == 'OBJECT' || relatedType['kind'] == 'INPUT_OBJECT') {
                customTypes.add(typeName);
              } else if (relatedType['kind'] == 'ENUM') {
                enumTypes.add(typeName);
              }
            }
          }
        }
        
        // Detectar si es necesario importar main.dart en modelos (types)
        bool needsMainImport = false;
        for (final field in fields) {
          dynamic t = field['type'];
          while (t is Map && (t['kind'] == 'NON_NULL' || t['kind'] == 'LIST')) {
            t = t['ofType'];
          }
          if (t is Map && (t['kind'] == 'INPUT_OBJECT' || t['kind'] == 'ENUM' || t['kind'] == 'OBJECT')) {
            needsMainImport = true;
            break;
          }
        }
        if (needsMainImport) {
          buffer.writeln('import "/src/domain/entities/main.dart";');
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
          bool isNonNull = false;
          if (field['type'] != null) {
            dynamic t = field['type'];
            if (t['kind'] == 'NON_NULL') {
              isNonNull = true;
              t = t['ofType'];
            }
            // Si es ENUM, usar el nombre correcto del enum (con sufijo Enum)
            String? enumTypeName;
            if (t is Map && t['kind'] == 'ENUM') {
              enumTypeName = t['name'];
            }
            if (enumTypeName != null) {
              dartType = enumTypeName + (isNonNull ? '' : '?');
            } else {
              dartType = _mapGraphQLTypeToDart(field['type']);
              if (!dartType.trim().endsWith('?') && !isNonNull) {
                dartType = dartType + '?';
              }
            }
          }
          // Si es String, bool, num o List, debe ser no nulo
          if (dartType == 'String' || dartType == 'String?') {
            buffer.writeln('  final String $dartField;');
          } else if (dartType == 'bool' || dartType == 'bool?') {
            buffer.writeln('  final bool $dartField;');
          } else if (dartType == 'num' || dartType == 'num?') {
            buffer.writeln('  final num $dartField;');
          } else if (dartType.startsWith('List<')) {
            // Quitar el ? para que no sea nullable
            final nonNullableListType = dartType.replaceAll('?', '');
            buffer.writeln('  final $nonNullableListType $dartField;');
          } else if (isNonNull && (dartType.endsWith('Input') || dartType.endsWith('Input?') || dartType.endsWith('Enum') || dartType.endsWith('Enum?') || dartType.endsWith('Object') || dartType.endsWith('Object?'))) {
            // Si es un objeto no nulo, inicializar con el constructor por defecto
            final typeName = dartType.replaceAll('?', '');
            buffer.writeln('  final $typeName $dartField;');
          } else {
            buffer.writeln('  final $dartType $dartField;');
          }
        }
        buffer.writeln('  $className({');
        for (final field in fields) {
          final fieldName = field['name'];
          var dartField = _dartFieldName(fieldName);
          if (_isReserved(dartField)) {
            dartField = '${dartField}_';
          }
          // Determinar tipo para saber si es String, bool, num o List no nulo
          String dartType = 'String?';
          bool isNonNull = false;
          if (field['type'] != null) {
            dynamic t = field['type'];
            if (t['kind'] == 'NON_NULL') {
              isNonNull = true;
              t = t['ofType'];
            }
            String? enumTypeName;
            if (t is Map && t['kind'] == 'ENUM') {
              enumTypeName = t['name'];
            }
            if (enumTypeName != null) {
              dartType = enumTypeName + (isNonNull ? '' : '?');
            } else {
              dartType = _mapGraphQLTypeToDart(field['type']);
            }
          }
          if (dartType == 'String' || dartType == 'String?') {
            buffer.writeln('    this.$dartField = "",');
          } else if (dartType == 'bool' || dartType == 'bool?') {
            buffer.writeln('    this.$dartField = false,');
          } else if (dartType == 'num' || dartType == 'num?') {
            buffer.writeln('    this.$dartField = 0,');
          } else if (dartType.startsWith('List<')) {
            buffer.writeln('    this.$dartField = const [],');
          } else if (isNonNull && (dartType.endsWith('Input') || dartType.endsWith('Object') || dartType.endsWith('Enum'))) {
            // Inicializar con el constructor por defecto
            final typeName = dartType.replaceAll('?', '');
            buffer.writeln('    this.$dartField = const $typeName(),');
          } else {
            buffer.writeln('    this.$dartField,');
          }
        }
        buffer.writeln('  });');
        buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
        buffer.writeln('  Map<String, dynamic> toJson() => _\$${className}ToJson(this);');
        buffer.writeln('}');
        final outPath = '$libRoot/src/domain/entities/types/${className.toLowerCase()}/${className.toLowerCase()}_model.dart';
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsStringSync(buffer.toString());
        print('  + Modelo generado: $outPath');
      }
    }
    for (final type in types) {
      if (type['kind'] == 'ENUM' && !type['name'].startsWith('__')) {
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
        final outPath = '$libRoot/src/domain/entities/enums/${enumName.toLowerCase()}_enum.dart';
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
        if (fields.isEmpty) {
          // No generar clase vacía
          continue;
        }
        // Buscar a qué type OBJECT asociar este input (por convención)
        // Ejemplo: CreateUserInput, UpdateUserInput, UserInput => User
        String? parentType;
        for (final objectType in types.where((t) => t['kind'] == 'OBJECT' && !t['name'].startsWith('__'))) {
          final objectName = objectType['name'];
          if (className.toLowerCase().contains(objectName.toLowerCase())) {
            parentType = objectName;
            break;
          }
        }
        // Si no se encuentra, usar carpeta general de inputs
        String inputOutPath;
        if (parentType != null) {
          inputOutPath = '$libRoot/src/domain/entities/types/${parentType.toLowerCase()}/inputs/${className.toLowerCase()}_input.dart';
        } else {
          inputOutPath = '$libRoot/src/domain/entities/inputs/${className.toLowerCase()}_input.dart';
        }
        final buffer = StringBuffer();
        // Buscar imports necesarios para INPUT_OBJECT y ENUM
        final Set<String> inputObjectTypes = {};
        final Set<String> enumTypes = {};
        for (final field in fields) {
          dynamic t = field['type'];
          while (t is Map && (t['kind'] == 'NON_NULL' || t['kind'] == 'LIST')) {
            t = t['ofType'];
          }
          if (t is Map && t['kind'] == 'INPUT_OBJECT') {
            inputObjectTypes.add(t['name']);
          } else if (t is Map && t['kind'] == 'ENUM') {
            enumTypes.add(t['name']);
          }
        }
        
        // Detectar si es necesario importar main.dart
        bool needsMainImport = false;
        for (final field in fields) {
          dynamic t = field['type'];
          while (t is Map && (t['kind'] == 'NON_NULL' || t['kind'] == 'LIST')) {
            t = t['ofType'];
          }
          if (t is Map && (t['kind'] == 'INPUT_OBJECT' || t['kind'] == 'ENUM' || t['kind'] == 'OBJECT')) {
            needsMainImport = true;
            break;
          }
        }
        if (needsMainImport) {
          buffer.writeln('import "/src/domain/entities/main.dart";');
        }
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
          // Determinar tipo y valor por defecto
          String dartType;
          String? fieldInitializer = '';
          bool isNullable = true;
          dynamic t = field['type'];
          if (t['kind'] == 'NON_NULL') {
            isNullable = false;
            t = t['ofType'];
          }
          if (t is Map) {
            switch (t['kind']) {
              case 'SCALAR':
                switch (t['name']) {
                  case 'String':
                    dartType = isNullable ? 'String?' : 'String';
                    if (!isNullable) fieldInitializer = ' = ""';
                    break;
                  case 'Boolean':
                    dartType = isNullable ? 'bool?' : 'bool';
                    if (!isNullable) fieldInitializer = ' = false';
                    break;
                  case 'Int':
                  case 'Float':
                    dartType = isNullable ? 'num?' : 'num';
                    if (!isNullable) fieldInitializer = ' = 0';
                    break;
                  default:
                    dartType = isNullable ? 'String?' : 'String';
                    if (!isNullable) fieldInitializer = ' = ""';
                }
                break;
              case 'ENUM':
                dartType = t['name'] + (isNullable ? '?' : '');
                if (!isNullable) fieldInitializer = ' = ${t['name']}.values.first';
                break;
              case 'OBJECT':
              case 'INPUT_OBJECT':
                dartType = t['name'] + (isNullable ? '?' : '');
                if (!isNullable) fieldInitializer = ' = ${t['name']}()';
                break;
              case 'LIST':
                String innerType = _mapGraphQLTypeToDart(t['ofType']);
                dartType = 'List<$innerType>' + (isNullable ? '?' : '');
                if (!isNullable) fieldInitializer = ' = const []';
                break;
              default:
                dartType = isNullable ? 'String?' : 'String';
                if (!isNullable) fieldInitializer = ' = ""';
            }
          } else {
            dartType = 'String?';
          }
          buffer.writeln('  $dartType _${dartField}${fieldInitializer};');
          buffer.writeln('  $dartType get $dartField => _${dartField};');
          buffer.writeln('  set $dartField($dartType value) {');
          buffer.writeln('    _${dartField} = value;');
          buffer.writeln('    notifyListeners();');
          buffer.writeln('  }');
        }
        buffer.writeln('  $className({');
        for (final field in fields) {
          var dartField = _dartFieldName(field['name']);
          if (_isReserved(dartField)) {
            dartField = '${dartField}_';
          }
          buffer.writeln('    $dartField,');
        }
        buffer.writeln('  }) {');
        for (final field in fields) {
          var dartField = _dartFieldName(field['name']);
          if (_isReserved(dartField)) {
            dartField = '${dartField}_';
          }
          // Determinar valor por defecto para la asignación
          String defaultValue;
          bool isNullable = true;
          dynamic t = field['type'];
          if (t['kind'] == 'NON_NULL') {
            isNullable = false;
            t = t['ofType'];
          }
          if (t is Map) {
            switch (t['kind']) {
              case 'SCALAR':
                switch (t['name']) {
                  case 'String':
                    defaultValue = '""';
                    break;
                  case 'Boolean':
                    defaultValue = 'false';
                    break;
                  case 'Int':
                  case 'Float':
                    defaultValue = '0';
                    break;
                  default:
                    defaultValue = '""';
                }
                break;
              case 'ENUM':
              case 'OBJECT':
              case 'INPUT_OBJECT':
                defaultValue = 'null';
                break;
              case 'LIST':
                defaultValue = isNullable ? 'null' : 'const []';
                break;
              default:
                defaultValue = '""';
            }
          } else {
            defaultValue = 'null';
          }
          buffer.writeln('    this.$dartField = $dartField ?? $defaultValue;');
        }
        buffer.writeln('  }');
        buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
        buffer.writeln('  Map<String, dynamic> toJson() => _\$${className}ToJson(this);');
        buffer.writeln('}');
        final outFile = File(inputOutPath);
        outFile.createSync(recursive: true);
        outFile.writeAsStringSync(buffer.toString());
        print('  + Input generado: $inputOutPath');
      }
    }
    // --- Generar main.dart (barrel file) para entidades ---
    final entitiesDir = Directory('$libRoot/src/domain/entities');
    if (entitiesDir.existsSync()) {
      final buffer = StringBuffer();
      buffer.writeln('// GENERATED BARREL FILE. NO EDITAR MANUALMENTE.');
      buffer.writeln('// Exporta todos los modelos, inputs y enums\n');
      final dartFiles = <File>[];
      void collectDartFiles(Directory dir) {
        for (final entity in dir.listSync(recursive: false)) {
          if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('main.dart')) {
            dartFiles.add(entity);
          } else if (entity is Directory) {
            collectDartFiles(entity);
          }
        }
      }
      collectDartFiles(entitiesDir);
      for (final file in dartFiles) {
        final relPath = file.path.replaceFirst(entitiesDir.path + '/', '');
        buffer.writeln("export './$relPath';");
      }
      final mainFile = File('${entitiesDir.path}/main.dart');
      mainFile.writeAsStringSync(buffer.toString());
      print('  + Barrel generado: ${mainFile.path}');
    }
  }
}

// Función auxiliar para extraer el nombre de tipo personalizado
String? _extractCustomTypeName(Map? type) {
  if (type == null) return null;
  dynamic t = type;
  while (t is Map) {
    if (t['kind'] == 'LIST' && t['ofType'] != null) {
      t = t['ofType'];
    } else if (t['kind'] == 'NON_NULL' && t['ofType'] != null) {
      t = t['ofType'];
    } else {
      break;
    }
  }
  if (t is Map && t.containsKey('name') && (t['kind'] == 'OBJECT' || t['kind'] == 'INPUT_OBJECT' || t['kind'] == 'ENUM')) {
    return t['name'];
  }
  return null;
}
