;###############################################################################
;## Name: SRProcess_Mask.pro
;## Date: 9/24/2013
;## Authors: M. Diabate; H. W. Dean 
;## USDA Agriculture Research Service
;## Beltsville, MD 20705
;## 
;## Purpose: 
;##         1. Apply Scan, Cloud and Snow Mask
;##         2. Calculate NDVI
;##         3. Calculate NDRI
;##         4. Export layers as geotiff
;## 
;## Required:  
;##           1. ESPA processed LandSat Surface Reflectance as HDF
;##################################################################################

;start Envi
e=envi(/HEADLESS)

;User select folder and Landsat files
DIR = 'F:\LandsatImagery\Landsat_SR\14_33\LE70140332009309EDC00-sr_5_NOV_2009'
;dir = dialog_pickfile(/DIRECTORY ,title ='Choose folder containing landsat files')
cd, dir

FILEHDF = dialog_pickfile(/READ,title ='Select SR Landsat File',filter ='*.hdf')

Print, '******* START SR Script *****'

;;Reads HDF and extracts Scan, cloud and snow bands
FileID=HDF_SD_START(FILEHDF, /READ) ;Read HDF FILE
    HDF_SD_FileInfo, FileID, No, na ;Query hdf file for number of bands

    ;; Extract Masks values
     ;Scan Line Masks
      thisSDS = HDF_SD_Select(fileid, 0)
      HDF_SD_getInfo, thisSDS, name=thisSDSname
      HDF_SD_GETDATA, thissds, Band1
      ScanVal = -9999
      Scan_Ind = where(band1 eq ScanVal)
      
      BadVal = 255
     ;Cloud Mask 
      thisSDS = HDF_SD_Select(fileid, 9)
      HDF_SD_GetInfo, thisSDS, Name=thisSDSname
      HDF_SD_GETDATA, thissds, Bcl
      cl_Ind = where(Bcl eq BadVal)
      
     ;Snow Masks 
      thisSDS = HDF_SD_Select(fileid, 11)
      HDF_SD_GetInfo, thisSDS, Name=thisSDSname
      HDF_SD_GETDATA, thissds, BSnow
      Snow_Ind = where(BSnow eq BadVal)
    

;; Apply masks indices to the rest of the bands
    for j=0, No-1 do begin
      thisSDS = HDF_SD_Select(fileid, j)
      HDF_SD_GetInfo, thisSDS, Name=thisSDSname
      HDF_SD_GETDATA, thissds, band
     
      bandf=float(band) ;convert to float

      bandf[Scan_ind] = !VALUES.f_NAN  ;Scan line are changed to NAN
      bandf[Cl_ind] = !VALUES.f_NAN  ;Cloud value are changed to NAN
      bandf[Snow_ind] = !VALUES.f_NAN  ;Snow values are changed to NAN
    
      ;Export RGB, NIR, MIR bands individually
      if j eq 0 then bBlue = bandf else $
      if j eq 1 then bGreen = bandf else $
      if j eq 2 then bRed = bandf else $
      if j eq 3 then bNIR = bandf else $
      if j eq 5 then bMIR = bandf
  
    endfor

    Print, "Bands are extracted and Masked' 

;;Create 3d Arrays and store RGB, NIR, MIR, Clouds and Snow bands
  dims = size(Band1,/dimensions)
  datarer = fltarr(7 ,dims[0],dims[1]) ;array for full extent image
  
  Datarer[0,*,*] = bBlue
  Datarer[1, *,*]= bGreen
  Datarer[2,*,*] = bRed
  Datarer[3,*,*] = BNir
  Datarer[4, *,*]= bMir
  Datarer[5,*,*] = BCL
  Datarer[6,*,*] = BSNOW
  
  print, "Stacked Array created"

;;Open HDF and extract Spatial Reference Value
raster = e.OpenRaster(filehdf, external_type='landsat_hdf');, external_type='landsat_hdf');, external_type='landsat_hdf')
Rspatial = raster[0].spatialref

  print, "Spatial Reference is extracted"

;;Extract LANDSATID and convert Julian date format
LANDSATNAME = file_basename(FILEHDF)
LandsatID = strmid(lANDSATNAME,6,21)
fileYear= strmid(LandsatID, 9, 4)
filedoy= strmid(LandsatID, 13, 3)
FileDate = DATECONVERT(Fileyear, filedoy)

;;Create the output directory
file_mkdir, 'SR_Output'
cd, c=c
outdir = c + '\SR_Output'
cd, outdir 

;;Create Stack Raster and Export to Geotiff
stackname = LandSatID+'_sr_'+FileDate+'_Stack.tif'
metadata = e.createrastermetadata()
metadata.additem, 'Band Names',['Blue','Green','Red','NIR','MIR','Cloud','Snow']
StackRaster = e.createraster('landsat_stack', datarer, Interleave = 'bip', spatialref = rspatial, metadata = metadata)
Stackraster.save
e.exportraster, StackRaster, stackname, 'TIFF'

Print, "Landsat layer stacked is created"
;;Calculate NDVI and NDVI bands and export to Geotiff
bNDVI = (bNIR - bRED) / (bNIR + bRED)
bNDRI = (bRED - bMIR) / (bRED + bMIR)

ndvimetadata = e.createrastermetadata()
ndvimetadata.additem, 'Band Names',['NDVI']

NDVIRaster = e.createraster('NDVI', bNDVI, spatialref = rspatial, metadata = ndvimetadata)
NDVIRaster.save
NDVIname = LandSatID+'_sr_'+FileDate+'_NDVI.tif'
e.exportraster, NDVIRaster, NDVIname, 'TIFF'

print, "NDVI band is created"
ndrimetadata = e.createrastermetadata()
ndrimetadata.additem, 'Band Names',['NDRI']

NDRIRaster = e.createraster('NDRI', bNDRI, spatialref = rspatial, metadata = ndrimetadata)
NDRIRaster.save
NDRIname = LandSatID+'_sr_'+FileDate+'_NDRI.tif'
e.exportraster, NDRIRaster, NDRIname, 'TIFF'

print, "NDRI band is created"


print, '=========================================================='
print, '!!!!! END OF PROGRAM !!!!!'
print, '=========================================================='

end