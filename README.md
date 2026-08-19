# Maestro Mobile Automation - Android USB

Proyecto base de automatizacion mobile con Maestro, YAML, JavaScript y GitHub Actions para ejecutar pruebas en un dispositivo Android fisico conectado por USB.

El documento compartido contiene 10 casos de prueba. Este proyecto incluye esos 10 flujos en `.maestro/flows`. Si existe un caso 11 adicional, agregalo siguiendo el patron de los flujos existentes.

## Stack

- Maestro CLI
- YAML para los flujos de prueba
- JavaScript para datos reutilizables de prueba
- Android Debug Bridge (`adb`) para dispositivo fisico por USB
- GitHub Actions con runner self-hosted conectado al dispositivo Android

## Requisitos locales

- Windows 10/11
- Java 17+
- Android SDK Platform Tools (`adb`)
- Maestro CLI
- Dispositivo Android fisico con Developer Options y USB Debugging habilitado
- Git
- Node.js 20+ opcional, util para scripts y mantenimiento del proyecto

## Inicio rapido

1. Instala los requisitos siguiendo [docs/INSTALLATION.md](docs/INSTALLATION.md).
2. Copia `.env.example` a `.env` y ajusta `APP_ID`.
3. Conecta el Android por USB y acepta la huella RSA en el dispositivo.
4. Verifica el dispositivo:

```powershell
.\scripts\check-android-device.ps1
```

5. Ejecuta todos los flujos:

```powershell
.\scripts\run-maestro.ps1 -AppId "com.tuempresa.foodapp"
```

6. Ejecuta un flujo puntual:

```powershell
.\scripts\run-maestro.ps1 -AppId "com.tuempresa.foodapp" -FlowPath ".maestro\flows\authentication\01-blank-fields-validation.yaml"
```

7. Prepara el repositorio para GitHub:

```powershell
.\scripts\init-github-repo.ps1 -RemoteUrl "https://github.com/ORG/REPO.git"
```

## Estructura

```text
.github/workflows/          GitHub Actions para runner self-hosted
.maestro/flows/             Flujos Maestro en YAML
.maestro/scripts/           Datos JavaScript reutilizables por los flujos
docs/                       Guias de instalacion, CI y trazabilidad
scripts/                    Scripts PowerShell para validar y ejecutar
```

## GitHub Actions

Los runners hospedados por GitHub no pueden acceder a tu telefono conectado por USB. Para CI/CD con dispositivo fisico necesitas un runner self-hosted instalado en la maquina donde estara conectado el Android.

Guia completa: [docs/GITHUB_ACTIONS_SELF_HOSTED_RUNNER.md](docs/GITHUB_ACTIONS_SELF_HOSTED_RUNNER.md).
