# Module JavaScript MIME Type Server Test

ES module JavaScript, known for its `import` and `export` statements, [can be used in all major browsers](https://caniuse.com/#feat=es6-module) provided it served with the proper MIME type in the `Content-Type` header. Per the [WHATWG spec](https://html.spec.whatwg.org/#scriptingLanguages), the MIME type should be `text/javascript`; though per the [IANA spec](https://www.iana.org/assignments/media-types/media-types.xhtml), `text/javascript` is deprecated in favor of `application/javascript`.

In practice browsers accept either MIME type, however they do not execute ES module JavaScript if it lacks a `Content-Type` header or that header contains a non-JavaScript MIME type like `text/plain`. Therefore it is important that webservers include a valid JavaScript MIME type in the `Content-Type` header for all JavaScript files they serve.

Most webservers choose what MIME type to include for a file based on the file’s extension. Most servers’ extension-to-MIME type mappings are configurable, though due to the popularity of shared hosting it’s certainly not a given that every user has sufficient access to configure their server. Therefore defaults are important; and now that there are two common file extensions for JavaScript, `.js` and `.mjs`, I wanted to see what the support looked like for serving each extension with a proper MIME type.

This repo contains a script which uses Docker to launch many different common webservers, including the two most popular (Nginx and Apache httpd). The script then uses `curl` to request both a `.js` and an `.mjs` file from the Dockerized server, and the `Content-Type` header for each file is printed. You can run the script yourself by first [installing Docker](https://docs.docker.com/install/) and running `test.sh` in a Bash environment such as the Mac or Linux command lines.

Here are the results on my machine as of 2019-12-15:

```
Nginx
.js:	application/javascript
.mjs:	application/octet-stream

Apache httpd
.js:	application/javascript
.mjs:

Node.js
.js:	application/javascript; charset=UTF-8
.mjs:	application/javascript; charset=UTF-8

PHP
.js:	application/javascript
.mjs:

Python
.js:	application/javascript
.mjs:	application/javascript

Ruby
.js:	application/javascript
.mjs:	application/octet-stream
```

As you can see, all servers correctly serve `.js` files with a MIME type that browsers will accept for ES modules; however only Node.js (via the `http-server` package) and Python (via its `http.server`) serve `.mjs` files correctly.

Depending on [which](https://trends.builtwith.com/web-server) [source](https://w3techs.com/technologies/overview/web_server) you believe, Apache and Nginx account for about 70% to 74% of all websites. Furthermore, according to [this source](https://w3techs.com/technologies/details/ws-apache/2), 22% of the Apache sites are running Apache 2.2—which reached end-of-life on 2018-01-01. (The current version is 2.4, which was released in 2012.) This would seem to imply that the speed at which most hosts upgrade their webserver software is considerably slow (which incidentally, can’t be great for security).

Just because most of the Web uses Apache and Nginx doesn’t in turn mean that all those sites will fail to serve `.mjs` properly; many of them are probably configured with more MIME type mappings than Apache or Nginx provide by default, or users can configure their own through tools like `.htaccess` files. However it seems clear that many, if not the vast majority, of such sites are probably not _currently_ configured to properly serve `.mjs` files; and based on the still substatial Apache 2.2 usage, it will likely take many years before this situation changes.
