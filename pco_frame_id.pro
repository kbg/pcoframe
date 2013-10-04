; Copyright (c) 2010 Kolja Glogowski
; 
; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated documentation
; files (the "Software"), to deal in the Software without
; restriction, including without limitation the rights to use,
; copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the following
; conditions:
; 
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
; OTHER DEALINGS IN THE SOFTWARE.
;
;+
; NAME:
;   PCO_FRAME_ID
;
; PURPOSE:
;   This function extracts the frame number from images that were recorded
;   by the PCO 2000 or PCO 4000 camera.
;
; INPUTS:
;   data:  An image (2d-array with dimension WxH), a collection of images
;          (3d-array with dimension WxHxN) or a single line (1d-array with
;          dimension W) which contains the bcd-encoded frame id.
;
; KEYWORDS:
;   line:  The line of the image that contains the bcd-encoded data. The
;          default is the last line (H-axis) of the array.
;          If the frames were recorded by the PCO CamWare program, it may
;          be necessary to set this keyword to 0.
;   offs:  The offset (W-axis) to the beginning of the frame id bcd data.
;          The default value is 0.
;
; OUTPUTS:
;   The frame id(s) of the input images.
;
; NOTES:
;   To use this function, the images must be recorded with the timestamp mode
;   set to BINARY or BINARY+ASCII. This mode is always enabled for the
;   PcoGui but can be turned off when using the CamWare program.
;-
function pco_frame_id, data, line=line, offs=offs
    compile_opt idl2
    
    dim = size(data, /dimensions)
    ndim = size(data, /n_dimensions)
    
    ; set default arguments
    if (n_elements(line) ne 1) && (ndim gt 1) then line = (dim[1])-1
    if n_elements(offs) ne 1 then offs = 0
    npix = 4 + offs
    
    case ndim of
        1:    d = pco_decode_bcd(data[offs:(npix-1)])
        2:    d = pco_decode_bcd(reform(data[offs:(npix-1), line]))
        3:    d = pco_decode_bcd(reform(data[offs:(npix-1), line, *]))
        else: message, 'Invalid array dimensions'
    endcase
    
    ddim = [size(d, /dimensions), 1]

    ; multiply digits with decimal basis
    fid = lonarr(ddim[1])
    for i = 0, (ddim[0])-1 do $
        fid += d[i, *] * 10L^(ddim[0]-i-1)

    return, fid
end

