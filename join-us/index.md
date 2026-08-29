---
title: Join Us
nav:
  order: 7
  tooltip: Opportunities to join the XShen Lab
---

<div class="join-page">
  <header class="join-hero" data-reveal>
    <div class="join-hero__meta">
      <span>Opportunities / 2026</span>
      <a href="{{ '/zh/join-us/' | relative_url }}">中文 <span aria-hidden="true">↗</span></a>
    </div>
    <h1>Join Us</h1>
    <p>Work across experiment, computation, and theory to uncover how biological information becomes cell fate.</p>
  </header>

  <article class="join-feature" data-reveal style="--reveal-order: 1">
    <a class="join-feature__image" href="{{ '/blog/simple-rules-of-life-rotation/' | relative_url }}" aria-label="Read the rotation invitation">
      <img src="{{ '/images/blog/simple-rules-of-life-rotation/rotation-invitation.jpg' | relative_url }}" alt="A Dr. Seuss character beside the quote: Everything stinks until it’s finished." loading="eager">
      <span aria-hidden="true"></span>
    </a>
    <div class="join-feature__copy">
      <div class="join-entry-meta">
        <span class="join-pin"><i aria-hidden="true"></i> Pinned</span>
        <time datetime="2026-08">2026—08</time>
        <span>Rotation invitation</span>
      </div>
      <h2><a href="{{ '/blog/simple-rules-of-life-rotation/' | relative_url }}">In Search of Life’s Simple Rules</a></h2>
      <p>For students willing to cross disciplinary boundaries, bring quantitative thinking into the life sciences, and search for principles beneath biological complexity.</p>
      <div class="join-feature__footer">
        <p><span>Written by</span><strong>Xiaohua Shen</strong></p>
        <a href="{{ '/blog/simple-rules-of-life-rotation/' | relative_url }}">Read invitation <span aria-hidden="true">↗</span></a>
      </div>
    </div>
  </article>

  <article class="join-posting" id="recruitment-2026-06">
    <header class="join-posting__header" data-reveal style="--reveal-order: 2">
      <div class="join-entry-meta">
        <time datetime="2026-06">2026—06</time>
        <span>Recruitment</span>
        <span class="join-status">Open</span>
      </div>
      <h2>Research Assistant &amp;<br>Undergraduate Research Intern</h2>
      <p>We welcome applicants from experimental biology, bioinformatics, mathematics, physics, computer science, statistics, and related fields.</p>
    </header>

    <div class="join-posting__body">
      {% capture overview %}
## Laboratory Overview

The Xiaohua Shen Laboratory is based in the School of Basic Medicine at Tsinghua University. Our long-term research focuses on noncoding-RNA-mediated transcriptional and chromatin regulation in cell-fate determination, with particular interest in the functions and mechanisms of noncoding RNA, RNA-binding proteins, and chromatin regulators in stem-cell fate transitions, development, disease, and aging.

Current research directions include, but are not limited to:

1. **Noncoding RNA and chromatin regulation:** Define how noncoding RNA, RNA-binding proteins, and chromatin regulators control cell-fate decisions.
2. **Aging and regeneration:** Explore cellular senescence, tissue regeneration, stem-cell maintenance, and reprogramming.
3. **Immune regulation and disease mechanisms:** Investigate the roles of noncoding RNA and noncanonical translation in immune regulation and disease.
4. **Multi-omics and bioinformatics:** Integrate transcriptomic, epigenomic, proteomic, and single-cell datasets for mechanistic analysis and model building.
5. **Mathematical and physical modeling:** We welcome students with backgrounds in mathematics, physics, computer science, and related disciplines to develop models of living systems, analyze complex data, and create theoretical methods.

