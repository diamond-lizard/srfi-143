(module srfi-143 ()
  (import scheme)
  (import (chicken base))
  (import (chicken module))
  (import (chicken platform))
  (import (chicken module))

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

  (register-feature! 'srfi-143)

  (include "srfi-143/rubber-chicken.scm"))
