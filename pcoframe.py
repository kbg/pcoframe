#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2010 Kolja Glogowski
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

import datetime
import numpy as np


def decode_bcd(a):
    '''
    This function bcd-decodes the lowest bytes of all elements in the array.

    Arguments:
      a:  An array with up to 2 dimensions.

    Returns:
      An array containing the decoded digits.
    '''
    ndim = a.ndim
    if ndim == 1:
        a = a.reshape((1, a.shape[0]))
    elif ndim > 2:
        raise TypeError('Invalid data dimensions')

    # only use lowest bytes
    a = a & 0xff

    # create digit array
    d = np.zeros((a.shape[0], a.shape[1] * 2), dtype = np.int32)
    for i in range(a.shape[1]):
        d[:, 2*i]   = a[:, i] >> 4
        d[:, 2*i+1] = a[:, i] & 0x0f

    return d if ndim != 1 else d[0]


def frame_id(data, line = -1, offs = 0):
    '''
    This function extracts the frame number from images that were recorded
    by the PCO 2000 or PCO 4000 camera.

    Arguments:
      data:  An image (2d-array with dimension WxH), a collection of images
             (3d-array with dimension WxHxN) or a single line (1d-array with
             dimension W) which contains the bcd-encoded frame id.
      line:  The line of the image that contains the bcd-encoded data. The
             default is the last line (H-axis) of the array.
             If the frames were recorded by the PCO CamWare program, it may
             be necessary to set this keyword to 0.
      offs:  The offset (W-axis) to the beginning of the frame id bcd data.
             The default value is 0.

    Returns:
      The frame id(s) of the input images. The type of the result is an
      integer array (3d input-array) or an int value (2d input-array).
    
    Notes:
      To use this function, the images must be recorded with the timestamp
      mode set to BINARY or BINARY+ASCII. This mode is always enabled for
      the PcoGui but can be turned off when using the CamWare program.
    '''
    npix = 4 + offs
    if data.shape[-1] < offs + npix:
        raise TypeError('Invalid width (less than %d pixels)' % npix)

    if data.ndim == 3:
        d = decode_bcd(data[:, line, offs:npix])
    elif data.ndim == 2:
        d = decode_bcd(data[line, offs:npix])
    elif data.ndim == 1:
        d = decode_bcd(data[offs:npix])
    else:
        raise TypeError('Invalid data dimensions')

    if d.ndim == 1:
        d = d.reshape((1, d.shape[0]))

    # multiply digits with decimal basis
    fid = np.zeros(d.shape[0], dtype = np.int32)
    for i in range(d.shape[1]):
        fid += d[:, i] * 10**(d.shape[1]-i-1)

    return fid if data.ndim == 3 else fid[0]


def frame_time(data, line = -1, offs = 4):
    '''
    This function extracts the date and time of recording from images that
    were recorded by the PCO 2000 or PCO 4000 camera.
    
    Arguments:
      data:  An image (2d-array with dimension WxH), a collection of images
             (3d-array with dimension WxHxN) or a single line (1d-array with
             dimension W) which contains the bcd-encoded frame id.

      line:  The line of the image that contains the bcd-encoded data. The
             default is the last line (H-axis) of the array.
             If the frames were recorded by the PCO CamWare program, it may
             be necessary to set this keyword to 0.
      offs:  The offset (W-axis) to the beginning of the date/time bcd data.
             The default value is 4.
    
    Returns:
      The date and time when the input images were created. The type of the
      result is a list of datetime objects (3d input-array) or a single
      datetime object (2d input-array).

    Notes:
      To use this function, the images must be recorded with the timestamp
      mode set to BINARY or BINARY+ASCII. This mode is always enabled for
      the PcoGui but can be turned off when using the CamWare program.
    '''
    npix = 10 + offs
    if data.shape[-1] < npix:
        raise TypeError('Invalid width (less than %d pixels)' % npix)

    if data.ndim == 3:
        d = decode_bcd(data[:, line, offs:npix])
    elif data.ndim == 2:
        d = decode_bcd(data[line, offs:npix])
    elif data.ndim == 1:
        d = decode_bcd(data[offs:npix])
    else:
        raise TypeError('Invalid data dimensions')

    if d.ndim == 1:
        d = d.reshape((1, d.shape[0]))

    year = 1000 * d[:,0] + 100 * d[:,1] + 10 * d[:,2] + d[:,3]
    month = 10 * d[:,4] + d[:,5]
    day = 10 * d[:,6] + d[:,7]
    hour = 10 * d[:,8] + d[:,9]
    minute = 10 * d[:,10] + d[:,11]
    second = 10 * d[:,12] + d[:,13]
    musec = (100000 * d[:,14] + 10000 * d[:,15] + 1000 * d[:,16] +
             100 * d[:,17] + 10 * d[:,18] + d[:,19])

    res = []
    for i in range(d.shape[0]):
        res.append(datetime.datetime(year[i], month[i], day[i],
            hour[i], minute[i], second[i], musec[i]))
    
    return res if data.ndim == 3 else res[0]
    
