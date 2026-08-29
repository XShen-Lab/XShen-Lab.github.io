---
title: 论文发表
---

<p class="right"><small><a href="{{ '/publications/' | relative_url }}">English</a></small></p>

# 论文发表

以下成果围绕**生命信息流：从基因组到细胞命运**组织。代表性论文按照五个科学模块以横向精修卡片呈现，并在每个模块内部优先排列 Nature 与 Cell 正刊论文；其后可通过发表年份和主要研究类别交叉浏览完整论文目录。

{% assign publications_ui = site.data.publication_browser.ui["zh-CN"] %}

<div class="pub-nav publication-page-nav">
  <a href="#representative-publications">{{ publications_ui.representative_heading }}</a>
  <a href="#all-publications">{{ publications_ui.browser_heading }}</a>
</div>

{% include section.html %}

## {{ publications_ui.representative_heading }} {#representative-publications}

{{ publications_ui.representative_intro }}

{% include publications/representatives.html lang="zh-CN" %}

{% include section.html %}

## {{ publications_ui.browser_heading }} {#all-publications}

{{ publications_ui.browser_intro }}

{% include publications/browser.html lang="zh-CN" %}
