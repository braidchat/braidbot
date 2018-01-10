#lang racket/base
;;; Implementation of RFC4122 UUID v4
(provide uuid uuid? uuid-hi64 uuid-lo64 make-uuid uuid->string)

(require racket/random
         racket/string
         racket/format
         (only-in file/sha1 bytes->hex-string)

         "util.rkt")

(struct uuid (hi64 lo64) #:prefab)

(define (rand-64)
  (~> (crypto-random-bytes 8)
      (integer-bytes->integer #t #t)))

;;    0                   1                   2                   3
;;     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
;;    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
;;    |                          time_low                             |
;;    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
;;    |       time_mid                |         time_hi_and_version   |
;;    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
;;    |clk_seq_hi_res |  clk_seq_low  |         node (0-1)            |
;;    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
;;    |                         node (2-5)                            |
;;    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

;; The algorithm is as follows:

;; o  Set the two most significant bits (bits 6 and 7) of the
;;    clock_seq_hi_and_reserved to zero and one, respectively.

;; o  Set the four most significant bits (bits 12 through 15) of the
;;    time_hi_and_version field to the 4-bit version number from
;;    Section 4.1.3. (b#0100)

;; o  Set all the other bits to randomly (or pseudo-randomly) chosen
;;    values.

(define (make-uuid)
  (let ([hi (~> (rand-64)
                ;; Set version in 4 sig bits of time_hi_and_version
                (bitwise-and (~> #b1111
                                 (arithmetic-shift 12)
                                 (bitwise-not)))
                (bitwise-ior (~> #b0100
                                 (arithmetic-shift 12))))]
        [lo (~> (rand-64)
                ;; set 2 sig bits of clock_seq_hi_res to 0 & 1
                (bitwise-and (~> 1
                                 (arithmetic-shift (- 64 6))
                                 (bitwise-not)))
                (bitwise-ior (~> 1 (arithmetic-shift (- 64 7)))))])
    (uuid hi lo)))

(define (hex n [min-width 2])
  (~r n #:base 16 #:min-width min-width #:pad-string "0"))

;; UUID                   = time-low "-" time-mid "-"
;;                          time-high-and-version "-"
;;                          clock-seq-and-reserved
;;                          clock-seq-low "-" node
;; time-low               = 4hexOctet
;; time-mid               = 2hexOctet
;; time-high-and-version  = 2hexOctet
;; clock-seq-and-reserved = hexOctet
;; clock-seq-low          = hexOctet
;; node                   = 6hexOctet
;; hexOctet               = hexDigit hexDigit
;; hexDigit =
;;       "0" / "1" / "2" / "3" / "4" / "5" / "6" / "7" / "8" / "9" /
;;       "a" / "b" / "c" / "d" / "e" / "f" /
;;       "A" / "B" / "C" / "D" / "E" / "F"
(define (uuid->string uuid)
  (let* ([hi (uuid-hi64 uuid)]
         [lo (uuid-lo64 uuid)]
         [time-low (bitwise-bit-field hi 32 64)]
         [time-mid (bitwise-bit-field hi 16 32)]
         [time-hi-and-version (bitwise-bit-field hi 0 16)]
         [clock-seq-and-reservered (bitwise-bit-field lo 56 64)]
         [clock-seq-low (bitwise-bit-field lo 48 56)]
         [node (bitwise-bit-field lo 0 48)])
    (string-join
     (list
      (hex time-low 8)
      (hex time-mid 4)
      (hex time-hi-and-version 4)
      (string-append
       (hex clock-seq-and-reservered 2)
       (hex clock-seq-low 2))
      (hex node 12))
     "-")))
