(require :asdf)
(asdf:initialize-source-registry `(:source-registry
                                   (:directory ,*default-pathname-defaults*)
                                   :inherit-configuration))
