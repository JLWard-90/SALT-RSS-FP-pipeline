;Here is the complete pipeline for SALT Fabry-Perot data reduction version 0.1.4
;updated 11/02/2016
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Start, obtain system time;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compile the relevant functions...
;RESOLVE_ROUTINE, 'convert_ndf', /IS_FUNCTION

pro salt_fp_pipeline_0.1.4

!quiet = 1
!except = 1
CATCH, Error_status



;This statement begins the error handler:

IF Error_status NE 0 THEN BEGIN

  PRINTf, 8, 'Error index: ', Error_status

  PRINTf, 8, 'Error message: ', !ERROR_STATE.MSG

  ; Handle the error by extending A:
    sysT_err = systime(/UTC)
    CATCH, /CANCEL
    printf, 8, string('program stopped due to above error.')
    printf, 8, string('time: ' + sysT_err)
    close, 8
    STOP

ENDIF

print,'      IDL Fabry-Perot data pipeline           '
print,'           version 0.1.4                      '

sysT = systime(/UTC)
;C = string(sysT)
;sysT = STRTRIM(C, 1)
sysT_arr = strsplit(sysT, ' :', /EXTRACT)
if (sysT_arr[1] eq 'Jan') then month1 = 1
if (sysT_arr[1] eq 'Feb') then month1 = 2
if (sysT_arr[1] eq 'Mar') then month1 = 3
if (sysT_arr[1] eq 'Apr') then month1 = 4
if (sysT_arr[1] eq 'May') then month1 = 5
if (sysT_arr[1] eq 'Jun') then month1 = 6
if (sysT_arr[1] eq 'Jul') then month1 = 7
if (sysT_arr[1] eq 'Aug') then month1 = 8
if (sysT_arr[1] eq 'Sep') then month1 = 9
if (sysT_arr[1] eq 'Oct') then month1 = 10
if (sysT_arr[1] eq 'Nov') then month1 = 11
if (sysT_arr[1] eq 'Dec') then month1 = 12
sysTs = TIMESTAMP(YEAR = sysT_arr[6], MONTH = month1, DAY = sysT_arr[2], HOUR = sysT_arr[3], MINUTE = sysT_arr[4], SECOND = sysT_arr[5])

log_fname = string('SALT_FP_pipeline_' + sysTs + '.log')
openw,8, log_fname;, /get_lun
    printf, 8, string('IDL SALT Fabry-Perot Pipeline v0.1.4')
    printf, 8, 'Start time: ', sysTs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;read in inputs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

input1 = ''
READ, input1, PROMPT='Input list of fits files: '
printf, 8, string('Input file list: ' + input1)
data_template = ASCII_TEMPLATE(input1)
list_fits = READ_ASCII(input1, template=data_template)
Restw = 0.0
Read, Restw, PROMPT='Rest wavlength of emission line: '
printf, 8, 'Input rest wavelength of target line: ', Restw
arcF = ''
Read, arcF, PROMPT='Input arclamp fits: '
printf, 8, string('Input radial wavelength shift solution file: ' + arcF)
arcwav = 0.0
etpos = 0.0
arclampname = ''
arcdata_hdr2 = READFITS(string(arcF), archdrdetails, /NOSCALE,Exten_no=0)
arclampname = SXPAR(archdrdetails, 'LAMPID')
etpos = SXPAR(archdrdetails, 'ET2WAVE0')
print, 'Arc lamp ID is ', arclampname, 'etalon wavelength position is', etpos, ' enter wavelength of line'
printf, 8, string('Arc lamp ID is ' + string(arclampname) + 'etalon wavelength position is' + string(etpos) + ' enter wavelength of line')
Read, arcwav, PROMPT='wavelength of arc lamp: '
printf, 8, string('Input rest wavelength of arc line: ' + string(arcwav))
REST_LAMBDA1 = Restw
whichet = 0
while (whichet eq 0) do begin
READ, whichet, PROMPT='Which etalon determines the wavelength (1 or 2)?: '
if (whichet lt 0) or (whichet gt 2) then whichet = 0
endwhile
ref_ans = ''
ref_test = 0
while (ref_test eq 0) do begin
  READ, ref_ans, PROMPT='Is a reference image available for astrometry calibration?: '
  if (ref_ans eq 'y') or (ref_ans eq 'yes') or (ref_ans eq 'Y') or (ref_ans eq 'YES') or (ref_ans eq 'Yes') then ref_test = 1
  if (ref_ans eq 'n') or (ref_ans eq 'no') or (ref_ans eq 'NO') or (ref_ans eq 'No') or (ref_ans eq 'N') then ref_test = 2
