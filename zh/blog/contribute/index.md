---
title: 提交实验室动态
description: 用于提交 XShen Lab 实验室新闻、论文故事、学术会议与实验室生活记录的审核入口。
permalink: /zh/blog/contribute/
translation_url: /blog/contribute/
---

<div class="contribute-page">
  <header class="contribute-hero">
    <p class="rna-section-label">编辑台</p>
    <h1>提交实验室动态。</h1>
    <p>欢迎成员帮助我们记录 XShen Lab 的科学、成员与共同生活。本入口用于实验室官网内容，不是期刊论文投稿系统。</p>
  </header>

  <section class="contribute-categories" aria-labelledby="contribute-categories-title">
    <div class="contribute-section-head">
      <span>01</span>
      <div><h2 id="contribute-categories-title">选择一个分类</h2><p>请选择一个主要分类；更细的主题标签可由编辑时补充。</p></div>
    </div>
    <ol>
      {% for category in site.data.blog_categories %}
        <li><span>0{{ forloop.index }}</span><strong>{{ category.labels["zh-CN"] }}</strong><p>{{ category.descriptions["zh-CN"] }}</p></li>
      {% endfor %}
    </ol>
  </section>

  <section class="contribute-checklist" aria-labelledby="contribute-checklist-title">
    <div class="contribute-section-head">
      <span>02</span>
      <div><h2 id="contribute-checklist-title">准备内容材料</h2><p>材料简洁、信息完整，可以显著加快中英文编辑与发布。</p></div>
    </div>
    <ul>
      <li><strong>拟题与分类</strong><span>注明活动或论文公开日期，以及涉及的成员。</span></li>
      <li><strong>摘要与正文</strong><span>提交 100–300 字的中文、英文或双语草稿。</span></li>
      <li><strong>原始图片</strong><span>附原尺寸文件，并提供图注、拍摄者或来源以及建议裁切位置。</span></li>
      <li><strong>授权与发布时间</strong><span>确认可识别人物同意公开，且内容不包含受 embargo 约束或尚未公开的结果。</span></li>
      <li><strong>相关链接</strong><span>如适用，请附公开论文、会议、数据、protocol 或机构新闻链接。</span></li>
    </ul>
  </section>

  <section class="contribute-review" aria-labelledby="contribute-review-title">
    <div class="contribute-section-head">
      <span>03</span>
      <div><h2 id="contribute-review-title">发送并等待审核</h2><p>请通过邮件发送正文和原始图片。按钮会打开预填邮件；附件需要在邮件客户端中添加。</p></div>
    </div>
    <a class="rna-button primary" href="mailto:xshen@tsinghua.edu.cn?subject=%5B%E5%AE%98%E7%BD%91%E6%8A%95%E7%A8%BF%5D%20%E5%88%86%E7%B1%BB%20%E2%80%94%20%E6%8B%9F%E9%A2%98&amp;body=%E5%88%86%E7%B1%BB%EF%BC%9A%0A%E6%8B%9F%E9%A2%98%EF%BC%9A%0A%E6%B4%BB%E5%8A%A8%E6%88%96%E8%AE%BA%E6%96%87%E6%97%A5%E6%9C%9F%EF%BC%9A%0A%E6%8A%95%E7%A8%BF%E4%BA%BA%EF%BC%9A%0A%E6%8F%90%E4%BE%9B%E8%AF%AD%E8%A8%80%EF%BC%9A%0A%E5%9B%BE%E6%B3%A8%E4%B8%8E%E7%BD%B2%E5%90%8D%EF%BC%9A%0A%E6%8E%88%E6%9D%83%E5%B7%B2%E7%A1%AE%E8%AE%A4%EF%BC%9A%0A%E7%9B%B8%E5%85%B3%E9%93%BE%E6%8E%A5%EF%BC%9A%0A%0A%E8%AF%B7%E9%99%84%E6%AD%A3%E6%96%87%E8%8D%89%E7%A8%BF%E4%B8%8E%E5%8E%9F%E5%A7%8B%E5%9B%BE%E7%89%87%E3%80%82">开始投稿邮件 <span aria-hidden="true">↗</span></a>
    <p class="contribute-note">所有内容都会经过事实核验、图片授权与隐私、中英文呈现以及发布时间审核；发送材料不会自动公开发布。</p>
  </section>
</div>
