---
title: 论文发表
---

<p class="right"><small><a href="{{ '/publications/' | relative_url }}">English</a></small></p>

# 论文发表

以下成果围绕**生物信息流：从基因组到细胞命运**组织。顶部特色卡片继续由现有论文集合驱动，并链接至 scFLUENT-seq 详情页；完整目录严格沿用简历中正式 FULL PUBLICATIONS 部分的顺序与内容。

{% assign papers = site.publications | sort: "date" | reverse %}

<div class="publication-grid">
  {% for paper in papers %}
    <article class="publication-entry">
      <a class="publication-entry-image" href="{{ paper.url | relative_url }}">
        <img
          src="{{ paper.image | relative_url }}"
          alt="{{ paper.title | escape }} 的图文摘要"
          loading="lazy"
        >
      </a>
      <div class="publication-entry-content">
        <div class="publication-entry-meta">{{ paper.journal }} · {{ paper.year }}</div>
        <h3><a href="{{ paper.url | relative_url }}">{{ paper.title }}</a></h3>
        <p class="publication-entry-authors">{{ paper.authors }}</p>
        <p>scFLUENT-seq 揭示单细胞中稀疏且随机的基因组使用，并将转录多样性与细胞可塑性联系起来。</p>
        {% if paper.metric %}
          <div class="publication-entry-metric">{{ paper.metric }}（范围取决于细胞类型）</div>
        {% endif %}
        <div class="publication-entry-tags">
          <span>单细胞基因组学</span>
          <span>新生 RNA</span>
          <span>转录异质性</span>
          <span>细胞可塑性</span>
        </div>
        <div class="publication-entry-actions">
          <a href="{{ paper.url | relative_url }}">阅读简介</a>
          <a href="{{ paper.doi }}">查看论文</a>
        </div>
      </div>
    </article>
  {% endfor %}
</div>

<div class="pub-nav">
  <a href="#代表性科学贡献">代表性科学贡献</a>
  <a href="#最新论文">最新论文</a>
  <a href="#按研究方向浏览">按研究方向浏览</a>
  <a href="#完整论文目录">完整论文目录</a>
</div>

{% include section.html %}

## 代表性科学贡献

### 1. 基因组组织与生物信息的空间编码 {#zh-genome-organization}

重复元件并非惰性的基因组材料；其序列特征参与同类聚集、染色质区室化与协调调控，构成生物信息的空间层次。

代表性已发表论文：

- **Homotypic clustering of L1 and B1/Alu repeats compartmentalizes the 3D genome.** *Cell Research*, 2021.
- **Genomic repeats categorize genes with distinct functions for orchestrated regulation.** *Cell Reports*, 2020.

### 2. RNA 网状体系与细胞核信息处理环境 {#zh-rna-networks}

实验室确立了基因组邻近性作为 lncRNA 顺式调控原则，并揭示新生 RNA 和 RNA 结合蛋白通过相分离与 RNA 稳态组织转录机器、染色质关联和细胞核环境。

代表性已发表论文：

- **Nuclear RNA homeostasis promotes systems-level coordination for cell fate and vitality.** *Cell Stem Cell*, 2024.
- **Phase separation of RNA-binding protein promotes polymerase engagement and transcription.** *Nature Chemical Biology*, 2022.
- **U1 snRNP regulates chromatin retention of noncoding RNAs.** *Nature*, 2020.
- **RNA targets ribosome biogenesis factor WDR43 to chromatin for transcription and pluripotency control.** *Mol Cell*, 2019.
- **The lncRNA Hand2os1/Uph locus orchestrates heart development through regulation of precise expression HAND2.** *Development*, 2019.
- **Divergent lncRNAs regulate gene expression and lineage differentiation in pluripotent cells.** *Cell Stem Cell*, 2016.
- **Opposing roles for the lncRNA Haunt and its genomic locus in regulating HOXA gene activation during embryonic stem cell differentiation.** *Cell Stem Cell*, 2015.

### 3. 转录监控与有效生物信息选择 {#zh-transcriptional-surveillance}

正在开展的研究关注 RNA 聚合酶 II 活性、RNA 加工、RNA 降解和质量控制如何从广泛基因组活动中选择有效输出。简历将这些研究标注为未发表，且未在该贡献项下列出正式发表论文，因此不公开相关稿件标题。

### 4. 概率性基因组活动与细胞命运稳定化 {#zh-cell-fate-dynamics}

scFLUENT-seq 揭示了单细胞基因组活动的稀疏性和概率性。论文报告每个细胞转录约 0.02%–3.1% 的基因组，范围取决于细胞类型，支持稳定细胞身份由随机转录的统计性稳定产生这一模型。

代表性已发表论文：

- **Single-cell nascent transcription reveals sparse genome usage and plasticity.** *Cell*, 2025. doi: 10.1016/j.cell.2025.09.003.

### 5. 应激信号与细胞命运表观遗传调控基础 {#zh-foundations}

早期研究阐明了保守的未折叠蛋白反应机制，并鉴定出调控干细胞自我更新与分化平衡的 Polycomb 调控因子，为实验室当前的细胞命运问题奠定基础。

代表性已发表论文：

- **Jumonji modulates Polycomb activity and self-renewal versus differentiation of stem cells.** *Cell*, 2009.
- **EZH1 mediates methylation on histone H3 lysine 27 and complements EZH2 in maintaining stem cell identity and executing pluripotency.** *Mol Cell*, 2008.
- **Complementary signaling pathways regulate the unfolded protein response and are required for C. elegans development.** *Cell*, 2001.

{% include section.html %}

## 最新论文

以下为简历中 2025 年和 2024 年的全部正式记录；同一年内沿用简历顺序。

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

## 按研究方向浏览

<div class="pub-theme-grid">
  <div class="pub-theme"><h3><a href="#zh-genome-organization">基因组组织</a></h3><p>空间编码、重复元件、染色质区室化与核内定位。</p></div>
  <div class="pub-theme"><h3><a href="#zh-rna-networks">RNA 网络</a></h3><p>RNA–RBP 网状体系、非编码 RNA、细胞核 RNA 稳态与信息处理环境。</p></div>
  <div class="pub-theme"><h3><a href="#zh-transcriptional-surveillance">转录监控</a></h3><p>通过聚合酶、RNA 加工、降解和质量控制选择有效转录。</p></div>
  <div class="pub-theme"><h3><a href="#zh-cell-fate-dynamics">细胞命运动力学</a></h3><p>单细胞新生转录、概率性基因组活动、可塑性与稳定细胞状态。</p></div>
  <div class="pub-theme"><h3><a href="#zh-foundations">基础研究</a></h3><p>应激信号、Polycomb 调控、多能性、分化与发育控制。</p></div>
</div>

{% include section.html %}

## 完整论文目录

以下 52 条记录严格保留所提供英文简历正式 FULL PUBLICATIONS 部分的顺序、内容和不完整字段；未推断或补充缺失信息。

{% include full-publications.html %}
