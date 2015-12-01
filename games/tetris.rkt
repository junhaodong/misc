;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Fundies-PS-8) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require 2htdp/image)
(require 2htdp/universe)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Direction is one of:
;; - "none"
;; - "left"
;; - "right"
;; - "down"

;; A Block is a (make-block Number Number Color)
;; (x,y) are coordinates in a plane where (0,0)
;; is the top left corner. 
(define-struct block (x y color))
 
;; A Tetra is a (make-tetra Posn BSet)
;; The center point is the point around which the tetra (a set of blocks)
;; rotates when it spins.
;; A Tetra is one of:
;; - O-tetra
;; - I-tetra
;; - L-tetra
;; - J-tetra
;; - T-tetra
;; - S-tetra
;; - Z-tetra
(define-struct tetra (center blocks))

;; A Set of Blocks (BSet) is one of:
;; - empty
;; - (cons Block BSet)
;; Order does not matter.

;; A World is a (make-world Tetra BSet)
;; The BSet represents the pile of blocks at the bottom of the screen.
(define-struct world (tetra pile))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define SIDELEN 10)
(define WIDTH (* 10 SIDELEN))
(define HEIGHT (* 20 SIDELEN))
(define BG (empty-scene WIDTH HEIGHT))

(define CENTER-X (/ WIDTH 2))

;; The four possible initial x-coordinates of a block
(define X0 (- CENTER-X SIDELEN SIDELEN))
(define X1 (- CENTER-X SIDELEN))
(define X2 CENTER-X)
(define X3 (+ CENTER-X SIDELEN))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tetra
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define O-bset (list (make-block X1 0       "green")
                     (make-block X1 SIDELEN "green")
                     (make-block X2 0       "green")
                     (make-block X2 SIDELEN "green")))
(define O-tetra (make-tetra (make-posn (/ (+ X1 X2) 2) (/ SIDELEN 2)) O-bset))

(define I-bset (list (make-block X0 0 "blue")
                     (make-block X1 0 "blue")
                     (make-block X2 0 "blue")
                     (make-block X3 0 "blue")))
(define I-tetra (make-tetra (make-posn CENTER-X 0) I-bset))

(define L-bset (list (make-block X1 SIDELEN "purple")
                     (make-block X2 SIDELEN "purple")
                     (make-block X3 0       "purple")
                     (make-block X3 SIDELEN "purple")))
(define L-tetra (make-tetra (make-posn X3 SIDELEN) L-bset))

(define J-bset (list (make-block X1 0       "aqua")
                     (make-block X1 SIDELEN "aqua")
                     (make-block X2 SIDELEN "aqua")
                     (make-block X3 SIDELEN "aqua")))
(define J-tetra (make-tetra (make-posn X1 SIDELEN) J-bset))

(define T-bset (list (make-block X1 SIDELEN "orange")
                     (make-block X2 0       "orange")
                     (make-block X2 SIDELEN "orange")
                     (make-block X3 SIDELEN "orange")))
(define T-tetra (make-tetra (make-posn CENTER-X SIDELEN) T-bset))

(define Z-bset (list (make-block X1 0       "pink")
                     (make-block X2 0       "pink")
                     (make-block X2 SIDELEN "pink")
                     (make-block X3 SIDELEN "pink")))
(define Z-tetra (make-tetra (make-posn CENTER-X 0) Z-bset))

(define S-bset (list (make-block X1 SIDELEN "red")
                     (make-block X2 0       "red")
                     (make-block X2 SIDELEN "red")
                     (make-block X3 0       "red")))
(define S-tetra (make-tetra (make-posn CENTER-X SIDELEN) S-bset))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rendering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; draw-world : World -> Image
;; Draws the world, including the falling tetra
;; and the pile of tetra on the bottom of the screen.
(check-expect (draw-world testWorld)
              (draw-bset (tetra-blocks (world-tetra testWorld))
                         (draw-bset (world-pile testWorld) BG)))
(define (draw-world aworld)
  (draw-bset (tetra-blocks (world-tetra aworld))
             (draw-bset (world-pile aworld)
                        BG)))

;; draw-bset : BSet Image -> Image
;; Draws all the blocks in a given BSet onto an Image
(check-expect (draw-bset (tetra-blocks T-tetra) BG)
              (draw-block 
               (make-block X1 SIDELEN "orange")
               (draw-block
                (make-block X2 0 "orange")
                (draw-block
                 (make-block X2 SIDELEN"orange")
                 (draw-block
                  (make-block X3 SIDELEN "orange") BG)))))
