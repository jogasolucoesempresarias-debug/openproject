# Confere que o "Compartilhar" pago sumiu DEPOIS do deploy (lê do sistema no ar, não do arquivo).
# Rodar no container:  bundle exec rails runner /tmp/conferir_compartilhar.rb
# Se alguma linha disser ATENÇÃO, o zz_joga_sem_compartilhar.rb não foi carregado.

User.current = User.find_by!(login: "admin") # os filtros "de mim" só existem para quem está logado

ligadas = %i[share_work_packages view_shared_work_packages].select { |p| OpenProject::AccessControl.permission(p) }
lateral = WorkPackages::Menu.new(params: {}).default_queries.map(&:title)
nomes = %i[shared_with_users shared_with_me].map { |k| I18n.t("js.work_packages.default_queries.#{k}") }
caixa = Notifications::Menu.new(params: {}, current_user: User.current).menu_items.flat_map(&:children)

puts "Lateral dos pacotes: #{lateral.join(' · ')}"
puts "Caixa de entrada:    #{caixa.map(&:title).join(' · ')}"
puts(ligadas.empty? ? "OK: botão Compartilhar desligado (vale para o admin)." : "ATENÇÃO, permissões ainda ligadas: #{ligadas}")
puts((lateral & nomes).empty? ? "OK: lateral sem os filtros de compartilhado." : "ATENÇÃO, ainda na lateral: #{lateral & nomes}")
puts(caixa.none? { |i| i.href.include?("name=shared") } ? "OK: Caixa de entrada sem \"Compartilhado\"." : "ATENÇÃO, Caixa de entrada ainda com \"Compartilhado\".")

# Comando (uma linha, no servidor):
# C=$(sudo docker ps -q -f name=openproject_openproject) && sudo docker cp ~/JOGA-OpenProject/conferir_compartilhar.rb $C:/tmp/ && sudo docker exec $C bash -c "cd /app && bundle exec rails runner /tmp/conferir_compartilhar.rb"
