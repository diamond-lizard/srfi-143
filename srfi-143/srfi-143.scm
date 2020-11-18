;;;; Chicken module for SRFI 143

(module srfi-143 ()

  (import scheme)
  (import (chicken module))
  (import (rename (chicken base) (exact-integer-sqrt fxsqrt)))

  (export fx-width fx-greatest fx-least)
  (export fixnum? fx=? fx<? fx>? fx<=? fx>=?
          fxzero? fxpositive? fxnegative?
          fxodd? fxeven? fxmax fxmin)
  (export fx+ fx- fxneg fx* fxquotient fxremainder
          fxabs fxsquare fxsqrt)
  (export fx+/carry fx-/carry fx*/carry)
  (export fxnot fxand fxior fxxor fxarithmetic-shift
          fxarithmetic-shift-left fxarithmetic-shift-right
          fxbit-count fxlength fxif fxbit-set? fxcopy-bit
          fxfirst-set-bit fxbit-field
          fxbit-field-rotate fxbit-field-reverse)

  (import (only (chicken bitwise) bit->boolean))
  (import (rename (only (chicken fixnum)
                        fxmax fxmin fx= fx< fx> fx<= fx>= fx/ fxlen fxrem
                        fxshl fxshr fixnum-bits
                        most-positive-fixnum most-negative-fixnum)
		  (fxmax chicken:fxmax)
		  (fxmin chicken:fxmin)
		  (fx= chicken:fx=)
		  (fx< chicken:fx<)
		  (fx> chicken:fx>)
		  (fx<= chicken:fx<=)
		  (fx>= chicken:fx>=)
		  (fx/ fxquotient)
                  (fxlen fxlength)
		  (fxrem fxremainder)
                  (fxshl fxarithmetic-shift-left)
                  (fxshr fxarithmetic-shift-right)
		  (fixnum-bits fx-width)
		  (most-positive-fixnum fx-greatest)
		  (most-negative-fixnum fx-least)))
  (import (only (chicken base) fixnum?))
  (import (only (chicken fixnum) fx+ fx- fx* fxneg fxand fxior fxxor
                        fxnot fxodd? fxeven?))

  ;; Core functions not available in Chicken

  (define (logical:ash-4 x)
    (if (negative? x)
        (+ -1 (quotient (+ 1 x) 16))
        (quotient x 16)))

  (define fxbit-count
    (letrec ((logcnt (lambda (n tot)
                       (if (fxzero? n)
                           tot
                           (logcnt (fxquotient n 16)
                                   (fx+ (vector-ref
                                       '#(0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4)
                                       (fxremainder n 16))
                                      tot))))))
      (lambda (n)
        (cond ((fxnegative? n) (logcnt (fxnot n) 0))
              ((fxpositive? n) (logcnt n 0))
              (else 0)))))

  (include "srfi-143/carries.scm")
  (include "srfi-143/srfi-143-impl.scm")
)