endwhile

if (ref_test eq 1) then begin
  input_refim = ''
  READ, input_refim, PROMPT='Input reference image: '
  printf, 8, string('Input reference image file: ' + input_refim)
endif



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Prepare names for output files;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

input1_base = FILE_BASENAME(input1, '.dat')
wavelistout = string(input1_base + '_wavelist' + string(sysTs) + '.dat')
output_arcsol = 'arc_wavecal_' + string(sysTs) + '.fits'
wavelist_name = string(input1_base + '_wavelist_' + string(sysTs) + '.dat')
output_cube = string(input1_base + '_cube_' + string(sysTs) + '.fits')
output_sumim = string(input1_base + '_sum_' + string(sysTs) + '.fits')
output_contsubcube = string(input1_base + '_contsubcube_' + string(sysTs) + '.fits')
output_contim = string(input1_base + '_contim_' + string(sysTs) + '.fits')
output_nocontim = string(input1_base + '_contsubim_' + string(sysTs) + '.fits')
output_linemap = string(input1_base + '_intfluxim_' + string(sysTs) + '.fits')
output_linerrmap  = string(input1_base + '_intferrim_' + string(sysTs) + '.fits')
output_velmap = string(input1_base + '_velmap_' + string(sysTs) + '.fits')
output_velerrmap = string(input1_base + '_velerrmap_' + string(sysTs) + '.fits')
output_centmap = string(input1_base + '_centmap_' + string(sysTs) + '.fits')
output_centerrmap = string(input1_base + '_centerrmap_' + string(sysTs) + '.fits')
;Read, output1, PROMPT='Output file name: '


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Use figaro bclean function to clean all images;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Cleaning images...')

N = N_ELEMENTS(list_fits.Field1)
List_cleaned = MAKE_ARRAY(N, VALUE='')
for i = 0, N -1 do begin
  input_now = string(list_fits.Field1[i])
  ;print, input_now
  a = convert_ndf(input_now)
  b = call_bclean(a)
  c = convert_ndffits(b)
  List_cleaned[i] = c
endfor

printf, 8, string('Cleaning images complete')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Obtain additional header information.... ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Combining fits header information...')

N = N_ELEMENTS(list_fits.Field1)
for i = 0, N -1 do begin
  input_old = string(list_fits.Field1[i])
  input_now = List_cleaned[i]
  data = READFITS(input_now, prihdr, /NOSCALE)
  crapdata = READFITS(input_old, exthdr, /NOSCALE, exten_no=0)
  SXDELPAR, exthdr, 'NAXIS'
  SXDELPAR, exthdr, 'BITPIX'
  SXDELPAR, exthdr, 'SIMPLE'
  SXDELPAR, exthdr, 'EXTEND'
  SXDELPAR, prihdr, 'END'
  newhdr = [prihdr, exthdr]
  writefits, input_now, data, newhdr
endfor

printf, 8, string('Fits headers combined')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make radial wavelength shift calibration solution ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Calculating radial wavelength solution...')

done1 = wavcal_SALTFP(arcF, arcwav, output_arcsol)
print, done1

print, 8, 'Radial wavelength solution complete, output: ', output_arcsol

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compile cube and produce list of image wavelengths;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Compiling initial data cube...')

lambda_list =  compile_Cube(list_cleaned, wavelist_name, output_cube, whichet)

printf, 8, string('Data cube compiled')
printf, 8, string('Outputs:')
printf, 8, string(output_cube)
printf, 8, string(wavelist_name)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate astrometry parameters;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Calculating inital astrometry solution...')
ast_cal_cube = astrCalc(output_cube)
printf, 8, string('Initial astrometry calculation done.')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make sum image;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Making sum image...')

data1 = readfits(ast_cal_cube, prihdr, /NOSCALE)
Xpix = SXPAR(prihdr, 'NAXIS1')
Ypix = SXPAR(prihdr, 'NAXIS2')
Zpix = SXPAR(prihdr, 'NAXIS3')
data_sumout = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)

