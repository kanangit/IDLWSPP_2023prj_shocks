; v0.1
;
; NAME:
;       readTrackPy
;
; PURPOSE:
;       This function reads the output file "position.cvs"
;       file must consist of the columns of data in the following
;       order: particle number, frame label, particle area,
;       paricle x-coordinate, particle y-coordinate, slice number.
;       It is assumbed that columns are separated by commas
;       and arbitrary number of spaces AND/OR tabs.
;
; CALLING SEQUENCE:
;       Result = readTrackPyK()
;
; INPUTS
;       The fuction doesn't have input variables.
;
; OUTPUTS
;       A structure with the following tags:
;         .iParticle  - an array of particle numbers
;         .iFrame     - an array of frame numbers
;         .X          - an array of x-coordinate of the particles
;         .Y          - an array of y-coordinate of the particles
;         .area       - an array with area of the particles
;         .error      - an array with errors in particle positions
;
;
; PROCEDURE:
;
;
; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, February 2023
;           Modified:    Anton Kananovich, February 2023.
;                         Optimized for memory economy. Now works

;-



function readTrackPy, path
  numParams = N_Params()
  IF (numParams EQ 0) THEN BEGIN
    filename = DIALOG_PICKFILE(/READ, FILTER = '*.csv')
  ENDIF
  IF (numParams EQ 1) THEN BEGIN
    filename = path
  ENDIF


  returnStructur = 0
  ;check if the template file exist
  existance = FILE_TEST('readTrackPyTemplate.sav')
  ; if it does not exist, ask user to create one:
  if (existance EQ 0) then begin
    rTemplate = ASCII_TEMPLATE(filename)
    SAVE, rTemplate, FILENAME='readTrackPyTemplate.sav'
    existance = 1
  endif
  ;obtain the file template rTemplate stored in the
  ;file 'readImageJKtemplate.sav':
  RESTORE, 'readTrackPyTemplate.sav'
  ;input the data
  inputStructur = READ_ASCII(filename, template=rTemplate)
  ;determine number of elements
  nelements = N_ELEMENTS(inputStructur.X)
  ;create a structure in which we store all the data our fucntion will return:
  returnStructur = {iParticle:LONARR(nelements),iFrame:LONARR(nelements), $
    area:DBLARR(nelements), X:DBLARR(nelements),Y:DBLARR(nelements),error:DBLARR(nelements)}

  ;prepare to convert framelabel (string) to frame number (integer)

  for i = 0L, nelements-1 do begin
    ;use the regexp syntax to determine the position of the frame number:
    pos = STREGEX(inputStructur.Framelabel[i], '([0-9]+)(\.|$)', length=len, /SUBEXPR) ;extract the
    ;framenumber out of the frame label string using regular expressions
    ;The regular expression '[0-9]+$' means
    ;"give me the end of the string, which contains digits only"
    returnStructur.iFrame[i] = LONG(STRMID(inputStructur.Framelabel[i],pos[1],len[1])); now we are ready to pass the
    ;frame number to the corresponding field of the return structure
  endfor
  returnStructur.iParticle = inputStructur.iParticle
  returnStructur.area = inputStructur.area
  returnStructur.X = inputStructur.X
  returnStructur.Y = inputStructur.Y
  returnStructur.error = inputStructur.error

  inputStructur = 0 ; free the memory
  RETURN, returnStructur
END