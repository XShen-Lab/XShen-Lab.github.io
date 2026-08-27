---
title: 团队成员
member_gallery: true
---

<div class="people-page-intro" data-reveal>
  <p class="people-kicker">团队 / XShen Lab</p>
  <h1>团队成员</h1>
  <p class="people-deck">XShen Lab 汇聚了具有分子细胞生物学、基因组学、生物信息学、生物物理学、数学和计算生物学背景的研究人员。</p>

  <nav class="member-nav" aria-label="团队成员分类">
    <a href="#课题组负责人">课题组负责人</a>
    <a href="#行政助理">行政助理</a>
    <a href="#博士后">博士后</a>
    <a href="#研究生">研究生</a>
    <a href="#本科生">本科生</a>
    <a href="#离组成员">离组成员</a>
  </nav>
</div>

{% include section.html %}

<div class="people-section people-section--pi">
  <h2 id="课题组负责人">课题组负责人</h2>
  {% include people/pi-card.html %}
</div>

{% include section.html %}

<div class="people-section people-section--placeholder">
  <h2 id="行政助理">行政助理</h2>
  <div class="people-placeholder" aria-label="行政助理">
    <span>行政助理</span>
    <strong>信息待更新</strong>
  </div>
</div>

{% include section.html %}

<div class="people-section">
  <h2 id="博士后">博士后</h2>
  {% include people/gallery.html role="postdoc" id="zh-postdoc-gallery" label="博士后成员" %}
</div>

{% include section.html %}

<div class="people-section">
  <h2 id="研究生">研究生</h2>
  {% include people/gallery.html role="phd" id="zh-graduate-gallery" label="研究生成员" %}
</div>

{% include section.html %}

<div class="people-section">
  <h2 id="本科生">本科生</h2>
  {% include people/gallery.html role="undergrad" id="zh-undergraduate-gallery" label="本科生成员" %}
</div>

{% include section.html %}

<div class="people-section">
  <h2 id="离组成员">离组成员</h2>
  {% include people/gallery.html role="alumni" id="zh-alumni-gallery" label="离组成员" %}
</div>
