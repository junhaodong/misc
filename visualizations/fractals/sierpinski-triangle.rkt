;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Fundies-PS-10) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

; Sidelength of the smallest triangle
(define LEN 4)
(define small-triangle (triangle LEN 'outline 'red))
 
; sierpinski-tri : Number -> Image
(check-expect (sierpinski-tri LEN) small-triangle)
(check-expect (sierpinski-tri (* 2 LEN))
              (above small-triangle
                     (beside small-triangle
                             small-triangle)))
(define (sierpinski-tri side)
  (cond [(<= side LEN) (triangle side 'outline 'red)]
        [else (local ((define half-sized (sierpinski-tri (/ side 2))))
                     (above half-sized
                            (beside half-sized
                                    half-sized)))]))
(big-bang 512
          (to-draw sierpinski-tri))
