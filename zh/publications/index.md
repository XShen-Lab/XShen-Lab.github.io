---
title: 论文发表
---

<p class="right"><small><a href="{{ '/publications/' | relative_url }}">English</a></small></p>

# 论文发表

本页收录 **52 篇已发表成果**，研究主题涵盖基因组组织与三维核内结构、RNA 网络与核内 RNA 稳态、转录调控与转录监控、单细胞基因组活动与细胞命运动力学，以及应激信号和细胞命运的表观遗传调控。这些工作共同关注生物信息如何从基因组出发，经由 RNA 与细胞核环境被组织、处理并稳定为细胞状态。

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
