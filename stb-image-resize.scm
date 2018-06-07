;; see modules files for imports

(define-foreign-type stbir_datatype integer)
(define-foreign-type stbir_colorspace integer)
(define-foreign-type stbir_edge integer)

(foreign-declare "
#define STB_IMAGE_RESIZE_IMPLEMENTATION
#include \"stb_image_resize.h\"
")

(define (flags->int flags) 0) ;; TODO

(define (edge->int edge)
  (case edge
    ((clamp)   (foreign-value "STBIR_EDGE_CLAMP" int))
    ((reflect) (foreign-value "STBIR_EDGE_REFLECT" int))
    ((wrap)    (foreign-value "STBIR_EDGE_WRAP" int))
    ((zero)    (foreign-value "STBIR_EDGE_ZERO" int))
    (else (error "edge-mode not one of (clamp reflect wrap zero)" edge))))

(define (filter->int filter)
  (case filter
    ((box) (foreign-value "STBIR_FILTER_BOX" int))
    ((triangle) (foreign-value "STBIR_FILTER_TRIANGLE" int))
    ((cubicbspline) (foreign-value "STBIR_FILTER_CUBICBSPLINE" int))
    ((catmullrom) (foreign-value "STBIR_FILTER_CATMULLROM" int))
    ((mitchell) (foreign-value "STBIR_FILTER_MITCHELL" int))
    (else
     (error "filter not one of (box triangle cubicbspline catmullrom mitchell)" filter))))

(define (colorspace->int colorspace)
  0 ;; TODO
  )

(define (image-resize pixels width height channels
                      width-out height-out
                      #!key
                      (colorspace 'srgb)
                      (flags '())
                      (edge-mode-horizontal 'clamp)
                      (edge-mode-vertical   'clamp)
                      (alpha-channel #f)
                      (filter 'mitchell)
                      (filter-horizontal filter)
                      (filter-vertical filter)
                      (stride 0) (stride-out 0)
                      (region '#(0 0 1 1)))

  (define pixels-out
    (cond ((u8vector?  pixels) (make-u8vector (* width-out height-out channels)))
          ((u16vector? pixels) (make-u16vector (* width-out height-out channels)))
          ((u32vector? pixels) (make-u32vector (* width-out height-out channels)))
          ((f32vector? pixels) (make-f32vector (* width-out height-out channels)))
          (else (error "unknown type in input pixels (expecting srfi4 u8/u16/u32/f32 vector)"
                       pixels))))

  (define pixels*
    (cond ((u8vector?  pixels) (u8vector->blob/shared pixels))
          ((u16vector? pixels) (u16vector->blob/shared pixels))
          ((u32vector? pixels) (u32vector->blob/shared pixels))
          ((f32vector? pixels) (f32vector->blob/shared pixels))))

  (define pixels-out*
    (cond ((u8vector?  pixels-out) (u8vector->blob/shared  pixels-out))
          ((u16vector? pixels-out) (u16vector->blob/shared pixels-out))
          ((u32vector? pixels-out) (u32vector->blob/shared pixels-out))
          ((f32vector? pixels-out) (f32vector->blob/shared pixels-out))))

  (define s0 (vector-ref region 0))
  (define t0 (vector-ref region 1))
  (define s1 (vector-ref region 2))
  (define t1 (vector-ref region 3))

  (define ret
    ((foreign-lambda* int
                      ((scheme-pointer input_pixels)
                       (int input_w)
                       (int input_h)
                       (int input_stride_in_bytes)

                       (scheme-pointer output_pixels)
                       (int output_w)
                       (int output_h)
                       (int output_stride_in_bytes)

                       (stbir_datatype datatype)
                       (int num_channels)
                       (int alpha_channel)
                       (int flags)

                       (stbir_edge edge_mode_horizontal)
                       (stbir_edge edge_mode_vertical)

                       (int filter_horizontal)
                       (int filter_vertical)
                       (stbir_colorspace space)
                       ;;((c-pointer void) alloc_context)
                       (float s0)
                       (float t0)
                       (float s1)
                       (float t1))
                      "return(stbir_resize_region(input_pixels ,
                                     input_w , input_h , input_stride_in_bytes,
                                     output_pixels,
                                     output_w, output_h, output_stride_in_bytes,
                                     datatype,
                                     num_channels, alpha_channel, flags,
                                     edge_mode_horizontal, edge_mode_vertical,
                                     filter_horizontal,  filter_vertical,
                                     space, 0/*alloc_context*/,
                                     s0, t0, s1, t1));")
     pixels*
     width
     height
     stride

     pixels-out*
     width-out
     height-out
     stride-out

     ;; datatype
     (cond ((u8vector? pixels) (foreign-value "STBIR_TYPE_UINT8" int))
           ((u16vector? pixels) (foreign-value "STBIR_TYPE_UINT16" int))
           ((u32vector? pixels) (foreign-value "STBIR_TYPE_UINT32" int))
           ((f32vector? pixels) (foreign-value "STBIR_TYPE_FLOAT" int)))

     channels

     ;; index of alpha channel
     (or alpha-channel (foreign-value "STBIR_ALPHA_CHANNEL_NONE" int))
     (flags->int flags)
     (edge->int edge-mode-horizontal)
     (edge->int edge-mode-vertical)
     (filter->int filter-horizontal)
     (filter->int filter-vertical)
     (colorspace->int colorspace)
     s0 t0 s1 t1))

  (unless (= 1 ret)
    (error "unable to resize image"))

  pixels-out)
