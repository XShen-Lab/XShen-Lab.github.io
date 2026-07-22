---
title: 团队成员
---

<p class="right"><small><a href="{{ '/team/' | relative_url }}">English</a></small></p>

# 团队成员

XShen Lab 汇聚了具有分子细胞生物学、基因组学、生物信息学、生物物理学、数学和计算生物学背景的研究人员。

<div class="member-nav">
  <a href="#课题组负责人">课题组负责人</a>
  <a href="#行政助理">行政助理</a>
  <a href="#博士后">博士后</a>
  <a href="#研究生">研究生</a>
  <a href="#本科生">本科生</a>
  <a href="#离组成员">离组成员</a>
</div>
{% include section.html %}

## 课题组负责人

{% assign pi = site.members | where_exp: "member", "member.role == 'principal-investigator'" | first %}
<div class="member-section member-grid member-grid-pi">
  <div class="portrait-wrapper">
    <a href="{{ '/zh/people/xiaohua-shen/' | relative_url }}" class="portrait" aria-label="沈晓骅">
      {% include icon.html icon="fa-solid fa-microscope" %}
      <img src="{{ pi.image | relative_url }}" class="portrait-image" alt="沈晓骅" loading="lazy" {% include fallback.html %}>
      <span class="portrait-name">{{ pi.name }}</span>
      <span class="portrait-description">课题组负责人</span>
      <span class="portrait-affiliation">清华大学基础医学院</span>
    </a>
  </div>
</div>

{% include section.html %}

## 行政助理

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'admin'" %}
</div>

{% include section.html %}

## 博士后

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'postdoc'" %}
</div>

{% include section.html %}

## 研究生

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'phd'" %}
</div>

{% include section.html %}

## 本科生

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'undergrad'" %}
</div>

{% include section.html %}

## 离组成员

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'alumni'" %}
</div>
