  ;+
  ; :Description:
  ;Based upon the code driver_fp_2018unexpected_hists.pro,

  ;
  ;
  ;
  ;
  ; :Author: Anton Kananovich
  ; created: 2023.02.11
  ; modified: 2023.02.12
  ;-
PRO driver_an_buildHistorgams

  curDate='20230211'
  framesSkip = 1
  ;define borders of the region of interest
  leftBorder = 178.0d
  rightBorder= 300.0d;
  yMin = 420.0d;
  yMax = 1392.0d
  ;start and and frames
  iBegin = 0
  ;iEnd =  1168 see below




  ;aWignerZeiss = 7.191d ;Wigner-Zeiss radius in pixels
  ;dy = 3.0d * aWignerZeiss
  dy = 14.0d
  ;pixelsInMM = 29.790d
  ;frameRate = 800.0d ;frames/s
  
  ;cutpulwid = dy*2.0d
  nB = FLOOR((yMax - yMin)/dY); number of bins
  yBins = DINDGEN(nB)*dY+yMin + dY/2

  CD, 'C:\Users\kanton\OneDrive - University of Iowa\bDocs\prj_shocks\data20230207\soliton_240fps_63-1\analysis\20230208histog\04_code_an_buildHistorgams\'
  CD, 'inputs'
  ;;s = readImageJK(/lowmem);

  filenam = DIALOG_PICKFILE(/READ, FILTER = '*.sav')
  RESTORE, filenam

  CD, '..\outputs\'

  iEnd = MAX(s.iframe)
  coreName = STRCOMPRESS('ff'+STRING(iBegin)+'-' + STRING(iEnd) + '_' + STRING(curDate))

  ;we need only the data inside the region of interest
  ind = WHERE(s.X LE rightBorder AND s.X GE leftBorder $
    AND s.Y LE ymax AND s.Y GE yMin)
  time = s.iframe[ind] ;array to track time
  Yroi = yMax - (s.Y[ind] - yMin) ;because the vertical screen coordinates
  Xroim = s.X[ind]
  ;are from top to bottom, we make this change of variables




  ;-----------------------------------------------------------------------

  ;create the arrays to store position of the shock front
  ;vs time:
  timeT = []

  maxDen = []

  max_pos = []


  CD, 'hists'
  FOR i=iBegin, iEnd, framesSkip DO BEGIN
    print, 'frame ', i
    ;building histogram using cloud-in-cell (cic):
    indf = WHERE(time EQ i)
    Y = Yroi[indf]
    YforHist = (Y - yMin)/(yMax-yMin + 1.0E-8)*DOUBLE(nB)
    weighNumDens = DBLARR(N_ELEMENTS(YforHist))+1 ; weights for the number density
    histNumDens = CIC(weighNumDens, YforHist, nB, /ISOLATED) / dy / (rightBorder - leftBorder)
    maxDen_i=MAX(histNumDens, max_pos_ind_i);
    maxDen = [maxDen,maxDen_i]
    max_pos_i = YBins[max_pos_ind_i]
    max_pos = [max_Pos,max_pos_i]
    timeT = [timeT,i]


    seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
    filename = STRCOMPRESS(STRING(i,FORMAT='(I04)') + '.csv', /REMOVE_ALL)
    z=print2arrays(filename,yBins, histNumDens)
    ; also save the particles positions in the frame:
    pixIDLx = Y
    pixIDLy = Xroim[indf]

    ;   thead=STRCOMPRESS('Frame ' + STRING(i,FORMAT='(I04)') + 'particle coordinates in orientation when shock propagates along X axis from left to right')
    ;   colhead = ['pixIDLx','pixIDLy']
    ;   fnamCSV = STRCOMPRESS('partPosPixels_frame'+ STRING(i,FORMAT='(I04)')+ '_' + seconds + '.csv', /REMOVE_ALL)
    ;   WRITE_CSV, fnamCSV, pixIDLx, pixIDLy, HEADER = colhead, TABLE_HEADER = thead

  ENDFOR
  CD, '..'
  seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
  filename = STRCOMPRESS('amplVsTime' + coreName + '_systime' + seconds + '.csv', /REMOVE_ALL)
  thead=STRCOMPRESS('max density (px-2) vs time (frames)')
  colhead = ['frame','maxDen']
  WRITE_CSV, filename, timeT, maxDen, HEADER = colhead, TABLE_HEADER = thead

  filename = STRCOMPRESS('maxPosVsTime' + coreName + '_systime' + seconds + '.csv', /REMOVE_ALL)
  thead=STRCOMPRESS('position of max denisty (in pixels) vs time (in frames)')
  colhead = ['frame','max_pos']
  WRITE_CSV, filename, timeT, max_pos, HEADER = colhead, TABLE_HEADER = thead
  print, "maxDensity =", MAX(maxDen)
END

END