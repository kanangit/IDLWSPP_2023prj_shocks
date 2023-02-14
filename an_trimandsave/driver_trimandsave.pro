;v.0.23instability 20181004 trimming for seminar
;v.0.21claster 2018.09.28 bulk vel for liquid 2800 movie 457
;v.0.20claster 2018.09.27 bulk vel for liquid 3200 movie 442
;v.0.19 claster 2018.09.26. For the calculation of the bulk vel.
; on the claster computer. Saves the particle postions 3 different ways now.
; 
;v.0.18 2018.09.26 for calculating bulk vel. on the instability computer 
;v.0.17 from instability computer. 
;v.0.16 the routine seletcs the region of interest and saves as a new file. For huge files and small region of interests this could be a real time saver
PRO driver_trimandsave
curDate='20230209'
leftBorder = 178.0d
rightBorder= 300.0d;
yMin = 420.0d;
yMax = 1392.0d
iBegin = 0 
iEnd = 299
;leftBorder = 550.0d
;rightBorder= 850.0d;
;yMin = 0.0d;
;yMax = 1215.0d
;iBegin=1000 
;iEnd = 1250
coreName = STRCOMPRESS('ff'+STRING(iBegin)+'-' + STRING(iEnd) + '_' + STRING(curDate) + 'positionTrimmedForVid063_1', /REMOVE_ALL)

CD, 'C:\Users\kanton\OneDrive - University of Iowa\bDocs\prj_shocks\data20230207\soliton_240fps_63-1\analysis\20230208histog\03_code_an_trimandsave\'
CD, 'inputs'

s = readTrackPy()

;exclude all the bad elements of the data:
indGood = WHERE(FINITE(s.iparticle) AND FINITE(s.iFrame) $
 AND FINITE(s.area) AND FINITE(s.X) AND FINITE(s.Y) $
 AND FINITE(s.error))
iParticleTrim = s.iparticle[indGood]
iFrameTrim = s.iFrame[indGood]
areaTrim = s.area[indGood]
XTrim = s.X[indGood]
Ytrim = s.Y[indGood]
errorTrim = s.error[indGood]



;stop
;select the region of interest:
indROI = WHERE(XTrim LE rightBorder AND XTrim GE leftBorder AND Ytrim LE ymax AND Ytrim GE yMin AND iFrameTrim GE iBegin AND iFrameTrim LE iEnd)

Iparticle = iParticleTrim[indROI]
iFrame = iFrameTrim[indROI]
area = areaTrim[indROI]
X = XTrim[indROI]
Y = Ytrim[indROI]
error = errorTrim [indROI]
;preparing to save the data:
CD, '..\outputs'
;append the number of secods since January 1 1970 to make the
;filename distinguishable:
seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
fnam = STRCOMPRESS(corename + seconds + '.txt',/REMOVE_ALL)
resSave = print6arrays(fnam,iParticle,iFrame,area,X,Y,error, /firstinteger)

fnamWRITE_CSV = STRCOMPRESS(corename + seconds + 'WRITE_CSV.txt',/REMOVE_ALL) 

WRITE_CSV, fnamWRITE_CSV, iParticle, iFrame, area, X, Y, error

s = 0; save the memory

;saving this same data more fast way, as a snapshot of an IDL variable s:

nelements = N_ELEMENTS(X)
s = {iParticle:LONARR(nelements),iFrame:LONARR(nelements), $
 area:DBLARR(nelements), X:DBLARR(nelements),Y:DBLARR(nelements),error:DBLARR(nelements)}
s.iParticle = iParticle
s.iFrame = iFrame
s.area = area
s.X = X
s.Y = Y
s.Error = error

fnamSAV = STRCOMPRESS(corename + seconds + '.sav',/REMOVE_ALL)
SAVE, s,  FILENAME = fnamSAV

END