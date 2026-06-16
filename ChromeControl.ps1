# ChromeControl - Gestor grafico de politicas de Google Chrome via registro de Windows
# Autor: Daniel Rodriguez | https://xdoofy92.com

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# ─── Auto-elevacion a administrador ──────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if (-not $PSCommandPath) {
        # Ejecucion remota (irm | iex): descargar y relanzar como admin
        $url = "https://raw.githubusercontent.com/xdoofy92/ChromeControl/main/ChromeControl.ps1"
        $scriptContent = Invoke-RestMethod -Uri $url
        $tempFile = Join-Path $env:TEMP "ChromeControl_$([guid]::NewGuid().ToString('N')).ps1"
        $scriptContent | Out-File $tempFile -Encoding UTF8
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`""
        exit
    } else {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

# ─── Identidad de la app ─────────────────────────────────────────────────────
$REG_PATH  = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$APP_TITLE = "ChromeControl - dprojects.org"
$APP_NAME  = "ChromeControl"
$APP_SUB   = "Politicas de Google Chrome via registro"
$BROWSER   = "Google Chrome"

# ─── Paleta (compartida con BraveControl/EdgeControl, solo cambia el acento) ──
$BG       = [Drawing.Color]::FromArgb(17, 17, 20)
$CARD     = [Drawing.Color]::FromArgb(26, 26, 30)
$CARD2    = [Drawing.Color]::FromArgb(32, 32, 37)
$HOVER    = [Drawing.Color]::FromArgb(40, 40, 46)
$GRPBG    = [Drawing.Color]::FromArgb(22, 22, 26)
$BORDER   = [Drawing.Color]::FromArgb(46, 46, 54)
$FG       = [Drawing.Color]::FromArgb(232, 232, 236)
$MUTED    = [Drawing.Color]::FromArgb(140, 140, 150)
$GREEN    = [Drawing.Color]::FromArgb(86, 196, 138)
$RED      = [Drawing.Color]::FromArgb(232, 100, 100)
$TOG_OFF  = [Drawing.Color]::FromArgb(62, 62, 72)
$ACCENT   = [Drawing.Color]::FromArgb(66, 133, 244)    # Azul Google Chrome
$ACC_HOV  = [Drawing.Color]::FromArgb(90, 152, 250)
$ACC_DWN  = [Drawing.Color]::FromArgb(50, 110, 210)

# ─── Tipografias ─────────────────────────────────────────────────────────────
$FONT_TITLE = [Drawing.Font]::new("Segoe UI", 15, [Drawing.FontStyle]::Bold)
$FONT_SUB   = [Drawing.Font]::new("Segoe UI Semibold", 8.5)
$FONT_BODY  = [Drawing.Font]::new("Segoe UI", 9.5)
$FONT_DESC  = [Drawing.Font]::new("Segoe UI", 7.75)
$FONT_BTN   = [Drawing.Font]::new("Segoe UI Semibold", 9)
$FONT_CNT   = [Drawing.Font]::new("Segoe UI", 9, [Drawing.FontStyle]::Bold)
$FONT_STAT  = [Drawing.Font]::new("Segoe UI", 7.75)

# ─── Geometria ───────────────────────────────────────────────────────────────
$W_FORM = 462; $H_FORM = 632
$W_PANEL = 418
$W_ROW = 392; $X_ROW = 6; $H_ROW = 46
$TOG_W = 40; $TOG_H = 22
$X_TOG = $W_ROW - $TOG_W - 12
$X_TXT = 14
$W_TXT = $X_TOG - $X_TXT - 10

# Nota: NO creamos $REG_PATH al arrancar. La clave se crea solo cuando se aplica
# alguna politica (ver Set-Policies). Asi, tras pulsar "Default" la clave queda
# realmente eliminada y Chrome no muestra "Administrado por su organizacion".

# ─── Caracteristicas (listado unico, estilo debloat) ─────────────────────────
# Logica: el toggle refleja el estado de la caracteristica.
#   ON  (verde) = activada (estado normal)        Off = valor "activado" / no configurada
#   OFF (gris)  = se desactivara al pulsar Aplicar  -> escribe Val en el registro
# Formato: Nombre = @{ Key; Val=valor desactivado; Opp=valor activado; T=tipo; Desc }
$POLICIES = [ordered]@{
    # ── IA y Gemini ──
    # GenAiDefaultSettings = 2 desactiva en bloque las funciones de IA generativa.
    # GeminiSettings = 1 desactiva el panel de Gemini. Las demas son por-funcion.
    "Gemini e IA generativa"              = @{ Desc = "Gemini en Chrome y funciones de IA (escritura, temas, pestanas)"; KeySet = @(
        @{ Key = "GenAiDefaultSettings";   Val = 2; Opp = 0; T = "DWord" }   # interruptor maestro de IA generativa
        @{ Key = "GeminiSettings";         Val = 1; Opp = 0; T = "DWord" }   # panel lateral de Gemini
        @{ Key = "TabOrganizerSettings";   Val = 2; Opp = 0; T = "DWord" }   # organizador de pestanas con IA
        @{ Key = "HelpMeWriteSettings";    Val = 2; Opp = 0; T = "DWord" }   # "Ayudame a escribir"
        @{ Key = "CreateThemesSettings";   Val = 2; Opp = 0; T = "DWord" }   # crear temas con IA
        @{ Key = "HistorySearchSettings";  Val = 2; Opp = 0; T = "DWord" }   # busqueda en historial con IA
    ) }
    # ── Privacy Sandbox (publicidad basada en interes) ──
    "Privacy Sandbox (anuncios)"          = @{ Desc = "Topics, anuncios por interes y medicion publicitaria de Google"; KeySet = @(
        @{ Key = "PrivacySandboxAdTopicsEnabled";        Val = 0; Opp = 1; T = "DWord" }   # API Topics (categorias de interes)
        @{ Key = "PrivacySandboxSiteEnabledAdsEnabled";  Val = 0; Opp = 1; T = "DWord" }   # anuncios sugeridos por el sitio
        @{ Key = "PrivacySandboxAdMeasurementEnabled";   Val = 0; Opp = 1; T = "DWord" }   # medicion de anuncios
        @{ Key = "PrivacySandboxPromptEnabled";          Val = 0; Opp = 1; T = "DWord" }   # ventana de bienvenida de Privacy Sandbox
    ) }
    # ── Telemetria y diagnostico ──
    "Telemetria de uso (Metrics)"         = @{ Key = "MetricsReportingEnabled";                Val = 0; Opp = 1; T = "DWord"; Desc = "Envio de estadisticas de uso e informes de fallos" }
    "Datos anonimos por URL"              = @{ Key = "UrlKeyedAnonymizedDataCollectionEnabled"; Val = 0; Opp = 1; T = "DWord"; Desc = "Recopilacion de datos asociados a URLs visitadas" }
    "Corrector ortografico de Google"     = @{ Key = "SpellCheckServiceEnabled";               Val = 0; Opp = 1; T = "DWord"; Desc = "Correccion ortografica mejorada (envia texto a Google)" }
    "Encuestas de opinion (Feedback)"     = @{ Key = "FeedbackSurveysEnabled";                 Val = 0; Opp = 1; T = "DWord"; Desc = "Encuestas de satisfaccion dentro del navegador" }
    # ── Busqueda y barra de direcciones ──
    "Sugerencias de busqueda"             = @{ Key = "SearchSuggestEnabled";                   Val = 0; Opp = 1; T = "DWord"; Desc = "Sugerencias mientras escribes (envian datos a Google)" }
    "Prediccion de red (prefetch)"        = @{ Key = "NetworkPredictionOptions";               Val = 2; Opp = 0; T = "DWord"; Desc = "Precarga de paginas y resolucion DNS anticipada" }
    # ── Cuenta y sincronizacion ──
    "Forzar inicio de sesion"             = @{ Key = "BrowserSignin";                          Val = 0; Opp = 1; T = "DWord"; Desc = "Inicio de sesion con cuenta de Google en el navegador" }
    "Sincronizacion de navegacion"        = @{ Key = "SyncDisabled";                           Val = 1; Opp = 0; T = "DWord"; Desc = "Sincronizacion con la cuenta de Google" }
    # ── Autocompletar y pagos ──
    "Gestor de contrasenas"               = @{ Key = "PasswordManagerEnabled";                 Val = 0; Opp = 1; T = "DWord"; Desc = "Guardado y autocompletado de contrasenas" }
    "Autocompletar direcciones"           = @{ Key = "AutofillAddressEnabled";                 Val = 0; Opp = 1; T = "DWord"; Desc = "Autocompletado de direcciones y datos de contacto" }
    "Autocompletar tarjetas"              = @{ Key = "AutofillCreditCardEnabled";              Val = 0; Opp = 1; T = "DWord"; Desc = "Guardado y autocompletado de tarjetas de credito" }
    "Consulta de metodos de pago"         = @{ Key = "PaymentMethodQueryEnabled";              Val = 0; Opp = 1; T = "DWord"; Desc = "Permite a los sitios saber si tienes pagos guardados" }
    # ── Funciones extra (molestias) ──
    "Modo en segundo plano"               = @{ Key = "BackgroundModeEnabled";                  Val = 0; Opp = 1; T = "DWord"; Desc = "Chrome sigue ejecutandose al cerrar la ventana" }
    "Pestanas promocionales / What's New" = @{ Key = "PromotionalTabsEnabled";                 Val = 0; Opp = 1; T = "DWord"; Desc = "Paginas promocionales y de novedades tras actualizar" }
    "Aviso de navegador predeterminado"   = @{ Key = "DefaultBrowserSettingEnabled";           Val = 0; Opp = 1; T = "DWord"; Desc = "Insistencia para fijar Chrome como predeterminado" }
    "Pagina de bienvenida (actualizar)"   = @{ Key = "WelcomePageOnOSUpgradeEnabled";          Val = 0; Opp = 1; T = "DWord"; Desc = "Pagina de bienvenida al actualizar el sistema" }
    "Lista de compras y precios"          = @{ Key = "ShoppingListEnabled";                    Val = 0; Opp = 1; T = "DWord"; Desc = "Lista de compras y seguimiento de precios" }
    "Sugerencias de contenido (NTP)"      = @{ Key = "NTPCardsVisible";                        Val = 0; Opp = 1; T = "DWord"; Desc = "Tarjetas de contenido en la pagina de nueva pestana" }
    "Recomendaciones multimedia"          = @{ Key = "MediaRecommendationsEnabled";            Val = 0; Opp = 1; T = "DWord"; Desc = "Recomendaciones de medios en la nueva pestana" }
    # ── Privacidad y seguridad ──
    "Bloquear cookies de terceros"        = @{ Key = "BlockThirdPartyCookies";                 Val = 1; Opp = 0; T = "DWord"; Desc = "Bloquea las cookies de seguimiento de terceros" }
    "Navegacion segura (Safe Browsing)"   = @{ Key = "SafeBrowsingProtectionLevel";            Val = 0; Opp = 1; T = "DWord"; Desc = "Filtro anti-phishing (envia URLs a Google)" }
    # ── Telemetria y servicios de Google adicionales ──
    "Informes de fiabilidad (Domain Rel.)" = @{ Key = "DomainReliabilityAllowed";              Val = 0; Opp = 1; T = "DWord"; Desc = "Informes de fiabilidad de red enviados a Google" }
    "Experimentos / Variations"           = @{ Key = "ChromeVariations";                       Val = 0; Opp = 2; T = "DWord"; Desc = "Pruebas de funciones (field trials) de Google" }
    "Paginas de error alternativas"       = @{ Key = "AlternateErrorPagesEnabled";             Val = 0; Opp = 1; T = "DWord"; Desc = "Sugerencias de Google al fallar la navegacion" }
    "Conjuntos de sitios relacionados"    = @{ Key = "RelatedWebsiteSetsEnabled";              Val = 0; Opp = 1; T = "DWord"; Desc = "Related Website Sets (cookies compartidas entre dominios)" }
    "Subida de registros WebRTC"          = @{ Key = "WebRtcEventLogCollectionAllowed";        Val = 0; Opp = 1; T = "DWord"; Desc = "Envio de registros de eventos WebRTC a Google" }
}

# ─── Estado en memoria ───────────────────────────────────────────────────────
$script:state   = [ordered]@{}   # $true = caracteristica activada (toggle ON)
$script:labels  = [ordered]@{}
$script:toggles = [ordered]@{}
$script:total   = $POLICIES.Count

# ─── Helpers de registro ─────────────────────────────────────────────────────
function Get-PolicyState {
    param([string]$Key)
    try {
        $value = Get-ItemProperty -Path $REG_PATH -Name $Key -ErrorAction SilentlyContinue
        if ($null -ne $value) { return $value.$Key }
    } catch {}
    return $null
}

# Normaliza una politica a una lista de claves de registro.
# Soporta el formato simple (Key/Val/Opp/T) y el multi-clave (KeySet = @(...)).
# Nota: el campo se llama KeySet y no "Keys" porque .Keys colisiona con la propiedad
# nativa de las hashtables (devolveria los nombres de los campos, no el array).
# La primera clave es la "primaria": determina el estado mostrado en el toggle.
function Get-PolicyKeys {
    param($p)
    # El operador coma (,) evita que PowerShell desenvuelva un array de un solo
    # elemento al devolverlo (en cuyo caso [0] daria $null en el caso simple).
    if ($p.Contains('KeySet')) { return ,@($p['KeySet']) }
    return ,@(@{ Key = $p.Key; Val = $p.Val; Opp = $p.Opp; T = $p.T })
}

function Update-Counter {
    $off = ($script:state.Values | Where-Object { -not $_ }).Count
    $script:counter.Text = "$off / $script:total a Desactivar"
    $script:counter.ForeColor = if ($off -gt 0) { $ACCENT } else { $MUTED }
}

function Update-CurrentState {
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        $primary = (Get-PolicyKeys $p)[0]
        $cur = Get-PolicyState -Key $primary.Key
        if ($cur -eq $primary.Val) {
            # Ya esta desactivada en el registro -> toggle OFF
            $script:state[$name] = $false
            $script:labels[$name].ForeColor = $MUTED
        } else {
            # Activada (no configurada o valor activado) -> toggle ON
            $script:state[$name] = $true
            $script:labels[$name].ForeColor = $FG
        }
        $script:toggles[$name].Invalidate()
    }
    Update-Counter
}

function Invoke-PolicyToggle {
    param([string]$Name)
    $script:state[$Name] = -not $script:state[$Name]
    $script:labels[$Name].ForeColor = if ($script:state[$Name]) { $FG } else { $MUTED }
    $script:toggles[$Name].Invalidate()
    Update-Counter
}

function Set-Policies {
    $disabled = 0; $fail = 0; $reenabled = 0
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        $keys = Get-PolicyKeys $p
        $primary = $keys[0]
        $cur = Get-PolicyState -Key $primary.Key
        if (-not $script:state[$name]) {
            # Toggle OFF -> desactivar caracteristica (todas sus claves)
            if (-not (Test-Path $REG_PATH)) { New-Item $REG_PATH -Force | Out-Null }
            try {
                foreach ($k in $keys) { Set-ItemProperty -Path $REG_PATH -Name $k.Key -Value $k.Val -Type $k.T -Force }
                $disabled++
            } catch { $fail++ }
        } elseif ($cur -eq $primary.Val) {
            # Toggle ON y estaba desactivada -> reactivar (quitar todas sus claves)
            # SilentlyContinue: en multi-clave algunas pueden no existir y no debe contar como error
            try {
                foreach ($k in $keys) { Remove-ItemProperty -Path $REG_PATH -Name $k.Key -Force -ErrorAction SilentlyContinue }
                $reenabled++
            } catch { $fail++ }
        }
    }
    return $disabled, $fail, $reenabled
}

# ─── Helpers de UI ───────────────────────────────────────────────────────────
function New-Toggle {
    param([string]$Name, [int]$X, [int]$Y, [Drawing.Color]$BaseBg)
    $t = [Windows.Forms.Panel]::new()
    $t.Size     = [Drawing.Size]::new($TOG_W, $TOG_H)
    $t.Location = [Drawing.Point]::new($X, $Y)
    $t.BackColor = $BaseBg
    $t.Tag      = $Name
    $t.Cursor   = [Windows.Forms.Cursors]::Hand
    $t.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $on = [bool]$script:state[$s.Tag]
        $w = $s.Width; $h = $s.Height
        $col = if ($on) { $GREEN } else { $TOG_OFF }
        $path = New-Object Drawing.Drawing2D.GraphicsPath
        $path.AddArc(0, 0, $h, $h, 90, 180)
        $path.AddArc($w - $h, 0, $h, $h, 270, 180)
        $path.CloseFigure()
        $b = New-Object Drawing.SolidBrush($col)
        $g.FillPath($b, $path)
        $kd = $h - 6
        $kx = if ($on) { $w - $h + 3 } else { 3 }
        $wb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(245, 245, 245))
        $g.FillEllipse($wb, $kx, 3, $kd, $kd)
        $b.Dispose(); $wb.Dispose(); $path.Dispose()
    })
    return $t
}

function New-Button {
    param([string]$Text, [int]$X, [int]$Y, [int]$W, [int]$H, [switch]$Primary)
    $b = [Windows.Forms.Button]::new()
    $b.Text      = $Text
    $b.Location  = [Drawing.Point]::new($X, $Y)
    $b.Size      = [Drawing.Size]::new($W, $H)
    $b.Font      = $FONT_BTN
    $b.FlatStyle = "Flat"
    $b.Cursor    = [Windows.Forms.Cursors]::Hand
    if ($Primary) {
        $b.BackColor = $ACCENT
        $b.ForeColor = [Drawing.Color]::White
        $b.FlatAppearance.BorderSize = 0
        $b.FlatAppearance.MouseOverBackColor = $ACC_HOV
        $b.FlatAppearance.MouseDownBackColor = $ACC_DWN
    } else {
        $b.BackColor = $CARD2
        $b.ForeColor = $FG
        $b.FlatAppearance.BorderSize  = 1
        $b.FlatAppearance.BorderColor = $BORDER
        $b.FlatAppearance.MouseOverBackColor = $HOVER
        $b.FlatAppearance.MouseDownBackColor = $CARD
    }
    return $b
}

# ─── Ventana ─────────────────────────────────────────────────────────────────
$form = [Windows.Forms.Form]::new()
$form.Text            = $APP_TITLE
$form.ClientSize      = [Drawing.Size]::new($W_FORM, $H_FORM)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $BG
$form.ForeColor       = $FG
$form.Font            = $FONT_BODY
$form.MaximizeBox     = $false
$form.FormBorderStyle = "FixedDialog"

# ── Cabecera ──
$header = [Windows.Forms.Panel]::new()
$header.Size      = [Drawing.Size]::new($W_FORM, 62)
$header.Location  = [Drawing.Point]::new(0, 0)
$header.BackColor = $CARD
$form.Controls.Add($header)

# -- Logo oficial de Google Chrome (PNG oficial de Wikimedia Commons embebido en Base64 -> PictureBox) --
$LOGO_B64 = "iVBORw0KGgoAAAANSUhEUgAAAUoAAAFKCAYAAAB7KRYFAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAABmJLR0QA/wD/AP+gvaeTAAAAB3RJTUUH6gYIEQEgDm6XxQAATmdJREFUeNrtnXl8VNX5/z/PvbNmJwkJ2dhDgEAgJOz7poKKiGCrVb/ajdba1tra+uumdavWal3qjtq6K3VBVERQNtn3fUlYA4GQkH2bzNz7/P4IgQQyySx3Zu7MnM/r5Qszc+65d+ae857P85zlEoSENFLR6Ox4QEpjlVNUoq5EnEhMiUxqEkBdAMSAEAmWogCOAXEMmOTzh8sAYgCAqPkFBmoIcJx/XwVQxaBqItSBuY5IqlKZKwlUwsxlksRlzFIpsXoaUE9lrN9bLu6KkBYi8RUIuaq92dmmyGjqw0RZEqv9VEIfYmQA1ANAdwBR1GnL6rzJEXnRdKnNP7UAnwDoOJiKQFzIEhcYHDhQUa0eyd67t0ncVSEBSiGPxIB0cuSAPqpEQ5lpCIAhAA0A0PO88+u8QekDlB3JAdAxBvZLxLugYgcbpJ3pq3ccpmb3KiQkQCl0UUfGDOhBijRaAkYyMBLAYABRbVsHudeg9A/Ky+uhFheKXUy8SVZpA7G0IXXd9uOilQhQCoWZWzw+euAQME1mxgQ0g7Fbu40hPEF52Z8EnFGZN5JEq4iwMnX1zp3CdQpQCoWYjo/MHqgSTQNjMsATAMS71BgEKJ2pnIHVAK8wkLw8Zc32faKVCVAKBZmK8/IiGqT6MZJE1wJ0HYAeHjUGAUpXazjDhGVgWmy1m5cmbNxYLVqhAKWQDlWQ27erbDDPJuIbAEwCYHaDOgKUXoDykou2EXiFCvrYAPo0Zc32UtE6BSiFAqii0f3S7IphDpjngKTxBJY9pI4ApXagbH28QsAaBn+kqNLH3dduLxatVoBSyB/OcWTfGJmNswHMA+gqAIYOb6YAZSBB2VoqgPXEeNNsN78vwnMBSiGNxfMgHzk+4Coi6VYwZgFsdflmClDqBZSt1QDwIpXorfTkzKW0cKEiWrkApZCHOpGblaoYDbcy+Gdonuzt/s0UoNQjKFurGERvSRK/lLJyxzHR6gUohVxxj4B0ZET/mcQ0H5BmACy7epcEKIMSlC0FFRCWsIqX0tbsWCLmaQpQCrWjA2Ozos1NdBMz3Q3CgI46sABlSILywh/EOMyEV5skfrnXyh2VoncIUIa9jo3I6qWw9CsCfojzu+d01oEFKEMblK3+rwqM10jm50RYLkAZlirMHzAIEn5PjJsAGMiNDixAGR6gbPWXCtBHpCh/S1m7c6/oPQKUIa+C/IG5JPFviPEDAJLzGyFAKUB5WR3MxF/IJD3SbeW2DaI3CVCGnI7mDRypEj8IwhWu3QgByvADpVt1LCXiv6Ss2rFZ9C4BypAIsYnwVwBz3cOHAKVwlC7UQVgOVfpD6pqt20RvE6AMOh0e0b8fVDwC0A0AqLNvWoBSgNJDUDaH5OCFKuPPGat3FIjeJ0CpexWNzo5vcqi/B+NutGxM4cI3LUApQOkFKFtkB/gNya7+pdu6XWdFbxSg1J225OUZ46S6O4jxCECJ7n7TApQClBqAsuXFCmZ+vEmKfabXypWNoncKUOojzB7W/xpI9DTAfZx+rQKUApT+A+WFpkkS/TplxdYvRC8VoAyYDg3v11uG/BiY53X6tQpQClD6H5Qtf30uKfKvk7/bfET0WgFKv6lodLq1sSnqPiL8HoDFpS4iQClAGThQAkADCP9oRMxjIhwXoPR9mJ3Xb5xK0qsE9HcJcgKUApRefGkagvJiOM74abfV274VvVmA0geA7B3LkulBMO5CqxU1ApQClEHiKFuLAbztsJjvzli6vlz0bgFKTVSQnzWLmF4AIc1tyAlQClDqD5Qt13ySwD/vtnLb56KXC1B6DsiRfWNIMTwBxk9d6JsClAKUQQbKC/8ubGT1p2JLNwFKt1U4vP8YqPTmxSk/ApQClCEKymYdB6TbU1ZuWSl6vwBl5y6yb1+zFGt4lIG7cUkuUoBSgDKEQQkwVEh4sjzR9ufshXubBA0EKNvV4RH9+7GC9wHketA3BSgFKIMblBeBuU0mfC9p5bZCQYVmSeIrOA/J/P43sMIbnUJSSCh87NMwBdh2ZnLezeLLEI4SAFCclxfRgNpnGfiRB7ZPOErhKEPPUbYqQEyv2JuMd2esX98gQBmuLjIvuzuT4yMw8j2kmQClAGVIg7I5EsdO2SDNSV4evksgwzb0LszvN0OFY8dFSAoJCd/i5KqGsF3dXDJ52JUClGEiBqggL+sPzPQ5gC6icwrpqnXql+HxzLSkZFLeY/xA+HEjrELvnTk5kRFG29sAZnsU6IjQW4TeYRh6X1qUwR9xNN2WunhrvQBliOlAblaqTPgMhDyPm6UApQClAGXLCzsVRbo2bfXmIhF6h4gO5vYbIhM2AG0hKSQk5LGGyLK6oXjysLDoUyEPysJh/a6XiNYByBBtW0hIU6VKoFVnJufPEqAMYhXkZv2QQR8CiBBtWkjIJ4oE+OOSKXk/E6AMTkj+AYTXABhEWxYS8qlkZrxYMiXvsVD9gCE3mMPzIB8+nPU8A/Nd+cRiMKeD48Vgjhs9KewGc5x9Df9JUqN/QitXOgQo9eoi+/Y1I1b+AIzrXP3EApQClAKU2oESABj0cXliw02htANRyITeBX37mhEjL+wQkkJCQn5wXzwnsdT8adHo0VYBSh2pOC8vgmIMnwO4VjRTIaHAi4lmGC22JaVjx0YLUOpAe7Ozo+q49nMGTxPNUyjYvViIfZ6JDlPjl+dmjIwRoAygDozNijaZ7csATBadTCgEfFgoon+cvVEJemcZtKAszkuNkOvVzwCMEh1MSEjXGqOYbEvOTsqOEqD0o4pGp1vrOGoxiCaJNigkFBQay2T9JFgHeIIOlEcn9bQ02CI/ZWCKaHtCQkGlaSaz/aOCGX3NApQ+FM+DbK8yvgXwFaLNCQkFoQgzYmxx7/O8ebIApY9UWNjvaYDmitYmJBTUmn227OjzApQ+0KGhWQ8zcJdoY0JCIeEs55dMyb9fgFJDHRzW7y4Q/0m0LiGhkNIDwbLrkO5nuB4c2m8mET4DIF961eTJxxBrvV0/Xqz1dqNdibXendXjpG2ozLi+24otnwlH6aEKhvTNJcIHbSApJCQUSpKI8E7J5BFDBCg90IHcrFSWpM8ARIm2JCQU0ooCqV+emzQyXYDSDe3Nzo6SwF8ASBdtSEgoLJTqkJRFZ67IiRSgdEEMkNFofxPAUNF2hITCSsPgML7OOhw70R0oC3Iz/wTC9aLNCAmFnwh049mp+ffq77p0pENDM6eDaAk6G7wRo96uX54Y9Xa9HjHq7bSAD0e925NKwDVJ325ZIhzlJdo/tH9PEL0HMcItJBTukhh4u2RKXh8BylYqGp1ulUn9FECCaCNCQkIA4gFaeHTSJIsA5Xk1NEQ8DWCIaBtC4S0SX0Fb5UbINU8KUAIoGJo1D4SfijYhJCR0mZjuPDMl/6aw/gkryOvbh1VpK4BYT65aDOa4cAoxmON6PWIwx2kBPw/mXKoqSDQsefnmI2HnKPdmZ5tYlT90G5JCQkLhplhS+X2el20KO1AajU0PATxMtAEhIaFOI3BgeOk561/DKvQ+MDRrLJG6ikCyN1ctQm8ReovQOyxC7/OHkQpgctK3m1eHvKPcmZMTSVD/AzFfUkhIyF1eEd4IxKNv/Q5Kq9zwLIC+4p4LCQl5oN6qpemfIQ3Kg0P7zWTGD8W9FhIS8lQE/KRk2ogrQxKUO3NyIgH+t7jNQkJC3rJSYrzszxDcb6C0SI3/ANBL3GMhISFvxeAebGl62I8u1vcqGNZ3lKrS2jZgJoA8H/665OLFqLfTYmLU2/V6xKi30wI6GfW+/Hk7Ek9IXrZlbdA7yoK+fc2qQm8gyJ4hLiQkpHtJUOkVf0xE9zm8OIp+B0J/cU+FhIR8EBIPLK2IuCeoQ+/CQX0yFIO0H0Bke2cWobcIvUXoLUJvL0LvFtUripydsnLDsaB0lIpRerpdSAoJCQlppwhZVp8IytD7UG6/aWDMEfdQSEjI9+K5Z6fkz/BV7QZfVDppxSRDyQNn70+qsov7J3RpiGojo6GMLBEVcnRMPVmtRJFRDEliKSLKDlkyyJZGA2BTQXaGpEhE9QrUertsqgbMNUaSGhlKU1NzhaqvO6DHobdrVbMnCQZtr92zONiN717S7pQdncWs3s5/wTKaDEdQgLKmJOEnj94UbXj6pQMCDOEJwwYpKrLIkNa9yjQgm83ZOSZjZlYXQ7fUblJMrBlA2vn/PJNSB7adbEJjUQnX7q5GzQ5Frd1pgK04AWpjsmt8YB9Cx8262ZfX4oPy7O/rcV121bgCsL/kk98FLTV20axoW4PxEIBuv/r0+PaRB6pynZ1ZDOa4WIfOB3Mks/mEsU/maev4KVLkxClphh69UiEFaDaYUgeu2V7CZZ+fUcu/kVF/OB3siNMlcAQwfdECSgwWRyaNQ42uHWVTg/GPALoBwItXZ8QMP1TlkFTfOFehABlGSSo39et/KOraOUbrxKkD5ITE7gC66+Li5EhQ3LhkihuXLJ3vjFx/oJ7PLipUSxYS6gszAba0hb+rHdbH5YlcCsf9dj2dladL3yI34edueZeU7Ggw/AFw/Fm3jnLk23PSFQMdBBDR8trVG0pX37zy9AThKIPbUZLJctQyYszpmO/dnGYZNqJHwByj146zAXzuy5N88rVStXpDBtiRqEuHye7WL9xlK9UbZEcWTcZJXYIy//05/wXotjYnYD738jP7KbLRES9AGWSglKjanJt3KO7/5idaRozuGXLWmBXwuSXHlWNPVKFmRxbAZvc7rQjH9QhMYn7DMF3RbKcyzUA54v3r+6mQ9rYJ589/5gEnalb9+b2jEwUogwKUbOiatD32/37CkbPmDCWTOTw2WHZUOtSiF/app162wl6RKfKXQQ9MhwI52zLNdkiL5qFZ/KRCevACJLn5v+Z/GPu6R409mmItgJCe1WTMzNqQ8t+Fx9MWfzssau5NeWEDSQAwxBmkXn/MMYw7ninnfVOMmLxtACnu/QK788PvZnnycf0elfcwj+MfD2eQoGr2jB1NHGX++9cPAqSd4Gbwcju/CDG1jm0vPb9/mHCUOnOUhOqI0eMLEu57IFNOSo4RvxetPE39kSq18N4CPrd8IKBG6MbRCXfpsn9TIeWapzXt0omjlB66CElu94NVRxmGrcqJ2yS6n05EVB8xfvLa7svWU9JTL+YJSLbzFUX0jpVzPso3jC2AlDB9K4Am33kQN90l6c1dkhtv+/p6LoJJgvoXXTjK4e/MG8qSuo3BndYlKzj6xr/2pBoUNgtHGTBHabfk5u/s+tAT/eTErgKO7viaxqPVyp4fHkHNlhz3TIaeRscDXJ69rd9td8kqS0PM05t2B9RRsqTe5wokAUCR0euNaanrRZcLjIyp6d+lLfzyTLcX/5MvIOnB77OlV4whf8VQOX9NKczd9+rC0RH8lL/UyH+1e2qfuksi4j8E1FEOf+eG3qrEB+HOxHVG7QsvHKiLq7MnC0fpH0dJJuPJxPv/Xh059aqBAncaOswz7+9VDtyVCLYl68bRifxlux5NkeX+lsm2woA4SlXCfXB3dQ8h6p9zex4U3cwvslvzR67tvnRdVwFJHzjMbt/PNow7Ei8lXLkVgJsj5D7yMyJ/2Z5kg+L4TUAc5fAP53VTFeUoAIsnjP3ru0cPDThZ19+bqxaO0nkdFBF5IOWVt4ymzKw+Aml+cJeVa46ou+YaWKl3cymnyF/6yV02GmRHL5qMM351lKqi3u0hJAGG9NSc7o1MvtwHKnz7rGXY8NXdv17bW0DSj+4ybnxveezRVCl23DbdzHcM+vylptducTgMd/nVUY7+cJ61SVGKACR4A/zbvj2zbsbWsjHCUWrkKGW5tOvfHi+JnD5jkEBXAH+pTr+1Vzn4y1Sw2kVs5+ZFee0dZpkhwtGdxqDB3Xvq0a4+NlW9lbyEJAC8PTm555RdFfVmuxIhupd3MiR03ZD23qd9pdi4oIFkZb2K8jpGVYOKWltzA2m0N/9rMTb/OkSZCXERErpENP8bFO4y5dZsQ/zkCsfmcXtgLx/kux11PNidyC1g6mB3ojZve11/or3OeBNgf90vjjLvvTk7AeR486PR8vLog1Urf/1Z0SThKD13lJbho9amPPvqKEiS7pYcFlcqOHDagX2nHSg8q+BkhYKicgVnqhQ43Nyc3CAB3WJlZMTLSO8iIzNZxoBuBgxINSAlVoerLdmhKLvmbuXyb0fowqFdVjQM85eEPYYpjhxyM+3nNihz35s7VYK63FtAtvq/hmdeLShPrmxKc/eqBSjRGH/XPXtib/1Rvh64oKjArpN2bDxix+ZjTdhyzI6yWtUv5+4aLSGvhxEjepkwsrcROelGSARdSD32923q0b8PBmAMfmCGQDiuYpLxCscqn4Iy/70bPmLwHM8hefmbKedsa//1euFYAUrXQUkSFSe/8EapNXf4kEBCoNbGWLbPhm/22bDqUBPK61RdwCkhSsLEfiZMHWDGtIFmRJkDS00+99UBZdf3kwA13rNOLnYn0hCYC43T7Df6DJQj352V7CBD0cVfRo9d5GVF/vDR8V25R2qHuHPVYQtKo6Eo/d1FMHbvmRGITt/kYHy914ZPtzfi2wNNsDn0PXnBYiRM6W/C7FwLrsg2wygHBppct7dI2TzBALan6AY4wQxMz5dDNhkUewZdibM+AWXee9f/AaDHNATkBZmblANvPHuwn8QsuXrV4QhKyWIpTF/4ZRc5KTnB3x39cKkD72xowMItjbpxjp44zXn5FvxgZAR6dw1AXrPhRKWyeXg1Kw3ddeXQvArHfV3eF+6Sf2ec5nhSe1AyKO/9OQcBZGoJyNa6Yd3ZNfPWlo4XoGwflFJE5J6MT79Ok2Ljuvizb286asdr39Vjye5GKMHJx8u/XQLG9TXhR+MjMH2g2c+W/GyVY0NuCZSafroLacMnHD9omGof4OqgjsuEyftgzmSo+NY1SHoWihGj9LXnDlgibEq0AGVbUMpx8VsyFi3rTxZLlL/688qDTXhiaS12nAjt57MP62HEvVdGYUI/k/9O6qiqc2wYfAz2ymxdwzKkgckTjNMca1w5o8sT01jFHRfOye1fmzeQPL8jetfnrknbCqG2Nykyak/6p0v9BsnNx+y4/vly/ODVipCHJABsO27HTa9U4IYXKrD1uJ8+ryE20jBqV2/I0QXt/2zqaL22LndXJzdcR/vliekOTUPvvMXXRqDGWAIgSqswu4PDmv75n8Li9DJbT+EoATKbD3X/YkVXKSbW5+H26SoFj31Zi4+2NbpvIkJI0waa8fDsaGTE+yGHaS+tVtYNOsdqQy/dOrTLiupotZF37rLaEGHv5spKHZccJdWYrrsUkm0dpAe9yvlhpsfm9DwDIZDRdDzj068TfQ1Jhwo8v6IO4x47h/9tDW9IAsDyfTZMfuIcXl5V7/ucrLFrjDxySwyR8VRgHZo7Vfvy+Td+3Z0oRqk3Xa1Z6M3gH/jYRbZRWYxh1LoBsdvCm5LS6bT/fcFyQmK8L0+z55QDVz9zDo9+UXth+aAQ0GBnPLi4Btc+V459xQ7fnsySkSCNWMeQpHLtgONjQIXIdm4M9RZNQDn6w3nxAKb72EVeVuyFK9NiFYnsYdpPG1OeX1BmTEnt6asTMAML1tTjmmfLseeUA0Lta2eRHTOePocnv66F6sPfEYrISpcH/68EUmfP5RH5S6+B2RaBM3h55/tWdApKu0OZx4DJX4BsKWY3oM+7E5LXhWHf5Pi7f7/Lkj9ysK9OcLpKwdwXK3D/ohrYFeEiXUlNPPV1Hb7/cgVKqn0Xi1P8tAHU/b5drrFBR4DyeDs3BKZ820s12cl4vdegVIAb/AnI1rH5F3nxQ2qs8rlw6pQR4yatir359hG+qn/j0SbMfLocG440Qcg9rS1swvSnzmFtoe++O7nXH/MpbsI611mlI0C5nb/URzhOTHO8+haGvjE7TjJTCQD3J5ixJ8UuP6j/yfpVf3v/2MT2rjrURr0NiV03Zny+It9XuwAtWFOPhxbXuL1rj1BbGWTgb7OicftYH+0OyA7FsT5rN5pKh7rXp8T8Sw/L2wxqUzJNR5VHjlI203VuQ9IjF+n8oAPpEeMOd7MeCvneJ0llqW99lOkLSDIDT35di/sXCUhqEoorwJ8+qcFfP63xzQwBMsiGvHXpILnUvQ2cRf7SQ19oVuSOR7+lTuq93vXeqC0gWxWR/z6ne12I9z016ZGnTvpihFtRgd//rxpPfR3qX6H/9dp39bj7gyo4FB9Ubk5OlAcsKGnuINQ2jBL5Sy/Kt38tzB2zziko8xZfG8Fq82i3v8JsZwfUWOXcb3PiNoRqh4sYM+G7yKlXDNW63iYH42dvVeLdjQ0Q8o3+t6URP/5vJRp8MLWKkm4YRHHj17fbyUX+UuvyV/EK588AcwpKqjZNAiEiQC7ysiILpqSk2Q3UGHIRd0TEgeQnnhutdb3VDYwbX6rAl7ttgmY+1rJ9Ntz8SgWqG7SHpZzzUT7kiENOAeUyMHUUjusTmFEOxTzebVAqUK/UAyAvXI9MGQumpoSaq7SnvPRfkNFo1LLSRjvj/16vwOZj4ToN1f/adNSOm1+tQH2TxrCUzCZ5yCIJgKNDIIj8pfflSZ3hvqMkzNADIFtr1aC4/PJoY0nIhNwTp24w98/ur2Wdigrc9U4VNh0VkPS3tp+w4+dvV2k+YEYxI/pS/NQNnQIhaPOXPgr33S4vXeUWKHPevLYXWu87Cfg8D+li3VGPz04PiRFwMhqLkx/8x3At62RuHrhZskeE24HS8n023PNBleaj4XL2O8NdXg+ueTju4/L6CccHNCy19HIZlEaDcYZeXOSlOppkHXsgLWJvsHeorn9+uJysVouWdT78RQ3e3yQGbgKtj7Y24vEltRqT0mqW+j1T5hagRDjudnlZ5ivcCL15st4A2eow6bHrMpgJQbv2zpiRsSFqxrWaPn97wZp6vLSyXlBKJ3ru2zq8uU7bHy1K+cEQWHpsdAsIYTOdSKPRfYkmuwZKBjFjgg4BeUH1FmnQ58MSgnUduD35yZdStKxwXWETHlpcI+ikM/1lUTW2abwRsJyzMBWA3W2A6AaY7lTt//mUxDyRuZ2tMy59If+t67MBJHUGL2d/uXCAW5B0hs13J3TtbTNS0M2ituaP3Gzq2auHVvWdrlJ8MoAg5L0cCnDXu1WoadQu+KGIrAyKHbPFY0AFPH+p++lE3WwrzP06BaUq8yT9uchLXmFAAaU8d2XapmDqOERUl/TQEwO1qk9l4FfvVaOsVlBSrzp+TsFvP6zW1lVmv9YfRPVeAUHkL52Wl1RM6hSURDRRT2H2pYBs/efGzOhRZ2ONJ4Ol00RMvXKLnJAYp1V9z6+ow7pCsQuQ3vXFrkb8Z62G+WNTaheKn7HFa0CJ5ZDtl2+HgZeBkhljOnZ2/gQkd1av9ZHrM04EiZss7/qnB4dpVd+eUw78c2mtoFCQ6G+LazXdKV0e8MJQgCo1AZRYDnmpxnQIyuHvXZcBIBWdhb7OaOeBuDNsdlJvcRfzmG19onbovaNETrlijxQZFa1FXQ4VuHdhtW82YxDyiZocjHsXVmv3DB5DXAwlztijKaDEcsiWUj14dUSKU1A6FHmknvKQrtb7r5mpFpVIz9iwJfz2/2k2HejlVXXYdVKsvAk27Siy47U12oXgct9/DgC19+gILwEl8pdQHMpwp6Ak8Aj/AxIeA7JFjQap/wejE3U7XcicnbNFTkzSZAu1U5WK2DItiPXE0lqcqdLIVlpSExCZs9UngArz5ZAMGukUlEwYGajpPt7UCwCfjogfUGc2VOmwb3DiHx9I16qyhz8XT0sMZtU3MR79Urs5r3LWc6md95xwyl9qFI4znICSQQTO1XuY7UwqUeK/rk7ZrreOYUjsutXcr78m8yY3H7Nj8c5GQZsg18fbGrH9hDapE4oe0gOmrttdh4KHgArG/KV39Q9rF5R5H8zuzUB0sAGydTU7ekSOKUowH9VTp4i7Y75mQ52PL6n1zaMHhPwbYjA0XUkld/+N3QsguFc+fJZDduFl1u6XgZIdnOM7QMKngGz1gunh69NLddMjSKqMnj03T4uqVh5swvrDYs5kqGjjUbtmc2Ap9Ue5gFTlN0CFSf5SITXnMlCqRDnOuOYuvNCZi9TiV7ndFxjnogwjVveP2aKHzmAZlr+fTCZNNuV9QsyZDDn94yuN7qlkNlHsyP1+B1SIb+fGoMtBSUBOMIXZbV9o++oL07t1USQK+PyZ+Pl3JWhRz7rCJuw4IaYDhZo2H7NrtsGy1OMPcQEDVIhOJ2KiwZeBEsCg4ANk+xbVIVOf/0xMXhvQXmAyHrbk5vfToqqXVont00JVL6/SZqoXxU/sT2Q6FjBAheBySAK3BeWkFZMMYPTyDpAIACCdn+CrnNihVVb5XKA6QMTo8ae0qOdwqQMrDogdy0NVX++14WiZFmslCOgysSjggAqp7dyoL38I+QIoK4sTegFwOZcW6DykKydgQtzjs9L3BKoDxH7/llQt6nl7QwNUMdIdslIZmj1OWEqfn6wbQIXGdm7mxq6WjIuht8ouhYh6ykO6okMplnGF3SwH/d34SZLOWYcN7+NtPXaF8dFWMW8y1LVwS4Mm6/apy6RMkFSuLXC8BFSQ5y8N59koAYBEaqb+w2yPJD96XYbfE3ymzKyDkGTytp6v9thwTuw1GfIqrVHx9T4N0iskEyL6H9AFcEIkf8mQLoJSBfd1D5Cdbn+mISC9O0G1Vcr9enDcen82/Ohr58ha1PPpduEmw0WLdmhzr+XU21h3z8sO4u3ciKTMi44S6NmBX3QeZmsgb/KQruq1yclpNpn85Sw5cvpVXj+ru9bGWHlQTDAPF32zz4Y6m/dtnpJuGNDceXQ0YHJp+aBaDsk9LoCSQd2du8jAT/fx6jwMOAjdX57WbaM/GjyZzMfl+IRYb+tZts8mNr8IIzXYGd/s1yD8NibGk2Q67hfHFR7LIVsN5gAZep/u4wkgW6+LXtU/ZnhZtPGUrxu8qU9msRb1LN8npgSFnavUahpY5IBTOgSOn8Nxzco3gzL7w3lRDMSFSph9KSBbKerRWSk+3zAjYsIkrwdxVAbWFIiwO9y04kCTNlPBEq+i9vt+KADTV+7YaflEXgerZG50ZAQmzNYWkC2Q7Ogqjidaxu7OiNjpy8YeOXm61/MndxbZxWh3GOpcrYo9p7xf0iglXpvSMbt0NGByaflOL83vsCebzZwmscSpoZCHdA7JNldB/7g6VWKCTyhERHWm3pkZ3tYjdgkKX2084j0oKXJAD+CSZ96Tt0DzM6B0FI7LCqVIKjjRv4D0S5jt9Fz1JmnwJ8MSfPLYCIqILAKR5G09W46JDTDCVZuPafEjSRLkqBOusULkLzsrTxJ1lcDcFRqaPH/kITsOszs/13tjE/o0mKQarRu5IT1dk0dRbD0uQBm2oNRoNyFYelQ4BYLIX7pVXiXqKhGkxGDLQ3YMSRc+OJDy3JUpmu9Zae6f7fVCtFOVCspEfjJsdbZGRUm19/efooeqnVKGtAIa/FM+QO6SgEQJOO8ofRJm+xOQ7p1vY6/I0adjjcc1BeWgIV5v0ru/2CFoEebaf9r7NiDFjjC4BChCcOUvAxGOq9RVYsCjx6jqOQ/p4gewPDw7vVjLBm4eMMjrieb7TgtQClBqEH5H5ca6BQSRv3RanoEEiZw9UKwTSF7+gr7ykK58gDMxxtGbekdqFoIbU9O8nhp0pFQRpAhzHT7rfRsga/c0jwASNMB051Dv0gMEipLgBij1E2ZrkydgAE9dlRqtEmlg48gmRcdEeVvLyQoBynBXkRZtQI6OuWyKkLvA1Bg42pb343Qi4miJQJ127hAIs51OE7XJlPX2GA2mCxkMmjz9sahcgDLsQalRGyDJUOYVoEQ43lI2SuIOHGUoA7K1Ph0WP7jW4sqGp84lWSwV3n4PKgNnqgQow12nKhVNnt/OUkSFe0AQwHRSNkoCONKlANfveUgNwmwXa2KgyxMzUnd5Gel4/ZSo6gYVDjEzKOzlUJq32fM+yomr0xRQAQOmh+G7RvlLBqIlAGbXXaS2gAyki7y0xK5067gjSeYCj8OcyEivEVdeJ7ZVE2ppCxrMpTREqz4BlN/zl4FdDkmASQJgCKcwu4MShodmpVZ73CjNFq+/pKoGYSeFmlVRr0FbkCyqzwAVXuG4QQJgCOrpPh7t59F+iUqrnLeif/Rmz9qk2euW3dAkHKVQszTZtFmKYJ8DKjyWQxokPu8oL1JGn8sOXTnUNUB2XOqFKUlJDpnc3kGVzFavv7QmMY4j1NIWtFh3IFlVvwEqpLdzY6MEQA6XPKQr9Tok6rFgfKLbDyMjs8lrR2lXhKMUagGlBm1BtvgfUCG5nZtkkMCgMMpDulTs6+zYvHORhrNuNh4S3VtIX5LYY4CIcLxNYQlgTRcX+3rZoXthtvv1AgAToh+fmXzAnctTGxq8BqVRFqwVapbJoEFbUBukgAIqdJZD2iUAmoDSn8sOfeEiL9WhZOu4fWnWfS5fpq3R6w17TbIAhFALKDWoRKkn7wCiITC1BJrm5TsNxx1egzLYw+wO3pYendlNYXLtA2gBSqtJOEqhZlmMWjlKnQAquLdzc0jsIShDGJAXVGuWB385OM6lgR222bwGZVyEJAghBADookVbUBvcHXUR4Xj7wLRLBLj9kI5QyEO6+vZr4xK6N8nU0GmbrK31umXHRwpHKdTSFrwHJTuqSTfACVpgAgyySwBcXqMcanlIV2pRJaQ/N7Xrhs5BWRPtbcOOtkjNSwCEwloGGYgya/Cj6aiK9h1AfJ2/1CDc18hNE6FGAtDpQ7bCIczuqNSaftEjz8QaO9wNnRsb471t1xIB3WLFiE64Ky1O1mSyGSm2eN1O+A4ud1krAagVgOw0BxDx6IxuRzs8QnEkQPV+fW5GvABluEurNsBwJDazQMcTvoMCmFwrEbUPSj1sf+bWuViLWtjpBZ5IMI3Z2iNiZ0cRk1JRXq2XTiIUxKDsokEbcFRWAGy9yAIdD5joBpjOsEA1EqttQ+9wD7M7eImevCLZwASnttF+6uQZb9t3n64ClOGuzGTvJ1Fy44ni9lmg4wnfLr3l/+3cGKiViHBOANK1A+uNUvaHefFrndVm27/Ha0c5MMUgSBHm6q9FG6jZUdUxC3T8/BudheMElEkMLg2l6T5e5CFdOvCD4XH9601Su0C07dnl9SqnAakClOGuARqAUq3erHTOAhGOu1i+TAKjzCto6cxFelSJGx9VJer6r2lJW9sF5cF9XrfwlFgZXaPFHKFwVVKMhCQN7j/X7JJdZ0E4AtMdnFGpxESlIsx27+Nt6hk5tijedOzS95XTp+K16Cz5PYyCGGGqEb1M2lTUeKKLWwDxW/5So/Ddj8shJaZSiZnKQhuQnofZHRQ3PTiz22UDN2pjYwY7HF5vvztcq84iFHQa3lOLH0nVAbW+h9sA8Uv+MvjCcWaUSRKrp8Nxuo+HH++CzsYYR32XGb3lkpeNtr07T3jbzEf2Fo4yXKXFvefavccARHgMEJG/bBspSmqx1KiQZx07TMLsjvTM5K5dVIK99Wt1K5ad9bah56QbkRgl8pThpqRoCYNSvQelWrr4tCaA0u10Ir8uh2SzOeaUdPBHn9WAUCUA6WZxBppk9HlzdPy61i/Xr/vO64mQEgHjM0X4HW6amGXWZOkily+TvAKO03A8LJdDltGYk+f3q2MUBTcg4VdAtn4A26c5cTk1Frm85W37iWM9teg00waaBTnCTFMHaPPjSA2FGZoDyqP8ZQiE40RFANDyy1PkLoPcgpaHxQKdh7y84OXnYkKXv1+VtOtiQkNJtBcdL/e2sU8faNZm81ahoJDVSJg6QIMfR1vJWVbt3X0GqHDLX543kecdJR0XYXYngOxg8fueFOvYIwnmwpa/6776vNDb9h5pJkzpL8LvcNH0bDMiNNjhnks/OeAXQIVJ/pIYJy6AkiQUCkB2FGZ3KuP916ZcWK1Ts2SxJstrZudaBEHCRNcN1eZeK2fekf0GqDDIX6oSCi6AktXmP0Qe8lJAul55lVUatiwrehMA2E8WDeTGRq/3XLsi2yxGv8NAXaMlTNMi7GZFRcPhgX4HVAjnL0lVD10EJfMhkYdsFWZ7OK/0hYldu9kNZAOzpW7Vt16H30aZcEOecJWhrhvzrTBosGkUl3+zH6x2CRigQjB/6ZDpIijVSMsRnH/ImMhDethIAThkdH9pbMJ6AKj+37vlWnSiW0ZFQBJjOiEriYCbR1o1qUstfrVUF4AKne3cbJaSqos5yr03Lmxi4Hh4h9meA7L10csGxgyriDCcbdy9szdUhb1t/L27ytqMhgrpUlcNMqNnohZ7kDKjckNv3QAqFLZzIzpMN0K5AMrz2q3LMFtHeUhXzsOMmAdnJh2AoiTVfrPsoBadaf7ECEGUENX8iZGa1MPl3+xhdnT3D3DcKB/E4TgzLkz7aw3KXboMs92El6s/vt6sb+/sQZSFieZxe1LM+6pef7lei04wuo8Jw8SOQiGnkb2MyO+pzX1Vjz9ZqyvghAAwiS6aR+miy+TdugJkEITZHbwhPTSzm9J4+GC2UlnRoEVHuPfKKEGWENO9V2l0T5X6Bq7ZOViXwGnXiAbHdm7UnqOUVOwU0328BuSFN+qNNPizwbFbqt797x4t+sKEfiaM7iMmoIeKxmVqdz+5+NVtII7yDXB8AKgg2c5NNrYDyh3H8w8DqPM2vg2l6T6uhNkdfa43RnfpefazDzVLMP6/mVGabJogFFhJ1HwvtZJy8pVI99igE0DpOxyvxNiKostAiQceUAm8I3TCbPZXmO2UnAoh7el8U2n92tVHtOgQeT2MmD1UzKsMds3Nt2Johja5Sa7eVABHxdA2QHCJDeEYjrtRnmgr0cVOLbVlC20MfkAiAIB0fr7vekaM3PX2v09r1cn+dE0UrGKzjKBVpJlw3wwN3WTBveecAoF0AJxgXQ7JvKlNFNDmPQmbtAUkEMp5SJd+IgjW+zOryFZ4qESLjpESK+N3YmAnaPX7q6KQHKPRstTG42dQX5DfIXncCsd1ACidLIckVdroFJQG1bDRSRTZSZDphot0E14u0h+BykO6opOx8ugvlryyT6vO9pMJERiSIaYLBZuGZhhxx1jt5sQqBfcWADC4BCif5C9DdzqRbKLNTkG5445Pj4FREjxhduDzkC6ehx4x70u1nzldpkUHkSXgn/NiYJRFCB4sMhsIT94YA1mrPU7s5ee4cm2u20AIpnAcCEj+koEiGldW7BSU57Ve/4CErvKQnZ6HgQYJWc+seH6XVh1vYKoBv78qUhAoSPS366LRP8WgWX3KwTt3A4jyCAg+DcdDIn95GQOly4vyKvfxEN55yI4A2frwN+q255SfPHxWq87ys0mRGCeeraN7XTPEgltHW7Wr0FZ8livWjPQaUCJ/6az8ys5BKcmrXA8yRR7SaXXc3nuc+Me1zxRo1V8kAp67KRZJ0WLPSr2qZ6KMf86L0bROZd+PDgOwagYokb9s20+li2bRKSh3Hh22k4Fz+gmzgyYP2a6LvFSrawqHHzyy47BWnSYpRsKC2+NEvlKHMhkIL90ai2iLdveG6/cXcu2u4T4BlMhfAkCpaXz5/k5BiQceUBn8nX7CbH8CUrswu6P+87P1/yzTskPm9TDigVliypDe9NDsaAxO0252AoNRtv22CnQ60q3XcDwItnMjrG490dw5KAEQaIXWYXa45CFdOaqk4dzIDw58uUXLTnn72AjcNUUM7uhFd0+PxC2jrJrWebjwjS1d1NPD/QIoXSyHdKO8RuE4AyvaK+kMlEu1DrNdK+jPPKR3Ybb7h7ct/PC657tXN9XWatmR7psRhZtGWCEUWM3Nt+B3V2jr8KsaK2rNRX+P8zuggnE5pBfAVB3yVy6Dcvcdiw8AfESE2dq5yEulqGrSr5c/tFXLzkQEPD43BjMHix3RA6XpA8148sZYzTcv2bL1t5tSDA19Awao8MhfFlimnj3sMijPn2ip/wAZumF2R9pYvGvc1tN7dmrZoWQJeO7mWIzsJVbu+FvDehjx4q2xMGg8CWFb0fr9QxzfDA04oHSVv3SnWlfr5iXO3nF6S0nlpZ5Ep+E03UeDb0H+8ZI/RTY6muq17FgWI+E/P+yCEQKWftPIXka88+Mumm9YUt1UV39w1z0lcZISrxtAheh2bgTpK7dBqTZEfgOGTXsXGVrTfTwG8vmijUpT3x8v+eMmrTtujJXwwfwuuDpHhOH+CLff/WkXxFi1n6L156/v3Xh99MlxvgOOF4AKrXC8XjaZVzp1NM7eKP1yX1PSdf1GA8jUxkF6Di33HaR3gPShg7xQtPURp2tLe6RGJ20ekNAnTdswnDBzsAVnq1XsPuUQRPOB5uVb8e8fxMJk0B6Sr27/cOug6v9Y+lub0vT5+NdQWg5Jn8vjz7zjtqNs7sz8ifcOEmGdh7y0qJMj6C+rn+5TUld2WuvOJkvNAzz3XCGmDmmtX0yOxL++F6N5ThIAjlWeLP54+8u2a+JqhunWofkNmD5wx5fkLwnqJx0V7/AWm8CLgObn2nrmIkUe0pmLvCzVwZxw3Ud3Fims2rTudETAb6+Iwt/nxPjE+YSbTAbC43Nj8MerffNoDpvSZJvzvzvLnup+LI0ITs6h0wd0BedySLtssn/hMSi3/3BJKVqt0hF5SE1d5GWqstWMuP2L+77zVQe/bYwVn/2yC3omyoJ2Hiq9i4yP7+yi+WTy1rrxo19tzjWdrexnaerR+sfOr47LW0AFV/5yJY2pLvcYlOf1sZgP6VtAttaW07unPrvlzdW+6oSD04z46u4EzBLP3nFbMwaZseyeBOR2991sgr+ufGbj/rKCrH/2ODOsvcggcO4ydPOXzPRJZzV0CkrFrixsL/xuH5AiD+kpIFtX8uL2d0d/c2z9Zl91xmgL4cVbYvHM92NhEc/fcSnU/tt10Vhwe5xPRrZb9HnBiq3v7l2cf2dy+aEYWY1y1sEFMDV10w6jAx9rcqbs16/+GsB0p2G2F3I/D+nleQKYh3TvXHT2yxtfOdcrNmOALyGwr9iB3y2sxs4iuyBiO8rtbsQ/58Vouulue9pTWlB4/Yd3JllJKd46+HA/iVhytT2yZjM/2EdlLynPPq7fvfJfGieWXu21ozx/J95t9+6IPKQGLtLJkcxJsxb+LKKkru2W9FprYKoBi38Zj/uvjUaESbjLFkWam13korvifQ7JIxVFp+Ys/EU0g2P+1fN0U/uQdO5rRP7S8/IEfkezb6bv2zNizE3SGQBWMR/SVw6y/ZdNsvHQipvfjo23xib7Gg4l1Sqe+roW725sgMoISxEBV+dY8Ndro5AW5/tBrzO1pWWT3r610aE40vtYmtZ/mXVstDftJzDu0ovyHNDrqTOo3I0ml3a6OY3LCB74+tUfEPONApDeAtLJ0R1wM8Jo2b36lnfToowR8f6AxfYTdjzyRS3WH24KK0iO7WvCH6+OwlA/PeGyvLGyasJ/f3Cu0WHrDaDhm4HHKtONTSla9KzQBKa218LAO6aJZ29xpSaXp8qSym8ISGrhIt2DJADU2xsHT3n3tqN19vpyf3Tg3O5G/O/nXfDhz7pgeM/QXy8+stfFz+svSFY0VJ+b9OYtp85DElfF1WxON9pTtAo5tR3wge/LB2A7NyJ6Q/tP9cADUnbGpiMAeghA+ibM7uzKrAbLnuU3/TcxwRrbzZ8g2XXSjtfW1OOT7Y1Q1NCAo0TAlAFm/Hh8BMb7+QFtZ+vOlU59+7byBoctCwBkUk9vG3Q01iKpEb5wUCIcv7w8AUflCWf7EsGlFu0W/ge+NvN+Ah4QgPQvIFvLKBsKln7vdXNqVFJ3f8PlaJmCdzY04H9bG1BaE5zE7BotYV6+FT8YaQ3IxPsT1cXFV777wya74ujZctfvSynbcEdS5ShfA0oAs1V5pj8ZJ5U86hOfnPPqjHRFomPoYDMNMd2ng3OxNrdZJvnEorkv1Pbt0mNgIGDjUIBl+234dHsjvtlnQ4Nd3yM/ViNh2kAzZudaMG2AGYYALUzaX3b40OyFd0YrqpLSMlUiWlb3bB58JJtc6ovhBEyfTidyGGSlB41zfUaJ2/NBBi24+gsmnilcpP9cZPs3jk6/OuPhI+My8sYGEkJ1NsY3+234Zr8NKw82oaxWH06za7SEiVkmTBtgxtQB5oBPfVp6eM3Wu5Y+2JtZ7dLqxqvvZJ4qyI9syAoEoJh9V7fO3eVi48SSWe71N/dBeTUTfy4AGRhAXgwdAAC2u/JuWX9X/q2T9AAnlYE9p+zYeMSOTUebsOWYHWf9FKInxUgY3tOI4b1MGNXbiEGpRp9sWOGJnli/YNXL294bA8DY+sZnW21rP846OTaQgArPcJyvNE48+7VPQQkGZb8+cz8DWQKQvg+zXWnZQ5IGLHt39lPjZJJ092SxkmoV+087sP+0HYfPKjhRruBkhYJTlQocint1GWQgLU5GRryMjC4y+iTJGJhqRP9uBiTHSHr76FBUxXbTp79Zu+303imXL7xC7eqBx+qTjUqSHgAVPsCkQ4YJZ/q390habUEJYODrM38FxjOufeYwy0P63kW2qzhz9Novv7cgPd4a1wNBoppGxrlaFdWNKqobGAzAdj7faTYSCM07tcdaJcRHSoi2BM/KoTO1pcUz3//x2erG2qHttYF58TWrH+l+dkLAgaMLYPpvOSQT/9w04exL7t5Pj1pe1muzog1wFDEQK8LswAKyzc0kqfTvk+4pmN1v+hgIBUzv7/t8/V9WPN2PmRPaawdGwontOUeSTcRmn0JEuMtLy1caGpFOV5bUuXtPPRr/O/fZwaak2ZndwBglAOnfMLuj8zA4cvmxdWnri3d+OStzSqpMkglCflODw9Zwy6f3bHpn12djAEQ4awcPdT9bkBNhc3F6l//Xa4fw7kT/lqeWfOHJvfU4saOQ+jQAx+VdNnS3P3P1Erw7D1zecMTJeaStp3dfnf/GnON7Sgu2CXz5R5uKd27Pe/W64q3Fe8d2dH8SDcrWefG1+boETmgD026Qpec8vb9eJX0GLpj5FoBbRB7S/2G2i8XsecnZa1675tHhVoMlWuBMe9U7bNW/WPLXzWuOb5nUOkJzcn8cH/U7dXxwpK2PF40fwZ2/9OO1cxvQvW6YeOZHnt5nr4YKJaZHAVY9REKQbn/mCxd53kGypt8AABi3ntk7Jf/1Gyo+O7T8Owhpqg/3fbk295VratYc3zK1BZId3Z/hUY3rL0CyjU3Ro0NDuw7TV+G+T8pfPExVCE96c6+9HkYcuGDGIgCz3MGPcJAu/Ux7d552DkiN6vrNf2b9I7VHTOoACHmsA+eO7Ltj0X0VpfXnxrp6f4i4YuOgIo4zOOI17BgQ04lcKv+RccKZuV6ZQm8bjUr8WGg4SCCI8pBuHtD8YnHt2alXvHt771sW/W55eUPlaQi5pTO1pafnLLxz1TXv/aRfCyRdvT//l1i9xykk2xghneb/2nGXwZK/ZBWPe3vvNZmYNmDBjKUEXCFcpKthtm9+O9sHpFPVjkrPXfvv6X/NiTZHpkDI+Rdlryv784qnN39e8O04MKLdvT9m4sM7hhzrIRMM7t98kb/0rjx9YZxQfI0uQDnotZn5KvOmS+sTgAwUIF2rhZudQdm4jPxdj068Jys5MjFNYLGVg6wrO3n/yqf3fHt0wygGx3l6f/7V8+y2q7vUDXP7LrO/ABiy4TizyiNNk854/aA+zZY6DFww4zMA1wpAutWCAgbIdmTrFZu+7qlp/y8hu2tmTjgDclfJwQN/Xf30mT0lh0YBsHjTDtLN9k3fDjw5wqs7LvKXnpVnfGKceHqOFm1CM1BmvzJzKEu8jVvqFJB02UUGGJCXFlC7WGLW3pn/g4abs68dY5QMUeEAx0aHrfGtPZ/tXLDtA9O5+oqhrfuGF23AtmTAyTN9LPYemrQAAUx3yjOTlGsaf2qnrkAJAP1fm7GQVMz1yRcgwmwnB2jkVtspQISyYd0G7bx31I9ih3XLHgYNBv90JuW7oq07ntrweu3uswdzGRxzuSnxXJNi6la/0qej9dxhAEynXcG318JQ3zdNOHOTVg1FU1AOeOmaTMjKXgBGEWYHlYvsVAZZ2j82Le/Ej4bO7ToybWgOgXz7DFdfkZFVx5oTW3a/vmPhuY3FO3srqtK7/ajNO0mEs1sGH7dGyRztEyh4nL8MC3fZpChStmXyyUJdghIA+r868xkC/yrwgHT+CycACa/29ZNIOtMvvtfumwZdjRm9Jw2Ms0TrehDoXEPFyc8LVhz4YO8XUkHF8RxmJDqzO1rt1f7rlMp1v+hWOcbngBLheHvvPWWccPq3WrYh7UH536kJ1GQqBBAnwuzgCbO9gLFqkg2H+sX3Lpreayyu7jsxpUdsWiYAMwIjW2H58cIvD686vfzIWrmg/HiGXXX0advWfQdIMBAh8b5tQ070l4glvwFKALNFFYYmyqRpp87pGpQAMHDBjN8x4wkByNBxkW7yuyLSaD2aEZtWntutv5LXbbBhcFJmXFp0cqpZNmkxZ5MbHI1nTladKd5Tdqhq86ndyo6zB+Si6jOJDfaGngBi3GlgWkISAL+RWbJ7bHRDjt8B5bfpRNqE+z6BJdFvjeNPPaU103wCyr7PzjCbrLyPgd6hB8jwCrM1MLiXNDg6Z5DkMqvRUh5rjqyJNEZIkcYIxSQbEWG0NlmNZgMzUO9oVBrtjcZGRxPVOxqk2qYGrrZVR9fbbfEKK8nMHOvtL7DGgGxu+2b7+i+zT40OKKDC1F0S+LBcG5FNMwttQQFKAMh+5apZKmGRbwHp5GgBSN0B0pWD2ScPc2S/ALLF6H6Tfao6w+xI1gWgwgyYRLjWMP7U575oRT6b7rH3p199BtDnvnWR/oIk+xGSrq0eFpB0sX34BZLN57o2vm5zhllJ1s1657BaP06LfAVJn4ISAGQVdwNodNZ+w3j7sw42r/DyPC5fSMcFuX0WaPujBpf3BvEMkKxVO3D2US7+YQBOP9yjYoQegOM8bgzM9mzulvdgO7cGB9t/40uW+RSUe+YvOUw4v3NHUAESAQAke3eesAck/AjIy3/U7kurOGEl1aInh+a8iP8fL+Fbd8mPWSeWHA1aUAJAdU3042AqENufhRMgEQBAsh8ByW3+ijUou25NrhnpL8flVfnQC8cPGhTTP3zNMZ+D8uQ9CxsY+Iln7VbkIbW5EH/nId1N1msQZmvWDpxVdPnnaplH+mKfMiu5/oAriPylZsBUoUo/ocnHGoMelABw4KdLVoHxqj7DbJGHDL4w2595SLQLyJZXhkY2rcuPasps84ArHQPHuQkNvvwlMb9knFS0xh8M89smBw4b3QvgpP7CbH8CUuQhtQmzEbAwm9t22tp/9y0beFkHJ70B050qgyZ/WSyrxj/5i19+A2Xhr5ZUM/FdIswOFUAC4ZSHbO8830uo3Z5sUOKddnK3uKADQAVVOM7zafKxSn/xi+Bn9X/lyv8CdJunJBTrsj0rGNzzIeHHPKRr5zEBJ7YPO5liIjZ6+hm0a31hN2H9NcP4kz/2J7f8vr9gEyu/AnA89Kf7eHkekYeEXvKQ7emR3ufOugbJVo4orPKXPvNrR2Wj5R5/c8vvoDwyf3mVyrgFgOI/QIrpPiIP6V2Y3VpdTeqO2V0a8j0CiM/zlxoDyuP8pU/grTLzHTSqsDrkQQkAh+Z/9R0IT/s+zBbTfYIuzNZZHrIdOV7tWxrnNaB8lr8M3elEDP6HccLJVYFgVsC29nc0SH8CY6eY7iNcpE7mQ7qkUVG29dlWe0/NgCCmE7lUnoBthvjY+wPFK0IAlb3gyr6Kgq04v3+g2N0nDB1kO6f04e4+Xp1HAleuH3Ka4g1qrPatjH33QD5flfffYE+tTEo+jSs+GChWBfRhUXt/vLSQmH8q8pB6cJCAyEN2rB8n1+9xDZIeOii385e+9EQ6CsdJ+lkgIRlwR9mirJevfA3ADz3ubH5xkWK6T/C5SIZWX5OF+PCO3OKeMkH2m5sT04kA4BXD+BPzA80oXTx+NAqmXzKw1z1Aijyk9zYs9Lc/8/o85w/8V6/K2mZI+sFBifxl86uE3bKs3q0HRukClFvnL66XWb0eQKVrYbY/ASmm+wRfmK0dIAGgh9mxcVqX+iEBAVT4LoeskCR1Do052SBA2Ur7f7asgKB+D5fOr3SzBwtAehbmhMuyQw9uh+3lvmXpAQeUbvKXfplOpILoFhqj3XO5QwaUAHBg/rKvmfBgu53NB5kXsf3ZRUhqDsggme7T2YHT4xo39rEqadoDx8PyYbCdGxH9yTDu+Jd6YhNBb2JQ1itXLgT4BvE4WK0ACT8CEkEz3aezA2Vw6eZhJZHRkhqhywd0Be10og7L/08ed/xGIjB0JF05yvPoZhjMd4CxU4TZEHlI/4bZbfSb9NrCZkjqyKF5FY7rO39JhO1yfePteoOkPh3leWU9Nz0VRtoIIN13YbYGv5PsfS3aOkj4McQG/Pw4WJ86yNaKlNUD24aWZEnEpFuH1omT17W7bFOMAaBYVg2jaOLhIj3ySIJOdfCXy4olousA1GnrIl3PQ2rnIv0ZZos8pAY/bPxc7wqWJCa4/0TAAJRvNZ0o2PKXzf9Tr0rybL1CUtegBID985duI0i3AVDFfEi9hNn63v7Mu/vWXCgrwrF+fJxtQOfM0ukGt8E0/5KgQsLNprFHNuuZRTJ0rrLPC/cnXtu3GsBVnjsGMVAjwmzXCjGj7qPsc9ExMke63ufDMX+pjTsm5l8axh1/S+8ckhAEOjh/6dNgPOZZZxOQ1HWYHaCBmksLtfzf7MSGrWkmJckpQAIOTDcBpePt3Bh4UB5//PlgYBAhWMSgfi9f8SqAHwkX6U9AIujWZbvtIs//ayAU7cwrSTITm12ulL1uPP4rr6fpRMSvGMYem48gkRQsFwoCH4qPnQ/wxx27BjHdR1MHGaJ5yPaK/6V71en2IdmBgxLhuCflF8lNPX+BIBIhyJT+1GhrhDVmMcBTw8NBAmK6j28cZGvFG3nnpqElQ7w6KWvSuHToMDW8FsZSuUa+jmYW2oKJOxKCTCfvWd9QK5lmMXilO/5DLDt0w0X6Jcz2FyS5U0gCUBZkVkZ47aA0z1/Ct+X9P53oO7m+/oZgg2RQghIAiucvrrdG0jWAusbraEyE2SEeZndePC/avi4nsilTM0CRVkALqelE62WYZtKVJXXByBxCEKv3y9NiDSotB5AfOg4SIsz2cZjdpgMQqjYMKVUTjGoXn4ScIRuOu1E/Y5NslKYH4umJYe0oW3Rk/vKqpkb7dAKtD24HCYjtz7RykOzWeW5JrN/VPiQ1cnRBN/8SWk8n2izLTTOCGZJB7yhblPPmFZGNdfwZA1OEi3ThXGEy3aczmcBHduWfzTAQjH5zdJo5zKB4HMVqGcZraNzBmmBnjIQQ0K7bvq6rlSzXgvB18LhIkYcMlItsKfhY7+oKA5HR9QsS+UvX6+evZKnpqlCAZMiAEmge4LGb7deBsVgA8tIwGyLMvqRgilHdMivBlhcQQIX+cshP5Gp5tl4e4yBAeYmO3bGysSAx7noGvaoFIP0VZos8pP8AeV72BVmViQEHVGjmL/8j2zNuDMYpQFrGEsEhBvV74Yr7mfh+T3M2Ig/pykfRfx6yvYITYptWv55VOUGDC9K2fDAth2yvjRE9bhhT+P/0uPGuAGUH6vfC9F8w8Gxb5ywAqc1H0ed0n84KSuCyzcPKTLEGjtENcFyuQrfTiRQi/qU89siLocoSCSGsQ3cuex7ENwKoF3nIsA2z22h+auNB1yApwnGXyktUBwlzQxmSIe8oW5T5/PShIP4MQIZwkQEOs/3sIFvLKuHgjvzSTPmCQdBpSKsLh+lS2WKV1etM445sCXWGSAgDFfxi2Q5JoVEEbA0NF+nP6T7tr8sONkgCwLOZ1TaZILV9wJXepuS4Y2UC9/xuAnbKrI4OB0iGDSiB5mfwGNkxiQiLBCDdCbM1AmQAwuzW6mlRN0yOs+W0zwwdPv9G3+H4R5K5fgyNO3IiXPhBCDcxqO+L038P8KNgb38oxPZnenaQrdSwfEh5eU+LkuZJikGE462bNv/DMKbwj0RQwwkbEsJNBC68c9njDPUaABW+cJGaAzJ8tz/TApK4Kt62ySkkLzNNOn1gmE8dpkuqBvh649jC+8INkuHpKFup77NT+kCWPgEw2NteKqb76M5FAgBk4jPb88qjIy48LIy9+l60vdDgcJfE2CURz6GxhYfDlRUSwliFv/r2cL3BOgqMN7xxkGK6D3SRh2zvwN9l1B+NaPNExU4fn+rH/GUQTCciek2y1I0OZ0iGvaNs4y6fnzoXoFcBxLnyKyvykPp0kK1BHCPznm355dnOVyqzm9cRVvnLGrD6c8O4wncEHcLcUbZxl7/45n8GyZALYKMrLlL7MDsU85CBgyQA9eWsGqnj7RxccFwhl790pVbaJpMyTEBSgLJdHfj5V8egGCeC+Sng8oS1mO6j7zC79eEDIx3rR0TbB2oGKPIWaPBvec/CcZWJnpDiDKNpzOFCQQQReneqPs9PGUNEb4LRR4TZQeEgW7fq2nVDKuuSzWqy+ycI23D8OKvS7cbxB1aK3i8cpcs6/Itv18FhGsaMV7QHpNj+zPsPzk4Pn5vYuO0iJN31A+EYjtNCWTXnCkgKR+mV+v572nUMfgFAqtc2T2x/5hsXeV5G8IldIyq7mYhNfnN0unWY3NnLp6DSzw3jDywWvVw4Sq9VeNfyRWykgWjesk11v2GLPKRWF+T08PNv/K1XfYlzSPrI0ek2f+nkWpr3i3xLJkOOgKRwlD5R7+enjZNYfZVB/V0Ls/3hINsHZDg4yNZvJBh4+6b8ityAujn95y8PM+OnxrEHvxW92XXJ4itwTxVfHjkRMa3b60bZqAAYCcAQPmG2PwGJCw7SxXod72bXNCabOF5Tt+iJu9Rn/rKRiB6WbbYfyBMOF4ieLByl39T32Sl9INHTDFwT2oDUr4ts0fBox5r3s2vGB8ChBYPDXC5D/SWNOXRA9FoBysAB87nJs1TC08TUS4TZ/gUkABChYnNeFboY1C4BDGn1CMsjINxtGC3ykN5KDOZooMJfrvjMWpbYn0F3A6gU0308u6DOBmqc6fbkxj3OIemJH9C4vP/D8Vpm/E22NWYLSApHqUulP3VlvMlg/z0IdwMwB1+Y7aFb9bOLbJGZ+MiuEZXdDdRerliH7tK3DtMO0BsyG/5CY3edFb1RgFL36v3M9EySlEcYmOvW9yzCbLfqfa5f3faZCfZc99eW6ikc97p+FYyFMkl/pjF7xdJDAcrgU59nJg2CJP21U2AKQLpdb5pF3bQ6t3pE2+ODYMK3tu5yuUr4g2n0/m2itwlQBr16PTtlBBEeAnCFAKQm9TZ9lVtzJtOidG+3Mtb8y9JbOP6Vqkp/MY3bs0X0LgHKkFPfZ6flMtTfMOFmcOt5rGK6jzua3MW+ekH/ugmdnje0gMkAf6GqeMQ0bv8G0ZsEKEMfmP+enM0q/YGBmwA2CEC6LolQtjW/0hxjQLRrlxH0+Us7QO/LEh6jUXv3id4jQBl26vHchF6yKv8ShB8yECsA2bl+ldG49tfptrFuV8Q6f/7N5UUqGbzAoNJzNG7vCdFbBCjDXtnPT4qqd9DNkOhuMA8ITkA2H+wrQAJAhIyDO4dXZUrUeg6wm0DTfzheSET/lhr4NZq8t1b0DgFKoUv1wANS78SVM1mR5oN4Bpytxw8zF9lSyxsD6/ZOiHUM0gRQ+gKmA8CXAL8kj9q3NBwfCStAKeSRMp6bniqz/VYCzQfQK4wBCQDoa3WsXzq0brSmHyTw+ctTDH7boKov0tj9x0WrF6AU8sJl9khYfSUpfCsRrgMQEU6APB/Q168eVluVblZTfPLB/Ju/rAPwKRPeNIzcs1y4RwFKIY2V/tRoq1GyXgPCbQBfBcAQiGWHfgQkAOCaRMfqZzMbJvh8gMV34bgK8HoielNyNL1H4w7WiNYsQCnkp9DcoNqvJ+AGBiawq/uLBoWLvAhjA3B658iaOKsEq4/CX18B0wFgFYE+kmTlExqx94xotQKUQgFU32fHd1VYvo4Zc0CYDMAS7IBs+Z8/97Rt+GFq0yhNAOj7cLwRjG8A/liWHYto5IFzonUKUArpNDw3GcxjVRXTQLgOjP6e1eT3PORl9cYYsHv7iJpB1GFbDTgwj4Hpa0BdLqtNX4mwWoBSKAjV/dmpAyVVnQbwZIAnAOTC4xIC6yLPS/1wUH1hfozSzyfhtefheBmA1QRaKbG6jMbsFjuHC1AKhZQeeEDqFb9qMDNPAvMEAKMAStUZIAEA2RHq2sVD68b6HICd6yRAG4jVNQ5SV5pG7tlNpLWfFhKgFNK1+jw5IUOVaRQIo1TGCABDgEvWUfsRkOcbZs36/HpbkklN9JtjbFY1gF0MbCTwBhnYQKN2nRStRIBSSOhSZlD3p8f1IkhDCVIOE+eAkY3mSe9GTRDZCce+n2xf/Wgf2wQfOkY7A0cItJeZd5PEO2VJ3Yn83UeFWxQSoBTyWHkv5xkraq29HCRnEVEWwL3ByCBCDwYyAMR54yJbZAIf3z2qLsUoweSlW6wkoIiZj4NwgkBHmNSDMtNBNMQdpckrHeKuCglQCvlVWY+PjW4wmrpLxF1BajJD6kqq0pUlSmRGVzAiCYhkoihAjQNTFKgVDBlxAOjxvo1b5iU78sCobAXHJoDqCKhgQi2Y6wCqA1DK4DKJqJRVlDLUElXmUlNT4wkx+iyklf4/skH3vjnzREcAAAAldEVYdGRhdGU6Y3JlYXRlADIwMjYtMDYtMDhUMTc6MDE6MzIrMDA6MDCGDDL0AAAAJXRFWHRkYXRlOm1vZGlmeQAyMDI2LTA2LTA4VDE3OjAxOjMyKzAwOjAw91GKSAAAAABJRU5ErkJggg=="
$logo = [Windows.Forms.PictureBox]::new()
$logo.Size      = [Drawing.Size]::new(36, 36)
$logo.Location  = [Drawing.Point]::new(16, 13)
$logo.BackColor = $CARD
$logo.SizeMode  = [Windows.Forms.PictureBoxSizeMode]::Zoom
$logo.Image     = [Drawing.Image]::FromStream([IO.MemoryStream]::new([Convert]::FromBase64String($LOGO_B64)))
$header.Controls.Add($logo)

$lblTitle = [Windows.Forms.Label]::new()
$lblTitle.Text      = $APP_NAME
$lblTitle.Font      = $FONT_TITLE
$lblTitle.ForeColor = $FG
$lblTitle.Location  = [Drawing.Point]::new(60, 8)
$lblTitle.AutoSize  = $true
$header.Controls.Add($lblTitle)

$lblSub = [Windows.Forms.Label]::new()
$lblSub.Text      = $APP_SUB
$lblSub.Font      = $FONT_SUB
$lblSub.ForeColor = $MUTED
$lblSub.Location  = [Drawing.Point]::new(62, 39)
$lblSub.AutoSize  = $true
$header.Controls.Add($lblSub)

$script:counter = [Windows.Forms.Label]::new()
$script:counter.Size      = [Drawing.Size]::new(180, 24)
$script:counter.Location  = [Drawing.Point]::new($W_FORM - 196, 19)
$script:counter.Font      = $FONT_CNT
$script:counter.ForeColor = $MUTED
$script:counter.TextAlign = "MiddleRight"
$header.Controls.Add($script:counter)

# Franja de acento bajo la cabecera
$accentStrip = [Windows.Forms.Panel]::new()
$accentStrip.Size      = [Drawing.Size]::new($W_FORM, 2)
$accentStrip.Location  = [Drawing.Point]::new(0, 62)
$accentStrip.BackColor = $ACCENT
$form.Controls.Add($accentStrip)

# ── Panel scrollable con scrollbar oscuro personalizado (todo negro) ──
$SBW       = [Windows.Forms.SystemInformation]::VerticalScrollBarWidth  # ancho del scrollbar nativo (se oculta)
$VBAR_W    = 8                                                          # ancho de nuestro scrollbar
$TRACK_COL = $BG                                                        # pista/fondo: negro
$THUMB_COL = [Drawing.Color]::FromArgb(64, 64, 72)                      # pulgar en reposo
$THUMB_HOV = [Drawing.Color]::FromArgb(98, 98, 110)                     # pulgar en hover/arrastre

# Contenedor que recorta el scrollbar nativo del panel
$scrollHost = [Windows.Forms.Panel]::new()
$scrollHost.Location  = [Drawing.Point]::new(16, 74)
$scrollHost.Size      = [Drawing.Size]::new($W_PANEL, 474)
$scrollHost.BackColor = $CARD
$form.Controls.Add($scrollHost)

# Panel real con AutoScroll; más ancho para que su scrollbar nativo quede fuera (recortado por el host)
$scrollPanel = [Windows.Forms.Panel]::new()
$scrollPanel.Location   = [Drawing.Point]::new(0, 0)
$scrollPanel.Size       = [Drawing.Size]::new($W_PANEL + $SBW, 474)
$scrollPanel.BackColor  = $CARD
$scrollPanel.AutoScroll = $true
$scrollHost.Controls.Add($scrollPanel)

# Pista del scrollbar (negra) y pulgar (gris oscuro)
$vbar = [Windows.Forms.Panel]::new()
$vbar.Size      = [Drawing.Size]::new($VBAR_W, 474)
$vbar.Location  = [Drawing.Point]::new($W_PANEL - $VBAR_W, 0)
$vbar.BackColor = $TRACK_COL
$scrollHost.Controls.Add($vbar)
$vbar.BringToFront()

$vthumb = [Windows.Forms.Panel]::new()
$vthumb.Size      = [Drawing.Size]::new($VBAR_W, 40)
$vthumb.Location  = [Drawing.Point]::new(0, 0)
$vthumb.BackColor = $THUMB_COL
$vthumb.Cursor    = [Windows.Forms.Cursors]::Hand
$vbar.Controls.Add($vthumb)

$script:vDrag = $false
$script:vDragStartY = 0
$script:vDragStartScrolled = 0

function Update-VScroll {
    $view    = $scrollPanel.ClientSize.Height
    $content = $scrollPanel.DisplayRectangle.Height
    if ($view -le 0 -or $content -le $view) { $vbar.Visible = $false; return }
    $vbar.Visible = $true
    $trackH = $vbar.Height
    $thumbH = [int][math]::Max(28, [math]::Round($trackH * $view / $content))
    if ($thumbH -gt $trackH) { $thumbH = $trackH }
    $maxScroll = $content - $view
    $scrolled  = - $scrollPanel.AutoScrollPosition.Y
    if ($scrolled -lt 0) { $scrolled = 0 } elseif ($scrolled -gt $maxScroll) { $scrolled = $maxScroll }
    $thumbY = if ($maxScroll -gt 0) { [int][math]::Round(($trackH - $thumbH) * $scrolled / $maxScroll) } else { 0 }
    if ($vthumb.Height -ne $thumbH) { $vthumb.Height = $thumbH }
    if ($vthumb.Top    -ne $thumbY) { $vthumb.Top    = $thumbY }
}

$vthumb.Add_MouseEnter({ if (-not $script:vDrag) { $vthumb.BackColor = $THUMB_HOV } })
$vthumb.Add_MouseLeave({ if (-not $script:vDrag) { $vthumb.BackColor = $THUMB_COL } })
$vthumb.Add_MouseDown({
    $script:vDrag = $true
    $script:vDragStartY = [Windows.Forms.Cursor]::Position.Y
    $script:vDragStartScrolled = - $scrollPanel.AutoScrollPosition.Y
    $vthumb.BackColor = $THUMB_HOV
})
$vthumb.Add_MouseUp({
    $script:vDrag = $false
    $vthumb.BackColor = $THUMB_COL
})
$vthumb.Add_MouseMove({
    if (-not $script:vDrag) { return }
    $view    = $scrollPanel.ClientSize.Height
    $content = $scrollPanel.DisplayRectangle.Height
    $maxScroll = $content - $view
    if ($maxScroll -le 0) { return }
    $denom = $vbar.Height - $vthumb.Height
    if ($denom -le 0) { return }
    $dy = [Windows.Forms.Cursor]::Position.Y - $script:vDragStartY
    $newScrolled = $script:vDragStartScrolled + [int][math]::Round($dy * $maxScroll / $denom)
    if ($newScrolled -lt 0) { $newScrolled = 0 } elseif ($newScrolled -gt $maxScroll) { $newScrolled = $maxScroll }
    $scrollPanel.AutoScrollPosition = [Drawing.Point]::new(0, $newScrolled)
    Update-VScroll
})

# El thumb se sincroniza con la rueda y el arrastre nativo via timer + evento Scroll
$scrollPanel.Add_Scroll({ Update-VScroll })
$vtimer = [Windows.Forms.Timer]::new()
$vtimer.Interval = 60
$vtimer.Add_Tick({ Update-VScroll })
$vtimer.Start()
$form.Add_FormClosed({ $vtimer.Stop(); $vtimer.Dispose() })

$yGlobal = 8

# ── Filas de caracteristicas (listado unico) ──
$i = 0
foreach ($name in $POLICIES.Keys) {
    $p = $POLICIES[$name]
    $rowBg = if (($i % 2) -eq 0) { $CARD } else { $CARD2 }
    $i++
    $script:state[$name] = $true   # por defecto activada (ON)

    $row = [Windows.Forms.Panel]::new()
    $row.Size      = [Drawing.Size]::new($W_ROW, $H_ROW)
    $row.Location  = [Drawing.Point]::new($X_ROW, $yGlobal)
    $row.BackColor = $rowBg
    $row.Cursor    = [Windows.Forms.Cursors]::Hand
    $scrollPanel.Controls.Add($row)

    $lbl = [Windows.Forms.Label]::new()
    $lbl.Text      = $name
    $lbl.Location  = [Drawing.Point]::new($X_TXT, 7)
    $lbl.Size      = [Drawing.Size]::new($W_TXT, 17)
    $lbl.ForeColor = $FG
    $lbl.Font      = $FONT_BODY
    $lbl.BackColor = [Drawing.Color]::Transparent
    $lbl.Cursor    = [Windows.Forms.Cursors]::Hand
    $row.Controls.Add($lbl)
    $script:labels[$name] = $lbl

    $desc = [Windows.Forms.Label]::new()
    $desc.Text      = $p.Desc
    $desc.Location  = [Drawing.Point]::new($X_TXT, 25)
    $desc.Size      = [Drawing.Size]::new($W_TXT, 14)
    $desc.ForeColor = $MUTED
    $desc.Font      = $FONT_DESC
    $desc.BackColor = [Drawing.Color]::Transparent
    $desc.Cursor    = [Windows.Forms.Cursors]::Hand
    $row.Controls.Add($desc)

    $tog = New-Toggle $name $X_TOG ([int](($H_ROW - $TOG_H) / 2)) $rowBg
    $row.Controls.Add($tog)
    $script:toggles[$name] = $tog

    $keyList = ((Get-PolicyKeys $p) | ForEach-Object { $_.Key }) -join ", "
    $tt = [Windows.Forms.ToolTip]::new()
    $tt.SetToolTip($lbl,  "Clave: $keyList")
    $tt.SetToolTip($desc, "Clave: $keyList")

    # Click -> alternar
    $capture = $name
    $onClick = { Invoke-PolicyToggle $capture }.GetNewClosure()
    $row.Add_Click($onClick)
    $lbl.Add_Click($onClick)
    $desc.Add_Click($onClick)
    $tog.Add_Click($onClick)

    # Hover de fila
    $baseBg = $rowBg
    $onEnter = {
        $row.BackColor = $HOVER
        $tog.BackColor = $HOVER
        $tog.Invalidate()
    }.GetNewClosure()
    $onLeave = {
        $pt = $row.PointToClient([Windows.Forms.Cursor]::Position)
        if (-not $row.ClientRectangle.Contains($pt)) {
            $row.BackColor = $baseBg
            $tog.BackColor = $baseBg
            $tog.Invalidate()
        }
    }.GetNewClosure()
    $row.Add_MouseEnter($onEnter);  $row.Add_MouseLeave($onLeave)
    $lbl.Add_MouseEnter($onEnter);  $lbl.Add_MouseLeave($onLeave)
    $desc.Add_MouseEnter($onEnter); $desc.Add_MouseLeave($onLeave)
    $tog.Add_MouseEnter($onEnter);  $tog.Add_MouseLeave($onLeave)

    $yGlobal += $H_ROW + 2
}

# ── Botonera ──
$btnY = 560; $btnH = 36
$btnDefault    = New-Button "Default"      16  $btnY 92  $btnH
$btnEnableAll  = New-Button "Activar todo"  116 $btnY 92  $btnH
$btnDisableAll = New-Button "Desact. todo"  216 $btnY 92  $btnH
$btnApply      = New-Button "Aplicar"       316 $btnY 118 $btnH -Primary
$form.Controls.AddRange(@($btnDefault, $btnEnableAll, $btnDisableAll, $btnApply))

# ── Barra de estado ──
$script:status = [Windows.Forms.Label]::new()
$script:status.Location  = [Drawing.Point]::new(16, 606)
$script:status.Size      = [Drawing.Size]::new($W_PANEL, 18)
$script:status.ForeColor = $MUTED
$script:status.Font      = $FONT_STAT
$script:status.Text      = ""
$form.Controls.Add($script:status)

# ── Estado inicial ──
Update-CurrentState

# ── Eventos ──
$btnEnableAll.Add_Click({
    foreach ($n in @($script:state.Keys)) {
        $script:state[$n] = $true
        $script:labels[$n].ForeColor = $FG
        $script:toggles[$n].Invalidate()
    }
    Update-Counter
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas las caracteristicas activadas."
})

$btnDisableAll.Add_Click({
    foreach ($n in @($script:state.Keys)) {
        $script:state[$n] = $false
        $script:labels[$n].ForeColor = $MUTED
        $script:toggles[$n].Invalidate()
    }
    Update-Counter
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas marcadas para desactivar."
})

$btnDefault.Add_Click({
    # Elimina por completo la clave de politicas de Chrome -> vuelve todo a sus
    # valores predeterminados y Chrome deja de aparecer "Administrado por su organizacion".
    try {
        if (Test-Path $REG_PATH) { Remove-Item $REG_PATH -Recurse -Force -ErrorAction Stop }
        Update-CurrentState
        $script:status.ForeColor = $GREEN
        $script:status.Text = "Politicas eliminadas. Reinicia $BROWSER; ya no saldra administrado por su organizacion."
    } catch {
        $script:status.ForeColor = $RED
        $script:status.Text = "No se pudieron eliminar las politicas: $($_.Exception.Message)"
    }
})

$btnApply.Add_Click({
    $disabled, $fail, $reenabled = Set-Policies
    Update-CurrentState
    $msg = "$disabled desactivadas"
    if ($reenabled -gt 0) { $msg += ", $reenabled reactivadas" }
    if ($fail -gt 0)      { $msg += ", $fail errores" }
    $msg += ". Reinicia $BROWSER para que surtan efecto."
    $script:status.ForeColor = if ($fail -gt 0) { $RED } else { $GREEN }
    $script:status.Text = $msg
})

# Refresco inicial del scrollbar personalizado una vez mostrado el formulario
$form.Add_Shown({ Update-VScroll })

[void]$form.ShowDialog()
