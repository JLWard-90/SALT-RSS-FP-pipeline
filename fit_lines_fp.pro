function fit_lines_FP, input

  data1 = readfits(input, prihdr, /NOSCALE)
  Xpix = SXPAR(prihdr, 'NAXIS1')
  Ypix = SXPAR(prihdr, 'NAXIS2')
  Zlen = SXPAR(prihdr, 'NAXIS3')
  
  a = MAKE_ARRAY(6, /FLOAT, VALUE = 0.0)
  ;read, c, prompt='Gaussian width estimate: '
  c = 2
  a[2] = c
  pi = 3.14159265359
  coeff_array = MAKE_ARRAY(Xpix, Ypix, 12, /DOUBLE, VALUE=0.0)
  Y = MAKE_ARRAY(Zlen, /DOUBLE, VALUE=0.0)
  progressBar = Obj_New("SHOWPROGRESS", XSIZE=400, YSIZE=30, message='Fitting emission lines...')
  progressBar->Start
  CATCH, Error_status
  for i = 0, Xpix-1 do begin
    for j = 0, Ypix-1 do begin
    
      X = FINDGEN(Zlen, start=1)
      for k=0, Zlen-1 do begin
        Y[k] = data1[i,j,k]
      endfor
      testmax = max(Y, max_idx)
      a[1] = max_idx+1
      a[0] = Y[max_idx]
      coeff = make_array(6, /DOUBLE, VALUE=0)
      yfit = GAUSSFIT(X, Y, coeff, CHISQ =chisq1, ESTIMATES=a, SIGMA=sig1, NTERMS=6)
      for k = 0, 5 do begin
        coeff_array[i,j,k] = coeff[k]
        if (sig1[k] gt coeff[k]) then coeff_array[i,j,k] = !VALUES.D_NAN
      endfor
      for k = 6, 11 do begin
        coeff_array[i,j,k] = sig1[k-6]
      endfor
    endfor
    progressBar->Update, fix((float(i)/(float(Xpix)-1.0))*100.0)
  endfor
  progressBar->Destroy
  Obj_Destroy, progressBar
  
  return, coeff_array
  
end