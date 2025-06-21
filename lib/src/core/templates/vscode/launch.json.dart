String vscodeLaunchJson = '''{
    "version": "0.2.0",
    "configurations": [
        { 
            "name": "dev",
            "request": "launch",
            "type": "dart",
            "toolArgs": [
                "--dart-define-from-file=.env/dev.json"
            ]
        }
    ]
}''';