The laboratory provides comprehensive research platforms and academic support. Through Tsinghua’s Center for Life Sciences, Beijing Advanced Innovation Center for Structural Biology, and related platforms, lab members have access to a strong research environment and opportunities for scientific growth. More information is available on the [XShen Lab website](https://www.xshenlab.com/).
      {% endcapture %}
      <section class="join-posting__section join-posting__section--overview" data-reveal style="--reveal-order: 3">
        {{ overview | markdownify }}
      </section>

      {% capture assistant %}
### Responsibilities

1. Support the team’s research projects and participate in experimental design, optimization, and execution.
2. Independently perform routine molecular biology, biochemistry, and cell-culture experiments while maintaining standardized workflows and reliable data.
3. Contribute, as needed, to RNA experiments, sequencing-library preparation, protein assays, and cellular functional studies.
4. Organize, document, archive, and report preliminary experimental data.
5. Depending on background and interests, participate in projects involving aging and regeneration, immunology, bioinformatics, or physical modeling.

### Qualifications

**Education and background**

- Bachelor’s degree or above in biology, basic medicine, bioinformatics, or a related field.
- Applicants from mathematics, physics, computer science, or statistics with a strong interest in life-science research are also welcome.
- For applicants with at least one year of research-laboratory experience, degree requirements may be considered flexibly.

**Preferred experimental or analytical experience**

- PCR, qPCR, Western blotting, and cell culture.
- RNA experiments or next-generation sequencing library preparation.
- Mammalian or primary cell culture, flow cytometry, or immunofluorescence.
- Biochemical assays, protein purification, or RNA–protein interaction studies.
- Model-organism work, particularly mouse experiments.
- Transcriptomic, single-cell, epigenomic, or mass-spectrometry data analysis.

**Priority areas**

- Aging, regeneration, stem cells, or cellular reprogramming.
- Immunology, inflammation, or immune-cell function.
- RNA biology or chromatin regulation.
- Bioinformatics, multi-omics, or single-cell data analysis.
- Mathematical, physical, statistical, or computer-science training with modeling, algorithm-development, or data-analysis skills.
- Availability to start soon and commit to stable, long-term work, normally for at least one year.

**Personal qualities**

- Genuine enthusiasm for research and strong learning and hands-on abilities.
- Careful, responsible, dependable, and persistent work habits.
- Good teamwork, communication, and execution.
- Willingness to advance projects collaboratively and continue learning in an interdisciplinary environment.

### Compensation and Development

1. Employment follows Tsinghua University’s contract-staff policies, including statutory social insurance, housing fund, and university contract-staff benefits.
2. Competitive compensation will be determined according to education, experience, technical skills, and fit with the position.
3. Lab members may participate in academic exchanges, technical training, lab meetings, and collaborative research.
4. Outstanding team members may receive long-term development support, including opportunities to contribute to projects and publications and recommendations for further study.
      {% endcapture %}
      <section class="join-role" data-reveal style="--reveal-order: 4">
        <div class="join-role__label"><span>Position 01</span><strong>Research Assistant</strong></div>
        <div class="join-role__content">{{ assistant | markdownify }}</div>
      </section>

      {% capture intern %}
### Who Should Apply

Undergraduate students from Tsinghua University and other institutions are welcome to apply for research internships. The program is especially suitable for students who:

1. Have a background in mathematics, physics, computer science, statistics, biology, medicine, or a related field.
2. Want to experience an active research environment and gain experimental or data-analysis experience.
3. Intend to pursue graduate or doctoral training or a future career in life-science research.

### Internship Directions

**Bioinformatics**

- Transcriptomic, single-cell, proteomic, and related data analysis.
- Training in foundational R or Python analysis workflows.
- Data visualization, literature organization, and public-database mining.

**Mathematical and physical modeling**

- Pattern recognition, network analysis, and model construction using multi-omics data.
- Quantitative exploration of living systems through integration with experimental data.

### Requirements

1. Genuine interest in research and willingness to learn and follow laboratory practices.
2. Long-term, consistent participation is preferred; a continuous commitment of at least one year is generally recommended.
3. Prior biological experimentation or data-analysis experience is preferred but not required.

### Training and Support

1. The internship focuses on research training and skill development. The laboratory provides scientific guidance, experimental training, and opportunities for academic exchange.
2. Depending on the project, time commitment, and laboratory policies, appropriate support or a stipend may be discussed.
3. Students who participate consistently and perform well may receive further support with research training, graduate-school applications, and recommendation letters.
      {% endcapture %}
      <section class="join-role" data-reveal style="--reveal-order: 5">
        <div class="join-role__label"><span>Position 02</span><strong>Undergraduate Research Intern</strong></div>
        <div class="join-role__content">{{ intern | markdownify }}</div>
      </section>

      {% capture application %}
## How to Apply

Please send the materials below to [xshen@tsinghua.edu.cn](mailto:xshen@tsinghua.edu.cn), according to the position for which you are applying.

### Research Assistant Applicants

1. Curriculum vitae, including education, employment or research experience, technical skills, and contact information.
2. Relevant supporting materials, such as degree certificates, technical certificates, publications, experimental reports, or other evidence of research accomplishments, if available.
3. Please indicate your earliest available start date in the CV.

**Email subject:** `Research Assistant Application_Name`

### Undergraduate Research Internship Applicants

1. Curriculum vitae, including university, department, year, major, and contact information.
2. A brief description of your availability, such as days per week in the laboratory and expected internship duration.
3. Course projects, research training, programming experience, experimental work, or modeling experience may be included if available.

**Email subject:** `Undergraduate Internship_Name_University/Major`

Applicants who pass the initial review will be contacted by phone or email to arrange an interview or discussion. Applicants not selected for interview will not receive a separate notice. Please prepare relevant supporting materials for the interview.

The Xiaohua Shen Laboratory welcomes applicants who are curious, diligent, and genuinely excited about research. Whether your strengths are in molecular and cellular experiments, immunology, bioinformatics, or mathematical and physical modeling, we look forward to exploring the frontiers of **noncoding RNA, cell-fate regulation, aging and regeneration, immune regulation, and interdisciplinary quantitative life science** with you.
      {% endcapture %}
      <section class="join-posting__section join-posting__section--apply" data-reveal style="--reveal-order: 6">
        {{ application | markdownify }}
      </section>
    </div>
  </article>
</div>
