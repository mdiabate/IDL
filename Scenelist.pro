;; Specify Directory and set it as current
dir = '\\dhvlinux\raid1\Landsat_TM\4_Landsat_Imagery_SR_Archive\16_33'

cd, dir

FileList= file_search('*.gz') ;search directory for hdf files and list then
N = N_Elements(FileList)

openw, lun, '16_33_Toa_SceneList.txt',/get_lun

for i=0, N-1 Do begin
  filename = filelist(i)
  
  sceneId = strmid(filename,0,21)
  

  printf, lun, SceneID

  ;close file and free file pointer


endfor

free_lun, lun
end