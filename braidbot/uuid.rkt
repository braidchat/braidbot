#lang racket/base

(provide uuid uuid? uuid-hi64 uuid-lo64 make-uuid)

(require racket/random

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
