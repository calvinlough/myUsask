myUsask
=======

myUsask is a project I built for my portfolio in 2011. It scrapes data from PAWS (a website for University of Saskatchewan students to read their emails, view grades, etc.) and displays it in an iOS app. It was never really intended for real world use and many parts of it no longer work because of changes to the PAWS website.

Overall it was a fun and challenging project to work on. The challenging aspect was figuring out to authenticate the user and get to the content that I wanted. I ended up using Google Chrome developer tools to monitor how credentials were being supplied, which redirects were happening and what cookies were being stored. Once authentication was finished, all I had to do was fetch the pages I needed and use regular expressions to extract the content.

## Demo

In the file CLConstants.h, there is a constant called CL_FAKE_NETWORK_DATA that specifies whether placeholder data is used or not. It is set to 1 by default, which means that supplied credentials aren't actually used and no data is scraped from the website.

To run the project, you will need to have a recent version of Xcode installed.

## Screenshots

<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot1.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot1.png" width="283" align="left">
</a>
<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot2.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot2.png" width="283" align="left">
</a>
<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot3.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot3.png" width="283" align="left">
</a>
<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot4.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot4.png" width="283" align="left">
</a>
<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot5.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot5.png" width="283" align="left">
</a>
<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot6.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot6.png" width="283" align="left">
</a>
<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot7.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot7.png" width="283" align="left">
</a>
<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot8.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot8.png" width="283" align="left">
</a>
<a href="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot9.png" target="_blank">
  <img src="https://github.com/calvinlough/myUsask/raw/master/screenshots/screenshot9.png" width="283" align="left">
</a>
