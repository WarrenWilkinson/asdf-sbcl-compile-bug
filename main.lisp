(require "asdf")
(trace #+sbcl sb-c::compile-file
       #+clisp compile-file)
(asdf:initialize-source-registry `(:source-registry
                                   (:directory #p"/opt/")
                                   :inherit-configuration))
