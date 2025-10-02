# mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuración del Token de Acceso de Mapbox

Para que la aplicación funcione correctamente con Mapbox, necesitas configurar tu token de acceso. Puedes hacerlo a través del archivo `.vscode/launch.json`.

1.  Abre el archivo `.vscode/launch.json` en tu editor.
2.  Busca la configuración de lanzamiento de Flutter (normalmente la que tiene `"name": "Flutter"` o `"name": "proyecto-consultoria-equipo-4"`).
3.  Dentro de la sección `"args": [...]`, asegúrate de que exista una línea similar a esta, reemplazando `YOUR_MAPBOX_ACCESS_TOKEN` con tu token real de Mapbox:

    ```json
    "--dart-define",
    "ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN"
    ```

    Por ejemplo, tu configuración podría verse así:

    ```json
    {
        "name": "Flutter",
        "type": "dart",
        "request": "launch",
        "program": "lib/main.dart",
        "flutterMode": "debug",
        "args": [
            "--dart-define",
            "ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN"
        ]
    }
    ```

4.  Guarda el archivo `launch.json`.

Esto asegurará que tu token de acceso de Mapbox se pase a la aplicación cuando la ejecutes desde VS Code.
