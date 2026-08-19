# Instalacion local para Android fisico por USB

Esta guia asume Windows 10/11 y un dispositivo Android real conectado por USB.

## 1. Instalar Java 17+

Instala Temurin JDK 17 o superior:

```powershell
winget install EclipseAdoptium.Temurin.17.JDK
```

Verifica:

```powershell
java -version
```

Configura `JAVA_HOME` si tu instalador no lo hizo automaticamente.

## 2. Instalar Android SDK Platform Tools

Opcion con Android Studio:

1. Instala Android Studio.
2. Abre SDK Manager.
3. Instala Android SDK Platform-Tools.
4. Agrega `platform-tools` al `PATH`.

Opcion manual:

1. Descarga Platform Tools desde la documentacion oficial de Android.
2. Extrae en una ruta estable, por ejemplo `C:\Android\platform-tools`.
3. Agrega esa ruta al `PATH`.

Verifica:

```powershell
adb version
```

## 3. Configurar el dispositivo Android

1. Activa Developer Options.
2. Activa USB Debugging.
3. Conecta el dispositivo por USB.
4. Acepta la huella RSA en el telefono.
5. Verifica que aparezca como `device`:

```powershell
adb devices
```

Tambien puedes usar:

```powershell
.\scripts\check-android-device.ps1
```

## 4. Instalar Maestro CLI

Requisito: Java 17+.

En Windows:

Opcion automatizada desde este proyecto:

```powershell
.\scripts\install-maestro-windows.ps1
```

Luego cierra y abre una nueva terminal.

Opcion manual:

1. Descarga el ultimo `maestro.zip` desde `https://github.com/mobile-dev-inc/Maestro/releases`.
2. Extrae el ZIP en una ruta estable, por ejemplo `C:\maestro`.
3. Agrega `C:\maestro\bin` al `PATH`.
4. Cierra y abre una nueva terminal.

Verifica:

```powershell
maestro --help
```

En macOS o Linux:

```bash
curl -fsSL "https://get.maestro.mobile.dev" | bash
```

## 5. Configurar APP_ID

Identifica el package name de la app Android. Si la app ya esta instalada:

```powershell
adb shell pm list packages | Select-String "food"
```

Copia `.env.example` a `.env` y reemplaza:

```text
APP_ID=com.tuempresa.foodapp
```

Para ejecutar desde PowerShell tambien puedes pasar el valor directamente:

```powershell
.\scripts\run-maestro.ps1 -AppId "com.tuempresa.foodapp"
```

## 6. Ejecutar pruebas

Todos los flujos:

```powershell
.\scripts\run-maestro.ps1 -AppId "com.tuempresa.foodapp"
```

Un flujo puntual:

```powershell
.\scripts\run-maestro.ps1 -AppId "com.tuempresa.foodapp" -FlowPath ".maestro\flows\authentication\04-successful-login.yaml"
```

Los reportes quedan en `reports/maestro`.
