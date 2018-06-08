(cond-expand
 (chicken-5 (import srfi-4 stb-image stb-image-write stb-image-resize))
 (else (use srfi-4 stb-image stb-image-write stb-image-resize)))

(unless (pair? (command-line-arguments))
  (display "usage: csi -s example.scm <image>
prints png image thumbnail to stdout\n" (current-error-port))
  (exit))

(receive (pixels w h c)
    (with-input-from-file (car (command-line-arguments)) read-image)
  (display (conc w "*" h "*" c " => ") (current-error-port))
  (let* ((w2 64)
         (h2 (inexact->exact (floor (* h (/ w2 w)))))
         (_ (display (conc w2 "*" h2 "*" c "\n") (current-error-port)))
         (resized (image-resize (blob->u8vector/shared pixels)
                                w h c   w2 h2)))
    (write-png resized w2 h2 c)))
