unit hintsunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls;

// Procedure to apply all hints to form components
procedure ApplyAllHints(AForm: TComponent);

implementation

procedure ApplyAllHints(AForm: TComponent);
var
  Component: TComponent;
  
  procedure SetHint(const ComponentName, HintText: string);
  begin
    Component := AForm.FindComponent(ComponentName);
    if Assigned(Component) and (Component is TControl) then
    begin
      TControl(Component).Hint := HintText;
      TControl(Component).ShowHint := True;
    end;
  end;

begin
  // ============================================================================
  // MANGOHUD - ABA PRESET
  // ============================================================================
  
  // Layouts
  SetHint('basicBitBtn', 'Layout básico' + LineEnding +
    'Exibe FPS, frametime e informações essenciais');
  SetHint('fullBitBtn', 'Layout completo' + LineEnding +
    'Mostra todas as métricas disponíveis');
  SetHint('fpsonlyBitBtn', 'Apenas FPS' + LineEnding +
    'Exibe somente o contador de FPS');
  SetHint('basichorizontalBitBtn', 'Layout horizontal básico' + LineEnding +
    'Layout básico em orientação horizontal');
    
  // Position
  SetHint('topleftRadioButton', 'Posição: Canto superior esquerdo');
  SetHint('topcenterRadioButton', 'Posição: Centro superior');
  SetHint('toprightRadioButton', 'Posição: Canto superior direito');
  SetHint('middleleftRadioButton', 'Posição: Centro esquerdo');
  SetHint('middlerightRadioButton', 'Posição: Centro direito');
  SetHint('bottomleftRadioButton', 'Posição: Canto inferior esquerdo');
  SetHint('bottomcenterRadioButton', 'Posição: Centro inferior');
  SetHint('bottomrightRadioButton', 'Posição: Canto inferior direito');
  
  // ============================================================================
  // MANGOHUD - ABA PERFORMANCE
  // ============================================================================
  
  // FPS
  SetHint('fpsCheckBox', 'Exibir FPS' + LineEnding +
    'Mostra a taxa de quadros por segundo');
  SetHint('fpsavgCheckBox', 'FPS médio' + LineEnding +
    'Exibe a média de FPS calculada');
  SetHint('framecountCheckBox', 'Contador de frames' + LineEnding +
    'Mostra o número total de frames renderizados');
  SetHint('frametimegraphCheckBox', 'Gráfico de frametime' + LineEnding +
    'Exibe gráfico do tempo de renderização');
  SetHint('showfpslimCheckBox', 'Mostrar limite de FPS' + LineEnding +
    'Exibe o valor do limitador de FPS quando ativo');
    
  // CPU
  SetHint('cputempCheckBox', 'Temperatura da CPU' + LineEnding +
    'Mostra a temperatura atual do processador');
  SetHint('cpupowerCheckBox', 'Consumo da CPU' + LineEnding +
    'Exibe o consumo de energia do processador em Watts');
  SetHint('cpufreqCheckBox', 'Frequência da CPU' + LineEnding +
    'Mostra a frequência de clock atual');
  SetHint('cpuavgloadCheckBox', 'Carga média da CPU' + LineEnding +
    'Exibe a carga média de todos os núcleos');
  SetHint('cpuloadcoreCheckBox', 'Carga por núcleo' + LineEnding +
    'Mostra a carga individual de cada núcleo');
    
  // GPU
  SetHint('gputempCheckBox', 'Temperatura da GPU' + LineEnding +
    'Mostra a temperatura atual da placa de vídeo');
  SetHint('gpupowerCheckBox', 'Consumo da GPU' + LineEnding +
    'Exibe o consumo de energia da GPU em Watts');
  SetHint('gpufreqCheckBox', 'Frequência da GPU' + LineEnding +
    'Mostra a frequência de clock atual da GPU');
  SetHint('gpufanCheckBox', 'Velocidade do cooler' + LineEnding +
    'Exibe a velocidade da ventoinha em RPM ou %');
  SetHint('gpumemfreqCheckBox', 'Frequência da VRAM' + LineEnding +
    'Mostra a frequência da memória de vídeo');
  SetHint('gpujunctempCheckBox', 'Temperatura de junção' + LineEnding +
    'Temperatura interna do chip da GPU (hotspot)');
  SetHint('gputhrottlingCheckBox', 'Throttling da GPU' + LineEnding +
    'Indica quando a GPU está reduzindo desempenho');
  SetHint('gpuvoltageCheckBox', 'Voltagem da GPU' + LineEnding +
    'Exibe a voltagem atual da placa de vídeo');
    
  // Memory
  SetHint('ramusageCheckBox', 'Uso de RAM' + LineEnding +
    'Mostra a memória RAM utilizada/total');
  SetHint('vramusageCheckBox', 'Uso de VRAM' + LineEnding +
    'Exibe a memória de vídeo utilizada/total');
  SetHint('swapusageCheckBox', 'Uso de SWAP' + LineEnding +
    'Mostra o uso da memória swap');
  SetHint('procmemCheckBox', 'Memória do processo' + LineEnding +
    'Exibe a RAM usada pelo jogo/aplicativo');
  SetHint('procvramCheckBox', 'VRAM do processo' + LineEnding +
    'Mostra a VRAM usada pelo jogo/aplicativo');
    
  // Disk I/O
  SetHint('diskioCheckBox', 'I/O de disco' + LineEnding +
    'Exibe leitura e escrita em disco');
    
  // ============================================================================
  // MANGOHUD - ABA VISUAL
  // ============================================================================
  
  SetHint('hudcompactCheckBox', 'Modo compacto' + LineEnding +
    'Reduz o espaçamento entre elementos');
  SetHint('fahrenheitCheckBox', 'Usar Fahrenheit' + LineEnding +
    'Exibe temperaturas em °F ao invés de °C');
  SetHint('fpscolorCheckBox', 'Colorir FPS' + LineEnding +
    'Muda a cor do FPS baseado em limites definidos');
  SetHint('cpuloadcolorCheckBox', 'Colorir carga da CPU' + LineEnding +
    'Muda a cor baseado na carga do processador');
  SetHint('gpuloadcolorCheckBox', 'Colorir carga da GPU' + LineEnding +
    'Muda a cor baseado na carga da GPU');
    
  // ============================================================================
  // MANGOHUD - ABA METRICS
  // ============================================================================
  
  SetHint('archCheckBox', 'Arquitetura do sistema' + LineEnding +
    'Exibe x86_64, ARM, etc.');
  SetHint('distroinfoCheckBox', 'Informações da distribuição' + LineEnding +
    'Mostra nome e versão do Linux');
  SetHint('resolutionCheckBox', 'Resolução' + LineEnding +
    'Exibe a resolução atual da tela');
  SetHint('refreshrateCheckBox', 'Taxa de atualização' + LineEnding +
    'Mostra a taxa de atualização do monitor em Hz');
  SetHint('displayserverCheckBox', 'Servidor de display' + LineEnding +
    'Exibe X11, Wayland, etc.');
  SetHint('timeCheckBox', 'Hora atual' + LineEnding +
    'Mostra a hora do sistema');
  SetHint('wineCheckBox', 'Versão do Wine' + LineEnding +
    'Exibe a versão do Wine/Proton em uso');
  SetHint('engineversionCheckBox', 'Versão do engine' + LineEnding +
    'Mostra a versão do Vulkan/OpenGL');
  SetHint('engineshortCheckBox', 'Nome curto do engine' + LineEnding +
    'Usa abreviações (VK, GL, DX)');
  SetHint('vulkandriverCheckBox', 'Driver Vulkan' + LineEnding +
    'Exibe o driver Vulkan em uso');
  SetHint('gpumodelCheckBox', 'Modelo da GPU' + LineEnding +
    'Mostra o nome completo da placa de vídeo');
  SetHint('hudversionCheckBox', 'Versão do MangoHud' + LineEnding +
    'Exibe a versão do MangoHud');
  SetHint('gamemodestatusCheckBox', 'Status do GameMode' + LineEnding +
    'Indica se o GameMode está ativo');
  SetHint('vkbasaltstatusCheckBox', 'Status do vkBasalt' + LineEnding +
    'Indica se o vkBasalt está ativo');
  SetHint('batteryCheckBox', 'Bateria' + LineEnding +
    'Mostra o nível de carga da bateria');
  SetHint('batterywattCheckBox', 'Consumo da bateria' + LineEnding +
    'Exibe o consumo em Watts');
  SetHint('batterytimeCheckBox', 'Tempo de bateria' + LineEnding +
    'Mostra o tempo restante estimado');
  SetHint('deviceCheckBox', 'Nome do dispositivo' + LineEnding +
    'Exibe o hostname do sistema');
  SetHint('mediaCheckBox', 'Player de mídia' + LineEnding +
    'Mostra música/vídeo em reprodução');
  SetHint('networkCheckBox', 'Rede' + LineEnding +
    'Exibe tráfego de rede da interface selecionada');
    
  // ============================================================================
  // MANGOHUD - ABA EXTRAS
  // ============================================================================
  
  SetHint('fsrCheckBox', 'Indicador FSR' + LineEnding +
    'Mostra quando FidelityFX Super Resolution está ativo');
  SetHint('hdrCheckBox', 'Indicador HDR' + LineEnding +
    'Exibe quando HDR está habilitado');
  SetHint('fcatCheckBox', 'FCAT' + LineEnding +
    'Frame Capture Analysis Tool - análise de frames');
  SetHint('ftraceCheckBox', 'Ftrace' + LineEnding +
    'Rastreamento de funções do kernel');
  SetHint('dxapiCheckBox', 'DirectX API' + LineEnding +
    'Mostra a versão do DirectX em uso');
  SetHint('winesyncCheckBox', 'Wine Sync' + LineEnding +
    'Exibe o método de sincronização (fsync, esync)');
  SetHint('vpsCheckBox', 'VPS' + LineEnding +
    'Variable Pre-scaled - informações de escalonamento');
  SetHint('hidehudCheckBox', 'Ocultar HUD ao iniciar' + LineEnding +
    'Inicia com o overlay oculto (use o atalho para mostrar)');
  SetHint('autouploadCheckBox', 'Upload automático de logs' + LineEnding +
    'Envia logs automaticamente para flightlessmango.com');
    
  // ============================================================================
  // OPTISCALER
  // ============================================================================
  
  SetHint('spoofCheckBox', 'Spoof DLSS' + LineEnding +
    'Simula entradas DLSS sem spoofing' + LineEnding +
    'em jogos compatíveis');
  SetHint('fsrversionComboBox', 'Versão do FSR' + LineEnding +
    'Selecione a versão do FidelityFX Super Resolution');
  SetHint('optversionComboBox', 'Canal do OptiScaler' + LineEnding +
    'Stable: Versão estável' + LineEnding +
    'Pre-release: Versão de desenvolvimento');
  SetHint('updateBitBtn', 'Atualizar OptiScaler' + LineEnding +
    'Baixa e instala a versão mais recente');
  SetHint('optipatcherCheckBox', 'OptiPatcher' + LineEnding +
    'Aplica patches de compatibilidade' + LineEnding +
    'para jogos específicos');
    
  // FakeNVAPI
  SetHint('forcenvapiCheckBox', 'Forçar NVAPI' + LineEnding +
    'Força o uso da implementação NVAPI fake');
  SetHint('hidenvidiaCheckBox', 'Ocultar NVIDIA' + LineEnding +
    'Esconde a GPU NVIDIA do sistema');
  SetHint('forcelatencyflexCheckBox', 'Forçar Latency Flex' + LineEnding +
    'Habilita Latency Flex forçadamente');
  SetHint('forcereflexCheckBox', 'Forçar Reflex' + LineEnding +
    'Habilita NVIDIA Reflex forçadamente');
    
  // ============================================================================
  // VKBASALT
  // ============================================================================
  
  SetHint('casTrackBar', 'Contrast Adaptive Sharpening' + LineEnding +
    'Nitidez adaptativa baseada em contraste' + LineEnding +
    '0.0 = Desligado, 1.0 = Máximo');
  SetHint('dlsTrackBar', 'Denoised Luma Sharpening' + LineEnding +
    'Nitidez de luminância com redução de ruído' + LineEnding +
    '0.0 = Desligado, 1.0 = Máximo');
  SetHint('fxaaTrackBar', 'Fast Approximate Anti-Aliasing' + LineEnding +
    'Anti-aliasing rápido' + LineEnding +
    '0.0 = Desligado, 1.0 = Máximo');
  SetHint('smaaTrackBar', 'Subpixel Morphological Anti-Aliasing' + LineEnding +
    'Anti-aliasing morfológico de alta qualidade' + LineEnding +
    '0.0 = Desligado, 1.0 = Máximo');
  SetHint('reshaderefreshBitBtn', 'Atualizar shaders ReShade' + LineEnding +
    'Baixa os shaders mais recentes do repositório');
    
  // ============================================================================
  // TWEAKS
  // ============================================================================
  
  SetHint('gamemodeCheckBox', 'GameMode' + LineEnding +
    'Otimizações de desempenho do Feral GameMode' + LineEnding +
    'Requer o pacote gamemode instalado');
  SetHint('forcezinkCheckBox', 'Forçar Zink' + LineEnding +
    'Usa Zink (OpenGL sobre Vulkan)');
  SetHint('enwaylandCheckBox', 'Habilitar Wayland' + LineEnding +
    'Força o uso do Wayland ao invés de XWayland');
  SetHint('disablentsyncCheckBox', 'Desabilitar NTDLL Sync' + LineEnding +
    'Desativa sincronização NTDLL no Wine');
  SetHint('nofastclearsCheckBox', 'Desabilitar Fast Clears' + LineEnding +
    'RADV_DEBUG=nofastclears' + LineEnding +
    'Desativa otimização de limpeza rápida (AMD)');
  SetHint('highpriCheckBox', 'Alta prioridade' + LineEnding +
    'Executa o jogo com prioridade alta no sistema');
  SetHint('largeaddressCheckBox', 'Large Address Aware' + LineEnding +
    'Permite jogos 32-bit usarem mais de 2GB de RAM');
  SetHint('emurtCheckBox', 'Emular RT' + LineEnding +
    'Emula Ray Tracing em GPUs sem suporte nativo');
  SetHint('enhdrCheckBox', 'Habilitar HDR' + LineEnding +
    'Ativa High Dynamic Range quando disponível');
  SetHint('stagememCheckBox', 'Stage Memory' + LineEnding +
    'Otimização de memória para GPUs AMD');
  SetHint('simdeckCheckBox', 'Simular Steam Deck' + LineEnding +
    'Faz o jogo detectar o sistema como Steam Deck');
  SetHint('wow64CheckBox', 'WOW64' + LineEnding +
    'Modo de compatibilidade Windows 64-bit');
  SetHint('fexstatsCheckBox', 'FEX Stats' + LineEnding +
    'Estatísticas do emulador FEX-Emu (ARM)');
  SetHint('emufp8CheckBox', 'Emular FP8' + LineEnding +
    'Emula precisão de ponto flutuante FP8');
  SetHint('actprotonlogsCheckBox', 'Logs do Proton' + LineEnding +
    'Ativa logs detalhados do Proton');
  SetHint('heapdelayCheckBox', 'Heap Delay' + LineEnding +
    'Atraso na alocação de heap (Wine)');
  SetHint('ramtempCheckBox', 'Temperatura da RAM' + LineEnding +
    'Exibe temperatura dos módulos de memória');
    
  // ============================================================================
  // BOTÕES PRINCIPAIS
  // ============================================================================
  
  SetHint('saveBitBtn', 'Salvar configurações' + LineEnding +
    'Aplica e salva todas as alterações');
  SetHint('copyBitBtn', 'Copiar comando' + LineEnding +
    'Copia o comando de lançamento para a área de transferência');
  SetHint('gupdateBitBtn', 'Verificar atualizações' + LineEnding +
    'Verifica se há uma nova versão do GOverlay');
  SetHint('checkupdBitBtn', 'Verificar atualizações do MangoHud' + LineEnding +
    'Verifica a versão mais recente do MangoHud');
  SetHint('howtoBitBtn', 'Como usar' + LineEnding +
    'Instruções para Steam, Heroic e outros launchers');
  SetHint('themeToggleSpeedButton', 'Alternar tema' + LineEnding +
    'Alterna entre tema claro e escuro');
  SetHint('geSpeedButton', 'Global Enable' + LineEnding +
    'Ativa automaticamente para todos os jogos usando FGMOD');
    
  // ============================================================================
  // LOGGING
  // ============================================================================
  
  SetHint('logfolderBitBtn', 'Selecionar pasta de logs' + LineEnding +
    'Escolha onde os logs serão salvos');
  SetHint('delayTrackBar', 'Atraso inicial' + LineEnding +
    'Tempo de espera antes de iniciar o log (segundos)');
  SetHint('durationTrackBar', 'Duração do log' + LineEnding +
    'Tempo total de gravação do log (segundos)');
  SetHint('intervalTrackBar', 'Intervalo de amostragem' + LineEnding +
    'Frequência de coleta de dados (milissegundos)');
  SetHint('versioningCheckBox', 'Versionamento de logs' + LineEnding +
    'Adiciona timestamp aos nomes dos arquivos de log');
    
  // ============================================================================
  // FPS LIMITER
  // ============================================================================
  
  SetHint('fpslimmetComboBox', 'Método do limitador' + LineEnding +
    'early: Menor latência' + LineEnding +
    'late: Mais estável');
  SetHint('fpslimtoggleComboBox', 'Atalho do limitador' + LineEnding +
    'Tecla para ativar/desativar o limite de FPS');
  SetHint('hudonoffComboBox', 'Atalho do HUD' + LineEnding +
    'Tecla para mostrar/ocultar o overlay');
  SetHint('logtoggleComboBox', 'Atalho de log' + LineEnding +
    'Tecla para iniciar/parar gravação de log');
  SetHint('vkbtogglekeyCombobox', 'Atalho do vkBasalt' + LineEnding +
    'Tecla para ativar/desativar efeitos');
    
  // ============================================================================
  // VSYNC
  // ============================================================================
  
  SetHint('vsyncComboBox', 'VSync (Vulkan)' + LineEnding +
    '0 = Desligado' + LineEnding +
    '1 = Ligado' + LineEnding +
    '2 = Mailbox mode' + LineEnding +
    '3 = Adaptive');
  SetHint('glvsyncComboBox', 'VSync (OpenGL)' + LineEnding +
    '-1 = Adaptive' + LineEnding +
    '0 = Desligado' + LineEnding +
    '1 = Ligado');
    
  // ============================================================================
  // FILTERS
  // ============================================================================
  
  SetHint('afTrackBar', 'Filtragem anisotrópica' + LineEnding +
    'Melhora qualidade de texturas em ângulos' + LineEnding +
    '0 = Desligado, 16 = Máximo');
  SetHint('mipmapTrackBar', 'Bias de Mipmap' + LineEnding +
    'Ajusta nitidez de texturas distantes' + LineEnding +
    'Negativo = Mais nítido, Positivo = Mais suave');
    
  // ============================================================================
  // APPEARANCE
  // ============================================================================
  
  SetHint('fontsizeTrackBar', 'Tamanho da fonte' + LineEnding +
    'Ajusta o tamanho do texto no overlay');
  SetHint('transpTrackBar', 'Transparência' + LineEnding +
    'Opacidade do fundo do overlay' + LineEnding +
    '0 = Transparente, 100 = Opaco');
  SetHint('menuscaleTrackBar', 'Escala do menu' + LineEnding +
    'Tamanho geral do overlay' + LineEnding +
    '0.5 = 50%, 1.0 = 100%, 2.0 = 200%');
  SetHint('offsetSpinEdit', 'Deslocamento' + LineEnding +
    'Distância da borda da tela em pixels');
    
  // Color buttons
  SetHint('FontcolorButton', 'Cor da fonte' + LineEnding +
    'Cor padrão do texto');
  SetHint('hudbackgroundColorButton', 'Cor de fundo' + LineEnding +
    'Cor do fundo do overlay');
  SetHint('cpuColorButton', 'Cor da CPU' + LineEnding +
    'Cor do texto de métricas da CPU');
  SetHint('gpuColorButton', 'Cor da GPU' + LineEnding +
    'Cor do texto de métricas da GPU');
  SetHint('ramColorButton', 'Cor da RAM' + LineEnding +
    'Cor do texto de uso de memória');
  SetHint('vramColorButton', 'Cor da VRAM' + LineEnding +
    'Cor do texto de memória de vídeo');
  SetHint('engineColorButton', 'Cor do engine' + LineEnding +
    'Cor do texto de informações do engine');
  SetHint('wineColorButton', 'Cor do Wine' + LineEnding +
    'Cor do texto de informações do Wine');
  SetHint('batteryColorButton', 'Cor da bateria' + LineEnding +
    'Cor do texto de informações de bateria');
  SetHint('mediaColorButton', 'Cor do media player' + LineEnding +
    'Cor do texto de informações de mídia');
end;

end.
