---
title: Publications
nav:
  order: 4
  tooltip: Selected and full publications
---

<p class="right"><small><a href="{{ '/zh/publications/' | relative_url }}">中文</a></small></p>

# Publications

The work below is organized around **Biological Information Flow: From Genome to Cell Fate**. The featured card remains collection-driven and links to the existing scFLUENT-seq detail page; the complete bibliography follows the order and wording of the CV’s formal FULL PUBLICATIONS section.

{% assign papers = site.publications | sort: "date" | reverse %}

<div class="publication-grid">
  {% for paper in papers %}
    <article class="publication-entry">
      <a class="publication-entry-image" href="{{ paper.url | relative_url }}">
        <img
          src="{{ paper.image | relative_url }}"
          alt="Graphical abstract for {{ paper.title | escape }}"
          loading="lazy"
        >
      </a>

      <div class="publication-entry-content">
        <div class="publication-entry-meta">{{ paper.journal }} · {{ paper.year }}</div>
        <h3><a href="{{ paper.url | relative_url }}">{{ paper.title }}</a></h3>
        <p class="publication-entry-authors">{{ paper.authors }}</p>
        <p>{{ paper.summary }}</p>

        {% if paper.metric %}
          <div class="publication-entry-metric">{{ paper.metric }} (cell-type dependent)</div>
        {% endif %}

        <div class="publication-entry-tags">
          {% for tag in paper.tags %}
            <span>{{ tag }}</span>
          {% endfor %}
        </div>

        <div class="publication-entry-actions">
          <a href="{{ paper.url | relative_url }}">Read summary</a>
          <a href="{{ paper.doi }}">View article</a>
        </div>
      </div>
    </article>
  {% endfor %}
</div>

<div class="pub-nav">
  <a href="#featured-scientific-contributions">Featured Scientific Contributions</a>
  <a href="#latest-publications">Latest Publications</a>
  <a href="#browse-by-research-program">Browse by Research Program</a>
  <a href="#full-publications">Full Publications</a>
</div>

{% include section.html %}

## Featured Scientific Contributions

### 1. Genome organization and spatial encoding of biological information {#genome-organization}

Repetitive elements are not inert genomic material: their sequence identities contribute to homotypic clustering, chromatin compartmentalization, and coordinated regulation, establishing a spatial layer of biological information.

Representative published papers:

- **Homotypic clustering of L1 and B1/Alu repeats compartmentalizes the 3D genome.** *Cell Research*, 2021.
- **Genomic repeats categorize genes with distinct functions for orchestrated regulation.** *Cell Reports*, 2020.

### 2. RNA meshwork and nuclear information-processing environments {#rna-networks}

The laboratory established genomic proximity as a principle of lncRNA-mediated cis regulation and revealed that nascent RNA and RNA-binding proteins organize transcriptional machinery, chromatin association, and nuclear environments through phase separation and RNA homeostasis.

Representative published papers:

- **Nuclear RNA homeostasis promotes systems-level coordination for cell fate and vitality.** *Cell Stem Cell*, 2024.
- **Phase separation of RNA-binding protein promotes polymerase engagement and transcription.** *Nature Chemical Biology*, 2022.
- **U1 snRNP regulates chromatin retention of noncoding RNAs.** *Nature*, 2020.
- **RNA targets ribosome biogenesis factor WDR43 to chromatin for transcription and pluripotency control.** *Mol Cell*, 2019.
- **The lncRNA Hand2os1/Uph locus orchestrates heart development through regulation of precise expression HAND2.** *Development*, 2019.
- **Divergent lncRNAs regulate gene expression and lineage differentiation in pluripotent cells.** *Cell Stem Cell*, 2016.
- **Opposing roles for the lncRNA Haunt and its genomic locus in regulating HOXA gene activation during embryonic stem cell differentiation.** *Cell Stem Cell*, 2015.

### 3. Transcriptional surveillance and selection of productive biological information {#transcriptional-surveillance}

Ongoing studies examine how RNA Polymerase II activity, RNA processing, RNA degradation, and quality control select productive outputs from pervasive genome activity. The CV identifies these studies as unpublished and does not identify a formal published paper for this contribution; their manuscript titles are therefore omitted.

### 4. Probabilistic genome activity and stabilization of cell fate {#cell-fate-dynamics}

scFLUENT-seq revealed that genome activity in individual cells is sparse and probabilistic. The publication reports a cell-type-dependent range of approximately 0.02%–3.1% of the genome transcribed per cell, supporting a model in which stable cellular identities emerge through statistical stabilization of stochastic transcription.

Representative published paper:

- **Single-cell nascent transcription reveals sparse genome usage and plasticity.** *Cell*, 2025. doi: 10.1016/j.cell.2025.09.003.

