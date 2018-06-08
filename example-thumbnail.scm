(cond-expand
 (chicken-5 (import stb-image stb-image-resize
                    (only srfi-4 u8vector-ref)
                    (only (chicken process-context) command-line-arguments)
                    (only (chicken string) conc)))
 (else         (use stb-image stb-image-resize
                    (only srfi-4 u8vector-ref)
                    (only data-structures conc))))

(unless (pair? (command-line-arguments))
  (display "displays color images in terminal using ASCII escape sequences

usage: csi -s example-thumbnail.scm < image.jpg
e.g.:
    convert rose: jpg:- | csi -s example-thumbnail.scm -
    convert -pointsize 200 caption:\"test image for stb-image-resize\" png:- | csi -s example-thumbnail.scm -
" (current-error-port))
  (exit))

(when (equal? (command-line-arguments) '("-"))
  (command-line-arguments '("/dev/stdin")))

;; https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit :
;; ESC [ … 48;2;<r>;<g>;<b> … m Select RGB background color
(define (termcolor r g b #!optional (pixel " "))
  (conc "\x1b[48;2;" r ";" g ";" b "m " "\x1b[0m"))

(receive (pixels w h c)
    (with-input-from-file (car (command-line-arguments)) (lambda () (read-image channels: 3)))
  (display (conc w "*" h "*" c " => ") (current-error-port))
  (let* ((w2 48)
         (h2 (inexact->exact (floor (* h (/ w2 w)))))
         (w2 (* 2 w2)) ;; double width since spaces are narrow
         (_ (display (conc w2 "*" h2 "*" c "\n") (current-error-port)))
         (resized (image-resize pixels  w h c   w2 h2)))
    (do ((y 0 (+ 1 y)))
        ((>= y h2))
      (do ((x 0 (+ 1 x)))
          ((>= x w2))
        (display (termcolor (u8vector-ref resized (+ 0 (* c x) (* c w2 y)))
                            (u8vector-ref resized (+ 1 (* c x) (* c w2 y)))
                            (u8vector-ref resized (+ 2 (* c x) (* c w2 y))))))
      (print))))

