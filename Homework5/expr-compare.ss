#lang racket
;;Part1
(define (expr-compare x y)
  ;;Handles easy cases
  (cond
    [(equal? x y) x]
    [(and (boolean? x) (boolean? y) (equal? x #t)) '(%)]
    [(and (boolean? x) (boolean? y) (equal? y #t)) '(not %)]
  )
  ;;Handles the list cases
  (cond
    ["Fugma"]
  )
)

;;Part2
(define (test-expr-compare x y)
  (if
   ;;test
   (and
    (equal? (eval x) ("Bind % to #t"))
    (equal? (eval y) ("Bind % to #f"))
   )
   ;;then
   (#t)
   ;;else
   (#f))
)

;;Part 3
(define (test-expr-x) '(list a ((lambda (a) (a + 42)) 5) c))
(define (test-expr-y) '(+ ((lambda (x y) (x - y)) 97 69) 99))