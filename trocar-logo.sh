#!/bin/sh
# Troca as logos do OpenProject pelas da JOGA. Roda DENTRO do build da imagem (ver Dockerfile).
#
# Os arquivos do OpenProject têm um hash no nome que muda a cada versão
# (logo_openproject_white_big-2c6d79fa….png). Por isso a troca procura pelo COMEÇO do nome:
# numa versão nova o hash muda, o padrão continua casando e nada aqui precisa ser editado.
set -eu
P="${OP_PUBLIC:-/app/public}"
J="$(dirname "$0")/branding"

# $1 = padrão do arquivo original · $2 = arquivo da JOGA · $3 = "obrigatorio" ou vazio
troca() {
  achou=0
  for f in $(find "$P" -name "$1" ! -name '*.gz'); do
    cp "$J/$2" "$f"
    # O servidor entrega a cópia comprimida (.gz) quando ela existe. Se ela não for refeita
    # junto, o navegador continua recebendo a logo ANTIGA — sem erro nenhum.
    if [ -f "$f.gz" ]; then gzip -9 -n -c "$f" > "$f.gz"; fi
    echo "  trocado: ${f#$P/}"
    achou=$((achou + 1))
  done
  if [ "$achou" -eq 0 ] && [ "${3:-}" = "obrigatorio" ]; then
    echo "ERRO: nenhum arquivo '$1'. A versão nova do OpenProject mudou o nome da logo —"
    echo "      rode o find de '*logo*' no container e ajuste o padrão aqui."
    exit 1
  fi
}

echo "Trocando a marca do OpenProject pela da JOGA:"
troca 'logo_openproject_white_big-*.png' logo_header.png        obrigatorio  # topo (desktop)
troca 'icon_logo_white-*.svg'            icon_logo_white.svg    obrigatorio  # topo (celular)
troca 'logo_openproject-*.png'           logo_high_contrast.png              # tema claro de alto contraste
troca 'icon_logo-*.svg'                  icon_logo.svg                       # menu de módulos
troca 'logo_openproject_narrow-*.svg'    logo_narrow.svg
troca 'logo-black-bg-ua-*.png'           logo_black_bg.png
troca 'logo-white-bg-ua-*.png'           logo_white_bg.png
troca 'favicon*.ico'                     favicon.ico

# Ícones de celular: um arquivo por tamanho (apple-touch-icon-120x120-<hash>.png).
for f in $(find "$P" -name 'apple-touch-icon*.png'); do
  n=$(basename "$f" | sed -n 's/^apple-touch-icon-\([0-9]*\)x[0-9]*.*/\1/p')
  [ -f "$J/apple-touch-icon-${n:-180}.png" ] || n=180
  cp "$J/apple-touch-icon-${n:-180}.png" "$f"
  echo "  trocado: ${f#$P/}"
done
echo "Pronto."
