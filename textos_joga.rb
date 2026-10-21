# Textos da JOGA no OpenProject (nível 1): título do sistema, bloco de boas-vindas e rodapé dos e-mails.
#
# Roda DENTRO do container (ver comando no fim). Grava no BANCO (tabela settings), então sobrevive a
# reinício e a troca de imagem, e continua editável pela tela:
#   Administração → Configurações do sistema → Geral   (título e boas-vindas)
#   Administração → E-mails e notificações              (rodapé)
# Rodar de novo é seguro: só regrava os mesmos valores.

RODAPE = <<~TXT.strip
  JOGA Soluções Empresariais · Clareza para decidir, Direção para crescer.
  www.jogasolucoes.com.br
TXT

# Aparece na aba do navegador e na caixa de busca do topo ("Buscar em %{app_title}").
Setting.app_title = "JOGA Consultoria"

Setting.welcome_title = "Bem-vindo ao portal da JOGA"
Setting.welcome_text = <<~MD.strip
  Aqui você acompanha os projetos da sua empresa com a JOGA: **o que fazer, quem faz, quando entregar e quem aprova**.

  - Em **Minha página** ficam as tarefas atribuídas a você, de todos os projetos.
  - Cada projeto mostra as atividades, os prazos e o andamento.
  - Você recebe um e-mail sempre que uma tarefa for atribuída a você ou mudar.

  *Clareza para decidir, Direção para crescer.*
MD
Setting.welcome_on_homescreen = true

# Configuração por idioma: a pessoa recebe no idioma dela, com "en" de reserva.
Setting.emails_footer = { "pt-BR" => RODAPE, "en" => RODAPE }

puts "app_title:             #{Setting.app_title.inspect}"
puts "welcome_title:         #{Setting.welcome_title.inspect}"
puts "welcome_on_homescreen: #{Setting.welcome_on_homescreen.inspect}"
puts "emails_footer:         #{Setting.emails_footer.keys.inspect}"
puts "Pronto."

# Comando (uma linha, no servidor, depois de copiar este arquivo para ~/JOGA-OpenProject):
# C=$(sudo docker ps -q -f name=openproject_openproject) && sudo docker cp ~/JOGA-OpenProject/textos_joga.rb $C:/tmp/ && sudo docker exec $C bash -c "cd /app && bundle exec rails runner /tmp/textos_joga.rb"
