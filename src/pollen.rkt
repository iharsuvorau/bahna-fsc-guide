#lang racket/base

(require 
	pollen/core
    pollen/decode
    pollen/setup
    racket/date
    racket/list
    racket/match
    racket/path
    racket/string
    (only-in srfi/13 string-contains)
    txexpr)

(provide (all-defined-out))

(module setup racket/base
	(provide (all-defined-out))
	(define poly-targets '(html ltx pdf)))

(define (root . elements)
  (case (current-poly-target)
    [(ltx pdf)
     (define first-pass (decode-elements elements
                                         #:inline-txexpr-proc (compose1 txt-decode hyperlink-decoder)
                                         #:string-proc (compose1 ltx-escape-str smart-quotes smart-dashes)
                                         #:exclude-tags '(script style figure txt-noescape)))
     (make-txexpr 'body null (decode-elements first-pass #:inline-txexpr-proc txt-decode))]

    [else
      (define first-pass (decode-elements elements
                                          #:txexpr-elements-proc decode-paragraphs
                                          #:exclude-tags '(script style figure)))
      (make-txexpr 'body null
                   (decode-elements first-pass
                                    #:block-txexpr-proc detect-newthoughts
                                    #:inline-txexpr-proc hyperlink-decoder
                                    #:string-proc (compose1 smart-quotes smart-dashes)
                                    #:exclude-tags '(script style)))]))

(define (heading . elements)
	(case (current-poly-target)
		[(ltx pdf) (apply string-append `("\\section{" ,@elements "}"))]
		[else (txexpr 'h2 empty elements)]))

(define (em . elements)
	(case (current-poly-target)
		[(ltx pdf) (apply string-append `("\\textit{" ,@elements "}"))]
		[else (txexpr 'em empty elements)]))

; Escape $,%,# and & for LaTeX
; The approach here is rather indiscriminate; I’ll probably have to change
; it once I get around to handline inline math, etc.
(define (ltx-escape-str str)
  (regexp-replace* #px"([$#%&])" str "\\\\\\1"))

#|
`txt` is called by root when targeting LaTeX/PDF. It converts all elements inside
a ◊txt tag into a single concatenated string. ◊txt is not intended to be used in
normal markup; its sole purpose is to allow other tag functions to return LaTeX
code as a valid X-expression rather than as a string.
|#
(define (txt-decode xs)
    (if (member (get-tag xs) '(txt txt-noescape))
        (get-elements xs)
        xs))

(define (hyperlink-decoder inline-tx)
  (define (hyperlinker url . words)
    (case (current-poly-target)
      [(ltx pdf) `(txt "\\href{" ,url "}" "{" ,@words "}")]
      [else `(a [[href ,url]] ,@words)]))
  (if (eq? 'hyperlink (get-tag inline-tx))
      (apply hyperlinker (get-elements inline-tx))
      inline-tx))

#|
detect-newthoughts: called by root above when targeting HTML.
The ◊newthought tag (defined further below) makes use of the \newthought
command in Tufte-LaTeX and the .newthought CSS style in Tufte-CSS to start a
new section with some words in small caps. In LaTeX, this command additionally
adds some vertical spacing in front of the enclosing paragraph. There is no way
to do this in HTML/CSS without adding in some Javascript: i.e., there is no
CSS selector for “p tags that contain a span of class ‘newthought’”. So we can
handle it at the Pollen processing level.
|#
(define (detect-newthoughts block-xpr)
  (define is-newthought? (λ(x) (and (txexpr? x)
                                    (eq? 'span (get-tag x))
                                    (attrs-have-key? x 'class)
                                    (string=? "newthought" (attr-ref x 'class)))))
  (if (and(eq? (get-tag block-xpr) 'p)             ; Is it a <p> tag?
          (findf-txexpr block-xpr is-newthought?)) ; Does it contain a <span class="newthought">?
      (attr-set block-xpr 'class "pause-before")   ; Add the ‘pause-before’ class
      block-xpr))                                  ; Otherwise return it unmodified
