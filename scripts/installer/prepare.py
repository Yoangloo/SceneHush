#!/usr/bin/env python3
"""Build the offline, three-language drag-installation guide."""

import argparse
import base64
import html
import json
from pathlib import Path


REPOSITORY = "https://github.com/Yoangloo/SceneHush"
APPLE_HELP = "https://support.apple.com/en-us/102445"
SECURITY_SETTINGS = "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension"


def paragraph(text):
    return "<p>" + html.escape(text) + "</p>"


def section(title, text):
    return "<h2>" + html.escape(title) + "</h2>" + paragraph(text)


def steps(items):
    return "<ol>" + "".join("<li>" + html.escape(item) + "</li>" for item in items) + "</ol>"


def render_guide(copies, version, icon):
    sections = []
    for language, copy in copies.items():
        sections.append("""<section lang="{language}" data-language="{language}">
<p class="eyebrow">SceneHush {version}</p><h1>{title}</h1><p class="lead">{purpose}</p>
<div class="card"><h2>{installation_title}</h2>{install_steps}<p class="muted">{installation}</p>
<p class="note">{upgrade}</p></div>
<div class="card"><h2>{blocked_title}</h2><p>{unsigned}</p>{blocked_steps}<p>{first_launch}</p>
<p><a class="button" href="{settings}">{open_settings}</a></p><p class="muted">{manual_settings}</p>
<p><a href="{apple_help}">{apple_link}</a></p></div>
<div class="card"><h2>{permissions_title}</h2><p>{permissions}</p>
<h2>{safety_title}</h2><p>{safety}</p></div>
<footer><a href="{repository}/releases">{downloads}</a><span> · </span>
<a href="{repository}">{github}</a></footer></section>""".format(
            language=language, version=html.escape(version), title=html.escape(copy["guide_title"]),
            purpose=html.escape(copy["purpose"]), installation_title=html.escape(copy["installation_title"]),
            install_steps=steps(copy["install_steps"]), installation=html.escape(copy["installation"]),
            upgrade=html.escape(copy["upgrade"]), blocked_title=html.escape(copy["blocked_title"]),
            unsigned=html.escape(copy["unsigned"]), blocked_steps=steps(copy["blocked_steps"]),
            first_launch=html.escape(copy["first_launch"]), settings=SECURITY_SETTINGS,
            open_settings=html.escape(copy["open_settings"]), manual_settings=html.escape(copy["manual_settings"]),
            apple_help=APPLE_HELP, apple_link=html.escape(copy["apple_link"]),
            permissions_title=html.escape(copy["permissions_title"]), permissions=html.escape(copy["permissions"]),
            safety_title=html.escape(copy["safety_title"]), safety=html.escape(copy["safety"]),
            repository=REPOSITORY, downloads=html.escape(copy["downloads"]), github=html.escape(copy["github"])))
    return """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>SceneHush · Installation / 安装 / インストール</title>
<style>
:root{color-scheme:light dark;--ink:#222a38;--muted:#657184;--line:#e2e7ee;--paper:#fff;--bg:#f2f5f9;--blue:#345a8e}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.65 -apple-system,BlinkMacSystemFont,"Helvetica Neue",sans-serif}
main{max-width:800px;margin:auto;padding:38px 28px 48px}header{display:flex;align-items:center;justify-content:space-between;gap:24px;margin-bottom:44px}
header img{width:60px;height:60px;border-radius:16px}nav{display:flex;flex-wrap:wrap;gap:6px}nav button{font:inherit;font-size:13px;color:var(--muted);background:transparent;border:1px solid transparent;border-radius:18px;padding:6px 12px;cursor:pointer}
nav button[aria-pressed=true]{color:var(--blue);border-color:var(--line);background:var(--paper)}.eyebrow{font-size:13px;letter-spacing:.05em;color:var(--muted);margin:0}h1{font-size:36px;letter-spacing:-.04em;line-height:1.15;margin:12px 0 16px}h2{font-size:19px;letter-spacing:-.02em;line-height:1.35;margin:0 0 14px}
.lead{font-size:18px;color:var(--muted);margin:0 0 30px}.card{background:var(--paper);border:1px solid var(--line);border-radius:22px;padding:26px 28px;margin:16px 0}.card h2:not(:first-child){margin-top:28px}p{margin:12px 0}ol{padding-left:23px;margin:14px 0}li{padding-left:5px;margin:12px 0}.muted{color:var(--muted);font-size:14px}.note{border-left:3px solid #c0cad9;padding-left:14px;font-size:14px}.button{display:inline-block;background:var(--blue);color:white;text-decoration:none;border-radius:12px;padding:10px 18px;font-size:14px}a{color:var(--blue);text-underline-offset:3px}footer{text-align:center;font-size:13px;color:var(--muted);margin-top:32px}section[hidden]{display:none}
@media(prefers-color-scheme:dark){:root{--ink:#e6ebf3;--muted:#a3afc1;--line:#354152;--paper:#202a38;--bg:#17202c;--blue:#9bbbea}.button{color:#162334}}
@media(max-width:540px){main{padding:24px 18px}header{align-items:flex-start;margin-bottom:32px}header img{width:48px;height:48px}h1{font-size:30px}.card{padding:22px}}
</style></head><body><main><header><img alt="SceneHush" src="data:image/svg+xml;base64,__ICON__">
<nav aria-label="Language"><button type="button" data-choice="en">English</button><button type="button" data-choice="zh-Hans">简体中文</button><button type="button" data-choice="ja">日本語</button></nav></header>
__SECTIONS__
<script>
const chooseLanguage = language => {
  document.documentElement.lang = language;
  document.querySelectorAll('[data-language]').forEach(section => { section.hidden = section.dataset.language !== language; });
  document.querySelectorAll('[data-choice]').forEach(button => button.setAttribute('aria-pressed', String(button.dataset.choice === language)));
};
const preferred = (navigator.languages || [navigator.language || 'en']).find(language => /^(en|zh|ja)(-|$)/i.test(language)) || 'en';
chooseLanguage(/^zh/i.test(preferred) ? 'zh-Hans' : /^ja/i.test(preferred) ? 'ja' : 'en');
document.querySelectorAll('[data-choice]').forEach(button => button.addEventListener('click', () => chooseLanguage(button.dataset.choice)));
</script></main></body></html>
""".replace("__ICON__", icon).replace("__SECTIONS__", "\n".join(sections))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--version", required=True)
    args = parser.parse_args()
    copies = json.loads(Path(__file__).with_name("copy.json").read_text(encoding="utf-8"))
    icon = base64.b64encode((args.project_root / "assets/SceneHush.svg").read_bytes()).decode("ascii")
    args.output.write_text(render_guide(copies, args.version, icon), encoding="utf-8")


if __name__ == "__main__":
    main()
