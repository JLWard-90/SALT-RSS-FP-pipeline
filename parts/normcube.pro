function normcube, input1

data = READFITS(input1, prihdr, /NOSCALE)
;Get spectrum location in pixels:
;
data_out = data
Xpix = SXPAR(prihdr, 'NAXIS1')
Ypix = SXPAR(prihdr, 'NAXIS2')
Zpix = SXPAR(prihdr, 'NAXIS3')

for k = 0, zpix-1 do begin
  sumk = 0.0
  for m = 0, Xpix-1 do begin
    for n=0, Ypix-1 do begin
      sumk =sumk + data[m,n,k]
    endfor
  endfor
  meank = sumk / (Xpix*Ypix)
  for m = 0, Xpix-1 do begin
    for n=0, Ypix-1 do begin
      data_out[m,n,k] = data[m,n,k] / meank
    endfor
  endfor
endfor


input1_base = FILE_BASENAME(input1, '.fits')
output_f = string(input1_base + '_normcal' + '.fits')

writefits, output_f, data_out, prihdr
return, output_f
end