(define (draw-bset a-bset bg)
  (foldr (λ(a-block im) (draw-block a-block im)) bg a-bset))

;; draw-block : Block Image -> Image
;; Draws a single block onto an Image
(check-expect (draw-block (make-block X2 SIDELEN "red") BG)
              (place-image (overlay 
                            (square SIDELEN "outline" "black")
                            (square SIDELEN "solid" "red"))
                           45 5
                           BG))
(define (draw-block a-block bg)
  (place-image (overlay 
                (square SIDELEN "outline" "black")
                (square SIDELEN "solid" (block-color a-block)))
               (- (block-x a-block) (/ SIDELEN 2))
               (- (block-y a-block) (/ SIDELEN 2))
               bg))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tock (Updating the World)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; tock : World -> World
;; Increases the y-coordinate of the tetra by SIDELEN every tick
(check-random (tock (make-world (make-tetra (make-posn CENTER-X SIDELEN)
                                            (list (make-block X1 200 "red")
                                                  (make-block X2 300 "red")
                                                  (make-block X2 250 "red")
                                                  (make-block X3 210 "red")))
                                (world-pile testWorld)))
              (make-world (create-tetra (random 7)) 
                          (list (make-block X1 200 "red")
                                (make-block X2 300 "red")
                                (make-block X2 250 "red")
                                (make-block X3 210 "red"))))
(define (tock aworld)
  (if (can-move? aworld "down")
      (world-shift aworld "down")
      (new-world aworld)))


;; new-world : World -> World
;; Makes a new world after a Tetra has hit the bottom and froze.
(check-random (new-world testWorld)
              (make-world (create-tetra (random 7)) I-bset))
(define (new-world aworld)
  (make-world (create-tetra (random 7))
              (clear-all-rows (add-to-pile aworld) SIDELEN)))

;; create-tetra : Number -> Tetra
;; creates tetra
(check-expect (create-tetra 7) O-tetra)
(check-expect (create-tetra 0) O-tetra)
(check-expect (create-tetra 1) I-tetra)
(check-expect (create-tetra 2) L-tetra)
(check-expect (create-tetra 3) J-tetra)
(check-expect (create-tetra 4) T-tetra)
(check-expect (create-tetra 5) Z-tetra)
(check-expect (create-tetra 6) S-tetra)
(define (create-tetra n)
  (cond [(= n 0) O-tetra]
        [(= n 1) I-tetra]
        [(= n 2) L-tetra]
        [(= n 3) J-tetra]
        [(= n 4) T-tetra]
        [(= n 5) Z-tetra]
        [(= n 6) S-tetra]
        [else (create-tetra (modulo n 7))]))

;; add-to-pile : World -> BSet
;; Adds the Tetra to the Pile of the World
(check-expect (add-to-pile testWorld) I-bset)
(define (add-to-pile aworld)
  (combine-bsets (tetra-blocks (world-tetra aworld))
                 (world-pile aworld)))

;; combine-bsets : Bset Bset -> Bset
;; combines bsets into one bset
(check-expect (combine-bsets (list (make-block X1 200 "red"))
                             (list (make-block X2 300 "red")))
              (list (make-block X1 200 "red")
                    (make-block X2 300 "red")))
