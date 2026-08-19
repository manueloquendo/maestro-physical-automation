# Trazabilidad de casos de prueba

El documento compartido indica `Total test cases: 10`. Los flujos creados son:

| # | Caso | Flujo Maestro |
|---|---|---|
| 1 | Mobile Sign In - Blank Fields Validation | `.maestro/flows/authentication/01-blank-fields-validation.yaml` |
| 2 | Mobile Sign In - Authentication Failure with Incorrect Password | `.maestro/flows/authentication/02-incorrect-password.yaml` |
| 3 | Mobile Sign In - Invalid Email Format Validation | `.maestro/flows/authentication/03-invalid-email-format.yaml` |
| 4 | Mobile Sign In - Successful Authentication | `.maestro/flows/authentication/04-successful-login.yaml` |
| 5 | Mobile Forgot Password - Navigation and Email Validation | `.maestro/flows/forgot-password/01-navigation-and-validation.yaml` |
| 6 | Forgot Password - Successful Password Reset Request | `.maestro/flows/forgot-password/02-successful-reset.yaml` |
| 7 | Forgot Password - Reset Request for Unregistered Email Address | `.maestro/flows/forgot-password/03-unregistered-email.yaml` |
| 8 | Sign Up - Mandatory Form Fields Validation | `.maestro/flows/sign-up/01-mandatory-fields-validation.yaml` |
| 9 | Sign Up - Mismatched Passwords Validation | `.maestro/flows/sign-up/02-mismatched-passwords.yaml` |
| 10 | Sign Up - Privacy Policy and Terms & Conditions Acceptance Validation | `.maestro/flows/sign-up/03-terms-and-privacy-validation.yaml` |

## Ajustes esperados por aplicacion

Los locators del documento original son Appium/WebdriverIO. Maestro trabaja principalmente con texto visible, ids y jerarquia accesible. Por eso los flujos usan los textos visibles del documento como selectores iniciales.

Antes de dejar el CI como obligatorio, valida cada pantalla con Maestro Studio o con `maestro test` y ajusta los textos si la app expone variantes como `My Store` en lugar de `MyStore`, `Ok` en lugar de `OK`, o nombres distintos para `Forgot Email or Password`.
