# GLM Toggle — Claude Code için

> [Claude Code](https://claude.com/claude-code)'da **GLM-5.1 (z.ai)** ve **native Claude** arasında tek tıkla geçiş yapın — VS Code'un activity bar'ından direkt.

![GLM Toggle](docs/screenshots/preview.png)

Claude Code'u maliyet veya kullanılabilirlik nedeniyle [z.ai'nin GLM-5.1](https://z.ai) modeliyle kullanıyor, ama bazen Anthropic'in native Claude'una geri dönmek istiyorsanız bu eklenti tam size göre.

Artık her seferinde `~/.claude/settings.json`'ı elle düzenlemenize veya hangi env değişkenini yorum satırı yapacağınızı hatırlamanıza gerek yok.

> İngilizce versiyon için [README.md](README.md) dosyasına bakın.

---

## Özellikler

- **Tek tıkla geçiş** GLM-5.1 (z.ai) ve native Claude (Anthropic API) arasında
- **Activity bar ikonu** — özel paneliyle nerede olduğunu hep bilirsiniz
- **Status bar göstergesi** mevcut modu anlık gösterir (`⚡ GLM-5.1` / `✨ Claude`)
- **Renk kodlu** — GLM aktifken sarı arka plan, native Claude'da varsayılan
- **Dış değişikliği algılar** — `settings.json`'ı elle düzenlerseniz UI otomatik güncellenir
- **İsteğe bağlı CLI** — `glm.bat` ile herhangi bir terminalden toggle (`glm on`, `glm off`, `glm status`)

## Nasıl çalışıyor

Claude Code yapılandırmasını `~/.claude/settings.json`'dan okur. z.ai üzerinden GLM kullanmak için şuna benzer bir blok gerekli:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "z-ai-tokeniniz",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5.1",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5.1",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air"
  }
}
```

GLM Toggle **iki profil dosyası** tutar — biri z.ai env bloğuyla (GLM modu), biri o blok olmadan (native Claude modu) — ve siz butona basınca `settings.json`'ı bunlardan biriyle değiştirir.

```
~/.claude/
├── settings.json          ← aktif yapılandırma (toggle'da üzerine yazılır)
└── profiles/
    ├── glm.json           ← GLM-5.1 yapılandırmanız
    └── claude.json        ← Native Claude yapılandırmanız
```

> Claude Code env değişkenlerini sadece başlangıçta okur. **Toggle sonrası Claude Code'u yeniden başlatın** ki değişiklik uygulansın. Eklenti zaten hatırlatma bildirimi gösterir.

## Kurulum

### Ön koşullar

- VS Code 1.70+
- [Claude Code](https://claude.com/claude-code) kurulu
- (İsteğe bağlı) GLM-5.1 kullanmak için z.ai hesabı ve API token

### 1. Profil dosyalarını hazırlayın

Profil klasörünü oluşturup örnekleri kopyalayın:

```bash
mkdir -p ~/.claude/profiles
cp profiles/glm.json.example ~/.claude/profiles/glm.json
cp profiles/claude.json.example ~/.claude/profiles/claude.json
```

Sonra `~/.claude/profiles/glm.json` dosyasını açıp `YOUR_Z_AI_TOKEN_HERE` yerine gerçek z.ai token'ınızı yazın.

> ⚠️ **`~/.claude/profiles/glm.json` dosyasını ASLA version control'e commit etmeyin** — içinde API token'ınız var. Repo'nun `.gitignore` dosyası `.claude/` klasörünü zaten dışlıyor olmalı, yine de iki kez kontrol edin.

### 2. VS Code eklentisini kurun

**Seçenek A — .vsix'ten kur (çoğu kullanıcı için tavsiye):**

[Releases](../../releases) sayfasından en son `glm-toggle-X.Y.Z.vsix` dosyasını indirin ve kurun:

```bash
code --install-extension glm-toggle-0.1.0.vsix
```

Veya VS Code'da: Extensions panelini açın (`Ctrl+Shift+X`) → `...` menüsüne tıklayın → "Install from VSIX..." → dosyayı seçin.

**Seçenek B — kaynaktan derle:**

```bash
git clone https://github.com/system-conf/claude-code-glm-toggle.git
cd glm5-vscode-toogle
powershell -ExecutionPolicy Bypass -File scripts/build-vsix.ps1
code --install-extension glm-toggle-0.1.0.vsix
```

Kurduktan sonra **VS Code'u yeniden yükleyin** (`Ctrl+Shift+P` → "Developer: Reload Window").

## Kullanım

Kurduktan sonra göreceksiniz:

- Sol activity bar'da **toggle switch ikonu**
- Sağ alttaki status bar'da **mod göstergesi** (`⚡ GLM-5.1` veya `✨ Claude`)

**Mod değiştirmek için:**
- Activity bar ikonuna tıklayın → panelde istediğiniz moda tıklayın
- Veya status bar'daki öğeye tıklayın (iki mod arasında toggle yapar)
- Veya komut çalıştırın: `Ctrl+Shift+P` → `GLM Toggle: ...`

**Her geçişten sonra Claude Code'u yeniden başlatın** ki yeni env değişkenleri yüklensin.

## İsteğe bağlı: komut satırından toggle

VS Code açmadan terminalden toggle yapmak isterseniz `scripts/glm.bat`'i PATH'inizde bir klasöre kopyalayın:

```bash
cp scripts/glm.bat ~/.claude/
powershell -ExecutionPolicy Bypass -File scripts/add-to-path.ps1
```

Sonra herhangi bir terminalden:

```
glm status     # mevcut modu göster
glm on         # GLM-5.1'e geç
glm off        # native Claude'a geç
glm            # toggle
```

## Yapılandırma

| Ayar | Varsayılan | Açıklama |
|---|---|---|
| `glmToggle.claudeDir` | `""` (`~/.claude` kullanır) | `.claude` dizininize özel yol. Standart dışı bir yerdeyse kullanışlı. |

## Katkıda bulunma

PR'lar bekleniyor — özellikle:

- **macOS / Linux shell scriptleri** (CLI parçası şu an sadece Windows; eklenti zaten cross-platform)
- **Özel profil isimleri** (sadece `glm`/`claude` değil — `gpt`, `gemini`, birden fazla z.ai hesabı vs.)
- **Daha iyi activity bar ikonu**
- **README için ekran görüntüleri**

## Güvenlik

- API token'ınız `~/.claude/profiles/glm.json`'da duruyor. Eklenti onu hiçbir yere göndermez — sadece toggle yaparken `settings.json`'a kopyalar.
- Eklenti mevcut modu tespit etmek için `settings.json`'ı okur (içerikte `api.z.ai` arar). Sadece toggle komutu çalıştırıldığında yazar.
- **Token'ınızı yanlışlıkla commit ederseniz mutlaka rotate edin.**

## Lisans

MIT — [LICENSE](LICENSE) dosyasına bakın.
