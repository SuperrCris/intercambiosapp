# Contexto del proyecto

## Resumen

`intercambioapp` es una aplicación multiplataforma hecha con Flutter/Dart para el intercambio navideño de la familia Gutierrada. La interfaz está en español y Firebase es el servicio remoto para participantes y fotos.

Actualmente la app permite **inscribirse y consultar la lista de participantes**. No realiza todavía sorteos, asignaciones de regalos, autenticación ni administración de participantes.

## Estructura importante

- `lib/main.dart`: aplicación, pantalla principal, galería de participantes, formulario de inscripción y acceso a Firestore/Storage. La mayor parte de la lógica está concentrada aquí.
- `lib/firebase_options.dart`: configuración generada para conectar Firebase en cada plataforma.
- `recursos/burro.png`: imagen de reemplazo cuando un participante no agregó foto o la foto no se puede cargar.
- `recursos/fortalesa.otf`: tipografía usada en el encabezado principal.
- `pubspec.yaml`: dependencias, recursos y tipografías de Flutter.
- `FIRESTORE_SETUP.md`: pasos para configurar Firestore y Firebase Storage, reglas sugeridas y estructura de documentos.
- `STORAGE_CORS_FIX.md`: diagnóstico de CORS para imágenes en Firebase Storage en la web.
- `test/widget_test.dart`: prueba de widget del encabezado festivo y su borde dibujado.

## Flujo de inicio y navegación

1. `main()` inicializa Flutter y Firebase antes de abrir `MyApp`.
2. `MyApp` configura `MaterialApp` y muestra `MyHomePage`.
3. La pantalla principal consulta la colección `participantes`, presenta el listado y el botón **Participar**.
4. El botón abre `RegistrationPage`.
5. Al completar una inscripción, la app vuelve a la pantalla principal después de mostrar un diálogo con el identificador generado.

## Datos y servicios

### Firestore

- Colección: `participantes`.
- El ID de cada documento es un número aleatorio de 8 dígitos, comprobado previamente contra Firestore.
- Campos guardados:
  - `nombre`: nombre capturado en el formulario.
  - `photoUrl`: URL de descarga de Storage o `null` si no se seleccionó foto.
  - `createdAt`: marca de tiempo del servidor.
- La lista se obtiene con `descargarParticipantes()`, ordenada por `createdAt` ascendente. Se presenta el nombre y la foto, no el ID.

### Firebase Storage e imágenes

- La foto es opcional y se elige desde la galería del dispositivo.
- El selector limita la imagen a 512 × 512 y calidad 80.
- Las imágenes se suben a Storage usando el ID como nombre (`{id}.png`) y la URL resultante se guarda en Firestore.
- En web se leen bytes con `XFile.readAsBytes()`; en otras plataformas se sube el archivo local.
- Las imágenes ausentes o que fallan al cargar muestran `recursos/burro.png`.
- Verificar que las reglas de Storage acepten el tipo de imagen que entrega el selector: aunque la ruta se guarda con extensión `.png`, el formato real elegido puede variar.

## Interfaz actual

- Fondo verde oscuro con un patrón de árboles navideños; encabezados rojos con texto blanco.
- Las pantallas incluyen adornos navideños recortados en `recursos/bordes_superior_izquierdo.png` y `recursos/bordes_inferior_derecho.png`, anclados directamente a las esquinas sin márgenes transparentes. El adorno inferior se mantiene reducido para no invadir el pie ni la galería.
- El encabezado principal y el del formulario tienen una franja inferior de bastón de caramelo SVG; el contenedor del botón de participación tiene la misma franja en la parte superior. El recurso está en `recursos/candy_cane_border.svg`.
- Los participantes se muestran en dos columnas de impresiones tipo Polaroid, con pequeñas rotaciones y alturas/desplazamientos variados para un efecto escalonado.
- Si no hay participantes se muestra un estado vacío; la pantalla de inscripción permite registrar un nombre y una foto opcional.

## Desarrollo y comprobaciones

Desde la raíz del proyecto:

```shell
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

La app requiere que el proyecto de Firebase esté habilitado y que sus reglas permitan las operaciones previstas. La guía de configuración está en `FIRESTORE_SETUP.md`. Para inspeccionar o modificar el flujo principal, empezar por `lib/main.dart`; mantener sincronizados el formato de datos, la carga de imágenes y las reglas de Firebase.
