---
title: "Single-cell nascent transcription reveals sparse genome usage and plasticity"
short_title: "Sparse single-cell genome usage"
authors: "Shaoqian Ma, Yantao Hong, Junhan Chen, Jingzhao Xu, and Xiaohua Shen"
journal: "Cell"
volume: "188"
pages: "6873–6891"
year: 2025
date: 2025-09-26
doi: "https://doi.org/10.1016/j.cell.2025.09.003"

image: "/images/publications/2025-scfluent-seq/graphical-abstract.webp"
pdf: "/files/publications/2025-scfluent-seq/scfluent-seq-cell-2025.pdf"

summary: "scFLUENT-seq reveals sparse and stochastic genome usage in individual cells and links transcriptional diversity to cellular plasticity."

metric: "0.02–3.1% of the genome transcribed per cell"

tags:
  - Single-cell genomics
  - Nascent RNA
  - Transcriptional heterogeneity
  - Cellular plasticity

data:
  - label: GSE278775
    url: "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278775"
  - label: GSE278776
    url: "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278776"
  - label: GSE278777
    url: "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278777"

featured: true
---

# {{ page.title }}

**{{ page.authors }}**<br>
*{{ page.journal }}* {{ page.volume }} ({{ page.year }}): {{ page.pages }}

<img src="{{ page.image | relative_url }}" alt="Graphical abstract for {{ page.title | escape }}">

{{ page.summary }} The reported genome-usage range is cell-type dependent.

> **Key measurement:** {{ page.metric }}

- [View article]({{ page.doi }})

## Data

{% for dataset in page.data %}
- [{{ dataset.label }}]({{ dataset.url }})
{% endfor %}
