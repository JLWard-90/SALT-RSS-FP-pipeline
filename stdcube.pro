function stdcube, input1, stdcoords
Nspec = 9
  data = READFITS(input1, prihdr, /NOSCALE)
  ;Get spectrum location in pixels:
  ;
  data_out = data
  Xpix = SXPAR(prihdr, 'NAXIS1')
  Ypix = SXPAR(prihdr, 'NAXIS2')
  Zpix = SXPAR(prihdr, 'NAXIS3')

  pixrad = 1
  Xval = stdcoords[0]
  Yval = stdcoords[1]
  
  specX = MAKE_ARRAY(9, VALUE=0)
  specY = MAKE_ARRAY(9, VALUE=0)

  for i = 0, 2 do begin
    for j = 0, 2 do begin
      specX[i+j*3] = Xval-1+i
      specY[i+j*3] = Yval-1+j
    endfor
  endfor

 data_out = data
for k=0, Zpix-1 do begin
  sum1 = 0.0
  for j = 0, Nspec-1 do begin
    sum1 = sum1 + data[specX[j],specY[j],k]
  endfor
  meank = sum1 / float(Nspec)
  for m = 0, Xpix-1 do begin
    for n=0, Ypix-1 do begin
      data_out[m,n,k] = data[m,n,k] / meank
    endfor
  endfor
endfor

input1_base = FILE_BASENAME(input1, '.fits')
output_f = string(input1_base + '_stcal' + '.fits')
writefits, output_f, data_out, prihdr
return, output_f
end