for i = 0, Xpix-1 do begin
  for j=0, Ypix-1 do begin
    sum = 0.0
    for k = 0, Zpix-1 do begin
      sum = sum + data1[i,j,k]
    endfor
    data_sumout[i,j] = sum
  endfor
endfor

writefits, output_sumim, data_sumout, prihdr

printf, 8, string('Sum image done. Output: ' + output_sumim)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fit continuum to cube;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Start continuum fitting...')

data1 = readfits(ast_cal_cube, prihdr, /NOSCALE)
Xpix = SXPAR(prihdr, 'NAXIS1')
Ypix = SXPAR(prihdr, 'NAXIS2')
Zpix = SXPAR(prihdr, 'NAXIS3')

X_fitR = MAKE_ARRAY(4, VALUE=0)
Y_fitR = MAKE_ARRAY(4, VALUE=0)
X_fitR[0] = 0
X_fitR[1] = 1
X_fitR[2] = Zpix-2
X_fitR[3] = Zpix-1

data_contsub = MAKE_ARRAY(Xpix, Ypix, Zpix, /DOUBLE, VALUE=0.0)

for i = 0, Xpix-1 do begin
  for j=0, Ypix-1 do begin
    Y_fitR[0] = data1[i,j,0]
    Y_fitR[1] = data1[i,j,1]
    Y_fitR[2] = data1[i,j,(Zpix-2)]
    Y_fitR[3] = data1[i,j,(Zpix-1)]
    wavesol1 = POLY_FIT(X_fitR, Y_fitR, 1)
    wavesol2 = MAKE_ARRAY(Zpix, /DOUBLE, VALUE=0.0)
    for k=0, Zpix-1 do begin
      wavesol2[k] = wavesol1[0] + (wavesol1[1] * k)
      data_contsub[i,j,k] = data1[i,j,k] - wavesol2[k]
    endfor
  endfor
endfor
writefits, output_contsubcube, data_contsub, prihdr
printf, 8, string('Output continuum subtracted cube: ' + output_contsubcube)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get continuum and continuum subtracted images;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



data_contimout = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)
data_nocontimout = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)

printf, 8, string('Calculating continuum and continuum subtracted images... ')

for i = 0, Xpix-1 do begin
  for j=0, Ypix-1 do begin
    sum = 0.0
    for k = 0, Zpix-1 do begin
      if ((data1[i,j,k] - data_contsub[i,j,k]) gt 0.0) then sum = sum + data1[i,j,k] - data_contsub[i,j,k]
    endfor
    data_contimout[i,j] = sum
  endfor
endfor

for i = 0, Xpix-1 do begin
  for j=0, Ypix-1 do begin
    sum = 0.0
    for k = 0, Zpix-1 do begin
      if (data_contsub[i,j,k] gt 0.0) then sum = sum + data_contsub[i,j,k]
      endfor
    data_nocontimout[i,j] = sum
  endfor
endfor

writefits, output_contim, data_contimout, prihdr
writefits, output_nocontim, data_nocontimout, prihdr
printf, 8, string('done!')
printf, 8, string('Continuum image output: ' + output_contim)
printf, 8, string('Continuum subtracted image output: ' + output_nocontim)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Create initial wavelength solution based on etalon positions;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Getting initial wavelength solution from etalon positions...')

Y2 = MAKE_ARRAY(N_elements(lambda_list), /DOUBLE, VALUE=0.0)
X2 = MAKE_ARRAY(N_elements(lambda_list), /DOUBLE, VALUE=0.0)
wavesol2 = MAKE_ARRAY(N_elements(lambda_list), /DOUBLE, VALUE=0.0)
for i = 0, (N_elements(lambda_list)-1) do begin
  Y2[i] = lambda_list[i]
  printf, 8, Y2[i]
  X2[i] = i
endfor
print, N_elements(wavesol2)
print, N_elements(X2)
wavesol1 = POLY_FIT(X2, Y2, 1)
printf, 8, 'Initial wavlength solution param: ', wavesol1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fit emission lines in continuum subtracted cube and output the final maps;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  pi = 3.14159265359

  printf, 8, string('Assuming pi is 3.14159265359...')
  printf, 8, string('Initialising automated line fitting routine.')
  printf, 8, string('This process may take a while...')
