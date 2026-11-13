# SlotOS: ISO que liga direto no Tigre da Sorte

Sistema mínimo (Alpine Linux + Cage + Chromium em modo quiosque) com o jogo
dentro. Liga, e só aparece o jogo em tela cheia. Sem desktop, sem login.

> IMPORTANTE: este kit foi escrito, mas NÃO foi testado (o ambiente onde ele
> foi criado não tem internet, então a ISO não pôde ser gerada nem ligada).
> Teste na máquina virtual (passo 3) antes de gravar no pendrive. Se algo
> falhar, mande a mensagem de erro que eu corrijo.

## O que tem aqui
- `jogo/index.html`: seu jogo (arquivo único, já funciona offline)
- `build.sh`, `mkimg.slotos.sh`, `genapkovl-slotos.sh`, `slotgame`: montam a ISO

## 1. Gerar a ISO (precisa de internet e de Docker)

**Jeito fácil no Windows:** extraia o zip e dê dois cliques em `INSTALAR.bat`.
A ISO aparece em `Downloads\SlotOS-ISO`. (Ou use os comandos abaixo.)

Instale o Docker Desktop (Windows) ou Docker (Linux). Descompacte este kit,
abra um terminal DENTRO da pasta `slotos-kit` e rode:

**Windows (PowerShell):**
```
docker run --rm --privileged -v "${PWD}:/kit" -v "${PWD}\saida:/out" alpine:latest sh /kit/build.sh
```

**Linux / WSL / Mac:**
```
docker run --rm --privileged -v "$PWD:/kit" -v "$PWD/saida:/out" alpine:latest sh /kit/build.sh
```

Demora uns 10 a 30 minutos (baixa pacotes). A ISO aparece em `saida/`.

Sem Docker: dá pra rodar `build.sh` como root num Alpine Linux instalado em
máquina virtual, com as pastas `/kit` e `/out`.

## 2. Gravar no pendrive
- **Rufus**: escolha a ISO, e quando perguntar, use **modo Imagem DD**.
- ou **Ventoy**: copie a ISO pro pendrive e escolha ela no menu.

## 3. Testar antes (opcional, recomendado)
Com QEMU: `qemu-system-x86_64 -m 2048 -cdrom saida/slotos-*.iso -enable-kvm`
(ou crie uma VM no VirtualBox com 2 GB de RAM e a ISO no leitor).

## 4. Usar
Espete o pendrive, ligue o PC e escolha o USB no menu de boot (F12, F8, Esc...)
ou ponha USB como primeiro na BIOS. Precisa de uns 2 GB de RAM. O sistema
roda na memória: **nada é salvo** (se o jogo guardar créditos, eles zeram ao
desligar; ele não usa armazenamento do navegador, então não perde nada de
configuração).

## Som
O launcher agora escolhe a placa de som sozinho (USB primeiro, depois a analógica,
deixando o HDMI por último), tira o mudo e põe o volume no máximo. Se ainda ficar
mudo: no PC, aperte Ctrl+Alt+F2, entre como root e rode `aplay -l`; mande a saída pro Claude.

## Detalhes
- O jogo abre em modo app (sem barra de endereço, abas ou botões).
- Se o navegador fechar, ele reabre sozinho.
- Se a tela ficar preta em PC com placa de vídeo antiga ou VM, me avise com o
  modelo; dá pra ajustar as flags do `slotgame`.

## Sem Docker: montar pelo GitHub
1. Crie conta grátis em github.com e um repositório novo (Add file > Upload files).
2. Envie TODOS os arquivos do kit (build.sh, mkimg.slotos.sh, genapkovl-slotos.sh, slotgame e a pasta jogo).
3. Add file > Create new file. No nome digite: .github/workflows/build.yml
   Cole dentro o conteúdo do arquivo build.yml do kit e clique Commit.
4. Aba Actions > "Montar ISO SlotOS" > Run workflow. Espere ficar verde (~20 min).
5. Clique na execução e baixe "slotos-iso" no fim da página (vem num zip com a ISO).

## Controles do jogo (moedeiro por teclado)
- C: +R$1 de crédito (um aperto = R$1)
- F1 a F12: +R$1 a +R$12 de crédito (F12 = R$12)
- Espaço/Enter: girar | Setas cima/baixo: aposta | F: tela cheia
- V: liga/desliga o turbo (T também funciona)
- B: modo automático de 10 giros (aperte B de novo para parar)

## Modo demonstração
Se ninguém mexer por 60 segundos, o jogo joga sozinho (aparece "DEMONSTRAÇÃO",
com saldo de teste, sem mexer no crédito real). Qualquer tecla para a demonstração
e volta para a tela JOGAR; o crédito que o cliente tinha continua igual.
Para mudar o tempo, edite `DEMO_IDLE_MS` no fim do `jogo/index.html` (60000 = 60 s).
O jogo sempre começa com saldo zero.

## Taxa de pagamento do jogo
Valores fixos, iguais para todos os jogadores, no início do script do `jogo/index.html`:
`PAY` (quanto cada símbolo paga), `W` (quão comum é cada símbolo) e a chance do Tigre
(`Math.random()<.012` = 1,2% por giro). Simulando 1,5 milhão de giros: retorno de cerca de 77%,
ganho em ~39% dos giros (quase todos pequenos), Tigre soltando a carta em média 1 a cada ~80 giros.

## Tela cheia no computador
Em monitor deitado (proporção a partir de 6:5, como 16:9 e 16:10), o jogo ocupa a tela toda:
tigre, aviso, saldo/aposta/ganho e botões ficam numa coluna à esquerda, e os rolos grandes à direita.
Em tela em pé (celular) continua o layout original. O tamanho da coluna da esquerda é a medida `--u`
dentro de `@media (min-aspect-ratio:6/5)` no fim do CSS do `jogo/index.html`.
