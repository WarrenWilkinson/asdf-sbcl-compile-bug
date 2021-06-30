# ASDF Altering SBCL compiler demonstration

    (load "main.lisp")

Now when you compile broken.lisp you get:

    0: (COMPILE-FILE "broken.lisp" :OUTPUT-FILE "/tmp/dontcare.fasl")
    ; compiling file "/opt/broken.lisp" (written 30 JUN 2021 09:15:24 PM):
    ; processing (DEFPACKAGE :BROKEN ...)
    ; processing (IN-PACKAGE :BROKEN)
    ; processing (DEFUN GET-MY-VALUE ...)
    ; file: /opt/broken.lisp
    ; in: DEFUN GET-MY-VALUE
    ;     (DEFUN BROKEN::GET-MY-VALUE () BROKEN::*MYVALU*)
    ; --> PROGN SB-IMPL::%DEFUN SB-IMPL::%DEFUN SB-INT:NAMED-LAMBDA FUNCTION 
    ; ==>
    ;   (BLOCK BROKEN::GET-MY-VALUE BROKEN::*MYVALU*)
    ; 
    ; caught WARNING:
    ;   undefined variable: BROKEN::*MYVALU*
    ; 
    ; compilation unit finished
    ;   Undefined variable:
    ;     *MYVALU*
    ;   caught 1 WARNING condition
    
    ; wrote /tmp/dontcare.fasl
    ; compilation finished in 0:00:00.004
	(/tmp/dontcare.fasl T T)

and it's repeatable. It always returns true as 2nd and 3rd values and
always prints those messages about the error.  But with load-system,
compile-file no longer detects the issue (so ASDF doesn't throw an error).

    (asdf:load-system :broken)
    0: (COMPILE-FILE #P"/opt/broken.lisp" :OUTPUT-FILE #P"/root/.cache/common-lisp/sbcl-2.1.6-linux-x64/opt/broken-tmpGHU3ALSV.fasl" :EXTERNAL-FORMAT :UTF-8)
    ; compiling file "/opt/broken.lisp" (written 30 JUN 2021 09:15:24 PM):
    ; processing (DEFPACKAGE :BROKEN ...)
    ; processing (IN-PACKAGE :BROKEN)
    ; processing (DEFUN GET-MY-VALUE ...)
    
    ; wrote /root/.cache/common-lisp/sbcl-2.1.6-linux-x64/opt/broken-tmpGHU3ALSV.fasl
    ; compilation finished in 0:00:00.000
      0: COMPILE-FILE returned
           #P"/root/.cache/common-lisp/sbcl-2.1.6-linux-x64/opt/broken-tmpGHU3ALSV.fasl"
           NIL
           NIL
    
    ; file: /opt/broken.lisp
    ; in: DEFUN BROKEN::GET-MY-VALUE
    ;     (DEFUN BROKEN::GET-MY-VALUE () BROKEN::*MYVALU*)
    ; --> PROGN SB-IMPL::%DEFUN SB-IMPL::%DEFUN SB-INT:NAMED-LAMBDA FUNCTION 
    ; ==>
    ;   (BLOCK BROKEN::GET-MY-VALUE BROKEN::*MYVALU*)
    ; 
    ; caught WARNING:
    ;   undefined variable: BROKEN::*MYVALU*
    ; 
    ; compilation unit finished
    ;   Undefined variable:
    ;     BROKEN::*MYVALU*
    ;   caught 1 WARNING condition
    

But, compile-file still detects the error.  This behavior happens in SBCL, but not in Clisp.

## Dockerized SBCL Demonstration the problem

    docker build -f Dockerfile.sbcl -t asdfbroke:sbcl .
    docker run --rm -ti asdfbroke:sbcl \
       --eval "(load \"main.lisp\")" \
       --eval "(print (lisp-implementation-type))" \
       --eval "(print (lisp-implementation-version))" \
       --eval "(format t \"~%Before we load the system, compile-file detects the compilation problems:~%\")" \
       --eval "(dotimes (i 3) (format t \"~%~a\" (multiple-value-list (compile-file \"broken.lisp\" :output-file \"/tmp/dontcare.fasl\"))))" \
       --eval "(format t \"~%But if we use asdf:load-system, it's call to compile-file behaves differently. Lets load-system now:~%\")" \
       --eval "(asdf:load-system :broken)" \
       --eval "(format t \"~%And now, after load-system, compile-file still detects compile problems:~%\")" \
       --eval "(dotimes (i 1) (format t \"~%~a\" (multiple-value-list (compile-file \"broken.lisp\" :output-file \"/tmp/dontcare.fasl\"))))" \
       --quit

## Dockerized CLISP That does not have the problem.

    docker build -f Dockerfile.clisp -t asdfbroke:clisp .
    docker run --rm -ti asdfbroke:clisp \
       -x "(load \"main.lisp\")" \
       -x "(print (lisp-implementation-type))" \
       -x "(print (lisp-implementation-version))" \
       -x "(format t \"~%Before we load the system, compile-file detects the compilation problems:~%\")" \
       -x "(dotimes (i 3) (format t \"~%~a\" (multiple-value-list (compile-file \"broken.lisp\" :output-file \"/tmp/dontcare.fasl\"))))" \
       -x "(format t \"~%On clisp, asdf:load-system works as expected. Lets load-system now:~%\")" \
       -x "(asdf:load-system :broken)" \
       -x "(format t \"~%And now, after load-system, compile-file still detects compile problems:~%\")" \
       -x "(dotimes (i 1) (format t \"~%~a\" (multiple-value-list (compile-file \"broken.lisp\" :output-file \"/tmp/dontcare.fasl\"))))"
