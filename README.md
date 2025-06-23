# agile_front

Generador de código Clean Architecture para Dart/Flutter basado en introspección GraphQL.

## Instalación y preparación

1. **Crea un nuevo proyecto Flutter:**
   ```bash
   flutter create mi_proyecto
   cd mi_proyecto
   ```
2. **Elimina todos los archivos dentro de la carpeta `src`:**
   ```bash
   rm -rf lib/src/*
   ```
3. **Agrega las siguientes dependencias en tu `pubspec.yaml`:**

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_localizations:
       sdk: flutter
     agile_front:
       git:
         url: https://github.com/pjmd89/agile_front.git
         ref: main
     cupertino_icons: ^1.0.8
     json_annotation: ^4.9.0
     flutter_gen: ^5.10.0
     provider: ^6.1.5
     go_router: ^14.8.1
     google_fonts: ^6.2.1
     intl: any

   dev_dependencies:
     flutter_test:
       sdk: flutter
     build_runner: ^2.4.6
     json_serializable: ^6.7.1
     flutter_lints: ^5.0.0
   ```

4. **Ejecuta `flutter pub get` para descargar las dependencias.**

4.1. **Actualiza el paquete agile_front para asegurarte de tener la última versión:**
   ```bash
   dart pub upgrade agile_front
   ```

5. **Genera el código por primera vez:**
   ```bash
   dart run agile_front:core_graphql_cli init
   dart run agile_front:core_graphql_cli generate ${ENDPOINT}
   dart run build_runner build
   ```

6. **Luego de la primera generación, habilita el soporte de generación de recursos en tu `pubspec.yaml`:**
   ```yaml
   flutter:
     generate: true
   ```
   Esto es necesario para que Flutter procese los archivos generados automáticamente (por ejemplo, internacionalización).

## Comandos para generar el código

- Inicializar la estructura base:
  ```bash
  dart run agile_front:core_graphql_cli init
  ```
- Generar código a partir de un endpoint GraphQL:
  ```bash
  dart run agile_front:core_graphql_cli generate ${ENDPOINT}
  ```

## ¿Qué es la variable ENDPOINT?

El **ENDPOINT** es la URL donde tu servidor GraphQL expone su API. Por ejemplo, si tienes un backend corriendo localmente, el endpoint típico podría ser:

```
http://localhost/graphql
```

El generador utiliza este endpoint para obtener el esquema GraphQL y así generar automáticamente el código necesario para tu aplicación Flutter.

## Nota importante sobre build_runner
El código generado depende de modelos con anotaciones (por ejemplo, `json_serializable`). Por lo tanto, **es obligatorio** ejecutar el siguiente comando después de generar el código:
```bash
dart run build_runner build
```
Esto generará los archivos automáticos (`.g.dart`) necesarios para que tu aplicación funcione correctamente.

## Características principales
- Generación automática de modelos, builders, operaciones, usecases, páginas de presentación y rutas GoRouter.
- Soporte para alias, argumentos y directivas en fields y operaciones GraphQL.
- Generación de archivos y carpetas siguiendo convenciones Clean Architecture.
- Opción para omitir la capa de presentación (`--back`).
- Generación de archivos de internacionalización (`.arb`, `l10n.yaml`).
- Compatibilidad multiplataforma.

## Estructura generada
- `lib/src/domain/operation/fields_builders/` — Builders de selección de campos GraphQL
- `lib/src/domain/operation/queries/` — Queries generadas
- `lib/src/domain/operation/mutations/` — Mutations generadas
- `lib/src/presentation/pages/{Entidad}/{crud}/main.dart` — Páginas CRUD
- `lib/src/presentation/core/navigation/routes/` — Archivos de rutas GoRouter
- `lib/l10n/` — Archivos de internacionalización

## Personalización
- Puedes modificar los templates en `lib/src/core/` para adaptar la generación a tus necesidades.
- Los builders soportan argumentos complejos, variables y enums usando las clases auxiliares `GqlVar` y `GqlEnum`.

## Ejemplo de uso de builder

```dart
final builder = UserFieldsBuilder()
  ..id()
  ..name(alias: 'nombreUsuario', args: {'lang': 'es'})
  ..email(
    args: {'id': GqlVar('userId')}, // variable GraphQL
    directives: [Directive('include', {'if': true})],
  )
  ..status(
    args: {'filter': GqlVar('statusFilter')}, // variable GraphQL en otro campo
    directives: [Directive('deprecated', {'reason': GqlEnum('OUTDATED')})],
  )
  ..profile(
    builder: (p) => p
      ..avatar()
      ..address(
        builder: (a) => a
          ..city()
          ..zip(),
      ),
  )
  ..updateProfile(
    args: {
      'input': {
        'displayName': 'Nuevo nombre',
        'age': 30,
        'address': {
          'city': 'Madrid',
          'zip': '28001',
        },
        'tags': ['dev', 'flutter'],
        'isActive': true,
        'role': GqlEnum('ADMIN'),
        'refId': GqlVar('refId'), // variable GraphQL en input
      }
    },
    directives: [Directive('validate', {'strict': true})],
    builder: (b) => b
      ..success()
      ..error(),
  );

final selection = builder.build();
print(selection);
```

Esto generará una selección GraphQL como:

```graphql
id
nombreUsuario: name(lang: "es")
email(id: $userId) @include(if: true)
status(filter: $statusFilter) @deprecated(reason: OUTDATED)
profile { avatar address { city zip } }
updateProfile(
  input: {
    displayName: "Nuevo nombre",
    age: 30,
    address: {city: "Madrid", zip: "28001"},
    tags: ["dev", "flutter"],
    isActive: true,
    role: ADMIN,
    refId: $refId
  }
) @validate(strict: true) { success error }
```

## Clases auxiliares para GraphQL

El generador utiliza clases auxiliares para facilitar la construcción de queries y mutations complejas:

### Directive
Permite agregar directivas GraphQL (como `@include`, `@deprecated`, etc.) a fields u operaciones, con o sin argumentos.

```dart
Directive('include', {'if': true}) // @include(if: true)
Directive('deprecated', {'reason': GqlEnum('OUTDATED')}) // @deprecated(reason: OUTDATED)
```

### GqlVar
Indica que un argumento es una variable GraphQL (por ejemplo, `$userId`). Así, el formateador lo renderiza como variable y no como string literal.

```dart
args: {'id': GqlVar('userId')} // id: $userId
```

### GqlEnum
Permite pasar valores enum de GraphQL, que deben ir sin comillas en la query.

```dart
args: {'status': GqlEnum('ACTIVE')} // status: ACTIVE
```

Estas clases permiten construir queries y mutations seguras, tipadas y compatibles con GraphQL real, evitando errores de formato y facilitando la generación automática de código.

## Licencia
MIT
