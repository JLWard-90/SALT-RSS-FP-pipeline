function compile_Cube, list_fits, wavelist_name, output1, whichet

  wavelistout = wavelist_name
  ;Read, wavelistout, PROMPT='Output wavelist file name: '
  
  z_length = size(list_fits, /N_elements)
  wavelist_extra = MAKE_ARRAY(z_length, /DOUBLE, VALUE=0.0)
  
  im_x = 1585
  im_y = 1026
  data_bigheader = readfits(string(list_fits[1]), prihdr, /NOSCALE);, Exten_no=0)
  
  ;pixscale =  SXPAR(prihdr, 'NAXIS1')
  im_x = SXPAR(prihdr, 'NAXIS1')
  im_y = SXPAR(prihdr, 'NAXIS2')
  
  ;n_dith_x = 3
  ;n_dith_y = 0
  ;dith_12_arcsec = 20
  ;dith_23_arcsec = 40
  
  ;Dec1
  
  data_out = MAKE_ARRAY(im_x, im_y, z_length, /Double, Value=0.0)
  openw,lun2, wavelistout, /get_lun
  for i = 0, z_length-1 do begin
    ;fits_input = string(list_fits.Field1[i])
    data1 = readfits(string(list_fits[i]), goodhdr, /NOSCALE);, Exten_no=1)
    ;    datacrap = readfits(string(list_fits.Field1[i]), goodhdr, /NOSCALE);, Exten_no=0)
    if (whichet eq 2) then etpos = SXPAR(goodhdr, 'ET2WAVE0')
    if (whichet eq 1) then etpos = SXPAR(goodhdr, 'ET1WAVE0')
    wavelist_extra[i] = etpos
    printf, lun2, STRTRIM(string(etpos), 1)
    data_out[*,*,i] = data1
  endfor
  close, lun2
  
  ;output1 = 'test.fits'
  ;READ, output1, PROMPT='output file: '
  SXADDPAR, prihdr, ['NAXIS'], 3
  SXADDPAR, prihdr, ['NAXIS1'], im_x, AFTER='NAXIS'
  SXADDPAR, prihdr, ['NAXIS2'], im_y, AFTER='NAXIS1'
  SXADDPAR, prihdr, ['NAXIS3'], z_length, AFTER='NAXIS2'
  writefits, output1, data_out, prihdr
  ;print, craphdr
  ;print, prihdr
  return, wavelist_extra
end