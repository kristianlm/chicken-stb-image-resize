(cond-expand
 (chicken-5 (import stb-image-resize test srfi-4))
 (else (use stb-image-resize test srfi-4)))


(test-group
 "scale down"

 (test
  "scale down box filter u8"
  (u8vector 4)
  (image-resize (u8vector 0 8) 2 1 1  1 1 filter: 'box))

 (test
  "scale down box filter u16"
  (u16vector 4)
  (image-resize (u16vector 0 8) 2 1 1  1 1 filter: 'box))

 (test
  "scale down box filter u32"
  (u32vector 4)
  (image-resize (u32vector 0 8) 2 1 1  1 1 filter: 'box))

 (test
  "scale down box filter f32"
  (f32vector 1e40)
  (image-resize (f32vector 0 2e40) 2 1 1  1 1 filter: 'box)))

(test-group
 "scale up"

 (test
  "scale up box filter u8"
  (u8vector 0 0 0 0 0 0 0 0 16 16 16 16 16 16 16 16)
  (image-resize (u8vector 0 16)
                    2 1 1 ;; w h channels
                    16 1  ;; desintation w h
                    filter: 'box))

 (test
  "scale up box filter u16"
  (u16vector 0 0 0 0 0 0 0 0 16 16 16 16 16 16 16 16)
  (image-resize (u16vector 0 16)
                    2 1 1 ;; w h channels
                    16 1  ;; desintation w h
                    filter: 'box))

 (test
  "scale up box filter u32"
  (u32vector 0 0 0 0 0 0 0 0 16 16 16 16 16 16 16 16)
  (image-resize (u32vector 0 16)
                    2 1 1 ;; w h channels
                    16 1  ;; desintation w h
                    filter: 'box))

 (let ((big 1e40))
   (test
    "scale up box filter f32"
    (f32vector 0 0 0 0 0 0 0 0 big big big big big big big big)
    (image-resize (f32vector 0 big)
                  2 1 1 ;; w h channels
                  16 1  ;; desintation w h
                  filter: 'box))))

(test-group
 "filters"

 (test
  "scale up box filter u8"
  (u8vector 0 0 8 8)
  (image-resize (u8vector 0 8) 2 1 1  4 1 filter: 'box))

 (test
  "scale up triangle filter u8"
  (u8vector 0 2 6 8)
  (image-resize (u8vector 0 8) 2 1 1  4 1 filter: 'triangle))

 (test
  "scale up catmullrom filter u8"
  (u8vector 0 2 6 9)
  (image-resize (u8vector 0 8) 2 1 1  4 1 filter: 'catmullrom))

 (test
  "scale up cubicbspline filter u8"
  (u8vector 1 3 5 7)
  (image-resize (u8vector 0 8) 2 1 1  4 1 filter: 'cubicbspline)))

(test-group
 "region"
 ;; I wish cropping was a separate step and used fixnum coordinates.
 (test
  "crop with region"
  (u8vector 08 09
            13 14)
  (image-resize (u8vector 01 02 03 04 05
                              06 07 08 09 10
                              11 12 13 14 15
                              16 17 18 19 20)
                    5 4 1  2 2
                    region: (vector #i2/5 #i1/4  #i4/5 #i3/4))))

(test-group
 "3 channels"

 (test
  "3 channels u8"
  (let ((j 64))
    (u8vector j j j  j 0 0
              0 j 0  0 0 j))
  (image-resize
   (let ((i 255))
     (u8vector i i i    0 0 0    0 0 0   i 0 0
               0 0 0    0 0 0    0 0 0   0 0 0
               0 0 0    0 0 0    0 0 0   0 0 0
               0 i 0    0 0 0    0 0 0   0 0 i))
   4 4 3  2 2
   filter: 'box)))

(test-exit)
