---
title: People
member_gallery: true
nav:
  order: 3
  tooltip: Members of the XShen Lab
---

<div class="people-page-intro" data-reveal>
  <p class="people-kicker">People / XShen Lab</p>
  <h1>People</h1>
  <p class="people-deck">The XShen Lab brings together researchers with backgrounds in molecular cell biology, genomics, bioinformatics, biophysics, mathematics, and computational biology.</p>

  <nav class="member-nav" aria-label="People sections">
    <a href="#principal-investigator">Principal Investigator</a>
    <a href="#administrative-assistant">Administrative Assistant</a>
    <a href="#post-docs">Post Docs</a>
    <a href="#graduate-students">Graduate Students</a>
    <a href="#undergraduate-students">Undergraduate Students</a>
    <a href="#alumni">Alumni</a>
  </nav>
</div>

{% include section.html %}

<div class="people-section people-section--pi">
  <h2 id="principal-investigator">Principal Investigator</h2>
  {% include people/pi-card.html %}
</div>

{% include section.html %}

<div class="people-section people-section--placeholder">
  <h2 id="administrative-assistant">Administrative Assistant</h2>
  <div class="people-placeholder" aria-label="Administrative Assistant">
    <span>Administrative Assistant</span>
    <strong>Information forthcoming</strong>
  </div>
</div>

{% include section.html %}

<div class="people-section">
  <h2 id="post-docs">Post Docs</h2>
  {% include people/gallery.html role="postdoc" id="postdoc-gallery" label="Postdoctoral fellows" %}
</div>

{% include section.html %}

<div class="people-section">
  <h2 id="graduate-students">Graduate Students</h2>
  {% include people/gallery.html role="phd" id="graduate-gallery" label="Graduate students" %}
</div>

{% include section.html %}

<div class="people-section">
  <h2 id="undergraduate-students">Undergraduate Students</h2>
  {% include people/gallery.html role="undergrad" id="undergraduate-gallery" label="Undergraduate students" %}
</div>

{% include section.html %}

<div class="people-section people-section--placeholder">
  <h2 id="alumni">Alumni</h2>
  <div class="people-placeholder" aria-label="Alumni">
    <span>Alumni</span>
    <strong>Profiles forthcoming</strong>
  </div>
</div>
