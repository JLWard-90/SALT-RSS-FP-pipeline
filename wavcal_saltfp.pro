function wavcal_SALTFP, arcF, arcwav, output1

  ;To begin I will assume the central lambda is that of the proposal exactly and that there is 24A
  ;
  
  ;print, data_dim
  im_x = 1585 ;detector size (pix)
  im_y = 1026 ;detector size (pix)
  xlen = im_x
  ylen = im_y
  print, xlen
  print, ylen
  xcent = fix(xlen / 2.0)
  ycent = fix(ylen / 2.0)
  ;centlambda =
  x_edge = 309 ;; edge of the FOV on detector
  R_edge = xcent - x_edge
  
  
  ;comment out the following if no arc lamp file is available:
  arcdata = READFITS(string(arcF), archdr, /NOSCALE,Exten_no=1)
  ;print, archdr
  arcdata_hdr2 = READFITS(string(arcF), archdrdetails, /NOSCALE,Exten_no=0)
  ;print, archdrdetails
  etpos = 0.0
  arclampname = ''
  arclampname = SXPAR(archdrdetails, 'LAMPID')
  etpos = SXPAR(archdrdetails, 'ET2WAVE0')
  print, 'Arc lamp ID is ', arclampname, 'etalon wavelength position is', etpos, ' enter wavelength of line'
  ;Read, etpos, PROMPT='position of etalon (in A): '
  ylow = ycent - 5
  yhigh = ycent + 5
  xlow = xcent - 5
  xhigh = xcent +5
  Xarr = FINDGEN(xcent, start=0)
  Yarr = FINDGEN(ycent, start=0)
  S1a = MAKE_ARRAY(xcent, /FLOAT, VALUE=0.0)
  S1b = MAKE_ARRAY(xcent, /FLOAT, VALUE=0.0)
  S2a = MAKE_ARRAY(ycent, /FLOAT, VALUE=0.0)
  S2b = MAKE_ARRAY(ycent, /FLOAT, VALUE=0.0)
  print, SIZE(arcdata)
  for i = 0, xcent-1 do begin
    Ssum = 0.0
    for j = ylow, yhigh do begin
      ;print, j
      Ssum = Ssum + arcdata[i,j]
    endfor
    S1a[i] = Ssum
  endfor
  for i = xcent, xlen-2 do begin
    Ssum = 0.0
    for j = ylow, yhigh do begin
      Ssum = Ssum + arcdata[i,j]
    endfor
    ;print, i
    S1b[i-xcent] = Ssum
  endfor
  for i = 0, ycent-1 do begin
    Ssum = 0.0
    for j = xlow, xhigh do begin
      Ssum = Ssum + arcdata[j,i]
    endfor
    S2a[i] = Ssum
  endfor
  for i = ycent, ylen-2 do begin
    Ssum = 0.0
    for j = xlow, xhigh do begin
      Ssum = Ssum + arcdata[j,i]
    endfor
    S2b[i-ycent] = Ssum
  endfor
  Xarr2 = MAKE_ARRAY(N_ELEMENTS(Xarr), /FLOAT, VALUE=0.0)
  Yarr2 = MAKE_ARRAY(N_ELEMENTS(Yarr), /FLOAT, VALUE=0.0)
  for i=0, (N_ELEMENTS(Xarr)-1) do begin
    Xarr2[i] = xcent - Xarr[i]
  endfor
  for i=0, (N_ELEMENTS(Yarr)-1) do begin
    Yarr2[i] = ycent - Yarr[i]
  endfor
  
  S1bgaplow = 250
  S1bgaphigh = 290
  S1agaplow = 290
  S1agaphigh = 330
  
  Xarragap = MAKE_ARRAY((N_ELEMENTS(Xarr)-(S1agaphigh-S1agaplow)),/FLOAT,VALUE=0.0)
  Xarra2gap = MAKE_ARRAY((N_ELEMENTS(Xarr2)-(S1agaphigh-S1agaplow)),/FLOAT,VALUE=0.0)
  Xarrbgap = MAKE_ARRAY((N_ELEMENTS(Xarr)-(S1bgaphigh-S1bgaplow)),/FLOAT,VALUE=0.0)
  Xarrb2gap = MAKE_ARRAY((N_ELEMENTS(Xarr2)-(S1bgaphigh-S1bgaplow)),/FLOAT,VALUE=0.0)
  S1agap = MAKE_ARRAY((N_ELEMENTS(Xarr)-(S1agaphigh-S1agaplow)),/FLOAT,VALUE=0.0)
  S1bgap = MAKE_ARRAY((N_ELEMENTS(Xarr)-(S1bgaphigh-S1bgaplow)),/FLOAT,VALUE=0.0)
  for i = 0, S1agaplow-1 do begin
    Xarragap[i] = Xarr[i]
  endfor
  for i = S1agaphigh, N_ELEMENTS(Xarr)-1 do begin
    Xarragap[i-(S1agaphigh-S1agaplow)] = Xarr[i]
  endfor
  for i = 0, S1agaplow-1 do begin
    Xarra2gap[i] = Xarr2[i]
  endfor
  for i = S1agaphigh, N_ELEMENTS(Xarr2)-1 do begin
    Xarra2gap[i-(S1agaphigh-S1agaplow)] = Xarr2[i]
  endfor
  
  for i = 0, S1bgaplow-1 do begin
    Xarrbgap[i] = Xarr[i]
  endfor
  for i = S1bgaphigh, N_ELEMENTS(Xarr)-1 do begin
    Xarrbgap[i-(S1bgaphigh-S1bgaplow)] = Xarr[i]
  endfor
  for i = 0, S1bgaplow-1 do begin
    Xarrb2gap[i] = Xarr2[i]
  endfor
  for i = S1bgaphigh, N_ELEMENTS(Xarr2)-1 do begin
    Xarrb2gap[i-(S1bgaphigh-S1bgaplow)] = Xarr2[i]
  endfor
  
  
  for i = 0, S1agaplow-1 do begin
    S1agap[i] = S1a[i]
  endfor
  for i = S1agaphigh, N_ELEMENTS(Xarr)-1 do begin
    S1agap[i-(S1agaphigh-S1agaplow)] = S1a[i]
  endfor
  for i = 0, S1bgaplow-1 do begin
    S1bgap[i] = S1b[i]
  endfor
  for i = S1bgaphigh, N_ELEMENTS(Xarr)-1 do begin
    S1bgap[i-(S1bgaphigh-S1bgaplow)] = S1b[i]
  endfor
  
  
  ;S1afit = GAUSSFIT(Xarr, S1a, coeff_S1a, CHISQ =chisq1_S1a, ESTIMATES=est_S1a, SIGMA=sigS1a, NTERMS=6)
  S1afit = GAUSSFIT(Xarragap, S1agap, coeff_S1a, CHISQ =chisq1_S1a, SIGMA=sigS1a, NTERMS=6)
  S1bfit = GAUSSFIT(Xarrbgap, S1bgap, coeff_S1b, CHISQ =chisq1_S1b, SIGMA=sigS1b, NTERMS=6)
  S2afit = GAUSSFIT(Yarr, S2a, coeff_S2a, CHISQ =chisq1_S2a, SIGMA=sigS2a, NTERMS=6)
  S2bfit = GAUSSFIT(Yarr, S2b, coeff_S2b, CHISQ =chisq1_S2b, SIGMA=sigS2b, NTERMS=6)
  
  window,0,retain=2
  PLOT, Xarra2gap, S1agap, LINESTYLE=1
  OPLOT, Xarrbgap, S1bgap, LINESTYLE=1
  OPLOT, Xarra2gap, S1afit, LINESTYLE=0
  OPLOT, Xarrbgap, S1bfit, LINESTYLE=0
  window,1,retain=2
  PLOT, Yarr2, S2a, LINESTYLE=1
  OPLOT, Yarr, S2b, LINESTYLE=1
  OPLOT, Yarr2, S2afit, LINESTYLE=0
  OPLOT, Yarr, S2bfit, LINESTYLE=0
  
  ;ask if you want a to use the real or ideal wavelength solution...
  reid_test = 0
  while (reid_test eq 0) do begin
    ref_ans = ''
    READ, ref_ans, PROMPT='Should I use the real or ideal wavelength solution? (R/I): '
    if (ref_ans eq 'Real') or (ref_ans eq 'R') or (ref_ans eq 'REAL') or (ref_ans eq 'r') or (ref_ans eq 'real') then reid_test = 1
    if (ref_ans eq 'Ideal') or (ref_ans eq 'I') or (ref_ans eq 'IDEAL') or (ref_ans eq 'i') or (ref_ans eq 'ideal') then reid_test = 2
  endwhile
  
  max_or_fit = 0
  while (max_or_fit eq 0) do begin
    ref_ans = ''
    READ, ref_ans, PROMPT='Should I use the fit centroid? If not then the position of the maxium will be used (Y/N): '
    if (ref_ans eq 'Yes') or (ref_ans eq 'Y') or (ref_ans eq 'YES') or (ref_ans eq 'y') or (ref_ans eq 'yes') then max_or_fit = 1
    if (ref_ans eq 'No') or (ref_ans eq 'N') or (ref_ans eq 'NO') or (ref_ans eq 'n') or (ref_ans eq 'no') then max_or_fit = 2
  endwhile
  
  if max_or_fit eq 1 then begin
    R_S1a = xcent - coeff_S1a[1]
    R_S1b = coeff_S1b[1]
    R_S2a = ycent - coeff_S2a[1]
    R_S2b = coeff_S2b[1]
  endif
  if max_or_fit eq 2 then begin
    MAX_S1agap = max(S1agap, S1agap_mind)
    MAX_S1bgap = max(S1bgap, S1bgap_mind)
    MAX_S2a = max(S2a, S2a_mind)
    MAX_S2b = max(S2b, S2b_mind)
    R_S1a = xcent - Xarragap[S1agap_mind]
    R_S1b = Xarrbgap[S1bgap_mind]
    R_S2a = ycent - Yarr[S2a_mind]
    R_S2b = Yarr[S2b_mind]
  endif
  print, 'Radius S1a = ', R_S1a
  print, 'Radius S1b = ', R_S1b
  print, 'Radius S2a = ', R_S2a
  print, 'Radius S2b = ', R_S2b
  
  
  xcentshift = R_S1a-R_S1b
  ycentshift = R_S2a-R_S2b
  new_xcent = xcent - xcentshift
  new_ycent = ycent - ycentshift
  
  R_Avg = (R_S1a + R_S1b + R_S2a + R_S2b) / 4.0
  real_wshift = etpos - arcwav
  real_F = real_wshift / (R_Avg^2.0)
  
  ;centlambda - f(R) -> lambda
  ;F*R^2 = lambda_shift
  
  F = 24.0 / (R_edge^2.0)
  print, 'ideal F = ', F
  print, 'real F = ', real_F
  
  F_array = MAKE_ARRAY(xlen, ylen, /FLOAT, VALUE=0.0)
  
  for i = 0, xlen-1 do begin
    for j = 0, ylen-1 do begin
      delx = double(abs((i+1)-new_xcent))
      dely = double(abs((j+1)-new_ycent))
      R = sqrt((delx^2) + (dely ^ 2.0))
      if (reid_test eq 1) then begin
        F_array[i,j] = real_F*(R^2.0)
      endif
      if (reid_test eq 2) then begin
        F_array[i,j] = F*(R^2.0)
      endif
    endfor
  endfor
  
  writefits, output1, F_array, prihdr
  result = string('wavelength calibration image done...       ' + output1)
  return, result
  
end