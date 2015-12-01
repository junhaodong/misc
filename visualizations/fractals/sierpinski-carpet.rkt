;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Fundies-PS-10) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

; Sidelength of the smallest square
(define LEN 2)

(define small-square (square LEN "solid" "black"))

; sierpinski-carpet : Number -> Image
(define (sierpinski-carpet side)
  (cond [(< side LEN) small-square]
        [else (local [(define c (sierpinski-carpet (- side LEN)))
                      (define o (square (image-width c) "solid" "white"))]
                     (above (beside c c c)
                            (beside c o c)
                            (beside c c c)))]))

(big-bang 10
          (to-draw sierpinski-carpet))
