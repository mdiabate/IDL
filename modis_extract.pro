;  This example code illustrates how to access and visualize LP DAAC MOD13C2
; grid file in IDL. 
;
; If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS 
; data product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
; Define file name, grid name, and data field.


FUNCTION  Modis_extract, FILE_NAME, DATAFIELD_NAME
;CD, 'C:\users\Mouhamad\NASA\Assaf\Modis\'
;FILE_NAME='MOD13C2.A2000032.005.2006272104028.hdf'
GRID_NAME='MOD_Grid_monthly_CMG_VI'
;DATAFIELD_NAME='CMG 0.05 Deg Monthly NDVI'

; Open file.
file_id = EOS_GD_OPEN(FILE_NAME)

; Retrieve data.
grid_id = EOS_GD_ATTACH(file_id, GRID_NAME)
status = EOS_GD_READFIELD(grid_id, DATAFIELD_NAME, data)

; Close file.
status = EOS_GD_DETACH(grid_id)
status = EOS_GD_CLOSE(file_id)

; Retrieve attributes.
newFileID=HDF_SD_START(FILE_NAME, /READ)

index=HDF_SD_NAMETOINDEX(newFileID, DATAFIELD_NAME)

thisSdsID=HDF_SD_SELECT(newFileID, index)

long_name_index=HDF_SD_ATTRFIND(thisSdsID, 'long_name')
HDF_SD_ATTRINFO, thisSdsID, long_name_index, DATA=long_name

units_index=HDF_SD_ATTRFIND(thisSdsID, 'units')
HDF_SD_ATTRINFO, thisSdsID, units_index, DATA=units

scale_index=HDF_SD_ATTRFIND(thisSdsID, 'scale_factor')
HDF_SD_ATTRINFO, thisSdsID, scale_index, DATA=scale

offset_index=HDF_SD_ATTRFIND(thisSdsID, 'add_offset')
HDF_SD_ATTRINFO, thisSdsID, offset_index, DATA=offset

fillvalue_index=HDF_SD_ATTRFIND(thisSdsID, '_FillValue')
HDF_SD_ATTRINFO, thisSdsID, fillvalue_index, data=fillvalue

valid_range_index=HDF_SD_ATTRFIND(thisSdsID, 'valid_range')
HDF_SD_ATTRINFO, thisSdsID, valid_range_index, data=valid_range
HDF_SD_END, newFileID


;;;Calcluate lat/lon.
;;
;; Pixel must be centered.
;offsetX = 0.5
;offsetY = 0.5
;
;; We need to infer the limits of latitude and longitude because
;; This file has( -1.000000, -1.000000) for "UpperLeftPointMtrs" 
;; and "LowerRightMtrs" in StructMetadata.
;upleft = [-180.000000, 90.000000]
;lowright = [180.000000, -90.000000]
;lowright_d = floor(lowright)
;upleft_d = floor(upleft)
;dd = lowright_d-upleft_d
;lat_limit = dd(1)
;lon_limit = dd(0)
;
;; We need to calculate the grid space interval between two adjacent
;; points.
;dimsize=size(data,/dim)
;xdimsize = dimsize(0)
;ydimsize = dimsize(1)
;scaleX = lon_limit/float(xdimsize)
;scaleY = lat_limit/float(ydimsize)
;
;
;lon_value= FINDGEN(xdimsize)
;lat_value= FINDGEN(ydimsize)
;for i=0,xdimsize-1 do lon_value(i) = (i+offsetX)*(scaleX) + upleft_d(0);
;for j=0,ydimsize-1 do lat_value(j) = (j+offsetX)*(scaleY) + upleft_d(1);
;
;lon = float(lon_value)
;lat = float(lat_value)
;
;; Get min/max value for lat and lon.
;latmin=min(lat)
;latmax=max(lat)
;lonmin=min(lon)
;lonmax=max(lon)

; Convert data type.
dataf=float(data)


; Process fill value.
dataf[WHERE(data EQ fillvalue(0))] = !Values.F_NAN

; Process valid range.
dataf[WHERE(data LT valid_range(0) OR data GT valid_range(1))] = !Values.F_NAN

; Apply scale factor according to [1].
; Since add_offset is 0, we skip it in the following conversion.
dataf = dataf / scale(0)

;dataf = byte(dataf)

RETURN, dataf

END
















;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;XMap=[105.0, 155.0] 
;YMap=[-45.0, -5.0] 
;
;subset = data[XMap[0]:XMap[1],YMap[0]:YMap[1]]
;subset = float[subset];
;; Get max and min value of data.
;datamin = min(dataf, /NAN)
;datamax = max(dataf, /NAN)
;
;levels=254
;DEVICE, DECOMPOSED=0
;LoadCT,33, NCOLORS=levels, BOTTOM=1
;WINDOW, TITLE = 'FIELD:' + long_name + '  '+'UNIT:'+units
;MAP_SET, /GRID, /CONTINENTS, XMARGIN=5, YMARGIN=5, $
;  LIMIT=[latmin, lonmin, latmax, lonmax], POSITION=[0.05, 0.05, 0.82, 0.82]
;CONTOUR, dataf, lon, lat, /OVERPLOT, /CELL_FILL, C_Colors=Indgen(levels)+3, $
;  BACKGROUND=1, NLEVELS=levels, Color=Black
;MAP_GRID, /BOX_AXES, COLOR=255
;MAP_CONTINENTS, COLOR=255
;
;; Draw title and unit.
;XYOuts, 0.05, 0.86, /Normal, 'FIELD:' + long_name(0), $
;  Charsize=1.25, color=black, Alignment=0.0
;XYOuts, 0.82, 0.86, /Normal, 'UNIT:' + units, $ 
;  Charsize=1.25, Color=black, Alignment=1.0
;XYOuts, 0.43, 0.92, /Normal, FILE_NAME, $
;  Charsize=1.75, Color=black, Alignment=0.5
;
;; The following code is prepared for colorbar. 
;;
;;   If you require colorbar in your plot, you could download 
;; "Dr. Fanning's Coyote Library" from [2]. Make a directory named
;; coyote somewhere on your machine, and extract the Coyote files into
;; it. 
;;
;;   If color bar is not not necessary for your plot, you can ignore this
;; step and add comment character ';' ahead of coding. 
;;
;;    Add the coyote directory you create on your machine to your IDL
;;  path like below: 
;;
;; !PATH=Expand_Path('[coyote directory on your machine])+':'+!PATH
;
;; We assume that the coyote library is installed under the current working
;; directory that this code exists.
;!PATH=Expand_Path('+coyote/')+':'+!PATH
;
;;  The following code assumes that you've already download and installed 
;; "Dr. Fanning's Coyote Library" and add the coyote directory above. 
;;
;;  If you don't need color bar in your plot, you can ignore this step
;;  by adding comment character ';' at the beginning of the code.
;COLORBAR, Range=[datamin, datamax], Ncolors=levels, /Vertical, $
; Position=[0.9,0.05,0.94,0.8], FORMAT='(F4.1)'

; Reference
; [1]  https://lpdaac.usgs.gov/lpdaac/products/modis_products_table/vegetation_indices/monthly_l3_global_0_05deg_cmg/mod13c2 
; [2] Coyote's Guide to IDL Programming.
;     http://www.dfanning.com/documents/programs.html


