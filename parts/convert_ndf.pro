;Cleaning:

function convert_ndf, input

  input = STRTRIM(input, 1)
  ;input3 = string(string(39B) + input + '[1]' + string(39B))
  ;print, input3
  input2 = FILE_BASENAME(input, '.fits')
  output = string(input2 + '.sdf')
  output = STRTRIM(output, 1)
  print, output
  ;  SPAWN, 'figaro'
  ;
  CLOSE, 1
  
  SPAWN, 'rm convert_images_ndf.csh'
  OPENW, 1, 'convert_images_ndf.csh'
  PRINTF, 1, '#!/bin/csh'
  PRINTF, 1, 'convert \n'
  PRINTF, 1, 'echo $1 \n'
    PRINTF, 1, 'fits2ndf \"$1\[1\]\" $2 \n'
    CLOSE, 1
  SPAWN, 'chmod +x convert_images_ndf.csh'
  command1 = string('./convert_images_ndf.csh ' + input + ' ' + output)
  ;  print, command1
  SPAWN, command1
  SPAWN, 'rm convert_images_ndf.csh'
  return, output
end