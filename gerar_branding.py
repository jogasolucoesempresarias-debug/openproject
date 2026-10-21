"""Gera os arquivos de marca da JOGA no formato que o OpenProject espera.

Uso: python -I gerar_branding.py <pasta JOGA-Brand/assets> <pasta de saída>
"""
import io
import re
import sys
from pathlib import Path

from PIL import Image
from playwright.sync_api import sync_playwright

BRAND = Path(sys.argv[1])
OUT = Path(sys.argv[2])
OUT.mkdir(parents=True, exist_ok=True)

logo_creme = (BRAND / "joga-logo-dark.svg").read_text(encoding="utf-8")   # p/ fundo escuro
logo_escuro = (BRAND / "joga-logo-light.svg").read_text(encoding="utf-8")  # p/ fundo claro
mark_escuro = (BRAND / "joga-mark.svg").read_text(encoding="utf-8")
mark_creme = mark_escuro.replace("#13171E", "#F5F2EC")

ASPECTO = 451.78 / 134.82  # viewBox do logo


def render(page, svg, w, h, logo_h, top, aspecto=ASPECTO):
    """SVG alinhado à esquerda, com altura logo_h, num canvas w×h transparente."""
    svg = re.sub(r"<svg ", f'<svg width="{logo_h * aspecto:.2f}" height="{logo_h}" ', svg, count=1)
    html = (f'<html><body style="margin:0;background:transparent">'
            f'<div style="width:{w}px;height:{h}px;position:relative">'
            f'<div style="position:absolute;left:0;top:{top}px">{svg}</div></div></body></html>')
    page.set_content(html)
    png = page.screenshot(clip={"x": 0, "y": 0, "width": w, "height": h}, omit_background=True)
    return Image.open(io.BytesIO(png))


with sync_playwright() as p:
    b = p.chromium.launch()
    page = b.new_page(viewport={"width": 1100, "height": 400})
    # Cabeçalho: caixa de 130×40 px com background-size: contain → canvas 650×200 (mesma
    # proporção da caixa), logo com 88% da altura → ~35 px na tela.
    render(page, logo_creme, 650, 200, 176, 12).save(OUT / "logo_header.png", optimize=True)
    render(page, logo_escuro, 650, 200, 176, 12).save(OUT / "logo_high_contrast.png", optimize=True)
    # Variantes de fundo preto/branco (1000×238, mesmo tamanho das originais).
    render(page, logo_creme, 1000, 238, 200, 19).save(OUT / "logo_black_bg.png", optimize=True)
    render(page, logo_escuro, 1000, 238, 200, 19).save(OUT / "logo_white_bg.png", optimize=True)
    # Marca quadrada p/ favicon.
    sq = render(page, mark_escuro, 256, 256, 256, 0, aspecto=1)
    b.close()

(OUT / "icon_logo.svg").write_text(mark_escuro, encoding="utf-8")
(OUT / "icon_logo_white.svg").write_text(mark_creme, encoding="utf-8")
(OUT / "logo_narrow.svg").write_text(mark_escuro, encoding="utf-8")

sq.save(OUT / "favicon.ico", sizes=[(16, 16), (32, 32), (48, 48)])

# Ícones do iPhone/Android: fundo opaco (o avatar escuro da marca), um por tamanho.
avatar = Image.open(BRAND / "joga-avatar-dark.png").convert("RGB")
for n in (57, 60, 72, 76, 114, 120, 144, 152, 180):
    avatar.resize((n, n), Image.LANCZOS).save(OUT / f"apple-touch-icon-{n}.png", optimize=True)

for f in sorted(OUT.iterdir()):
    print(f.name, f.stat().st_size)
