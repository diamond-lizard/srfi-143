;;;; fxcore, fixnum version of core bitwise operations
;;; Copyright (C) 1991, 1993, 2001, 2003, 2005 Aubrey Jaffer
;;; This implementation of the eight core bitwise functions
;;; (fxnot, fxand, fxior, fxxor, fxarithmetic-shift-left,
;;; fxarithmetic-shift-right, fxbit-count, fxlength)
;;; is drawn from the SRFI 60 implementation.
;;; Here is Shivers's comment on this code in SRFI 33:

;;; The [following] implementations of these functions use [only] R4RS
;;; arithmetic, so a simple-minded implementation again doesn't need to
;;; do much to support them -- however, [these] general implementations
;;; are terribly inefficient relative to native support and should *not*
;;; be used except in case of dire emergency. (It's quite clever code,
;;; nonetheless, to provide the semantics with such little support.)

;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.


(define (fxnot n) (fx- -1 n))

(define logical:boole-xor
 '#(#(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
    #(1 0 3 2 5 4 7 6 9 8 11 10 13 12 15 14)
    #(2 3 0 1 6 7 4 5 10 11 8 9 14 15 12 13)
    #(3 2 1 0 7 6 5 4 11 10 9 8 15 14 13 12)
    #(4 5 6 7 0 1 2 3 12 13 14 15 8 9 10 11)
    #(5 4 7 6 1 0 3 2 13 12 15 14 9 8 11 10)
    #(6 7 4 5 2 3 0 1 14 15 12 13 10 11 8 9)
    #(7 6 5 4 3 2 1 0 15 14 13 12 11 10 9 8)
    #(8 9 10 11 12 13 14 15 0 1 2 3 4 5 6 7)
    #(9 8 11 10 13 12 15 14 1 0 3 2 5 4 7 6)
    #(10 11 8 9 14 15 12 13 2 3 0 1 6 7 4 5)
    #(11 10 9 8 15 14 13 12 3 2 1 0 7 6 5 4)
    #(12 13 14 15 8 9 10 11 4 5 6 7 0 1 2 3)
    #(13 12 15 14 9 8 11 10 5 4 7 6 1 0 3 2)
    #(14 15 12 13 10 11 8 9 6 7 4 5 2 3 0 1)
    #(15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0)))

(define logical:boole-and
 '#(#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
    #(0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1)
    #(0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2)
    #(0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3)
    #(0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4)
    #(0 1 0 1 4 5 4 5 0 1 0 1 4 5 4 5)
    #(0 0 2 2 4 4 6 6 0 0 2 2 4 4 6 6)
    #(0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 7)
    #(0 0 0 0 0 0 0 0 8 8 8 8 8 8 8 8)
    #(0 1 0 1 0 1 0 1 8 9 8 9 8 9 8 9)
    #(0 0 2 2 0 0 2 2 8 8 10 10 8 8 10 10)
    #(0 1 2 3 0 1 2 3 8 9 10 11 8 9 10 11)
    #(0 0 0 0 4 4 4 4 8 8 8 8 12 12 12 12)
    #(0 1 0 1 4 5 4 5 8 9 8 9 12 13 12 13)
    #(0 0 2 2 4 4 6 6 8 8 10 10 12 12 14 14)
    #(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)))

(define (logical:ash-4 x)
  (if (negative? x)
      (+ -1 (quotient (+ 1 x) 16))
      (quotient x 16)))

(define (logical:reduce op4 ident)
  (lambda args
    (do ((res ident (op4 res (car rgs) 1 0))
         (rgs args (cdr rgs)))
        ((null? rgs) res))))


(define fxand
  (letrec
      ((lgand
        (lambda (n2 n1 scl acc)
          (cond ((fx=? n1 n2) (fx+ acc (fx* scl n1)))
                ((fxzero? n2) acc)
                ((fxzero? n1) acc)
                (else (lgand (logical:ash-4 n2)
                             (logical:ash-4 n1)
                             (fx* 16 scl)
                             (fx+ (fx* (vector-ref (vector-ref logical:boole-and
                                                           (modulo n1 16))
                                               (modulo n2 16))
                                   scl)
                                acc)))))))
    (logical:reduce lgand -1)))

(define fxior
  (letrec
      ((lgior
        (lambda (n2 n1 scl acc)
          (cond ((fx=? n1 n2) (fx+ acc (fx* scl n1)))
                ((fxzero? n2) (fx+ acc (fx* scl n1)))
                ((fxzero? n1) (fx+ acc (fx* scl n2)))
                (else (lgior (logical:ash-4 n2)
                             (logical:ash-4 n1)
                             (fx* 16 scl)
                             (fx+ (fx* (fx- 15 (vector-ref
                                          (vector-ref logical:boole-and
                                                      (fx- 15 (modulo n1 16)))
                                          (fx- 15 (modulo n2 16))))
                                   scl)
                                acc)))))))
    (logical:reduce lgior 0)))

(define fxxor
  (letrec
      ((lgxor
        (lambda (n2 n1 scl acc)
          (cond ((fx=? n1 n2) acc)
                ((fxzero? n2) (fx+ acc (fx* scl n1)))
                ((fxzero? n1) (fx+ acc (fx* scl n2)))
                (else (lgxor (logical:ash-4 n2)
                             (logical:ash-4 n1)
                             (fx* 16 scl)
                             (fx+ (fx* (vector-ref (vector-ref logical:boole-xor
                                                           (modulo n1 16))
                                               (modulo n2 16))
                                   scl)
                                acc)))))))
    (logical:reduce lgxor 0)))

(define (fxarithmetic-shift-right n count)
  (let ((k (expt 2 count)))
    (if (fxnegative? n)
      (fx+ -1 (quotient (fx+ 1 n) k))
        (quotient n k))))

(define (fxarithmetic-shift-left n count)
  (* (expt 2 count) n))
;@
(define fxlength
  (letrec ((intlen (lambda (n tot)
                     (case n
                       ((0 -1) (fx+ 0 tot))
                       ((1 -2) (fx+ 1 tot))
                       ((2 3 -3 -4) (fx+ 2 tot))
                       ((4 5 6 7 -5 -6 -7 -8) (fx+ 3 tot))
                       (else (intlen (logical:ash-4 n) (fx+ 4 tot)))))))
    (lambda (n) (intlen n 0))))

(define fxbit-count
  (letrec ((logcnt (lambda (n tot)
                     (if (fxzero? n)
                         tot
                         (logcnt (quotient n 16)
                                 (fx+ (vector-ref
                                     '#(0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4)
                                     (modulo n 16))
                                    tot))))))
    (lambda (n)
      (cond ((fxnegative? n) (logcnt (fxnot n) 0))
            ((fxpositive? n) (logcnt n 0))
            (else 0)))))
