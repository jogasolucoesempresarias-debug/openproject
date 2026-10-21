# Portal da consultoria JOGA (OpenProject)

**`https://consultoria.jogasolucoes.com.br`**: o portal em que a JOGA e as empresas atendidas acompanham os
projetos da consultoria. Responde a quatro perguntas de cada projeto: o que fazer, quem faz, quando entregar
e quem aprova.

É o **OpenProject Community 17.8.1**, a versão gratuita e de código aberto, com a marca da JOGA. **Nenhum
arquivo de código do OpenProject foi editado.** Tudo o que é da JOGA fica em três camadas por fora dele (ver
[O que foi personalizado](#o-que-foi-personalizado)), e é isso que permite atualizar o OpenProject trocando um
número.

> ## ⚠️ Leia antes de mexer
>
> - **O Portainer está desatualizado.** A imagem e quase todas as variáveis foram aplicadas pelo terminal
>   (`docker service update`). Se alguém editar a stack `openproject` pelo Portainer, ele reaplica a cópia
>   velha que tem guardada, e **a logo e os itens pagos voltam sem aviso**. É a mesma armadilha que derrubou
>   a produção da Multpel em 08/2026. Até o editor do Portainer ficar igual ao [`stack.yml`](stack.yml),
>   **mexa nessa stack só pelo terminal.**
> - **A imagem `joga-openproject` não está em registro nenhum**: ela é gerada no próprio servidor. No
>   Portainer e no terminal, nunca peça para baixá-la de novo ("Re-pull"); use sempre `--no-resolve-image`.
> - **Nunca troque o `SECRET_KEY_BASE`.** Ele cifra dados no banco. Trocar desloga todo mundo e deixa
>   conteúdo cifrado ilegível.
> - **Senhas e chaves não ficam nesta pasta.** Elas estão nas variáveis da stack, no servidor.

## Estado em 21/10/2026

| | |
|---|---|
| **No ar** | `joga-openproject:17.8.1-2`: logo + e-mail de convite da JOGA (conferido no Gmail em 19/10) |
| **Pronta, deploy pendente** | `joga-openproject:17.8.1-3`: a `-2` + o "Compartilhar" pago escondido. Testada em Docker local em 21/10. O [`stack.yml`](stack.yml) já aponta para ela |
| **Servidor** | VPS da JOGA (2 vCPU, 7,8 GB, swap de 4 GB desde 15/10). O mesmo servidor da produção da Multpel |
| **Stack / serviço** | `openproject` / `openproject_openproject` |
| **Memória** | ~1,42 GB medido em 15/10, com teto de 3 GB e 1,5 vCPU |

## Arquivos desta pasta

| Arquivo | Para quê |
|---|---|
| [`stack.yml`](stack.yml) | A stack do Swarm, **sem segredos** (eles entram como `${OP_...}`). Cada variável tem o porquê comentado |
| [`Dockerfile`](Dockerfile) | Parte da imagem oficial e acrescenta logo, tradução e o initializer. Falha o build se algo que ele altera mudar de nome numa versão nova |
| [`trocar-logo.sh`](trocar-logo.sh) | Roda dentro do build. Troca logos, favicon e ícones de celular, procurando pelo **começo do nome** (o hash muda a cada versão) |
| [`branding/`](branding/) | As imagens da JOGA nos formatos que o OpenProject usa |
| [`gerar_branding.py`](gerar_branding.py) | Regera `branding/` a partir de `JOGA-Brand/assets` (Playwright + Pillow). Só precisa rodar se a logo da JOGA mudar |
| [`previa-logo.png`](previa-logo.png) | Antes e depois da barra do topo |
| [`traducoes/zz_joga.pt-BR.yml`](traducoes/zz_joga.pt-BR.yml) | 5 frases do e-mail de convite, por cima da tradução oficial |
| [`initializers/zz_joga_sem_compartilhar.rb`](initializers/zz_joga_sem_compartilhar.rb) | Esconde o "Compartilhar" pago (botão, filtros da lateral, Caixa de entrada). Imagem `-3` |
| [`textos_joga.rb`](textos_joga.rb) | Grava no banco o título do sistema, o bloco de boas-vindas e o rodapé dos e-mails. Rodou em 19/10 |
| [`conferir_email.rb`](conferir_email.rb) | Confere, no sistema no ar, que o e-mail de convite não fala em OpenProject |
| [`conferir_compartilhar.rb`](conferir_compartilhar.rb) | Confere, no sistema no ar, que o "Compartilhar" sumiu |

## O que foi personalizado

| Camada | O quê | Onde | Na atualização do OpenProject |
|---|---|---|---|
| **Imagem** | Logo, favicon e ícones | `Dockerfile` + `trocar-logo.sh` + `branding/` | é reaplicada no build; **falha avisando** se a logo do topo mudar de nome |
| | E-mail de convite: título, abertura, parágrafo dos vídeos e assinatura | `traducoes/zz_joga.pt-BR.yml` | continua valendo enquanto as chaves existirem |
| | Sem o "Compartilhar" pago (imagem `-3`) | `initializers/zz_joga_sem_compartilhar.rb` | o `grep` do Dockerfile **falha o build** se os pontos alterados mudarem |
| **Variáveis** | Itens pagos fora dos menus (global, topo, admin e projeto), banners de venda, "Novos recursos" e "Comunidade" fora da página inicial, página "Edição Enterprise" desligada | `stack.yml` | continuam valendo; mas **uma versão nova pode trazer item pago novo** (ver Atualizar) |
| | Modo leve: `WEB_WORKERS=0` (2,0 → 1,42 GB) e `GOOD__JOB__MAX__THREADS=5` | `stack.yml` | continuam valendo |
| | E-mail pelo Resend (`jogasolucoes@jogasolucoes.com.br`) | `stack.yml` | continua valendo |
| **Banco** | Título "JOGA Consultoria" (aba e caixa de busca), boas-vindas, rodapé dos e-mails | `textos_joga.rb`; editável depois em Administração → Configurações do sistema → Geral, e E-mails e notificações | fica no banco, não depende da imagem |

**Por que pelas variáveis e não pelo código:** o próprio OpenProject tem os interruptores
(`hidden_menu_items`, `ee_hide_banners`, `show_community_links`, `ee_manager_visible`). Os nomes de cada
item vieram do código-fonte da 17.8.1 (`config/initializers/menus.rb` e `modules/*/lib/**/engine.rb`), com
inventário de todo item marcado com `enterprise_feature`. Esse inventário só pega **itens de menu**. O
"Compartilhar", o "Alerta de data" e os "Modelos" de reunião ficam nas laterais (`app/menus/`) e na tela, onde
não há interruptor: o "Compartilhar" virou initializer; os outros dois estão nas Pendências.

## Como fazer

Todos os comandos rodam no servidor da JOGA (pelo MobaXterm), **uma linha cada**, porque a continuação com `\`
quebra no MobaXterm.

**Os arquivos chegam ao servidor pelo git**, não pelo SFTP. Este repositório (público, sem nenhuma senha) é
clonado em `~/JOGA-OpenProject`. Arrastar arquivo um por um já fez um build sair sem a tradução, porque um
arquivo ficou para trás; o `git pull` traz a pasta inteira.

Primeira vez, no servidor:
```bash
mv ~/JOGA-OpenProject ~/JOGA-OpenProject.antigo; git clone https://github.com/jogasolucoesempresarias-debug/openproject.git ~/JOGA-OpenProject
```
(O `mv` só é necessário se a pasta antiga, de antes do git, ainda existir.)

### Publicar uma imagem nova (logo, tradução, initializer)

1. No PC: commit e `git push` das mudanças.
2. No servidor: `cd ~/JOGA-OpenProject && git pull`. No build, o número de passos (`[N/N]`) tem de bater com
   o Dockerfile novo. Na `-3` são **7 passos**; o último é o
   `RUN grep` que confere o initializer.
3. Gere a imagem com **uma tag nova** e troque no serviço. O site fica de 1 a 2 minutos fora:
   ```bash
   cd ~/JOGA-OpenProject && git pull && sudo docker build -t joga-openproject:17.8.1-3 . && sudo docker service update --image joga-openproject:17.8.1-3 --no-resolve-image openproject_openproject
   ```
   Durante o boot, o site responde "Bad Gateway" (do Traefik) e depois "503" (do Apache interno). É normal.
4. Rode o `conferir_*.rb` correspondente (abaixo).
5. Atualize a tag no `stack.yml` e a seção "Estado" deste README.

A tag anterior continua no servidor. Para voltar, troque **só a imagem do serviço**, sem build: o comando
acima com a tag antiga a sobrescreveria com o Dockerfile atual, e a volta não voltaria nada.
```bash
sudo docker service update --image joga-openproject:17.8.1-2 --no-resolve-image openproject_openproject
```

### Conferir depois do deploy

```bash
C=$(sudo docker ps -q -f name=openproject_openproject) && sudo docker cp ~/JOGA-OpenProject/conferir_email.rb $C:/tmp/ && sudo docker exec $C bash -c "cd /app && bundle exec rails runner /tmp/conferir_email.rb"
```
```bash
C=$(sudo docker ps -q -f name=openproject_openproject) && sudo docker cp ~/JOGA-OpenProject/conferir_compartilhar.rb $C:/tmp/ && sudo docker exec $C bash -c "cd /app && bundle exec rails runner /tmp/conferir_compartilhar.rb"
```
Os dois terminam em linhas `OK:`. Qualquer `ATENÇÃO` quer dizer que a personalização não foi carregada.

### Esconder o "Compartilhar" (botão e filtros pagos)

O "Compartilhar" é recurso pago (Enterprise `work_package_sharing`). Sem a chave, ele aparece como
propaganda, com 💎, em três lugares:
- o **botão "Compartilhar"** no topo da tarefa;
- **"Compartilhado com usuários"** e **"Compartilhados comigo"** na lateral dos pacotes de trabalho;
- **"Compartilhado"** na lateral da Caixa de entrada.

**Por que precisa de imagem, e não de uma variável** como os outros itens: esses três não são itens de
menu. Conferido no código da 17.8.1: `WorkPackages::DefaultQueryGeneratorService` monta os dois filtros para
todo mundo, e `Notifications::Menu#reason_filters` tem a lista fixa. Não há interruptor. Quem esconde é o
[`initializers/zz_joga_sem_compartilhar.rb`](initializers/zz_joga_sem_compartilhar.rb), que entra na imagem
`-3`.

**Para publicar:**
1. Traga os arquivos: `cd ~/JOGA-OpenProject && git pull`.
2. Confira que chegaram. Tem de listar os dois arquivos e responder `2`:
   ```bash
   ls ~/JOGA-OpenProject/initializers ~/JOGA-OpenProject/conferir_compartilhar.rb && grep -c sem_compartilhar ~/JOGA-OpenProject/Dockerfile
   ```
3. Gere e publique. O build tem de mostrar **7 passos**; o site fica de 1 a 2 minutos fora:
   ```bash
   cd ~/JOGA-OpenProject && sudo docker build -t joga-openproject:17.8.1-3 . && sudo docker service update --image joga-openproject:17.8.1-3 --no-resolve-image openproject_openproject
   ```
4. Rode o `conferir_compartilhar.rb` (em [Conferir depois do deploy](#conferir-depois-do-deploy)). Tem de dar
   três linhas `OK:`. Depois abra uma tarefa com **Ctrl+F5**.

**Voltar:** `sudo docker service update --image joga-openproject:17.8.1-2 --no-resolve-image openproject_openproject`.

**Alternativa sem imagem:** em Administração → Papéis e permissões, desmarque "Compartilhar pacotes de
trabalho" e "Visualizar pacotes de trabalho compartilhados" em cada papel. Isso tira só o **botão**, e só para
quem não é administrador; os filtros da lateral continuam com 💎.

**Limite:** "Alerta de data", na Caixa de entrada, também é pago e continua aparecendo nas duas formas.
**Se um dia comprarem o Enterprise:** apague o initializer e gere a imagem de novo (o resto está em
"Decisões e porquês").

### Mudar uma variável

```bash
sudo docker service update --no-resolve-image --env-add "NOME=valor" openproject_openproject
```
Reinicia o serviço. Anote a mudança no `stack.yml`; ele é a única cópia fiel do que está no ar.

### Ver consumo

```bash
sudo docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"; free -h
```
Logo depois de um reinício o número é menor, porque a memória cresce com o uso e depois estabiliza. Meça
depois de uso real.

### Atualizar o OpenProject (17.9, 18…)

1. **Faça o backup** (abaixo). A versão nova atualiza o banco ao subir.
2. Leia as notas da versão. Nas versões maiores, refaça o **inventário de itens pagos**, porque item pago
   novo aparece com 💎. Procure em três lugares do código da versão nova:
   - `enterprise_feature` em `config/initializers/menus.rb` e `modules/*/lib/**/engine.rb`: itens de menu,
     escondidos pelas variáveis `HIDDEN__MENU__ITEMS_*`;
   - `show_enterprise_icon` e `EnterpriseToken.allows_to?` em `app/menus/` e `modules/*/app/menus/`: filtros das
     laterais;
   - `allowsTo(` em `frontend/src/`: botões da tela.

   Os dois últimos só se escondem por initializer. Foi por olhar só o primeiro que o "Compartilhar" escapou do
   inventário de 19/10.
3. Troque a versão na linha `FROM` do `Dockerfile`, gere com uma tag nova (ex.: `joga-openproject:17.9.0-1`) e
   publique como acima. Se o build falhar no `trocar-logo.sh` ou no `grep` do initializer, é o aviso de que a
   versão mudou algo que a JOGA altera: revise o arquivo indicado antes de forçar.
4. Rode os dois `conferir_*.rb`.

### Backup

> Ainda não foi executado. Confira o nome dos volumes com `sudo docker volume ls | grep openproject` antes
> do primeiro uso.

```bash
C=$(sudo docker ps -q -f name=openproject_openproject) && sudo docker exec $C sh -c 'pg_dump -Fc "$DATABASE_URL"' > ~/op_banco_$(date +%F).dump
```
```bash
sudo tar czf ~/op_anexos_$(date +%F).tgz -C /var/lib/docker/volumes/openproject_openproject-assets/_data .
```
O banco é o Postgres 17 embutido no container (`DATABASE_URL` já está na imagem); os anexos ficam no volume
`openproject-assets`. A Hostinger também guarda snapshots do servidor inteiro, mas eles não substituem esses
dois arquivos na hora de atualizar.

## Decisões e porquês

- **Community, não Enterprise.** Portfólios e programas, Planejador de equipe, logo e cores, Compartilhar,
  espaço reservado e outros são pagos (Enterprise Basic: € 5,95 por usuário por mês, mínimo de 25, anual). O
  que a consultoria precisa já está na versão grátis: projeto por empresa, papéis por projeto (o cliente A
  não vê o B), responsável e prazo, aviso por e-mail e modelos de projeto. Se um dia comprarem: para digitar
  a chave, ligue `EE__MANAGER__VISIBLE` e tire `enterprise` da lista de admin; para a tela de Design, tire
  `custom_style`; tire das listas os demais itens comprados e apague o initializer.
- **Imagem all-in-one** (banco, cache e app num container só): é o mais simples para o porte da JOGA e não
  mexe no Postgres compartilhado das outras stacks. O custo: atualização de versão maior do Postgres segue a
  da imagem, por isso o backup antes.
- **Logo pela imagem**, porque a tela de Design é paga.
- **E-mail de convite:** os links de vídeo e documentação do OpenProject **ficam de propósito** (decisão do
  Gabriel). Os nomes dos links ("Webinar Link"…) seguem em inglês porque estão no modelo do e-mail, não na
  tradução, e trocar exigiria editar um arquivo do OpenProject.
- **Teto de memória**: o servidor é o mesmo da produção da Multpel. Com teto, num pico quem cai é o
  OpenProject, e o Swarm o reinicia.

**Escala:** uma instalação atende várias empresas clientes da JOGA (um projeto por empresa) sem custo extra
relevante. Para vender a ferramenta a **outras consultorias**, cada uma com admin e marca próprios, o
OpenProject exige uma instalação por consultoria (de 1,5 a 2 GB cada). Nesse cenário, um sistema próprio e
enxuto, multiempresa, compensa mais. O manual do "Portal de Consultorias" do sócio é a especificação pronta
para isso, e o portal dele tem o diferencial de metodologia (Manifesto, Gestão do dono, MCI) que o OpenProject
não tem.

## Pendências

- [ ] **Deploy da imagem `-3`** (sem Compartilhar) e `conferir_compartilhar.rb`.
- [ ] **Alinhar o editor do Portainer com o `stack.yml`**, e só depois liberar edição por lá.
- [ ] **Apagar os projetos de demonstração** antes de convidar o primeiro cliente: eles são públicos e
      aparecem para qualquer pessoa logada.
- [ ] Montar a estrutura da consultoria: tipos Atividade e Tarefa, status de aprovação (Em execução →
      Enviada para aprovação → Ajustes solicitados → Aprovada), papéis Consultor JOGA / Diretor / Cliente e um
      projeto-modelo.
- [ ] Ainda com 💎 e sem tratamento: **"Alerta de data"** (Caixa de entrada) e **"Modelos"** de reunião.
- [ ] Primeiro backup real, e decidir onde guardar uma cópia fora do servidor.
- [ ] Remedir a memória depois de uso real e ajustar o teto de 3 GB.
