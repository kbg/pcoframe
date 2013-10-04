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
;   PCO_DECODE_BCD
;
; PURPOSE:
;   This function bcd-decodes the lowest bytes of all elements in the array.
;
; INPUTS:
;   array:  An array with up to 2 dimensions.
;
; OUTPUTS:
;   An array containing the decoded digits.
;-
function pco_decode_bcd, array
    compile_opt idl2

    a = array
    
    ; only use lowest bytes
    a = a and 255
    
    ndim = size(a, /n_dimensions)
    case ndim of
        0:    dim = [1, 1]
        1:    dim = [size(a, /dimensions), 1]
        2:    dim = size(a, /dimensions)
        else: message, 'Invalid array dimensions'
    endcase

    ; create digit array
    d = intarr(2 * dim[0], dim[1])
    for i = 0, dim[0]-1 do begin
        d[2*i, *]   = ishft(a[i, *], -4)
        d[2*i+1, *] = (a[i, *] and 15)
    endfor

    return, d
end

