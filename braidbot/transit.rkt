#lang racket/base

(provide pack unpack uuid)

(require racket/port
         racket/string
         racket/vector
         racket/match
         racket/date

         (prefix-in msgpack: msgpack)

         "uuid.rkt"
         "util.rkt")

(define (transit->form transit)
  (match transit
    [(hash-table (_ _) ...)
     (-> transit
         (hash-map (λ (k v) (cons (transit->form k) (transit->form v))))
         make-immutable-hash)]
    [(regexp #rx"^~:(.*)$" (list _ kw)) (string->keyword kw)]
    [(vector "~#u" (vector hi64 lo64)) (uuid hi64 lo64)]
    [(vector "~#m" ts) (seconds->date (* (/ 1000) ts))]
    [(vector "~#list" rest) (vector->list (vector-map transit->form rest))]
    [(vector thing ...) (map transit->form thing)]
    [_ transit]))

(define (unpack bytes)
  (-> (call-with-input-bytes
       bytes
       (λ (in) (msgpack:unpack in)))
      transit->form))

(define (form->transit form)
  (match form
    [(hash-table (_ _) ...)
     (-> form
         (hash-map (λ (k v) (cons (form->transit k) (form->transit v))))
         make-immutable-hash)]
    [(? keyword? kw) (string-append "~:" (keyword->string kw))]
    [(? date? d) (vector "~#m" (* 1000 (date*->seconds d)))]
    [(? uuid? u) (vector "~#u" (vector (uuid-hi64 u) (uuid-lo64 u)))]
    [(list thing ...) (vector "~#list"
                             (list->vector (map form->transit thing)))]
    [_ form]))

(define (pack thing)
  (call-with-output-bytes
   (λ (out)
     (-> thing form->transit (msgpack:pack out)))))
