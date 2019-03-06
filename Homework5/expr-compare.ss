#lang racket
;;Part1
;;Lambda helpers
(define lambda-boi (string->symbol "\u03BB"))
;;Replace lambda with symbol
(define (switchme x y)
  (if (or (equal? x lambda-boi) (equal? y lambda-boi)) lambda-boi 'lambda))

(define (toString x) (symbol->string x))
;;(define (quoteCheck))
(define (baby-food x y)
  (cond
    [(equal? x y) x]
    [(and (boolean? x) (boolean? y) (equal? x #t)) '%]
    [(and (boolean? x) (boolean? y) (equal? y #t)) '(not %)]
    [else (quasiquote(if % (unquote x) (unquote y)))]
  )
)

(define (real-food x y)
  (cond
    [(and (equal? x '()) (equal? y '())) '()]
    [(and (and (symbol? (car x)) (symbol? (car y))) (xor (equal? (toString(car x)) "if") (equal? (toString(car y)) "if"))) (quasiquote(if % (unquote x) (unquote y)))]
    [(and (symbol? (car x)) (symbol? (car y)) (and (equal? (toString(car x)) "quote") (equal? (toString(car y)) "quote"))) (if (equal? (cdr x) (cdr y)) x (quasiquote(if % '(unquote(cdr x)) '(unquote(cdr y)))))]
    [(and (equal? (cdr x) '()) (not(equal? (cdr y) '()))) (quasiquote(if % (unquote x) (unquote y)))]
    [(and (equal? (cdr y) '()) (not(equal? (cdr x) '()))) (quasiquote(if % (unquote x) (unquote y)))]
    [(and (list? (car x)) (list? (car y))) (cons (real-food (car x) (car y)) (real-food (cdr x) (cdr y)))]
    ;;lambda cases
    [()]
    [(list? (car x)) (cons (quasiquote(if % (unquote(car x)) (unquote(car y)))) (real-food (cdr x) (cdr y)))]
    [(list? (car y)) (cons (quasiquote(if % (unquote(car x)) (unquote(car y)))) (real-food (cdr x) (cdr y)))]
    [(equal? (car x) (car y)) (cons (car x) (real-food (cdr x) (cdr y)))]
    [else (cons (quasiquote(if % (unquote(car x)) (unquote(car y)))) (real-food (cdr x) (cdr y)))]
  )
)
(define (expr-compare x y)
  (cond
    ;;Handles the list cases
    [(and (list? x) (list? y)) (real-food x y)]
    ;;If one is a list
    [(xor (list? x) (list? y)) (quasiquote(if % (unquote x) (unquote y)))]
    ;;Handles the easy cases
    [else(baby-food x y)]
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