(define (combine-bsets bs1 bs2)
  (foldr cons bs2 bs1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Predicates 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; can-move?: World Direction -> Boolean
;; returns true if the BSET has room to move and 
;; and if it's not on the bottom
(check-expect (can-move? testWorld "right") true)
(check-expect (can-move? (make-world
                          (make-tetra (make-posn CENTER-X SIDELEN)
                                      (list (make-block 0 0  "red")
                                            (make-block 0 10 "red")
                                            (make-block 0 20 "red")
                                            (make-block 0 30 "red")))
                          empty)
                         "left") 
              false)
(define (can-move? aworld dir)
  (and (bset-in-canvas? (tetra-blocks (world-tetra aworld)) dir)
       (not (tetra-collided? aworld dir))))

;; bset-in-canvas?: BSet Direction -> Boolean
;; returns true if all of the blocks in the bset
;; are in the canvas after being moved in the direction dir
(check-expect (bset-in-canvas? O-bset "left")
              true)
(check-expect (bset-in-canvas? (list (make-block 0 SIDELEN "red")
                                      (make-block 10 0       "red")
                                      (make-block 10 SIDELEN "red")
                                      (make-block 20 0       "red")) "left")
              false)
(check-expect (bset-in-canvas? I-bset "right") 
              true)
(check-expect (bset-in-canvas? (list (make-block 90 SIDELEN "red")
                                     (make-block 100 0       "red")
                                     (make-block 100 SIDELEN "red")
                                     (make-block 110 0       "red")) "right")
              false)
(check-expect (bset-in-canvas? I-bset "down") 
              true)
(check-expect (bset-in-canvas? (list (make-block X1 200 "red")
                                     (make-block X2 300 "red")
                                     (make-block X2 250 "red")
                                     (make-block X3 210 "red")) "down")
              false)
(define (bset-in-canvas? a-bset dir)
    (andmap (λ(a-block) (block-in-canvas? a-block dir)) a-bset))

;; block-in-canvas? : Block Direction -> Boolean
;; returns true if the block would be in the canvas after
;; being shifted in the given direction
(check-expect (block-in-canvas? (make-block 40 40 "orange") "left") true)
(check-expect (block-in-canvas? (make-block 0 10 "orange") "left") false)
(check-expect (block-in-canvas? (make-block 70 100 "red") "right") true)
(check-expect (block-in-canvas? (make-block 110 10 "red") "right") false)
(check-expect (block-in-canvas? (make-block 70 10 "red") "down") true)
(check-expect (block-in-canvas? (make-block 110 210 "red") "down") false)
(check-expect (block-in-canvas? (make-block 70 10 "red") "none") true)
(check-expect (block-in-canvas? (make-block 110 210 "red") "none") false)
(define (block-in-canvas? a-block dir)
  (local [(define X (block-x a-block))
          (define Y (block-y a-block))
          (define C (block-color a-block))]
         (in-canvas? 
          (cond [(string=? dir "none")
                 a-block]
                 [(string=? dir "left") 
                 (make-block (- X (* 1.5 SIDELEN)) Y C)]
                 [(string=? dir "right")
                   (make-block (+ X (* 0.5 SIDELEN)) Y C)]
                 [(string=? dir "down")
                    (make-block X (+ Y SIDELEN) C)]))))

;; all-in-canvas? : Bset -> Boolean
;; checks if the bset is in the canvas
(check-expect (all-in-canvas? (list (make-block 70 80 "red")
                                    (make-block 50 60 "blue"))) true)
(check-expect (all-in-canvas? (list (make-block 70 80 "red")
                                    (make-block 100 220 "blue"))) false)
(define (all-in-canvas? a-bset)
  (andmap in-canvas? a-bset))

;; in-canvas? : Block -> Boolean
;; returns true if the block is in the canvas
(check-expect (in-canvas? (make-block 70 80 "red")) true)
(check-expect (in-canvas? (make-block 70 291 "red")) false)
(define (in-canvas? a-block)
  (and (<= (/ SIDELEN 2) (block-x a-block) WIDTH) 
       (<= (- 0 SIDELEN) (block-y a-block) HEIGHT)))


;; tetra-collided? : World Direction -> Boolean
;; Checks if the world's tetra collided with the world's pile
(check-expect (tetra-collided? (make-world T-tetra T-bset) "down") true)
(check-expect (tetra-collided? testWorld "down") false)
(define (tetra-collided? aworld dir)
  (bset-collided? (bset-shift (tetra-blocks (world-tetra aworld)) dir)
                  (world-pile aworld)))

;; bset-collided? : BSet BSet -> Boolean
;; Checks if any of the blocks in bs1 are in bs2
(check-expect (bset-collided? T-bset I-bset) true)
(check-expect (bset-collided? (list (make-block X2 210 "red")
                                    (make-block X2 300 "red")
                                    (make-block X2 250 "red")
                                    (make-block 0 200 "red"))
                              (list (make-block X1 200 "red")
                                    (make-block X3 400 "red")
                                    (make-block X3 420 "red")
                                    (make-block X3 430 "red"))) false)
(define (bset-collided? bs1 bs2)
    (ormap (λ(a-block) (bset-contains? a-block bs2)) bs1))

;; bset-contains? : Block BSet -> Boolean
;; Returns whether or not a-block is in a-bset
(check-expect (bset-contains? (make-block X0 0 "blue") I-bset) true)
(check-expect (bset-contains? (make-block 0 200 "red") I-bset) false)
(define (bset-contains? a-block a-bset)
  (ormap (λ(a-block2) (block=? a-block a-block2)) a-bset))

;; block=? : Block Block -> boolean
;; checks if the block are equal
(check-expect (block=? (make-block 0 200 "red") (make-block 0 200 "blue")) true)
(check-expect (block=? (make-block 200 200 "red") (make-block 0 200 "blue")) false)
(define (block=? b1 b2)
  (and (= (block-x b1) (block-x b2))
       (= (block-y b1) (block-y b2))))

;; can-tetra-rot? : World String -> Boolean
;; dir is a string of either cw or ccw
(check-expect (can-tetra-rot? testWorld "cw") true)
(check-expect (can-tetra-rot? testWorld2 "ccw") true)
(define (can-tetra-rot? aworld dir)
  (local [(define rotated-tetra (tetra-rotate (world-tetra aworld) dir))]
         (and (all-in-canvas? (tetra-blocks rotated-tetra))
              (not (bset-collided? (tetra-blocks rotated-tetra)
                                   (world-pile aworld))))))
               
       

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Movement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-shift: World String-> World
;; creates a world with shifted tetra
;; restriction: dir String is one of "left", "right", "down" for the direction
(check-expect (world-shift testWorld "left")
              (make-world (tetra-shift (world-tetra testWorld) "left")
                          (world-pile testWorld)))
(check-expect (world-shift testWorld "right")
              (make-world (tetra-shift (world-tetra testWorld) "right")
                          (world-pile testWorld)))
(check-expect (world-shift testWorld3 "right")
              testWorld3)
(define (world-shift aworld dir)
  (local [(define shifted-tetra (tetra-shift (world-tetra aworld) dir))]
          (if (can-move? aworld dir)
              (make-world shifted-tetra
                          (world-pile aworld))
              aworld)))

;; tetra-shift : Tetra String -> Tetra
;; Creates a tetra that has been shifted to the left or right by SIDELEN
;; restriction: dir String is one of "left", "right", "down" for the direction
(check-expect (tetra-shift T-tetra "left")
              (make-tetra (center-shift (tetra-center T-tetra) "left")
                          (bset-shift (tetra-blocks T-tetra) "left")))
(check-expect (tetra-shift T-tetra "right")
              (make-tetra (center-shift (tetra-center T-tetra) "right")
                          (bset-shift (tetra-blocks T-tetra) "right")))
(check-expect (tetra-shift T-tetra "down")
              (make-tetra (center-shift (tetra-center T-tetra) "down")
                          (bset-shift (tetra-blocks T-tetra) "down")))
(define (tetra-shift atetra dir)
  (make-tetra (center-shift (tetra-center atetra) dir)
              (bset-shift (tetra-blocks atetra) dir)))

;; bset-shift : Bset Direction -> Bset
;; Shifts all the blocks in a bset by SIDELEN in the direcion of dir
(check-expect (bset-shift (tetra-blocks T-tetra) "left")
              (list (block-shift (make-block X1 SIDELEN "orange") "left")
                    (block-shift (make-block X2 0 "orange") "left")
                    (block-shift (make-block X2 SIDELEN "orange") "left")
                    (block-shift (make-block X3 SIDELEN "orange") "left")))
(check-expect (bset-shift (tetra-blocks T-tetra) "right")
              (list (block-shift (make-block X1 SIDELEN "orange") "right")
                    (block-shift (make-block X2 0 "orange") "right")
                    (block-shift (make-block X2 SIDELEN "orange") "right")
                    (block-shift (make-block X3 SIDELEN "orange") "right")))
(check-expect (bset-shift (tetra-blocks T-tetra) "down")
              (list (block-shift (make-block X1 SIDELEN "orange") "down")
                    (block-shift (make-block X2 0 "orange") "down")
                    (block-shift (make-block X2 SIDELEN "orange") "down")
                    (block-shift (make-block X3 SIDELEN "orange") "down")))
(define (bset-shift a-bset dir)
  (map (λ(a-block) (block-shift a-block dir)) a-bset))
                                                 
;; block-shift : Block Direction -> Block
;; Shifts the block by SIDELEN in the direcion of dir
(check-expect (block-shift (make-block X2 SIDELEN "red") "left")
              (make-block (- X2 SIDELEN) SIDELEN "red"))
(check-expect (block-shift (make-block X2 SIDELEN "red") "right")
              (make-block (+ X2 SIDELEN) SIDELEN "red"))
(check-expect (block-shift (make-block X2 SIDELEN "red") "down")
              (make-block X2 (+ SIDELEN SIDELEN) "red"))
(check-expect (block-shift (make-block X2 SIDELEN "red") "none")
              (make-block X2 SIDELEN "red"))
(define (block-shift a-block dir)
  (local [(define X (block-x a-block))
          (define Y (block-y a-block))
          (define C (block-color a-block))]
         (cond [(string=? dir "left") (make-block (- X SIDELEN) Y C)]
               [(string=? dir "right") (make-block (+ X SIDELEN) Y C)]
               [(string=? dir "down") (make-block X (+ Y SIDELEN) C)]
               [(string=? dir "none") a-block])))


;; center-shift : Posn Direction -> Posn
;; Shifts the center by SIDELEN in the direcion of dir
(check-expect (center-shift (make-posn 20 20) "left")
              (make-posn 10 20))
(check-expect (center-shift (make-posn 20 20) "right")
              (make-posn 30 20))
(check-expect (center-shift (make-posn 20 20) "down")
              (make-posn 20 30))
(check-expect (center-shift (make-posn 20 20) "none")
              (make-posn 20 20))
(define (center-shift a-center dir)
  (local [(define X (posn-x a-center))
          (define Y (posn-y a-center))]
         (cond [(string=? dir "left") (make-posn (- X SIDELEN) Y)]
               [(string=? dir "right") (make-posn (+ X SIDELEN) Y)]
               [(string=? dir "down") (make-posn X (+ Y SIDELEN))]
               [(string=? dir "none") a-center])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rotation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; rot: World String -> World
;; Rotates the world 90 degrees counterclockwise or clockwise
;; restriction: String can only be cw or ccw for the direction it rotates
(check-expect (rot testWorld "cw")
              (make-world (tetra-rotate (world-tetra testWorld) "cw")
                          (world-pile testWorld)))
(define (rot aworld dir)
  (if (can-tetra-rot? aworld dir)
      (make-world (tetra-rotate (world-tetra aworld) dir)
                  (world-pile aworld))
      aworld))

;; tetra-rotate : Tetra String-> Tetra
;; Rotates the tetra 90 degrees counterclockwise
;; restriction: String can only be cw or ccw for the direction it rotates
(check-expect (tetra-rotate T-tetra "ccw")
              (make-tetra (tetra-center T-tetra)
                          (bset-rotate (tetra-center T-tetra)
                                           (tetra-blocks T-tetra) "ccw")))
(check-expect (tetra-rotate T-tetra "cw")
              (make-tetra (tetra-center T-tetra)
                          (bset-rotate (tetra-center T-tetra)
                                           (tetra-blocks T-tetra) "cw")))
(define (tetra-rotate atetra dir)
  (make-tetra (tetra-center atetra)
              (bset-rotate (tetra-center atetra)
                           (tetra-blocks atetra)
                           dir)))

;; bset-rotate : Posn Bset String -> Bset
;; Rotates the bset 90 degrees counterclockwise around the posn.
;; restriction: String can only be cw or ccw for the direction it rotates
(check-expect (bset-rotate (tetra-center T-tetra) (tetra-blocks T-tetra) "ccw")
              (list (block-rotate (tetra-center T-tetra)
                                  (make-block X1 SIDELEN "orange") "ccw")
                    (block-rotate (tetra-center T-tetra)
                                  (make-block X2 0 "orange") "ccw")
                    (block-rotate (tetra-center T-tetra)
                                  (make-block X2 SIDELEN "orange") "ccw")
                    (block-rotate (tetra-center T-tetra)
                                  (make-block X3 SIDELEN "orange") "ccw")))
(check-expect (bset-rotate (tetra-center T-tetra) (tetra-blocks T-tetra) "cw")
              (list (block-rotate (tetra-center T-tetra)
                                  (make-block X1 SIDELEN "orange") "cw")
                    (block-rotate (tetra-center T-tetra)
                                  (make-block X2 0 "orange") "cw")
                    (block-rotate (tetra-center T-tetra)
                                  (make-block X2 SIDELEN "orange") "cw")
                    (block-rotate (tetra-center T-tetra)
                                  (make-block X3 SIDELEN "orange") "cw")))
(define (bset-rotate c a-bset dir)
  (map (λ(a-block) (block-rotate c a-block dir)) a-bset))

;; block-rotate : Posn Block String -> Block
;; Rotate the block 90 degrees counterclockwise or clockwise around the posn.
;; restriction: String can only be cw or ccw for the direction it rotates
(check-expect (block-rotate (tetra-center T-tetra)
                            (make-block X1 SIDELEN "orange") "ccw")
              (make-block (+ (posn-x (tetra-center T-tetra))
                             (- (posn-y (tetra-center T-tetra))
                                SIDELEN))
                          (+ (posn-y (tetra-center T-tetra))
                             (- X1 (posn-x (tetra-center T-tetra))))
                          "orange"))
(check-expect (block-rotate (tetra-center T-tetra) 
                            (make-block X1 SIDELEN "orange") "cw")
              (block-rotate (tetra-center T-tetra)
                            (block-rotate (tetra-center T-tetra)
                                          (block-rotate (tetra-center T-tetra)
                                                        (make-block X1 SIDELEN "orange")
                                                        "ccw")
                                          "ccw")
                            "ccw"))
(define (block-rotate c b dir)
  (if (string=? dir "ccw")
      (make-block (+ (posn-x c) 
                     (- (posn-y c) (block-y b)))
                  (+ (posn-y c) 
                     (- (block-x b) (posn-x c)))
                  (block-color b))
      (block-rotate c (block-rotate c (block-rotate c b "ccw") "ccw") "ccw")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Full Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; clear-all-rows: BSet Number -> Bset
;; clears all the full rows
(check-expect (clear-all-rows
               (list
                          (make-block 10 200 "blue")
                          (make-block 20 200 "blue")
                          (make-block 30 200 "blue")
                          (make-block 40 200 "blue")
                          (make-block 50 200 "blue")
                          (make-block 60 200 "blue")
                          (make-block 70 200 "blue")
                          (make-block 80 200 "blue")
                          (make-block 90 200 "blue")
                          (make-block 100 200 "blue")) 200)
              empty)

(define (clear-all-rows a-bset y)
  (cond [(full-row? (row-blocks a-bset y))
         (clear-all-rows (clear-row a-bset y) (+ y SIDELEN))]
        [(<= y HEIGHT)
         (clear-all-rows a-bset (+ y SIDELEN))]
        [else a-bset]))

;; clear-row: BSet Number -> Bset
;; clears row and shifts them down
(check-expect (clear-row (list
                           (make-block 10 200 "blue")
                           (make-block 20 200 "blue")) 200)
              empty)

(check-expect (clear-row (list
                          (make-block 10 100 "blue")
                          (make-block 20 100 "blue")) 300)
              (list   (make-block 10 110 "blue")
                      (make-block 20 110 "blue")))
(check-expect (clear-row (list
                          (make-block 10 100 "blue")
                          (make-block 20 100 "blue")
                          (make-block 30 200 "blue")
                          (make-block 40 200 "blue")) 100)
              (list (make-block 30 200 "blue")
                          (make-block 40 200 "blue")))
              
(define (clear-row a-bset y)
  (foldr (λ(b rst) (cond [(= (block-y b) y)
                          rst]
                         [(< (block-y b) y)
                          (cons (block-shift b "down") rst)]
                         [(> (block-y b) y)
                          (cons b rst)]))
         empty
         a-bset))

;; row-blocks: BSet Number -> BSet
;; returns the blocks at a certain height
(check-expect (row-blocks (list
                           (make-block 10 200 "blue")
                           (make-block 20 200 "blue"))
                          200)
              (list
               (make-block 10 200 "blue")
               (make-block 20 200 "blue")))
(define (row-blocks a-bset y)
  (filter (λ(b) (= (block-y b) y)) a-bset))

;; full-row?: BSet -> Boolean
;; returns true if the row is filled by blocks
(check-expect (full-row?  (list
                          (make-block 10 200 "blue")
                          (make-block 20 200 "blue")
                          (make-block 30 200 "blue")
                          (make-block 40 200 "blue")
                          (make-block 50 200 "blue")
                          (make-block 60 200 "blue")
                          (make-block 70 200 "blue")
                          (make-block 80 200 "blue")
                          (make-block 90 200 "blue")
                          (make-block 100 200 "blue"))) true)
(define (full-row? a-bset)
  (= (length a-bset) (/ WIDTH SIDELEN)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; keyHandler, reached-top?, score, big-bang
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; keyHandler : World KeyEvent -> World
;; Rotates or shifts the world according to the KeyEvent
(check-expect (keyHandler testWorld "left")
              (world-shift testWorld "left"))
(check-expect (keyHandler testWorld "right")
              (world-shift testWorld "right"))
(check-expect (keyHandler testWorld "a")
              (rot testWorld "cw"))
(check-expect (keyHandler testWorld "s")
              (rot testWorld "ccw"))
(check-expect (keyHandler testWorld "down")
              (world-shift testWorld "down"))
(check-expect (keyHandler testWorld "r")
              testWorld)
(define (keyHandler aworld a-key)
  (cond [(key=? a-key "left") (world-shift aworld "left")]
        [(key=? a-key "right") (world-shift aworld "right")]
        [(key=? a-key "down") (world-shift aworld "down")]
        [(string=? a-key "a") (rot aworld "cw")]
        [(string=? a-key "s") (rot aworld "ccw")]
        [else aworld]))

;; reached-top? : World -> Boolean
;; Returns if the pile has reached beyond the top of the canvas
(check-expect (reached-top? testWorld) false)
(check-expect (reached-top? (make-world I-tetra
                                        (list
                                         (make-block 50 0 "blue")
                                         (make-block 50 10 "blue")
                                         (make-block 50 20 "blue")
                                         (make-block 50 30 "blue")
                                         (make-block 50 40 "blue")
                                         (make-block 50 50 "blue")
                                         (make-block 50 60 "blue")
                                         (make-block 50 70 "blue")
                                         (make-block 50 80 "blue")
                                         (make-block 50 90 "blue")
                                         (make-block 50 100 "blue")
                                         (make-block 50 110 "blue")
                                         (make-block 50 120 "blue")
                                         (make-block 50 130 "blue")
                                         (make-block 50 140 "blue")
                                         (make-block 50 150 "blue")
                                         (make-block 50 160 "blue")
                                         (make-block 50 170 "blue")
                                         (make-block 50 180 "blue")
                                         (make-block 50 190 "blue")
                                         (make-block 50 200 "blue")))) true)
(define (reached-top? aworld)
  (bset-collided? (tetra-blocks (create-tetra (random 7)))
                  (world-pile aworld)))

;; count-blocks : Bset -> Number
;; Returns the number of blocks in the Bset 
(check-expect (count-blocks empty) 0)
(check-expect (count-blocks I-bset) 4)
(define (count-blocks a-bset)
  (cond [(empty? a-bset) 0]
        [else (+ (count-blocks (rest a-bset))
                 1)]))


;; Score : World -> String
;; Gets the score of the world
(check-expect (score testWorld)
              (text "Score: 0" 22 "red"))
(define (score aworld)
  (text (string-append "Score: "
                       (number->string
                        (count-blocks (world-pile aworld))))
        22
        "red"))

;; display-score : World -> Image
;; Takes in the world and displays the image at the end of the game
(check-expect (display-score testWorld)
              (place-image (text "GAME OVER" 18 "red")
               (/ WIDTH 2)
               (/ HEIGHT 4)
               (place-image (text "Score: 0" 22 "red")
                            (/ WIDTH 2)
                            (/ HEIGHT 3)
                            BG)))
(define (display-score aworld)
  (place-image (text "GAME OVER" 18 "red")
               (/ WIDTH 2)
               (/ HEIGHT 4)
               (place-image (score aworld)
                            (/ WIDTH 2)
                            (/ HEIGHT 3)
                            BG)))

;; main: World -> World
;; Runs the world
(define (main aworld)
  (big-bang aworld
            (to-draw draw-world)
            (on-tick tock .2)
            (on-key keyHandler)
            (stop-when reached-top? display-score)))

(define testWorld (make-world I-tetra empty))
(define testWorld2 (make-world T-tetra empty))
(define testWorld3 (make-world (make-tetra (make-posn 200 200)
                                           (list
                                            (make-block 100 200 "blue")
                                            (make-block 100 200 "blue")
                                            (make-block 100 200 "blue")
                                            (make-block 100 200 "blue"))) empty))
(define World1 (make-world (create-tetra (random 7)) empty))
(main World1)

