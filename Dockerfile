FROM clfoundation/sbcl:2.1.5-buster

WORKDIR /opt/

ADD main.lisp /opt/main.lisp
ADD broken.asd /opt/broken.asd
ADD broken.lisp /opt/broken.lisp
