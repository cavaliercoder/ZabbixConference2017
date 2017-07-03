#!/bin/bash
yum install -y httpd lynx
systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<EOL
<html>
  <head>
    <title>Zabbix Conference 2017</title>
    <style>
      /*
       * Text effect by https://codepen.io/mandymichael/
       * URL: https://codepen.io/mandymichael/pen/vxmKpz
       */
      html,
      body {
        background: #71cad0;
        width: 100%;
        height: 100%;
      }
      
      h1 {
        font-family: 'CoreCircus', sans-serif;
        text-transform: uppercase;
        font-size: 10vw;
        text-align: center;
        line-height: 1;
        margin: 0;
        top: 50%;
        left: 50%;
        -webkit-transform: translate(-50%, -50%);
                transform: translate(-50%, -50%);
        position: absolute;
        color: #61c0c8;
        text-shadow: 1px 0px 0px #67c2c5, 0px 1px 0px #67c2c5, 2px 1px 0px #67c2c5, 1px 2px 0px #67c2c5, 3px 2px 0px #67c2c5, 2px 3px 0px #67c2c5, 4px 3px 0px #67c2c5, 3px 4px 0px #67c2c5, 5px 4px 0px #67c2c5, 4px 5px 0px #67c2c5, 6px 5px 0px #67c2c5, 5px 6px 0px #67c2c5, 7px 6px 0px #67c2c5, 6px 7px 0px #67c2c5, 8px 7px 0px #aff1f9, 7px 8px 0px #aff1f9, 9px 8px 0px #aff1f9, 8px 9px 0px #aff1f9, 10px 9px 0px #aff1f9, 9px 10px 0px #aff1f9, 11px 10px 0px #aff1f9, 10px 11px 0px #aff1f9;
      }
      h1:before, h1:after {
        content: attr(data-heading);
        position: absolute;
        overflow: hidden;
        left: 0;
        top: 0;
      }
      h1:before {
        color: white;
        width: 100%;
        z-index: 5;
        font-family: 'CoreCircus2DIn';
        font-weight: normal;
      }
      h1:after {
        z-index: -1;
        text-shadow: -1px -1px 0 white, 1px -1px 0 white, -1px 1px 0 white, 1px 1px 0 white, -3px 3px 2px #6c9d9e, -5px 5px 2px #6c9d9e, -7px 7px 2px #6c9d9e, -8px 8px 2px #6c9d9e, -9px 9px 2px #6c9d9e, -11px 11px 2px #6c9d9e;
      }
      
      /*
       * Webfont: CoreCircus by S-Core
       * URL: http://www.myfonts.com/fonts/s-core/core-circus/regular/
       * Copyright: Copyright (c) 2013 by S-Core Co., Ltd.. All rights reserved.
       * Licensed pageviews: 10,000
       *
       * Webfont: CoreCircus2DIn by S-Core
       * URL: http://www.myfonts.com/fonts/s-core/core-circus/in/
       * Copyright: Copyright (c) 2013 by S-Core Co., Ltd.. All rights reserved.
       * Licensed pageviews: 10,000
      */
      @font-face {
        font-family: 'CoreCircus2DIn';
        src: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BFA_1_0.eot");
        src: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BFA_1_0.eot?#iefix") format("embedded-opentype"), url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BFA_1_0.woff2") format("woff2"), url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BFA_1_0.woff") format("woff"), url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BFA_1_0.ttf") format("truetype");
      }
      @font-face {
        font-family: 'CoreCircus';
        src: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BF4_8_0.eot");
        src: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BF4_8_0.eot?#iefix") format("embedded-opentype"), url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BF4_8_0.woff2") format("woff2"), url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BF4_8_0.woff") format("woff"), url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/209981/333BF4_8_0.ttf") format("truetype");
      }      
    </style>
  </head>
  <body>
    <h1 contenteditable data-heading="Welcome to Zabbix Conference 2017">Welcome to Zabbix Conference 2017</h1>
  </body>
</html>
EOL
