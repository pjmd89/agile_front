String pubSpec = r'''name: ${your_project}
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.8.1

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

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  generate: true''';