#lang racket/base

(provide serve)

(require web-server/servlet
         web-server/servlet-env
         (only-in file/sha1 bytes->hex-string)
         grommet/crypto/hmac

         "util.rkt"
         "transit.rkt"
         "braid.rkt")

(define (make-handler bot-token act-on-message)
  (λ (request)
    (let ([body (-> request request-post-data/raw)]
          [sig (some->> request request-headers (assoc 'x-braid-signature) cdr)])
      (if (and sig body
               (string=? sig
                         (bytes->hex-string (hmac-sha256 bot-token body))))
          (begin
            (act-on-message (unpack body))
            (response/output void #:message #"OK"))
          (begin
            (println "Bad signature")
            (response/output void #:code 400 #:message #"Bad Request"))))))

(define (serve bot-token act-on-message port)
  (serve/servlet (make-handler bot-token act-on-message)
                 #:launch-browser? #f
                 #:quit? #f
                 #:listen-ip "127.0.0.1"
                 #:port port
                 #:servlet-regexp #rx""))
