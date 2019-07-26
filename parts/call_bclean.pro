function call_bclean, input


  input = STRTRIM(input, 1)
  input2 = FILE_BASENAME(input, '.sdf')
  output = string(input2 + '-cl.sdf')
  output = STRTRIM(output, 1)
  ;  SPAWN, 'figaro'
  ;
  CLOSE, 1
  
  SPAWN, 'rm call_bclean_123.csh'
  OPENW, 1, 'call_bclean_123.csh'
  PRINTF, 1, '#!/bin/csh'
  PRINTF, 1, 'figaro \n'
  PRINTF, 1, 'bclean $1 out=$2 accept'
    CLOSE, 1
  SPAWN, 'chmod +x call_bclean_123.csh'
  command1 = string('./call_bclean_123.csh ' + input + ' ' + output)
  print, command1
  SPAWN, command1
  SPAWN, 'rm call_bclean_123.csh'
  return, output
end