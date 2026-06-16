<div align="center">

# 🌐 ChromeControl

### Debloat de Google Chrome en un clic — desde una GUI con tema oscuro

*Adiós Gemini, Privacy Sandbox, telemetría y demás extras… sin tocar `regedit` a mano.*

<br>

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Chrome](https://img.shields.io/badge/Chrome-28_interruptores-4285F4?style=for-the-badge&logo=googlechrome&logoColor=white)
![License](https://img.shields.io/badge/Licencia-MIT-3DA639?style=for-the-badge)

</div>

---

## ✨ ¿Qué es?

**ChromeControl** es una herramienta gráfica de PowerShell que gestiona las **políticas de empresa de Google Chrome** desde el registro de Windows. En lugar de bucear por `regedit`, te presenta una lista de interruptores: **todo viene encendido** (como en una instalación normal) y tú **apagas lo que quieras desactivar**.

```powershell
irm https://raw.githubusercontent.com/xdoofy92/ChromeControl/main/ChromeControl.ps1 | iex
```

> 💡 Pégalo en una terminal **PowerShell como administrador** y listo. Se descarga, pide elevación y abre la ventana.

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

## 🚀 Instalación y uso

### Opción A — Directo desde GitHub *(recomendada)*

```powershell
irm https://raw.githubusercontent.com/xdoofy92/ChromeControl/main/ChromeControl.ps1 | iex
```

### Opción B — Local

```powershell
git clone https://github.com/xdoofy92/ChromeControl.git
cd ChromeControl
.\ChromeControl.ps1
```

### Pasos típicos

1. **Apaga** los interruptores de lo que no quieras (o pulsa **Desact. todo**).
2. Pulsa **Aplicar**.
3. **Reinicia Chrome** para que los cambios surtan efecto.

<details>
<summary>🛠️ ¿Error de "ejecución de scripts deshabilitada"?</summary>

<br>

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
- ⚠️ La ejecución `irm … | iex` descarga y ejecuta el script **como administrador**. Si prefieres revisarlo antes, usa la **Opción B** y léelo.

---

## 🤝 Contribuir

¿Una política nueva, un bug, una mejora de UI? ¡Bienvenido!

1. Haz *fork* del repositorio
2. Crea una rama: `git checkout -b feature/mi-mejora`
3. *Commit*: `git commit -m 'Añade mi mejora'`
4. *Push*: `git push origin feature/mi-mejora`
5. Abre un *Pull Request*

---

## 📝 Notas

- 🔄 **Reinicia Chrome** tras aplicar para ver los cambios.
- 🔒 Las políticas **persisten** hasta que las elimines (encender + Aplicar, o el botón **Default**).
- 🧪 Los nombres de política pueden variar entre versiones de Chrome. Las funciones de IA (`GenAiDefaultSettings`, `GeminiSettings`, etc.) requieren versiones recientes.

---

<div align="center">

**Licencia MIT** · Hecho por **[xdoofy92](https://github.com/xdoofy92)**

🔗 [Políticas de Google Chrome](https://chromeenterprise.google/policies/) · [Chromium](https://github.com/chromium/chromium)

⭐ *Si te resulta útil, deja una estrella en el repositorio* ⭐

</div>
