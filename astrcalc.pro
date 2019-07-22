function astrCalc, input

  input2 = FILE_BASENAME(input, '.fits')
  output = string(input2 + '_astcal.fits')
  
  data = READFITS(input, prihdr, /NOSCALE)
  
  prebin_facX = 4.0
  prebin_facY = 4.0
  badPIXSCALE = float(SXPAR(prihdr, 'PIXSCALE'))
  XPIXSCALE = (-1.0) * prebin_facX * badPIXSCALE
  YPIXSCALE = prebin_facY * badPIXSCALE
  XPIXSCALE = XPIXSCALE / 3600.0
  YPIXSCALE = YPIXSCALE / 3600.0
  
  
  RAstr = SXPAR(prihdr, 'TELRA')
  Decstr = SXPAR(prihdr, 'TELDEC')
  RA = strsplit(RAstr, ':', /EXTRACT)
  Dec = strsplit(Decstr, ':', /EXTRACT)
  RAdeg = ten(RA[0],RA[1],RA[2])*15
  Decdeg = ten(Dec[0],Dec[1],Dec[2])
  print, RAstr
  print, RA
  print, RAdeg
  print, Decstr
  print, Dec
  print, Decdeg
  
  SXADDPAR,prihdr, 'CRVAL1', RAdeg, AFTER='NAXIS3'
  SXADDPAR,prihdr, 'CRVAL2', Decdeg, AFTER='CRVAL1'
  
  POSANG1 = SXPAR(prihdr, 'DECPANGL')
  ;POSANG1 = (-1.0) * POSANG1
  POSANG1 = (POSANG1) / !RADEG
  ;C1_1   =  (-1.0) * pixscaleX * sin(POSANG1)
  C1_1   =   XPIXSCALE * cos(POSANG1)
  C1_2   = (-1.0) * XPIXSCALE * sin(POSANG1)
  C2_1 =   YPIXSCALE * sin(POSANG1)
  ;C2_1 = (-1.0) *  pixscaleY * cos(POSANG1)
  C2_2 = YPIXSCALE * cos(POSANG1)
  
  CRpixelX = fix((SXPAR(prihdr, 'NAXIS1')) / 2)
  CRpixelY = fix((SXPAR(prihdr, 'NAXIS2')) / 2)
  
  SXADDPAR, prihdr, ['CTYPE1'], 'RA---TAN', AFTER='EXTVER'
  SXADDPAR, prihdr, ['CTYPE2'], 'DEC--TAN', AFTER='CTYPE1'
  SXADDPAR, prihdr, ['CRPIX1'], CRpixelX, AFTER='CRTYPE1'
  SXADDPAR, prihdr, ['CRPIX2'], CRpixelY, AFTER='CRTYPE2'
  SXADDPAR, prihdr, ['CRVAL1'], RAdeg
  SXADDPAR, prihdr, ['CRVAL2'], Decdeg
  SXADDPAR, prihdr, ['CDELT1'], XPIXSCALE, AFTER='CRVAL1'
  SXADDPAR, prihdr, ['CDELT2'], YPIXSCALE, AFTER='CRVAL2'
  SXADDPAR, prihdr, ['CD1_1'], C1_1, AFTER='CDELT2'
  SXADDPAR, prihdr, ['CD1_2'], C1_2, AFTER='CD1_1'
  SXADDPAR, prihdr, ['CD2_1'], C2_1, AFTER='CD1_2'
  SXADDPAR, prihdr, ['CD2_2'], C2_2, AFTER='CD2_1'
  SXADDPAR, prihdr, ['EQUINOX'], 2000.0, AFTER='CD2_2'
  
  writefits, output, data, prihdr
  return, output
  
end