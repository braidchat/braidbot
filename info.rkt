#lang info
(define collection 'multi)
(define deps '("web-server-lib"
               "base"
               "msgpack"
               "grommet"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/braidbot.scrbl" ())))
(define pkg-desc "Description Here")
(define version "0.0")
(define pkg-authors '(james))
