# OpenProject com a marca da JOGA.
#
# Só ACRESCENTA arquivos à imagem oficial (logos, uma tradução e um initializer por cima); nenhum arquivo
# de código do OpenProject é alterado. Para atualizar o OpenProject: troque a versão na linha FROM e gere a imagem de
# novo (com a mesma tag nova na stack). O trocar-logo.sh procura os arquivos pelo começo do nome,
# então sobrevive à troca de versão — e, se um dia não sobreviver, o build FALHA em vez de
# subir com a logo antiga.
FROM openproject/openproject:17.8.1

COPY branding/ /tmp/joga/branding/
COPY trocar-logo.sh /tmp/joga/
# sed: garante fim de linha Unix caso o arquivo tenha passado pelo Windows.
RUN sed -i 's/\r$//' /tmp/joga/trocar-logo.sh \
 && sh /tmp/joga/trocar-logo.sh \
 && rm -rf /tmp/joga

# Textos da JOGA por cima da tradução oficial (só as chaves do arquivo; ver o comentário dentro dele).
# Tem de ficar na pasta crowdin/ — é a última carregada pelo Rails, então vence a tradução original.
COPY traducoes/zz_joga.pt-BR.yml /app/config/locales/crowdin/zz_joga.pt-BR.yml

# Esconde o "Compartilhar" pago (ver o comentário dentro do arquivo). O grep confere que os pontos que
# ele altera ainda existem nesta versão: se uma versão nova os renomear, o build FALHA em vez de subir
# com o botão de volta.
COPY initializers/zz_joga_sem_compartilhar.rb /app/config/initializers/zz_joga_sem_compartilhar.rb
RUN grep -q "def assign_params" /app/app/services/work_packages/default_query_generator_service.rb \
 && grep -q "def reason_filters" /app/app/menus/notifications/menu.rb \
 && grep -q "permission :share_work_packages" /app/config/initializers/permissions.rb \
 && grep -q "permission :view_shared_work_packages" /app/config/initializers/permissions.rb \
 || { echo "ERRO: a versão nova mudou o código que o zz_joga_sem_compartilhar.rb altera — revise o arquivo."; exit 1; }
