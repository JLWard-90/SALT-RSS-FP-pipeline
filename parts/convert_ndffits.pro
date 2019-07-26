function convert_ndffits, input

  input = STRTRIM(input, 1)
  input2 = FILE_BASENAME(input, '.sdf')
  output = string(input2 + '.fits')
  output = STRTRIM(output, 1)
  ;  SPAWN, 'figaro'
  ;
  CLOSE, 1
  
  SPAWN, 'rm convert_images_fits.csh'
  OPENW, 1, 'convert_images_fits.csh'
  PRINTF, 1, '#!/bin/csh'
  PRINTF, 1, 'convert \n'
  PRINTF, 1, 'ndf2fits $1 $2 \n'
    CLOSE, 1
  SPAWN, 'chmod +x convert_images_fits.csh'
  command1 = string('./convert_images_fits.csh ' + input + ' ' + output)
  SPAWN, command1
  SPAWN, 'rm convert_images_fits.csh'
  return, output
  
end