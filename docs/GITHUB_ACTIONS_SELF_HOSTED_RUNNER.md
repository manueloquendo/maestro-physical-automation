# GitHub Actions con Android USB

Un runner hospedado por GitHub no puede usar tu telefono conectado por USB. Para CI/CD con dispositivo fisico necesitas un runner self-hosted en la maquina donde estara conectado el Android.

## 1. Subir el proyecto a GitHub

Desde la raiz del proyecto:

```powershell
.\scripts\init-github-repo.ps1 -RemoteUrl "https://github.com/ORG/REPO.git"
```

Revisa el listado de archivos que imprime el script. Luego ejecuta los comandos que muestra para crear el commit y subirlo. Reemplaza `ORG/REPO` por tu repositorio real.

## 2. Crear variable del repositorio

En GitHub:

1. Ve a Settings.
2. Entra en Secrets and variables > Actions.
3. Abre la pestana Variables.
4. Crea `APP_ID` con el package name Android, por ejemplo `com.tuempresa.foodapp`.

## 3. Instalar el self-hosted runner

En GitHub:

1. Ve a Settings > Actions > Runners.
2. Click en New self-hosted runner.
3. Selecciona Windows.
4. Sigue los comandos que GitHub muestra para descargar, configurar e instalar el runner.

Durante la configuracion agrega estas labels:

```text
self-hosted, Windows, Android, USB
```

El workflow `.github/workflows/maestro-android-usb.yml` usa esas labels.

## 4. Preparar la maquina runner

En la maquina del runner instala:

- Java 17+
- Android SDK Platform Tools
- Maestro CLI
- Node.js 20+

Conecta el Android por USB y verifica:

```powershell
adb devices
maestro --help
```

Si el runner corre como servicio de Windows, instala Maestro y Android Platform Tools en rutas disponibles para la cuenta del servicio o configura el `PATH` del sistema, no solo el `PATH` del usuario actual.

## 5. Ejecutar CI/CD

El workflow corre automaticamente en `push` y `pull_request` hacia `main`. Tambien puedes correrlo manualmente desde Actions > Maestro Android USB CI > Run workflow.

El job realiza:

1. Checkout del repositorio.
2. Setup de Java 17.
3. Setup de Node.js 20.
4. Validacion del scaffold.
5. Verificacion del dispositivo Android USB.
6. Ejecucion de `maestro test`.
7. Publicacion de reportes como artifacts.
