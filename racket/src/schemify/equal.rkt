#lang racket/base
(require "wrap.rkt"
         "match.rkt")

;; Since a Racket `equal?` will shadow the host Scheme's `equal?`,
;; its optimizer won't be able to reduce `equal?` to `eq?` or `eqv?`
;; with obvious arguments. So, we perform that conversion in schemify.

(provide equal-implies-eq?
         equal-implies-eqv?)

(define (equal-implies-eq? e)
  (match e
    [`(quote ,val)
     (let ([val (unwrap val)])
       (or (symbol? val)
           (keyword? val)
           (boolean-or-fixnum? val)))]
    [`,val
     (let ([val (unwrap val)])
       ;; Booleans and numbers don't have to be quuted
       (boolean-or-fixnum? val))]))

(define (boolean-or-fixnum? val)
  (boolean? val)
  (and (integer? val)
       (exact? val)
       ;; Always fixnum? Conversatively...
       (<= (- (expt 2 16)) val (expt 2 16))))

(define (equal-implies-eqv? e)
  (match e
    [`(quote ,val)
     (let ([val (unwrap val)])
       (or (number? val)
           (char? val)))]
    [`,val
     (let ([val (unwrap val)])
       (number? val))]))
