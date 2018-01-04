#lang racket/base

(provide send-message reply-to)

(require racket/port
         racket/string
         net/url
         net/base64

         "transit.rkt"
         "util.rkt"
         "uuid.rkt")

(define (basic-auth-header user pass)
  (-> (list user ":" pass)
      (string-join "")
      string->bytes/utf-8
      (base64-encode #"") ; don't insert crlf every 75 chars
      bytes->string/utf-8
      (->> (string-append "Authorization: Basic "))))

(define (send-message msg
                      #:bot-id bot-id
                      #:bot-token bot-token
                      #:braid-url [braid-url "https://api.braid.chat"])
  (-> (combine-url/relative (string->url braid-url) "/bots/message")
      (post-pure-port (pack msg)
                      (list (basic-auth-header bot-id bot-token)
                            "Content-Type: application/transit+msgpack"))
      port->string))

(define (reply-to msg content
                  #:bot-id bot-id
                  #:bot-token bot-token
                  #:braid-url [braid-url "https://api.braid.chat"])
  (-> msg
      (hash-set '#:content content)
      (hash-set '#:id (make-uuid))
      (send-message #:bot-id bot-id #:bot-token bot-token #:braid-url braid-url)))
