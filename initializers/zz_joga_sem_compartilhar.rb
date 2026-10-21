# Some com o "Compartilhar" dos pacotes de trabalho — recurso PAGO (Enterprise "work_package_sharing").
#
# Sem a chave Enterprise ele não funciona: só aparece como propaganda, com o selo 💎, em lugares que
# nenhuma variável de ambiente esconde (conferido no código da 17.8.1):
#   - botão "Compartilhar" no topo da tarefa;
#   - "Compartilhado com usuários" e "Compartilhados comigo" na lateral dos pacotes de trabalho;
#   - "Compartilhado" na lateral da Caixa de entrada.
#
# O Dockerfile copia este arquivo para /app/config/initializers/ e FALHA o build se algum ponto que ele
# altera sumir numa versão nova. Se um dia a JOGA comprar o Enterprise, apague este arquivo e gere a
# imagem de novo.

module JogaSemCompartilhar
  # Lateral dos pacotes de trabalho (app/services/work_packages/default_query_generator_service.rb):
  # sem parâmetros o filtro não é montado, e o menu o pula.
  module FiltrosDaLateral
    def assign_params(query_key, project)
      return if %i[shared_with_users shared_with_me].include?(query_key)

      super
    end
  end

  # Lateral da Caixa de entrada (app/menus/notifications/menu.rb). Com ou sem Enterprise, o link do
  # filtro leva "name=shared".
  module CaixaDeEntrada
    private

    def reason_filters
      super.reject { |item| item.href.include?("name=shared") }
    end
  end
end

Rails.application.config.to_prepare do
  # Botão "Compartilhar": a tela só o mostra a quem tem a capacidade work_package_shares/index, que vem
  # da permissão view_shared_work_packages. Desligar a permissão é o mesmo caminho do
  # OPENPROJECT_DISABLED__MODULES (config/initializers/module_handler.rb) e vale também para o admin;
  # o código trata permissão desligada como "não pode", sem erro.
  %i[share_work_packages view_shared_work_packages].each do |nome|
    OpenProject::AccessControl.permission(nome)&.disable!
  end
  OpenProject::AccessControl.clear_caches

  WorkPackages::DefaultQueryGeneratorService.singleton_class.prepend(JogaSemCompartilhar::FiltrosDaLateral)
  Notifications::Menu.prepend(JogaSemCompartilhar::CaixaDeEntrada)
end
