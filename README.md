<div align="center">

# 🌐 ChromeControl

### Debloat de Google Chrome en un clic — desde una GUI con tema oscuro

*Adiós Gemini, Privacy Sandbox, telemetría y demás extras… sin tocar `regedit` a mano.*

<br>

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Chrome](https://img.shields.io/badge/Chrome-28_interruptores-4285F4?style=for-the-badge&logo=googlechrome&logoColor=white)
[![Licencia propietaria](https://img.shields.io/badge/Licencia-Propietaria-3DA639?style=for-the-badge)](<LICENSE.txt>)

</div>

---

## ✨ ¿Qué es?

**ChromeControl** es una herramienta gráfica de PowerShell que gestiona las **políticas de empresa de Google Chrome** desde el registro de Windows. En lugar de bucear por `regedit`, te presenta una lista de interruptores: **todo viene encendido** (como en una instalación normal) y tú **apagas lo que quieras desactivar**.

> 💡 Consulta la disponibilidad y las vías de obtención autorizadas en [DProjects](https://dprojects.org/) o contacta con [Daniel Rodriguez](https://xdoofy92.com/). Software propietario, de código cerrado y uso gratuito, también profesional y empresarial, según la [licencia](<LICENSE.txt>).

---

## 🎛️ Cómo funciona

La app refleja el **estado real** de cada característica con un interruptor estilo switch:

| Estado | Aspecto | Significado |
|:------:|:--------|:------------|
| 🟢 **Encendido** | verde, texto normal | La característica está **activa** (valor por defecto del navegador) |
| ⚪ **Apagado** | gris, texto atenuado | Se **desactivará** al pulsar **Aplicar** (escribe la política en el registro) |

El contador de la cabecera (**`0 / 28 a Desactivar`**) te dice cuántas tienes marcadas para apagar. Al pulsar **Aplicar**, los cambios se guardan en:

```
HKLM:\SOFTWARE\Policies\Google\Chrome
```

> 🔁 Volver a **encender** un interruptor + **Aplicar** elimina la política → la característica regresa a su estado original.

### 🔘 Botones

| Botón | Acción |
|:------|:-------|
| **Activar todo** | Enciende todos los interruptores (estado por defecto) |
| **Desact. todo** | Los apaga todos → *debloat completo* en un clic |
| **Default** | Elimina la clave de políticas → Chrome deja de salir *administrado por tu organización* |
| **Aplicar** | Guarda los cambios *(reinicia Chrome para que surtan efecto)* |

---

## 🧩 Características que puedes desactivar

> 28 interruptores en un único listado, todos encendidos por defecto. Aquí los agrupamos por tema para que sea más fácil de leer.

### 🤖 IA y Gemini

| Característica | Qué apaga | Clave(s) de registro |
|:--------------|:----------|:------------------|
| Gemini e IA generativa | Gemini en Chrome y funciones de IA (escritura, temas, organizador de pestañas, búsqueda en historial) | `GenAiDefaultSettings`, `GeminiSettings`, `TabOrganizerSettings`, `HelpMeWriteSettings`, `CreateThemesSettings`, `HistorySearchSettings` |

### 🪧 Publicidad y Privacy Sandbox

| Característica | Qué apaga | Clave(s) de registro |
|:--------------|:----------|:------------------|
| Privacy Sandbox (anuncios) | API Topics, anuncios por interés, medición publicitaria y su ventana de bienvenida | `PrivacySandboxAdTopicsEnabled`, `PrivacySandboxSiteEnabledAdsEnabled`, `PrivacySandboxAdMeasurementEnabled`, `PrivacySandboxPromptEnabled` |

### 📡 Telemetría y diagnóstico

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Telemetría de uso (Metrics) | Envío de estadísticas de uso e informes de fallos | `MetricsReportingEnabled` |
| Datos anónimos por URL | Recopilación de datos asociados a las URLs visitadas | `UrlKeyedAnonymizedDataCollectionEnabled` |
| Corrector ortográfico de Google | Corrección mejorada que envía tu texto a Google | `SpellCheckServiceEnabled` |
| Encuestas de opinión (Feedback) | Encuestas de satisfacción dentro del navegador | `FeedbackSurveysEnabled` |
| Informes de fiabilidad (Domain Rel.) | Informes de fiabilidad de red enviados a Google | `DomainReliabilityAllowed` |
| Experimentos / Variations | Pruebas de funciones (field trials) de Google | `ChromeVariations` |
| Subida de registros WebRTC | Envío de registros de eventos WebRTC a Google | `WebRtcEventLogCollectionAllowed` |

### 🔎 Búsqueda y barra de direcciones

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Sugerencias de búsqueda | Sugerencias mientras escribes (envían datos a Google) | `SearchSuggestEnabled` |
| Predicción de red (prefetch) | Precarga de páginas y resolución DNS anticipada | `NetworkPredictionOptions` |
| Páginas de error alternativas | Sugerencias de Google al fallar la navegación | `AlternateErrorPagesEnabled` |

### 👤 Cuenta y sincronización

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Forzar inicio de sesión | Inicio de sesión con cuenta de Google en el navegador | `BrowserSignin` |
| Sincronización de navegación | Sincronización con la cuenta de Google | `SyncDisabled` |

### 💳 Autocompletar y pagos

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Gestor de contraseñas | Guardado y autocompletado de contraseñas | `PasswordManagerEnabled` |
| Autocompletar direcciones | Autocompletado de direcciones y datos de contacto | `AutofillAddressEnabled` |
| Autocompletar tarjetas | Guardado y autocompletado de tarjetas de crédito | `AutofillCreditCardEnabled` |
| Consulta de métodos de pago | Permite a los sitios saber si tienes pagos guardados | `PaymentMethodQueryEnabled` |

### 🧹 Molestias y funciones extra

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Modo en segundo plano | Chrome sigue ejecutándose al cerrar la ventana | `BackgroundModeEnabled` |
| Pestañas promocionales / What's New | Páginas promocionales y de novedades tras actualizar | `PromotionalTabsEnabled` |
| Aviso de navegador predeterminado | Insistencia para fijar Chrome como predeterminado | `DefaultBrowserSettingEnabled` |
| Página de bienvenida (actualizar) | Página de bienvenida al actualizar el sistema | `WelcomePageOnOSUpgradeEnabled` |
| Lista de compras y precios | Lista de compras y seguimiento de precios | `ShoppingListEnabled` |
| Sugerencias de contenido (NTP) | Tarjetas de contenido en la página de nueva pestaña | `NTPCardsVisible` |
| Recomendaciones multimedia | Recomendaciones de medios en la nueva pestaña | `MediaRecommendationsEnabled` |

### 🕵️ Privacidad y seguridad

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Bloquear cookies de terceros | Mantiene **bloqueadas** las cookies de seguimiento de terceros | `BlockThirdPartyCookies` |
| Conjuntos de sitios relacionados | Related Website Sets (cookies compartidas entre dominios) | `RelatedWebsiteSetsEnabled` |
| Navegación segura (Safe Browsing) | Filtro anti-phishing (envía URLs a Google) | `SafeBrowsingProtectionLevel` |

> ⚠️ **Ojo con las dos últimas.** *Bloquear cookies de terceros* es positivo para la privacidad, pero apagar **Navegación segura** (Safe Browsing) **reduce tu protección** contra phishing y malware. Desactívala solo si sabes lo que haces.

---

## 🚀 Obtención y uso

### Canales oficiales

Consulta [DProjects](https://dprojects.org/) para conocer las copias oficiales disponibles y sus instrucciones, o solicita información al [autor](https://xdoofy92.com/). Este repositorio contiene un script, no un instalador; esta documentación no afirma que exista un instalador oficial publicado.

### Uso local — solo con una copia autorizada

Solo si el titular te ha proporcionado o autorizado expresamente una copia local del [script](<ChromeControl.ps1>), abre PowerShell en la carpeta donde la guardaste y ejecuta:

```powershell
.\ChromeControl.ps1
```

Esta indicación no concede permiso para obtener, modificar ni redistribuir el código. El script no es un instalador y no está incluido en el permiso general de redistribución.

### Pasos típicos

1. **Apaga** los interruptores de lo que no quieras (o pulsa **Desact. todo**).
2. Pulsa **Aplicar**.
3. **Reinicia Chrome** para que los cambios surtan efecto.

<details>
<summary>🛠️ ¿Error de "ejecución de scripts deshabilitada"?</summary>

<br>

Las siguientes opciones solo se aplican a la copia local proporcionada o expresamente autorizada por el titular. Respeta las políticas de seguridad de tu organización.

**Permanente (usuario actual):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Temporal (solo esta vez):**
```powershell
powershell -ExecutionPolicy Bypass -File .\ChromeControl.ps1
```

`RemoteSigned` es más segura que `Unrestricted`: permite scripts locales y scripts firmados de internet.

</details>

---

## ⚙️ Bajo el capó

- **Auto-elevación**: solicita privilegios de administrador automáticamente (necesarios para escribir en `HKLM`).
- **Interfaz**: Windows Forms con tema oscuro e interruptores dibujados a mano (anti-aliasing).
- **Tipo de valores**: todas las políticas se aplican como `DWord` (32 bits).
- **Multi-clave**: algunas filas (Gemini, Privacy Sandbox) escriben **varias** claves a la vez con un solo interruptor.
- **Reversible**: desmarcar y aplicar **elimina** la clave; no deja residuos.

---

## 🛡️ Seguridad y privacidad

- Solo toca claves bajo `HKLM\SOFTWARE\Policies\Google\Chrome`. **No** modifica otros navegadores ni el sistema.
- **No** recopila ni transmite ningún dato tuyo.
- ⚠️ Usa únicamente copias proporcionadas o autorizadas por el titular. La app solicita permisos de **administrador**; confirma su procedencia antes de ejecutarla.
- La implementación conserva una ruta de descarga remota para la auto-elevación cuando se ejecuta sin archivo local. No se documenta como vía pública de obtención ni concede permiso para distribuir scripts.

---

## 🤝 Sugerencias y desarrollo autorizado

¿Una política nueva, un bug, una mejora de UI? Envía tus sugerencias mediante los canales de [DProjects](https://dprojects.org/) o del [autor](https://xdoofy92.com/).

El desarrollo y cualquier instrucción técnica para modificar el proyecto se reservan al titular y a colaboradores **expresamente autorizados por escrito**, dentro del alcance de ese permiso. La visibilidad del repositorio no constituye una concesión pública para modificar, copiar para terceros ni redistribuir su código.

---

## 📄 Licencia y distribución

**Daniel Rodriguez (DProjects)** es el titular y desarrollador. Software **propietario y de código cerrado**, bajo la [licencia propietaria de uso gratuito](<LICENSE.txt>):

- Uso gratuito de copias oficiales, también **profesional y empresarial**.
- No se permite **modificar, vender ni revender** el programa sin autorización previa y por escrito del titular. Ajustar preferencias con las funciones de la app no es modificar el programa.
- Cualquiera puede redistribuir **gratis únicamente el instalador oficial publicado por DProjects**, completo e intacto, conservando autoría, licencia y avisos de terceros, indicando [la web oficial](https://dprojects.org/) y cumpliendo las demás condiciones de la licencia. No se permite cobrar ni reempaquetarlo.
- Ese permiso **no incluye scripts sueltos ni código fuente**; requieren autorización previa y por escrito. Siempre puedes compartir el enlace a la web oficial. No se afirma aquí que exista un instalador publicado.
- Los componentes y marcas de terceros conservan sus licencias, avisos y derechos. La licencia no restringe los permisos propios de esos componentes.
- Estos términos se aplican a las versiones distribuidas bajo ellos: **no revocan retroactivamente** derechos concedidos legítimamente sobre versiones anteriores bajo otras licencias.

---

## 📝 Notas

- 🔄 **Reinicia Chrome** tras aplicar para ver los cambios.
- 🔒 Las políticas **persisten** hasta que las elimines (encender + Aplicar, o el botón **Default**).
- 🧪 Los nombres de política pueden variar entre versiones de Chrome. Las funciones de IA (`GenAiDefaultSettings`, `GeminiSettings`, etc.) requieren versiones recientes.

---

<div align="center">

**[Licencia propietaria de uso gratuito](<LICENSE.txt>)** · Hecho por **[Daniel Rodriguez](https://xdoofy92.com/)** · **[DProjects](https://dprojects.org/)**

🔗 [Políticas de Google Chrome](https://chromeenterprise.google/policies/) · [Chromium](https://github.com/chromium/chromium)

⭐ *Si te resulta útil, deja una estrella en el repositorio* ⭐

</div>
