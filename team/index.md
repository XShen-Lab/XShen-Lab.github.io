---
title: Member
nav:
  order: 3
  tooltip: About XShen Lab
---

# {% include icon.html icon="fa-solid fa-users" %}Team

The XShen Lab brings together researchers with backgrounds in molecular cell biology, genomics, bioinformatics, biophysics, and computational biology.

Our team studies the noncoding genome, nuclear RNA, chromatin organization, transcriptional regulation, and cell fate determination through both experimental and computational approaches.

{% include section.html %}

## Principal Investigator

{% include list.html data="members" component="portrait" filter="role == 'pi'" %}

{% include section.html %}

## Current Members

{% include list.html data="members" component="portrait" filter="role != 'pi'" %}

{% include section.html background="images/background.jpg" dark=true %}

## Lab Life

We value rigorous science, open discussion, quantitative thinking, and close collaboration across molecular biology, genomics, computation, and theory.

{% include section.html %}

## Photos

{% capture content %}

{% include figure.html image="images/team/lab-photo-1.jpg" caption="XShen Lab" %}

{% include figure.html image="images/team/lab-photo-2.jpg" caption="Lab members" %}

{% include figure.html image="images/team/lab-photo-3.jpg" caption="Research and discussion" %}

{% endcapture %}

{% include grid.html style="square" content=content %}
