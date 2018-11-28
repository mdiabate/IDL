;###############################################################################
;## Name: TOA_Mask.pro
;## Authors: M. Diabate; H. W. Dean 
;## USDA Agriculture Research Service
;## Beltsville, MD 20705
;##
;## Last Modified: 9/27/2013
;## 
;## Purpose: Apply the following to Landsat Top of Atmosphere scene
;##         1. Read HDF
;##         2. Apply Cloud, Snow mask
;##         3. Process NDVI, NDRI
;##         4. Export Stack, NDVI and NDRI as geotiff
;## 
;## Required Files:  
;##           1. ESPA processed LandSat Top Of Atmosphere as HDF
;##           2. ESPA processed Landsat Surface Reflectance as HDF
;##           2. NDVI image file downloaded from ESPA (to import coordinate)
;##################################################################################
;start Envi
e=envi(/HEADLESS)

dir = 'F:\LandsatImagery\Landsat_SR\14_33\LE70140332009309EDC00-sr_5_NOV_2009'
;User select folder and Landsat files
;dir = dialog_pickfile(/DIRECTORY ,title ='Choose folder containing landsat files')
cd, dir

SRFILEHDF = dialog_pickfile(/READ,title ='Select SR files',filter ='*.hdf'); SR Image

TOAFILEHDF = dialog_pickfile(/READ,title ='Select TOA files',filter ='*.hdf') ;TOA Image



Print, '******* Starting TOA Script *****'

FileID=HDF_SD_START(SRFILEHDF, /READ) ;Read HDF FILE
    HDF_SD_FileInfo, FileID, No, na ;Query hdf file for number of bands
    
    ;; Extract Masks values
       ;Scan Line Masks
      thisSDS = HDF_SD_Select(fileid, 0)
      HDF_SD_getInfo, thisSDS, name=thisSDSname,  COORDSYS=C
      
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
;TOA image read
    toaFile=HDF_SD_START(toaFILEHDF, /READ) ;Read HDF FILE
    HDF_SD_FileInfo, toaFile, toAN, toana ;Query hdf file for number of bands
   
   ;apply mask to TOA image.
    for j=0, toAN-1 do begin
     
      thisSDS = HDF_SD_Select(toafile, j)
      HDF_SD_GetInfo, thisSDS, Name=thisSDSname
      HDF_SD_GETDATA, thissds, band
     
      
      bandf=float(band) ;convert to float
      
      bandf[Scan_ind] = !VALUES.f_NAN  ;Scan line are changed to NAN
      
      bandf[Cl_ind] = !VALUES.f_NAN  ;Cloud value are changed to NAN
      
      bandf[Snow_ind] = !VALUES.f_NAN  ;Snow values are changed to NAN
 
    
      ;Export RGB, NIR and MIR bands individually
      if j eq 0 then bBlue = bandf else $
      if j eq 1 then bGreen = bandf else $
      if j eq 2 then bRED = bandf else $
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
    
LANDSATNAME = file_basename(SRFILEHDF)
LandsatID = strmid(lANDSATNAME,6,21)
fileYear= strmid(LandsatID, 9, 4)
filedoy= strmid(LandsatID, 13, 3)
FileDate = DATECONVERT(Fileyear, filedoy)

;;Open HDF and extract Spatial Reference Value
raster = e.OpenRaster(toafilehdf, external_type='landsat_hdf');, external_type='landsat_hdf');, external_type='landsat_hdf')
Rspatial = raster[0].spatialref

print, "Spatial Reference is extracted"

file_mkdir, 'TOA_Output' ;creates and output directory
cd, c=c
outdir = c + '\TOA_Output'

cd, outdir 

;;Create Stack Raster and Export to Geotiff
stackname = LandSatID+'_toa_'+FileDate+'_Stack.tif'
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
NDVIname = LandSatID+'_toa_'+FileDate+'_NDVI.tif'
e.exportraster, NDVIRaster, NDVIname, 'TIFF'

print, "NDVI band is created"
ndrimetadata = e.createrastermetadata()
ndrimetadata.additem, 'Band Names',['NDRI']

NDRIRaster = e.createraster('NDRI', bNDRI, spatialref = rspatial, metadata = ndrimetadata)
NDRIRaster.save
NDRIname = LandSatID+'_toa_'+FileDate+'_NDRI.tif'
e.exportraster, NDRIRaster, NDRIname, 'TIFF'

print, "NDRI band is created"



print, '=========================================================='
print, '!!!!! END OF PROGRAM !!!!!'
print, '=========================================================='


end