### 5. Foundations in stress signaling and epigenetic regulation of cell fate {#foundations}

Earlier work defined conserved mechanisms of the unfolded protein response and identified Polycomb regulators that balance stem-cell self-renewal and differentiation, providing foundations for the laboratory’s current cell-fate questions.

Representative published papers:

- **Jumonji modulates Polycomb activity and self-renewal versus differentiation of stem cells.** *Cell*, 2009.
- **EZH1 mediates methylation on histone H3 lysine 27 and complements EZH2 in maintaining stem cell identity and executing pluripotency.** *Mol Cell*, 2008.
- **Complementary signaling pathways regulate the unfolded protein response and are required for C. elegans development.** *Cell*, 2001.

{% include section.html %}

## Latest Publications

The newest formal records are reproduced below in the CV’s order within each year.

### 2025

1. Ma S\*, Hong Y, Chen J, Xu J, Shen X\*. Single-cell nascent transcription reveals sparse genome usage and plasticity. Cell. 2025. doi: 10.1016/j.cell.2025.09.003. (* co-corresponding).
2. Hong Y, Shen X. Transposon exonization generates new protein-coding sequences. Mol Cell. 2025. doi: 10.1016/j.molcel.2024.12.009.
3. Y Zhou, C Tong, Z Shi, Y Zhang, X Xiong, X Shen, X Li, Y Yin. Condensation of ZFP207 and U1 snRNP promotes spliceosome assembly. Nature Structural & Molecular Biology 2025. 32 (6), 1038-1049

### 2024

4. New eyes and new landscapes. Cell. 2024 Aug; 187(17): 4434. Shen X featured her voice alongside several other scientists.
5. Han X, Xing L, Hong Y, Zhang X, Hao B, Lu J.Y, Huang M, Wang Z, Ma S, Zhan G, Li T, Hao X, Tao Y, Li G, Zhou S, Shao W, Zeng Y, Ma D, Zhang W, Xie Z, Deng H, Yan J, Deng W, and Shen X\*. Nuclear RNA homeostasis promotes systems-level coordination for cell fate and vitality. Cell Stem Cell. 2024. doi: 10.1016/j.stem.2024.03.015
6. Xiufeng Li, Luyao Bie, Yang Wang, Yaqiang Hong, Ziqiang Zhou, Yiming Fan, Xiaohan Yan, Yibing Tao, Chunyi Huang, Yongyan Zhang, Xueyan Sun, John Xiao He Li, Jing Zhang, Zai Chang, Qiaoran Xi, Anming Meng, Xiaohua Shen, Wei Xie, Nian Liu. LINE-1 transcription activates long-range gene expression. NATURE GENETICS 2024. 56 (7), 1494-1502
7. Yaqiang Hong, Luyao Bie, Tao Zhang, Xiaohan Yan, Guangpu Jin, Zhuo Chen, Yang Wang, Xiufeng Li, Gaofeng Pei, Yongyan Zhang, Yantao Hong, Liang Gong, Pilong Li, Wei Xie, Yanfen Zhu, Xiaohua Shen, Nian Liu. SAFB restricts contact domain boundaries associated with L1 chimeric transcription. Molecular cell 2024. 84 (9), 1637-1650. e10

{% include section.html %}

## Browse by Research Program

<div class="pub-theme-grid">
  <div class="pub-theme">
    <h3><a href="#genome-organization">Genome Organization</a></h3>
    <p>Spatial encoding, repetitive elements, chromatin compartmentalization, and nuclear positioning.</p>
  </div>
  <div class="pub-theme">
    <h3><a href="#rna-networks">RNA Networks</a></h3>
    <p>RNA–RBP meshwork, noncoding RNA, nuclear RNA homeostasis, and information-processing environments.</p>
  </div>
  <div class="pub-theme">
    <h3><a href="#transcriptional-surveillance">Transcriptional Surveillance</a></h3>
    <p>Selection of productive transcription through polymerase, RNA processing, degradation, and quality control.</p>
  </div>
  <div class="pub-theme">
    <h3><a href="#cell-fate-dynamics">Cell Fate Dynamics</a></h3>
    <p>Single-cell nascent transcription, probabilistic genome activity, plasticity, and stable cell states.</p>
  </div>
  <div class="pub-theme">
    <h3><a href="#foundations">Foundations</a></h3>
    <p>Stress signaling, Polycomb regulation, pluripotency, differentiation, and developmental control.</p>
  </div>
</div>

{% include section.html %}

## Full Publications

The 52 records below preserve the order, content, and incomplete fields of the formal FULL PUBLICATIONS section in the supplied CV. Missing information has not been inferred.

{% include full-publications.html %}
