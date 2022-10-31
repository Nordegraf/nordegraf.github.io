---
layout: post
title:  New website for the CF-Selbsthilfe Frankfurt e.V.
date:   2022-10-30 18:00:00 +0200
categories: cf-selbsthilfe
tags: cystic-fibrosis
excerpt_separator: <!--more-->
---

A few weeks ago the CF-Selbsthilfe Frankfurt e.V. reached out to me for help with their website. They are a non-profit organization that supports people with cystic fibrosis and their families in Frankfurt and the surrounding area, including my family when I was diagnosed. Naturally I offered to help them without hesitation.

I'm happy to announce, that their new site is now live here: <a class="link" href="https://cf-selbsthilfe.de/">cf-selbsthilfe.de</a>.

<!--more-->

Their page is built similarly to this blog. Jekyll and Bootstrap are used for a responsive layout and the final page is hosted on GitHub Pages. But this time the task of hosting this site was a bit more intricate. Posts are split into events and actual posts using categories. Both are listed on seperate pages and need pagination, which the jekyll-paginate plugin can not provide. To be able to use the jekyll-paginate-v2 plugin, which solves most of these problems, the page needs to be built using a <a class="link" href="https://github.com/CF-Selbsthilfe/cf-selbsthilfe.de/blob/main/.github/workflows/jekyll.yml">GitHub Actions workflow</a>.

Several actions to built Jekyll pages already exist and all of them have different benefits or disadvantages. I chose <a class="link" href="https://github.com/limjh16/jekyll-action-ts">jekyll-action-ts</a> because it uses node.js instead of a docker container and automatically formats the code using <a class="link" href="https://prettier.io">prettier.io</a>. To keep the list of upcoming events up-to-date the page is rebuild once a week using a cron job.

Events are displayed in a calendar, which is built using <a class="link" href="https://fullcalendar.io">FullCalendar</a>. For that a <a class="link" href="https://github.com/CF-Selbsthilfe/cf-selbsthilfe.de/blob/main/_pages/events.html">JSON file</a> is generated formating all necessary data to be able to display the events in the calendar. Additionally FullCalendar can display events loaded from a Google Calendar or from iCalendar files, but beacause of privacy concerns I decided against that for now.

To use the associations top-level domain without publishing my blog on their domain I had to move the code repository to its own <a class="link" href="https://github.com/CF-Selbsthilfe">GitHub Organization</a>. The code is open sourced under the GNU GPLv3 license and is accessible through its <a class="link" href="https://github.com/CF-Selbsthilfe/cf-selbsthilfe.de">repository</a>.

The whole project took me about two weeks and I'm really happy with the result!



