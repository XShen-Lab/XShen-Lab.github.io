---
title: Publications
nav:
  order: 4
  tooltip: Representative and full publications
---

<p class="right"><small><a href="{{ '/zh/publications/' | relative_url }}">中文</a></small></p>

# Publications

This bibliography brings together **52 publications** spanning genome organization and three-dimensional nuclear architecture; RNA networks and nuclear RNA homeostasis; transcriptional regulation and surveillance; single-cell genome activity and cell-fate dynamics; and foundational studies of stress signaling and epigenetic control of cell fate. Together, these studies examine how biological information is organized, processed and stabilized from the genome to cell state.

{% assign publications_ui = site.data.publication_browser.ui.en %}

<div class="pub-nav publication-page-nav">
  <a href="#representative-publications">{{ publications_ui.representative_heading }}</a>
  <a href="#all-publications">{{ publications_ui.browser_heading }}</a>
</div>

{% include section.html %}

## {{ publications_ui.representative_heading }} {#representative-publications}

{{ publications_ui.representative_intro }}

{% include publications/representatives.html lang="en" %}

{% include section.html %}

## {{ publications_ui.browser_heading }} {#all-publications}

{{ publications_ui.browser_intro }}

{% include publications/browser.html lang="en" %}
