# Sistema de Temas - Goverlay

Este documento explica como funciona o sistema de temas (claro/escuro) do Goverlay e como adicionar o botão de alternância na interface.

## 📋 Visão Geral

O sistema de temas permite alternar entre modo claro e escuro, salvando a preferência do usuário automaticamente. A implementação está no arquivo `themeunit.pas`.

## 🎨 Cores dos Temas

### Tema Escuro (Padrão)
```pascal
DarkBackgroundColor = $0045403A;      // Fundo escuro principal
DarkerBackgroundColor = $00232323;    // Fundo mais escuro (itens não selecionados)
DarkTextColor = clWhite;              // Texto claro
```

### Tema Claro
```pascal
LightBackgroundColor = clWhite;       // Fundo claro principal
LighterBackgroundColor = $00F5F5F5;   // Cinza claro (itens não selecionados)
LightTextColor = clBlack;             // Texto escuro
LightBorderColor = $00D0D0D0;         // Borda cinza
```

## 🔧 Funcionalidades Principais

### 1. Carregar Tema Salvo
No `FormCreate` do form principal, adicione:

```pascal
uses themeunit;

procedure Tgoverlayform.FormCreate(Sender: TObject);
var
  SavedTheme: TThemeMode;
begin
  // ... código existente ...

  // Carregar e aplicar tema salvo
  SavedTheme := LoadThemePreference;
  ApplyTheme(Self, SavedTheme);

  // ... resto do código ...
end;
```

### 2. Alternar Tema (Botão de Toggle)
Adicione um botão na interface e conecte ao evento Click:

```pascal
procedure Tgoverlayform.themeToggleBitBtnClick(Sender: TObject);
var
  NewTheme: TThemeMode;
begin
  // Alternar entre os temas
  NewTheme := ToggleTheme(Self);

  // Atualizar ícone do botão (opcional)
  if NewTheme = tmLight then
    themeToggleBitBtn.ImageIndex := 9  // índice do ícone sun/light
  else
    themeToggleBitBtn.ImageIndex := 10; // índice do ícone moon/dark

  // Opcional: Mostrar notificação
  if NewTheme = tmLight then
    SendNotification('Goverlay', 'Tema claro ativado', GetIconFile)
  else
    SendNotification('Goverlay', 'Tema escuro ativado', GetIconFile);
end;
```

### 3. Aplicar Tema Manualmente
Se precisar aplicar um tema específico:

```pascal
// Aplicar tema escuro
ApplyTheme(Self, tmDark);

// Aplicar tema claro
ApplyTheme(Self, tmLight);
```

## 🎯 Passo a Passo: Adicionar Botão de Toggle

### 1. Adicionar Ícones ao ImageList

No Lazarus IDE:
1. Abra `overlayunit.lfm`
2. Selecione `iconsImageList`
3. Adicione os ícones:
   - **Índice 9**: `data/icons/buttons/24x24/theme-light.png` (sol)
   - **Índice 10**: `data/icons/buttons/24x24/theme-dark.png` (lua)

### 2. Adicionar Botão na Interface

No Lazarus IDE:
1. Arraste um `TBitBtn` para o form
2. Nomeie como `themeToggleBitBtn`
3. Configure propriedades:
   - `Caption`: "Theme" ou deixe vazio
   - `Images`: `iconsImageList`
   - `ImageIndex`: `10` (começa com ícone escuro)
   - `Layout`: `blGlyphLeft`
   - `Hint`: "Toggle Light/Dark Theme"
   - `ShowHint`: `True`
   - `Width`: `80` (ou ajuste conforme necessário)

### 3. Adicionar Event Handler

1. Clique duas vezes no botão `themeToggleBitBtn`
2. Adicione o código:

```pascal
procedure Tgoverlayform.themeToggleBitBtnClick(Sender: TObject);
var
  NewTheme: TThemeMode;
begin
  NewTheme := ToggleTheme(Self);

  // Atualizar ícone do botão
  if NewTheme = tmLight then
    themeToggleBitBtn.ImageIndex := 9   // sol (tema claro ativo)
  else
    themeToggleBitBtn.ImageIndex := 10; // lua (tema escuro ativo)
end;
```

### 4. Carregar Tema no Startup

No evento `FormCreate`:

```pascal
procedure Tgoverlayform.FormCreate(Sender: TObject);
var
  SavedTheme: TThemeMode;
begin
  // Código existente...

  // Carregar tema salvo
  SavedTheme := LoadThemePreference;
  ApplyTheme(Self, SavedTheme);

  // Atualizar ícone do botão conforme tema carregado
  if SavedTheme = tmLight then
    themeToggleBitBtn.ImageIndex := 9
  else
    themeToggleBitBtn.ImageIndex := 10;

  // Resto do código...
end;
```

## 📁 Localização do Arquivo de Configuração

O tema é salvo em:
```
~/.config/goverlay/goverlay.conf
```

Formato do arquivo:
```ini
[Appearance]
Theme=dark
# ou
Theme=light
```

## 🎨 Personalização de Cores

Para ajustar as cores dos temas, edite as constantes em `themeunit.pas`:

```pascal
const
  // Dark theme colors (BGR format)
  DarkBackgroundColor = $0045403A;      // Altere aqui
  DarkerBackgroundColor = $00232323;    // Altere aqui
  DarkTextColor = clWhite;              // Altere aqui

  // Light theme colors
  LightBackgroundColor = clWhite;       // Altere aqui
  LighterBackgroundColor = $00F5F5F5;   // Altere aqui
  LightTextColor = clBlack;             // Altere aqui
```

**Nota**: Cores estão em formato BGR (Blue-Green-Red), não RGB!
- RGB `#FF0000` (vermelho) = BGR `$000000FF`
- RGB `#00FF00` (verde) = BGR `$0000FF00`
- RGB `#0000FF` (azul) = BGR `$00FF0000`

## 🔄 Componentes Suportados

O sistema de temas aplica cores automaticamente para:
- ✅ TForm (formulários)
- ✅ TLabel (rótulos)
- ✅ TCheckBox (caixas de seleção)
- ✅ TRadioButton (botões de opção)
- ✅ TMemo (campos de texto multilinha)
- ✅ TGroupBox (caixas de grupo)
- ✅ TCheckGroup (grupos de checkboxes)
- ✅ TRadioGroup (grupos de radio buttons)
- ✅ TPanel (painéis)
- ✅ TColorButton (botões de cor)

## 🐛 Troubleshooting

### Tema não carrega no startup
- Verifique se `LoadThemePreference` está sendo chamado no `FormCreate`
- Confirme que o arquivo de config existe em `~/.config/goverlay/goverlay.conf`

### Alguns componentes não mudam de cor
- Alguns componentes podem precisar ser adicionados manualmente em `ApplyDarkTheme` e `ApplyLightTheme`
- Exemplo para adicionar suporte a TEdit:
  ```pascal
  else if ctrl is TEdit then
  begin
    TEdit(ctrl).Font.Color := DarkTextColor;
    TEdit(ctrl).Color := DarkerBackgroundColor;
  end
  ```

### Ícone do botão não atualiza
- Verifique se os ícones foram adicionados ao ImageList nos índices corretos
- Confirme que `ImageIndex` está sendo atualizado no evento Click

## 🎯 Exemplo Completo

Aqui está um exemplo completo de como integrar o sistema de temas:

```pascal
unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  // ... outras units ...
  themeunit;  // Adicionar esta linha

type
  Tgoverlayform = class(TForm)
    // ... componentes existentes ...
    themeToggleBitBtn: TBitBtn;  // Adicionar este botão

    procedure FormCreate(Sender: TObject);
    procedure themeToggleBitBtnClick(Sender: TObject);
    // ... outros procedures ...
  end;

implementation

procedure Tgoverlayform.FormCreate(Sender: TObject);
var
  SavedTheme: TThemeMode;
begin
  // Código existente...

  // Carregar e aplicar tema salvo
  SavedTheme := LoadThemePreference;
  ApplyTheme(Self, SavedTheme);

  // Atualizar ícone do botão
  if SavedTheme = tmLight then
    themeToggleBitBtn.ImageIndex := 9
  else
    themeToggleBitBtn.ImageIndex := 10;

  // Resto do código...
end;

procedure Tgoverlayform.themeToggleBitBtnClick(Sender: TObject);
var
  NewTheme: TThemeMode;
begin
  // Alternar tema
  NewTheme := ToggleTheme(Self);

  // Atualizar ícone
  if NewTheme = tmLight then
    themeToggleBitBtn.ImageIndex := 9
  else
    themeToggleBitBtn.ImageIndex := 10;

  // Opcional: notificação
  if NewTheme = tmLight then
    SendNotification('Goverlay', 'Light theme activated', GetIconFile)
  else
    SendNotification('Goverlay', 'Dark theme activated', GetIconFile);
end;

end.
```

## 📚 API Reference

### Types
```pascal
TThemeMode = (tmLight, tmDark);
```

### Variables
```pascal
CurrentTheme: TThemeMode  // Tema atualmente ativo
```

### Functions
```pascal
// Aplicar tema escuro
procedure ApplyDarkTheme(AControl: TWinControl);

// Aplicar tema claro
procedure ApplyLightTheme(AControl: TWinControl);

// Aplicar tema específico
procedure ApplyTheme(AControl: TWinControl; ATheme: TThemeMode);

// Alternar entre temas
function ToggleTheme(AControl: TWinControl): TThemeMode;

// Salvar preferência
procedure SaveThemePreference(ATheme: TThemeMode);

// Carregar preferência
function LoadThemePreference: TThemeMode;
```

## 🎨 Sugestões de Posicionamento do Botão

Locais recomendados para o botão de toggle:
1. **Barra superior direita** - Ao lado do botão "About" ou menu
2. **Barra de menu** - Como item do menu principal
3. **Tab de configurações** - Em uma seção de "Appearance"
4. **Barra de status inferior** - Pequeno botão discreto

## 🚀 Próximas Melhorias

Possíveis melhorias futuras:
- [ ] Adicionar mais temas (ex: auto, sistema, high contrast)
- [ ] Animação suave na transição de temas
- [ ] Preview dos temas antes de aplicar
- [ ] Temas personalizados (cores customizáveis pelo usuário)
- [ ] Sincronizar com tema do sistema operacional
