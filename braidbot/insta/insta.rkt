#lang racket

;;; Language for a quick-start braidbot
;;; Based on web-server/insta:
;; https://github.com/racket/web-server/blob/master/web-server-lib/web-server/insta/insta.rkt

(require braidbot/server
         braidbot/braid
         (for-syntax racket)
         (for-syntax syntax/kerncase))

(provide
 (all-from-out braidbot/braid)
 (except-out (all-from-out racket) #%module-begin)
 (rename-out [bot-module-begin #%module-begin]))

(define server-listen-port 8899)
(provide listen-port)
(define (listen-port port)
  (set! server-listen-port port))

;; Check that id-stx is bound in body-stxs
(define-for-syntax (check-for-def stx id-stx error-msg body-stxs)
  (with-syntax ([(pmb body ...) (local-expand
                                (quasisyntax/loc stx
                                  (#%module-begin #,@body-stxs))
                                'module-begin
                                empty)])
    (let loop ([syns (syntax->list #'(body ...))])
      (if (empty? syns)
          (raise-syntax-error 'insta error-msg stx)
          (kernel-syntax-case
           (first syns) #t
           [(define-values (id ...) expr)
            (unless
                (ormap (λ (id)
                         (and (identifier? id)
                              (free-identifier=? id id-stx)))
                       (syntax->list #'(id ...)))
              (loop (rest syns)))]
           [_ (loop (rest syns))])))
    (quasisyntax/loc stx
      (pmb body ...))))


(define-syntax (bot-module-begin stx)
  (syntax-case stx ()
    [(_ body ...)
     (let* ([act-on-message (datum->syntax stx 'act-on-message)]
            [bot-token (datum->syntax stx 'bot-token)]
            ;; TODO: validate bot-token, bot-id
            [expanded (check-for-def
                       stx act-on-message
                       "You must provide an 'act-on-message' handler."
                       #'(body ...))])
       (quasisyntax/loc stx
         (#,@expanded
          (provide #,act-on-message)
          (serve #,bot-token #,act-on-message server-listen-port))))]))
