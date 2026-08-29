---
title: Contribute a Lab Update
description: A reviewed contribution route for XShen Lab news, publication stories, conference notes, and lab life.
permalink: /blog/contribute/
translation_url: /zh/blog/contribute/
---

<div class="contribute-page">
  <header class="contribute-hero">
    <p class="rna-section-label">Editorial desk</p>
    <h1>Contribute a lab update.</h1>
    <p>Help us document the science, people, and shared life of the XShen Lab. This route is for lab website stories—not journal manuscript submission.</p>
  </header>

  <section class="contribute-categories" aria-labelledby="contribute-categories-title">
    <div class="contribute-section-head">
      <span>01</span>
      <div><h2 id="contribute-categories-title">Choose a category</h2><p>Use one primary category. The editorial team can add more specific tags later.</p></div>
    </div>
    <ol>
      {% for category in site.data.blog_categories %}
        <li><span>0{{ forloop.index }}</span><strong>{{ category.labels.en }}</strong><p>{{ category.descriptions.en }}</p></li>
      {% endfor %}
    </ol>
  </section>

  <section class="contribute-checklist" aria-labelledby="contribute-checklist-title">
    <div class="contribute-section-head">
      <span>02</span>
      <div><h2 id="contribute-checklist-title">Prepare the story package</h2><p>A concise, well-documented package makes bilingual editing much faster.</p></div>
    </div>
    <ul>
      <li><strong>Working title and category</strong><span>Include the event or publication date and the people involved.</span></li>
      <li><strong>Short summary and body</strong><span>Provide a 100–300 word draft in English, Chinese, or both.</span></li>
      <li><strong>Original images</strong><span>Attach full-resolution files with a caption, photographer or source, and preferred crop.</span></li>
      <li><strong>Permission and timing</strong><span>Confirm that identifiable people agree to publication and that no embargoed or unpublished result is disclosed.</span></li>
      <li><strong>Related links</strong><span>Include the public paper, meeting, dataset, protocol, or institutional announcement when relevant.</span></li>
    </ul>
  </section>

  <section class="contribute-review" aria-labelledby="contribute-review-title">
    <div class="contribute-section-head">
      <span>03</span>
      <div><h2 id="contribute-review-title">Send for review</h2><p>Email the text and original images. The button opens a prepared message; add attachments in your mail application.</p></div>
    </div>
    <a class="rna-button primary" href="mailto:xshen@tsinghua.edu.cn?subject=%5BWebsite%20contribution%5D%20Category%20%E2%80%94%20Working%20title&amp;body=Category%3A%0AWorking%20title%3A%0AEvent%20or%20publication%20date%3A%0AContributor%3A%0ALanguage%20provided%3A%0AImage%20caption%20and%20credit%3A%0APermission%20confirmed%3A%0ARelated%20links%3A%0A%0APlease%20attach%20the%20draft%20and%20original%20images.">Start contribution email <span aria-hidden="true">↗</span></a>
    <p class="contribute-note">Every contribution is fact-checked and reviewed for image permission, privacy, bilingual presentation, and publication timing. Submission does not publish content automatically.</p>
  </section>
</div>
