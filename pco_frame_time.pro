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
;   PCO_FRAME_TIME
;
; PURPOSE:
;   This function extracts the date and time of recording from images that
;   were recorded by the PCO 2000 or PCO 4000 camera.
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
;   offs:  The offset (W-axis) to the beginning of the date/time bcd data.
;          The default value is 4.
;
; OUTPUTS:
;   The date and time when the input images were created. The format of each
;   line of the returned array is:
;
;       [ year, month, day, hour, minute, second, microsecond ]
;
; NOTES:
;   To use this function, the images must be recorded with the timestamp mode
;   set to BINARY or BINARY+ASCII. This mode is always enabled for the
;   PcoGui but can be turned off when using the CamWare program.
;-
function pco_frame_time, data, line=line, offs=offs
    compile_opt idl2
    
    dim = size(data, /dimensions)
    ndim = size(data, /n_dimensions)
    
    ; set default arguments
    if (n_elements(line) ne 1) && (ndim gt 1) then line = (dim[1])-1
    if n_elements(offs) ne 1 then offs = 4
    npix = 10 + offs
    
    case ndim of
        1:    d = pco_decode_bcd(data[offs:(npix-1)])
        2:    d = pco_decode_bcd(reform(data[offs:(npix-1), line]))
        3:    d = pco_decode_bcd(reform(data[offs:(npix-1), line, *]))
        else: message, 'Invalid array dimensions'
    endcase
    
    ddim = [size(d, /dimensions), 1]

    ; the resulting array contains the following 7 colums:
    ; year, month, day, hour, minute, second, microsecond
    fta = lonarr(7, ddim[1])
    fta[0, *] = 1000L * d[0,*] + 100L * d[1,*] + 10L * d[2,*] + d[3,*]  ; year
    fta[1, *] = 10L * d[4,*] + d[5,*]  ; month
    fta[2, *] = 10L * d[6,*] + d[7,*]  ; day
    fta[3, *] = 10L * d[8,*] + d[9,*]  ; hour
    fta[4, *] = 10L * d[10,*] + d[11,*]  ; minute
    fta[5, *] = 10L * d[12,*] + d[13,*]  ; sec
    fta[6, *] = 100000L * d[14,*] + 10000L * d[15,*] + 1000L * d[16,*] + $
                100L * d[17,*] + 10L * d[18,*] + d[19,*]  ; musec,*
    
    return, fta
end

