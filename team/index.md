---
title: People
nav:
  order: 3
  tooltip: Members of the XShen Lab
---

# Member

The XShen Lab brings together researchers with backgrounds in molecular cell biology, genomics, bioinformatics, biophysics, mathematics, and computational biology.

<div class="member-nav">
  <a href="#principal-investigator">Principal Investigator</a>
  <a href="#administrative-assistant">Administrative Assistant</a>
  <a href="#post-docs">Post Docs</a>
  <a href="#graduate-students">Graduate Students</a>
  <a href="#undergraduate-students">Undergraduate Students</a>
  <a href="#alumni">Alumni</a>
</div>

{% include section.html %}

## Principal Investigator

<div class="member-section member-grid member-grid-pi">
{% include list.html data="members" component="portrait" filter="role == 'principal-investigator'" %}
</div>

{% include section.html %}

## Administrative Assistant

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'admin'" %}
</div>

{% include section.html %}

## Post Docs

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'postdoc'" %}
</div>

{% include section.html %}

## Graduate Students

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'phd'" %}
</div>

{% include section.html %}

## Undergraduate Students

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'undergrad'" %}
</div>

{% include section.html %}

## Alumni

<div class="member-section member-grid">
{% include list.html data="members" component="portrait" filter="role == 'alumni'" %}
</div>
