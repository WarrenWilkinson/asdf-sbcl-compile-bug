FROM fukamachi/sbcl:latest-ubuntu

WORKDIR /opt/

ADD main.lisp /opt/main.lisp
ADD broken.asd /opt/broken.asd
ADD broken.lisp /opt/broken.lisp
