#lang racket

;; this used to be the interactive test runner, but now it's just a few
;; utility functions. I could probably merge this with ... test-engine?
;; not today, though.

(require "test-engine.rkt"
         "test-cases.rkt"
         
         ;; for xml testing:
         ;; mzlib/class
         ;; (all-except xml/xml-snipclass snip-class)
         ;; (all-except xml/scheme-snipclass snip-class)
         ;; mred
         )

;; no point in testing this file
(module* test racket/base)

(provide run-test run-tests run-all-tests run-all-tests-except)

(define legal-last-steps '(finished-stepping before-error error))

;; make sure that the test ends with an error or finished stepping
(define (check-final-step name steps)
  (when (empty? steps)
    (raise-argument-error 'check-final-step
                          (format "nonempty list for test ~v" name)
                          0 steps))
  (define tag-of-last-step (first (last steps)))
  (when (not (member tag-of-last-step legal-last-steps))
    (raise-argument-error
     'check-final-step
     (format
      "sequence of steps ending legally for test ~v"
      name)
     0 steps)))

;; add all the tests imported from the test cases file(s):
(define list-of-tests
  (for/list ([test-spec (in-list the-test-cases)])
    (match test-spec
      [(list name models string expected-steps extra-files)
       (define models-list
         (cond [(list? models) models]
               [else (list models)]))
       (check-final-step name expected-steps)
       (list name (stepper-test models-list string expected-steps extra-files))])))

;; run a test : (list symbol test-thunk) -> boolean
;; run the named test, return #t if a failure occurred during the test
(define (run-one-test/helper test-pair)
  (run-one-test (car test-pair) (cadr test-pair)))

(define (run-all-tests)
  (andmap/no-shortcut 
   run-one-test/helper
   list-of-tests))

(define (run-all-tests-except nix-list)
  (define reduced-list
    (filter (lambda (pr) (not (member (car pr) nix-list)))
            list-of-tests))
  (define num-tests-removed
    (- (length list-of-tests)
       (length reduced-list)))
  (unless (= num-tests-removed (length nix-list))
    (raise-argument-error 'run-all-tests-except
                          "list of test names each occurring once in list of tests"
                          0 nix-list))
  (andmap/no-shortcut 
   run-one-test/helper
   reduced-list))

;; given the name of a test, look it up and run it
(define (run-test name)
  (match (filter (lambda (test) (eq? (first test) name)) list-of-tests)
    [(list) (error 'run-test "test not found: ~.s" name)]
    [(list t) (run-one-test/helper t)]
    [other (error 'run-test "more than one test found with name ~a" name)]))

(define (run-tests names)
  (ormap/no-shortcut run-test names))


;; like an ormap, but without short-cutting
(define (ormap/no-shortcut f args)
  (foldl (lambda (a b) (or a b)) #f (map f args)))

(define (andmap/no-shortcut f args)
  (foldl (lambda (a b) (and a b)) #t (map f args)))



