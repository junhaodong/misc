;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname |Fundies PS 7|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require 2htdp/image)
(require 2htdp/universe)

;;;; CONSTANTS

(define WIDTH 300)
(define HEIGHT 300)
(define BG (empty-scene WIDTH HEIGHT))

(define CLOSE (/ HEIGHT 2))

(define T-WIDTH (/ WIDTH 8))
(define T-HEIGHT (/ HEIGHT 30))
(define T-Y (- HEIGHT (/ T-HEIGHT 2)))
(define TANK (rectangle T-WIDTH T-HEIGHT "solid" "blue"))

(define UFO (overlay (ellipse (/ T-WIDTH 1.5) (/ T-WIDTH 6) "solid" "black")
                     (ellipse (/ T-WIDTH 2.5) (/ T-WIDTH 3.5) "solid" "green")))
(define UFO-WIDTH (image-width UFO))
(define UFO-HEIGHT (image-height UFO))
(define UFO-SPEED 2)
(define HITBOX 5)

(define MISSILE (polygon (list (make-posn 0 0)
                               (make-posn (/ T-WIDTH 6)
                                          (/ T-WIDTH -4))
                               (make-posn (/ T-WIDTH 4) 0)
                               (make-posn (/ T-WIDTH 6)
                                          (/ T-WIDTH -6)))
                         "solid"
                         "red"))
(define MISSILE-SPEED 1)

;;;; DATA DEFINITIONS

(define-struct tank [loc vel])
;; A Tank is (make-tank Number Number).
;; interpretation: (make-tank x dx) means the tank is at position
;; (x, HEIGHT) and that it moves dx pixels per clock tick 

;; A UFO is Posn. 
;; interpretation: (make-posn x y) is the UFO's current location 

;; A Missile is Posn. 
;; interpretation: (make-posn x y) is the missile's current location 

;; A LOM [List-of-Missiles] is one of: 
;; – '()
;; – (cons Missile LOM)
;; interpretation: the collection of missiles fired and moving straight up

(define-struct SIGS [ufo tank missiles])
;; A SIGS is a (make-SIGS UFO Tank LOM)
;; interpretation: represents the state of the space invader game 

;;;; BIG-BANG

;; SIGS -> SIGS
(define (main state)
  (big-bang state
            [on-tick update ]
            [to-draw render]
            [on-key keyHandler]
            [stop-when end?]))

;;;; MOVING

;; SIGS -> SIGS
;; updates the game state
(define (update state)
  (make-SIGS (update-ufo (SIGS-ufo state))
             (SIGS-tank state)
             (update-lom (SIGS-missiles state))))

;; UFO -> UFO
(define (update-ufo a-ufo)
  (make-posn (posn-x a-ufo)
             (+ (posn-y a-ufo) UFO-SPEED)))

;; LOM -> LOM
(define (update-lom alom)
  (cond [(empty? alom) empty]
        [else (cons (update-missile (first alom))
                    (update-lom (rest alom)))]))

;; Missile -> Missile
(define (update-missile a-missile)
  (make-posn (posn-x a-missile)
             (- (posn-y a-missile) MISSILE-SPEED)))

;;;; RENDERING

;; SIGS -> Image
(define (render state)
  (tank-render (SIGS-tank state)
               (ufo-render (SIGS-ufo state)
                           (lom-render (SIGS-missiles state)
                                       BG))))

; Tank Image -> Image 
; adds t to the given image im
(define (tank-render a-tank image)
  (place-image TANK
               (tank-loc a-tank)
               T-Y
               image))
 
; UFO Image -> Image 
; adds u to the given image im
(define (ufo-render a-ufo image)
  (place-image UFO
               (posn-x a-ufo)
               (posn-y a-ufo)
               image))

;; LOM Image -> Image
(define (lom-render alom image)
  (cond [(empty? alom) image]
        [else (missile-render (first alom)
                              (lom-render (rest alom)
                                          image))]))

; Missile Image -> Image 
; adds m to the given image im
(define (missile-render a-missile image)
  (place-image MISSILE
               (posn-x a-missile)
               (posn-y a-missile)
               image))

;;;; KEYHANDLER

(define (add-missile state)
  (make-SIGS (SIGS-ufo state)
             (SIGS-tank state)
             (cons (new-missile state)
                   (SIGS-missiles state))))

;; SIGS -> Missile
(define (new-missile state)
  (make-posn (tank-loc (SIGS-tank state))
             (- HEIGHT T-HEIGHT)))
             
;; Op SIGS -> SIGS
;; moves the tank
(define (move op state)
  (make-SIGS (SIGS-ufo state)
             (move-tank op (SIGS-tank state))
             (SIGS-missiles state)))

;; Op Tank -> Tank
(define (move-tank op a-tank)
  (make-tank (op (tank-loc a-tank) (tank-vel a-tank))
             (tank-vel a-tank)))

;; SIGS KeyEvent -> SIGS
(define (keyHandler state ke)
  (cond [(key=? ke " ") (add-missile state)]
        [(key=? ke "left") (move - state)]
        [(key=? ke "right") (move + state)]
        [else state]))

;;;; STOPPED

;; SIGS -> Boolean
;; returns true if the UFO has landed or been shot
(define (end? state)
  (or (landed? (SIGS-ufo state))
      (won? (SIGS-ufo state)
            (SIGS-missiles state))))

(define (landed? a-ufo)
  (>= (posn-y a-ufo)
      (- HEIGHT (/ UFO-HEIGHT 2))))

(define (won? a-ufo alom)
  (cond [(empty? alom) false]
        [else (or (in-range? a-ufo (first alom))
                  (won? a-ufo (rest alom)))]))

(define (in-range? a-ufo a-missile)
  (and (in-height-range? a-ufo a-missile)
       (in-width-range? a-ufo a-missile)))

(define (in-height-range? a-ufo a-missile)
  (<= (- (posn-y a-ufo) (/ UFO-HEIGHT 2))
      (posn-y a-missile)
      (+ (posn-y a-ufo) (/ UFO-HEIGHT 2))))

(define (in-width-range? a-ufo a-missile)
  (<= (- (posn-x a-ufo) (/ UFO-WIDTH 2))
      (posn-x a-missile)
      (+ (posn-x a-ufo) (/ UFO-WIDTH 2))))

(define world1 (make-SIGS (make-posn (+ (random (floor (- WIDTH (/ UFO-WIDTH 2))))
                                        (/ UFO-HEIGHT 2))
                                     (/ UFO-HEIGHT 2))
                          (make-tank (/ WIDTH 2) 5)
                          empty))

(main world1)