coeff_array = fit_lines_FP(output_contsubcube)
  printf, 8, string('line coefficients have been calculated')
coeff_size = SIZE(coeff_array)
Xpix = coeff_size[1]
Ypix = coeff_size[2]

out_dat = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)
out_err = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)
out_cent = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)
out_centerr = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)
out_vel = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)
out_velerr = MAKE_ARRAY(Xpix, Ypix, /DOUBLE, VALUE=0.0)

printf, 8, string('Calculating integrated flux map and integrated flux uncertainty map...')
for i = 0, Xpix-1 do begin
  for j = 0, Ypix-1 do begin
    coeff = MAKE_ARRAY(6, /DOUBLE, VALUE=0.0)
    sig1 = MAKE_ARRAY(6, /DOUBLE, VALUE=0.0)
    for k = 0, 5 do begin
      coeff[k] = coeff_array[i,j,k]
    endfor
    for k=6, 11 do begin
      sig1[k-6] = coeff_array[i,j,k]
    endfor
    line_integral = double(coeff[0] * sqrt(2*pi*(coeff[2]^2)))
    ;line integral error calculation:
     A2_sqrt_etc = double(sqrt(2*pi*(coeff[2]^2)))
     A2_sqrt_etc_error = double(0.5*(1/sqrt(A2_sqrt_etc))*2*pi*2*coeff[2]*sig1[2])
     line_integral_error = double(line_integral * sqrt((sig1[0]/coeff[0])^2+(A2_sqrt_etc_error/(A2_sqrt_etc))^2))
     out_cent[i,j] = coeff[1]
     out_centerr[i,j] = sig1[1]
     ;   if (coeff[1] gt 36) or (coeff[1] lt 0) then line_integral = 'NaN'
     out_dat[i,j] = line_integral
     out_err[i,j] = line_integral_error
     if (out_err[i,j] gt out_dat[i,j]) then out_dat[i,j] = !VALUES.D_NAN
  endfor
endfor
printf, 8, string('done!')
Fdata = READFITS(output_arcsol, craphdr, /NOSCALE)
max_end = N_ELEMENTS(lambda_list)-1
printf, 8, string('Calculating wavelength and velocity maps...')
for i = 0, Xpix-1 do begin
  for j = 0, Ypix-1 do begin
    out_cent[i,j] = wavesol1[0] + (wavesol1[1] * out_cent[i,j])
    out_cent[i,j] = out_cent[i,j] - Fdata[i,j]
    out_vel[i,j] = (((out_cent[i,j] - rest_lambda1) / rest_lambda1) * (3.0*(10^8.0))) / 1000
    if (out_cent[i,j] gt (lambda_list[max_end] + 10)) or (out_cent[i,j] lt (lambda_list[0]-10)) then begin
      out_dat[i,j] = !VALUES.D_NAN
      out_cent[i,j] = !VALUES.D_NAN
      out_vel[i,j] = !VALUES.D_NAN
      out_err[i,j] = !VALUES.D_NAN
    endif
    ;out_velerr[i,j] = ((out_centerr / 6562.817) * (3.0*(10^8.0))) / 1000
  endfor
endfor
printf, 8, 'done!'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make output map headers;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

linmap_hdr = prihdr
SXADDPAR, linmap_hdr, ['NAXIS'], 2
SXDELPAR, linmap_hdr, 'NAXIS3'
SXADDPAR, linmap_hdr, ['HISTORY'], string('Reduced: ' + sysTs)
linerrmap_hdr = linmap_hdr
cenmap_hdr = linmap_hdr
velmap_hdr = linmap_hdr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Write final fits files;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

