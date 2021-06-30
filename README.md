# ASDF Altering SBCL compiler demonstration

In SBCL 2.0.9... 

    (load "main.lisp")

Now when you compile broken.lisp you get:

    (compile-file "broken.lisp" :output-file "/tmp/dontcare.fasl")
    ; compiling file "/home/wwilkinson/typhon-user2/broke/broken.lisp" (written 30 JUN 2021 09:55:27 AM):
    ; processing (DEFPACKAGE :BROKEN ...)
    ; processing (IN-PACKAGE :BROKEN)
    ; processing (LET (#) ...)
    ; processing (DEFUN DO-SOMETHING ...)
    
    ; file: /home/wwilkinson/typhon-user2/broke/broken.lisp
    ; in: DEFUN DO-SOMETHING
    ;     (DEFUN BROKEN::DO-SOMETHING () BROKEN::*MYVALUE*)
    ; --> PROGN SB-IMPL::%DEFUN SB-IMPL::%DEFUN SB-INT:NAMED-LAMBDA 
    ; --> FUNCTION 
    ; ==>
    ;   (BLOCK BROKEN::DO-SOMETHING BROKEN::*MYVALUE*)
    ; 
    ; caught WARNING:
    ;   undefined variable: BROKEN::*MYVALUE*
    ; 
    ; compilation unit finished
    ;   Undefined variable:
    ;     *MYVALUE*
    ;   caught 1 WARNING condition
    
    ; wrote /tmp/dontcare.fasl
    ; compilation finished in 0:00:00.004
    #P"/tmp/dontcare.fasl"
    
    T
    
    T

and it's repeatable. It always returns true as 2nd and 3rd values and
always prints those messages about the error.  But once you load the
system, this behavior is changed. Do this:

    (asdf:load-system :broken)

And from now on, compiling the file doesn't return errors.

    (compile-file "broken.lisp" :output-file "/tmp/dontcare.fasl")
    ; compiling file "/home/wwilkinson/typhon-user2/broke/broken.lisp" (written 30 JUN 2021 09:55:27 AM):
    ; processing (DEFPACKAGE :BROKEN ...)
    ; processing (IN-PACKAGE :BROKEN)
    ; processing (LET (#) ...)
    ; processing (DEFUN DO-SOMETHING ...)
    
    ; wrote /tmp/blahdontcare.fasl
    ; compilation finished in 0:00:00.003
    #P"/tmp/blahdontcare.fasl"
    
    NIL
    
    NIL

## Dockerized Demonstration

    docker build -t asdfbroke:latest .
    docker run --rm -ti asdfbroke:latest \
       --load "main.lisp" \
       --eval "(print (lisp-implementation-type))" \
       --eval "(print (lisp-implementation-version))" \
       --eval "(format t \"~%Before we load the system, compile-file detects the compilation problems:~%\")" \
       --eval "(dotimes (i 3) (format t \"~%~a\" (multiple-value-list (compile-file \"broken.lisp\" :output-file \"/tmp/dontcare.fasl\"))))" \
       --eval "(format t \"~%But if we use asdf:load-system, it changes the behavior. Lets load-system now:~%\")" \
       --eval "(asdf:load-system :broken)" \
       --eval "(format t \"~%And now, after load-system, compile-file no longer detects compile problems:~%\")" \
       --eval "(dotimes (i 3) (format t \"~%~a\" (multiple-value-list (compile-file \"broken.lisp\" :output-file \"/tmp/dontcare.fasl\"))))" \
       --quit
