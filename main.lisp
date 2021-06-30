(require :asdf)
(trace sb-c::compile-file)
(asdf:initialize-source-registry `(:source-registry
                                   (:directory ,*default-pathname-defaults*)
                                   :inherit-configuration))