writefits, output_linemap, out_dat, linmap_hdr
writefits, output_linerrmap, out_err, linerrmap_hdr
writefits, output_centmap, out_cent, cenmap_hdr
writefits, output_velmap, out_vel, velmap_hdr
printf, 8, string('Writing fits files...')
printf, 8, string(output_linemap)
printf, 8, string(output_linerrmap)
printf, 8, string(output_centmap)
printf, 8, string(output_velmap)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Perform astrometry correction....;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printf, 8, string('Starting DS9 and asking the user for input (fingers crossed!)...')
if (ref_test eq 1) then begin
  string_ds9 = string('ds9 -rgb red ' + string(input_refim) + ' -rgb blue ' + string(output_sumim) + ' &')
  SPAWN, string_ds9

  print, 'The summed image and reference image should now be displayed in SAO ds9.'
  print, 'The reference image is shown in red and the newly reduced summed image is'
  print, 'shown in blue.'
  print, 'Using whatever measurement method you prefer please check the astrometry'
  print, 'and input the differences in degrees below.
  print, 'Positive values will shift the new image positively (i.e. N and E)'
  RA_shift = 0.0
  Dec_shift = 0.0
  printf, 8, string('Astrometry correction shifts:')
  printf, 8, string('RA:' + RA_shift)
  printf, 8, string('Dec:' + Dec_shift)
  READ, RA_shift, PROMPT='RA shift: '
  READ, Dec_shift, PROMPT='Dec shift: '
  printf, 8, string('RA:' + RA_shift)
  printf, 8, string('Dec:' + Dec_shift)
  printf, 8, string('Calculating new RA and Dec...')
  print, 'Thanks! Calculating new values now...'
  CRRA1 = SXPAR(prihdr, 'CRVAL1')
  CRDec1 = SXPAR(prihdr, 'CRVAL2')
  CRRA2 = CRRA1 + RA_shift
  CRDec2 = CRDec1 + Dec_shift
  print, 'And copying into all output headers...'
  input_keys1 = MAKE_ARRAY(2, /DOUBLE, VALUE=0.0)
  input_keys1[0] = string(CRRA2)
  input_keys1[1] = string(CRDec2)

  list_of_outputs = [output_sumim, output_contsubcube, output_contim, output_nocontim, output_linemap, output_linerrmap, output_centmap, output_velmap]
  printf, 8, string('updated astrometry in the following fits files...')
for i = 0, 7 do begin
  input_file = list_of_outputs[i]
  data = READFITS(input_file, prihdr, /NOSCALE)
 ; RA_new = input_keys1[0]
 ; Dec_new = input_keys1[1]
  SXADDPAR, prihdr, ['CRVAL1'], CRRA2
  SXADDPAR, prihdr, ['CRVAL2'], CRDec2
  writefits, input_file, data, prihdr
  printf, 8, string(input_file)
endfor

 ; cpy_to_hdr, output_sumim, input_keys1
 ; cpy_to_hdr, output_contsubcube, input_keys1
 ; cpy_to_hdr, output_contim, input_keys1
 ; cpy_to_hdr, output_nocontim, input_keys1
 ; cpy_to_hdr, output_linemap, input_keys1
 ; cpy_to_hdr, output_linerrmap, input_keys1
 ; cpy_to_hdr, output_centmap, input_keys1
 ; cpy_to_hdr, output_velmap, input_keys1

endif

print, 'done!'

sysT = systime(/UTC)
;C = string(sysT)
;sysT = STRTRIM(C, 1)
sysT_arr = strsplit(sysT, ' :', /EXTRACT)
if (sysT_arr[1] eq 'Jan') then month1 = 1
if (sysT_arr[1] eq 'Feb') then month1 = 2
if (sysT_arr[1] eq 'Mar') then month1 = 3
if (sysT_arr[1] eq 'Apr') then month1 = 4
if (sysT_arr[1] eq 'May') then month1 = 5
if (sysT_arr[1] eq 'Jun') then month1 = 6
if (sysT_arr[1] eq 'Jul') then month1 = 7
if (sysT_arr[1] eq 'Aug') then month1 = 8
if (sysT_arr[1] eq 'Sep') then month1 = 9
if (sysT_arr[1] eq 'Oct') then month1 = 10
if (sysT_arr[1] eq 'Nov') then month1 = 11
if (sysT_arr[1] eq 'Dec') then month1 = 12
sysTs = TIMESTAMP(YEAR = sysT_arr[6], MONTH = month1, DAY = sysT_arr[2], HOUR = sysT_arr[3], MINUTE = sysT_arr[4], SECOND = sysT_arr[5])

printf, 8, string('Successfully finished, ' + sysTs)
close, 8
!quiet = 0
!except = 0
end
