;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Fundies-PS-10) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require 2htdp/image)
(require 2htdp/universe)

;###############################
;#### Dragon Fractal        ####
;###############################

; A Direction (Dir) is a Symbol and is one of:
; - 'left
; - 'right
; - 'up
; - 'down

; Length of the line
(define LEN 5)

; Screen Size...
(define W 850)
(define H 850)
 
; rotate-dir : Dir -> Dir
(define (rotate-dir dir)
  (cond [(symbol=? dir 'left) 'down]
        [(symbol=? dir 'right) 'up]
        [(symbol=? dir 'up) 'left]
        [(symbol=? dir 'down) 'right]))

; rotate-dirs : [List-of Dir] -> [List-of Dir]
(define (rotate-dirs lodir)
  (map rotate-dir lodir))

; move-pos : Number Number Dir Number -> Posn
(define (move-pos x y dir amt)
  (cond [(symbol=? dir 'left) (make-posn (- x amt) y)]
        [(symbol=? dir 'right) (make-posn (+ x amt) y)]
        [(symbol=? dir 'up) (make-posn x (- y amt))]
        [(symbol=? dir 'down) (make-posn x (+ y amt))]))

; draw-dirs : [List-of Dir] Number Number Image -> Image
(define (draw-dirs lodir x y im)
  (cond [(empty? lodir) im]
        [else (local [(define newx (posn-x (move-pos x y (first lodir) LEN)))
                      (define newy (posn-y (move-pos x y (first lodir) LEN)))]
                     (draw-dirs (rest lodir) newx newy
                                (add-line im x y
                                          newx newy
                                          "black")))]))

; dragon : [List-of Dir] Number -> [List-of Dir]
; Compute the next iteration of the Jurassic Fractal, given a [List-of Dir]
;   and the number of iterations left.(check-expect (dragon '(down) 0) '(down))
(check-expect (dragon '(down) 1) '(down right))
(check-expect (dragon '(down) 2) '(down right up right))
(check-expect (dragon '(down) 3) '(down right up right up left up right))
(define (dragon lodir iter)
  (cond [(zero? iter) lodir]
        [else (dragon (append lodir
                              (reverse (rotate-dirs lodir)))
                      (sub1 iter))]))

; draw : World -> Image
(define (draw w)
  (local [(define lst (dragon '(down) w))]
    (draw-dirs lst (/ W 2) (/ H 2) (empty-scene W H))))
 
; key : World KeyEvent -> World
(define (key w ke)
  (cond [(key=? ke "up") (add1 w)]
        [(and (key=? ke "down") (> w 1))
         (sub1 w)]
        [else w]))
 
(big-bang 0
          (to-draw draw)
          (on-key key))

