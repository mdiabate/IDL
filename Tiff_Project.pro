e=envi()


dir = 'F:\LandsatImagery\Landsat_SR\14_33\LT50140332011115GNC01-sr_25_APR_2011'
cd, dir

FileList= file_search('*.hdf') ;search directory for hdf files and list then
Nf = N_Elements(FileList)
;spatialaa = filelist
spatials=OBJARR(NF)

for g = 0, nf-1 do begin
  
  FILEHDF = Filelist[g]
  ;OAFILEHDF = filelist[0]

  

  ;envi_open_data_file, srfilehdf, /hds, r_fid=fid
  print, 'Reading HDF and extracting Projection info'
  raster = e.OpenRaster(filehdf, external_type='landsat_hdf');, external_type='landsat_hdf');, external_type='landsat_hdf')
  Rspatial = raster[0].spatialref
  
  ;save, spatial, filename = 'spatial.sav'
  ;'meta = srraster[0].metadata
  
  
  spatials[g] = Rspatial
;  
;  toaraster = e.OpenRaster(toafilehdf, external_type='landsat_hdf');, external_type='landsat_hdf');, external_type='landsat_hdf')
;  toaspatial = toaraster[0].spatialref
  save, spatials, filename = 'Projection.sav'

endfor
;LANDSATNAME = file_basename(SRFILEHDF)
;LandsatID = strmid(lANDSATNAME,6,21)
;fileYear= strmid(LandsatID, 9, 4)
;filedoy= strmid(LandsatID, 13, 3)
;;filedate = strmid(LandsatID, 22, 11)
;FileDate = DATECONVERT(Fileyear, filedoy)

dires = file_search(dir, '*', /Test_directory)
nd = n_elements(dires)
;srdire = dir + '\SR_OUTPUT'
;toadire = dir + '\TOA_OUTPUT'
;DIRES = [SRDIRE, TOADIRE]


FOR h = 0, nd-1 DO BEGIN

  if h eq 0 then spatial = spatials[0] else $
  if h eq 1 then spatial = spatials[1]
  
  cd, dires[h]
  
  FileList= file_search('*.tif') ;search directory for hdf files and list then
  N = N_Elements(FileList) ;number of hdf file founds
  
  
  print, 'Processing: ' + dires[h]
  
    for i = 0, N-1 DO BEGIN
      
      Tiff = filelist[i]
      ;Tiffe = read_tiff(tiff)
      Print, 'processing: ' + tiff
      ;envi_open_file, tiff, /invisible, /no_interactive_query, /no_realize, r_Fid = fida
      
      data = e.openraster(tiff, spatialref_override=Spatial)
     ;datatiff = e.createraster('tiffprj_st', , data_type='float', spatialref =spatial)
    ;  fid = envirastertofid(dataa)
    ;  envi_file_query, fid, dims=dims, nb=nb
    ;  pos=lindgen(nb)
      filename = strsplit(tiff, '.', /extract)
      outname = filename[0]+'_WGS84.tif'
     ; envi_output_to_external_format, fid = fid, dims=dims, out_name=LandSatID+'_toa_'+FileDate+'_stack_WGS84.tif', pos=pos, /tiff
      
      e.exportraster, data, outname, 'TIFF'
      
      print, 'Exported: '+ outname
      
      file_delete, tiff, /QUIET
    endfor
    
  print, 'Completed: ' + dires[h]
  
ENDFOR
print, 'End of program'
END
  