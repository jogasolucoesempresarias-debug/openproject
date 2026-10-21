# Confere os textos do e-mail de convite DEPOIS do deploy (lê do sistema no ar, não do arquivo).
# Rodar no container:  bundle exec rails runner /tmp/conferir_email.rb
# Se alguma linha ainda falar em OpenProject, a tradução da JOGA não foi carregada.

CHAVES = %i[mail_body_register_header_title mail_body_register mail_body_register_links_html
            mail_body_register_ending mail_body_register_closing].freeze
LINKS = { app_title: Setting.app_title, webinar_link: "[webinar]", get_started_link: "[videos]",
          youtube_link: "[youtube]", documentation_link: "[docs]" }.freeze

puts "Assunto: #{I18n.t(:mail_subject_register, value: Setting.app_title, locale: :"pt-BR")}"
CHAVES.each { |k| puts "#{k}: #{I18n.t(k, **LINKS, locale: :"pt-BR")}" }
sobrou = CHAVES.select { |k| I18n.t(k, **LINKS, locale: :"pt-BR").include?("OpenProject") }
puts(sobrou.empty? ? "OK: nenhum texto do convite fala em OpenProject." : "ATENÇÃO, ainda com OpenProject: #{sobrou}")

# Comando (uma linha, no servidor):
# C=$(sudo docker ps -q -f name=openproject_openproject) && sudo docker cp ~/JOGA-OpenProject/conferir_email.rb $C:/tmp/ && sudo docker exec $C bash -c "cd /app && bundle exec rails runner /tmp/conferir_email.rb"
