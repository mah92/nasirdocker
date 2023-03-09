# ای صاحب نعمت ها بنده تم
## ایجاد ایمیج داکر
به آدرس زیر برید:

https://www.onworks.net/os-distributions/ubuntu-based/free-ubuntu-online-version-20

یک سرور موقت ایجاد کنید.

وارد ترمینال شوید و در آن وارد کنید:

$ wget -O - https://raw.githubusercontent.com/mah92/nasirdocker/developing/build.sh | bash

برای جلوگیری از خارج شدن از سرور موقت دکمه کنترل هر یک دقیقه زده می شود اما نباید تب را عوض کنید. 

## ساخت ایمیل بدون نیاز به تایید پیامکی
منبع: https://red-dot-geek.com/free-email-services-no-phone
maah92

proton.me, tutanota.com

## ساخت اکانت در داکر هاب
منبع: https://digispark.ir/create-docker-hub-account-and-repository

## ساخت ریپوزیتوری در داکر هاب
reponame: docker-whale

visibility: public

## ارسال ایمیج
منبع: https://digispark.ir/push-pull-tag-image-in-docker

```
$ docker images
REPOSITORY           TAG          IMAGE ID            CREATED             VIRTUAL SIZE
docker-whale         latest       7d9495d03763        38 minutes ago      273.7 MB
docker/whalesay      latest       fb434121fc77        4 hours ago         247 MB
hello-world          latest       91c95931e552        5 weeks ago         910 B
```

$ docker tag 7d9495d03763 yourhubusername/docker-whale:latest

$ docker login --username=yourhubusername --email=youremail@company.com

Password:

$ docker push yourhubusername/docker-whale

## کارهای دیگر
### گرفتن ایمیج
 $ docker pull yourhubusername/docker-whale
### پاک کردن ایمیج
```
$ docker rmi -f 7d9495d03763
$ docker rmi -f docker-whale
```
### اجرا
$ docker run maryatdocker/docker-whale