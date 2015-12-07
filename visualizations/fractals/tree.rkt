;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Fundies-PS-10) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

(define W 400)
(define H 400)
(define BG (empty-scene W H))

; put-line : Number Number Number Number String Scene -> Scene
; Put a line in the scene starting at (x,y) len distance in the given direction
;   with the given color
(define (put-line x y ang len color scn)
  (place-image (line (* (cos ang) len)
                     (* (sin ang) len) color)
               (+ x (* (cos ang) (/ len 2)))
               (+ y (* (sin ang) (/ len 2))) scn))

; tree : Number Number Number Number Scene -> Scene
; Draws a tree onto the given scene.
; If the length is less than 3, draws a single line
;   onto the scene.
; `ang1` and `ang2` subject to change -- try (/ pi 3)
(define (tree x y ang len scn)
  (cond [(< len 3) (put-line x y ang len "green" scn)]
        [else (local [(define x1 (+ x (* (/ len 3) (cos ang))))
                      (define y1 (+ y (* (/ len 3) (sin ang))))
                      (define ang1 (+ ang (/ pi 6)))
                      (define x2 (+ x (* 2 (/ len 3) (cos ang))))
                      (define y2 (+ y (* 2 (/ len 3) (sin ang))))
                      (define ang2 (- ang (/ pi 6)))
                      (define newLen (* 2 (/ len 3)))]
                     (put-line x y
                               ang len
                               "brown" 
                               (tree x1 y1 ang1 newLen
                                     (tree x2 y2 ang2 newLen
                                           scn))))]))

(define myTree (lambda (len) 
                 (tree (/ W 2) H (* pi 1.5) len BG)))
(big-bang 200
          (to-draw myTree))
