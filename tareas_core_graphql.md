# Lista de tareas para el core GraphQL en Dart

1. Definir la estructura de carpetas y archivos base del paquete.
2. Implementar la lógica de introspección GraphQL para obtener el esquema.
3. Generar modelos Dart a partir de los tipos, inputs y enums del esquema.
4. Generar routers para queries y mutations, usando los modelos generados.
5. Crear un CLI para automatizar la generación de modelos, routers y carpetas.
6. Integrar soporte offline-first (almacenamiento local y sincronización).
7. Documentar el uso del paquete y ejemplos.
8. Preparar archivos para publicación en pub.dev (README, LICENSE, pubspec.yaml).
9. Incorporar internacionalización (i18n) para soporte multilenguaje.
10. Centralizar el manejo de errores y logging (error_manager.dart, logger.dart).
11. Integrar autenticación y autorización (AuthProvider/AuthManager en core/providers).
12. Centralizar configuración y constantes globales (config.dart o constants.dart en core).
13. Definir estructura y ejemplos para tests unitarios y de integración.
14. Permitir hooks o middlewares para lógica antes/después de acciones clave (por ejemplo, cambio de plantilla o tema).
15. Documentar y proveer ejemplos de uso y guía rápida para nuevos usuarios del core.

# Checklist de implementación inicial

- [ ] Crear la estructura de carpetas y archivos base del paquete.
- [ ] Implementar archivos genéricos en core (datasource_base.dart, repository_base.dart, app_router.dart, theme_manager.dart, template_manager.dart, etc.).
- [ ] Crear subcarpetas y archivos para temas (themes/) y plantillas (templates/).
- [ ] Implementar providers globales (ThemeProvider, AuthProvider, etc.).
- [ ] Agregar archivos para internacionalización (i18n/), manejo de errores (error_manager.dart), logging (logger.dart) y configuración global (config.dart).
- [ ] Crear la estructura y un ejemplo de módulo (por ejemplo, "ejemplo").
- [ ] Implementar la lógica de introspección GraphQL para obtener el esquema.
- [ ] Generar modelos Dart a partir de los tipos, inputs y enums del esquema.
- [ ] Generar routers para queries y mutations, usando los modelos generados.
- [ ] Crear un CLI para automatizar la generación de modelos, routers y carpetas.
- [ ] Integrar soporte offline-first (almacenamiento local y sincronización).
- [ ] Definir estructura y ejemplos para tests unitarios y de integración.
- [ ] Permitir hooks o middlewares para lógica antes/después de acciones clave.
- [ ] Documentar y proveer ejemplos de uso y guía rápida para nuevos usuarios del core.
- [ ] Preparar archivos para publicación en pub.dev (README, LICENSE, pubspec.yaml).

## Flujo de selección de plantillas desde los routers

- Cada router de módulo define qué presentación (pantalla) cargar y qué plantilla debe usarse para esa presentación.
- Al navegar a una ruta, el router llama a `TemplateManager.setTemplate('nombrePlantilla')` antes de mostrar la pantalla.
- El `TemplateManager` actualiza la plantilla activa.
- El widget raíz de la aplicación escucha los cambios del `TemplateManager` y aplica la plantilla correspondiente.

**Ventajas:**
- Centraliza la lógica de selección de plantilla en los routers.
- El TemplateManager solo aplica el cambio, manteniendo la lógica desacoplada.
- Fácil de mantener y escalar: agregar una nueva presentación solo requiere definir su plantilla en el router correspondiente.

**Ejemplo conceptual:**
```dart
// En el router de un módulo
void navigateToVisitas() {
  TemplateManager.instance.setTemplate('dashboard');
  Navigator.push(context, MaterialPageRoute(builder: (_) => VisitasPage()));
}
```
