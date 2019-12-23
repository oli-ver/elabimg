# Container image version
# Note: the version here is from Dockerfile:ELABIMG_VERSION not the tagged one

## 1.4.0

* add gzip compression for javascript and css
* add php7-exif
* improve disable_function sed

## 1.3.1

* Fix the client_max_body_size parameter
* Remove ./dockerenv file

## 1.3.0

* Add an option to define the MySQL port

## 1.2.0

* Fix nginx configuration for max file size allowed for upload
* Add ENABLE_IPV6 option for ipv6 in nginx

## 1.1.0

* Add redis support for session handling
* Use Alpine linux version 3.10
* Fix bug in DH params generation
* Use Gmagick 2.0.5RC1

## 1.0.6

* Remove form-action in CSP
* Update the example docker-compose file to version 3

## 1.0.5

* Add more restrictions in CSP
* Add circleci image vulnerability checks

## 1.0.4

* Add Feature-Policy header
* Disable access log for assets in nginx config

## 1.0.3

* Add unzip to open_basedir so composer can use it
* Whitelist allowed http methods in nginx
* Remove .git folder
* Use --no-cache instead of --update for apk
* Increase pcre.backtrack_limit value to prevent pdf issue
* Install unzip for composer

## 1.0.2

* Remove mcrypt dependency
* Replace google.com by gstatic.com in CSP header whitelist
* Add PHP_MAX_EXECUTION_TIME env var

## 1.0.1

* Start CHANGELOG
