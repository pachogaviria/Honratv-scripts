#**********************************************************

# PROCESAMIENTO DE ARCHIVOS DE VIDEO STREAMING
# Autor:
# Versión: 1.0

#  0: Crear Carpetas de Videos (Podcast, Cafecitos, Capsulas) con su correspondiente Folder de Thumbnails (Miniaturas) -----> Pacho
#  1: Synch Name: PodcastXXXX  - CafecitoXXX - CapsulasXXX
#  2: Codificar Videos - Run FFmpeg:
# 	    a. Ejecutar Rutina para crear Video using Codec para streming y colocar en carpeta OUT en Servidor (AWS), por ahora sera disco duro de Pacho.
# 	    b. Ejecutar Rutina para Calcular Bit Rate & Duracion - Generar File (table)TTXT para ser incorporado mas rapidamente en el archivo de ejecucion Json de AWS. 
#  3: Resize Miniaturas (Thumnails)  - Run jpgoptim
# 	    a. Resize Miniuatura (Thumnail)  a 800 x 450 - Colocarlas en las Carpetas de Miniuaturas (Thumnails) correspondientes a cada carpeta del Video correspondiente.

#  PARA el Puntyo 1 & 2 (above):

#  A. Asegurarse que cada Video en la CARPETA DE OUTPUT no sea sobre-escrito. Si el video anterior existe, entonces pase al siguiente (para cada tipo de video, i.e. Capsulas, Cafecitos, Podcasts)
#  B. Asegurarser que todos los videos en la Carpetas de OUTPUT esten sincronizados con los Videos de los tres tipos recibidos por Editor y que estan en el discoduro de Pacho: 
#  	    Podcast
# 	    Cafecito
# 	    Capsulas


#**********************************************************
#** Declaración de parámetros 
    
$PATH_IN = "M:\Streaning TV\path_in" #/Volumes/honratv/in_path"                   # Ruta Transitoria de Entrada para archivos de Video / Imagenes de Programas CAFECITO / CAPSULAS / PODCASTS 

$VIDEO_FILES = @()  #Array
$IMAGE_FILES = @()  #Array
$PARCIAL = @()      #Array

$ANO = ("2020","2021","2022")
$MESES = ("01.Enero", "02.Febrero","03.Marzo","04.Abril","05.Mayo", "06.Junio", "07.Julio", "08.Agosto", "09.Septiembre","10.Octubre","11.Noviembre","12.Diciembre")

$TITULO_CSV ="Ano; Mes; Nombre Archivo; Tipo Archivo; Capitulo; Titulo; Antiguo Nombre"
$DELIMITER_CSV_FILE = ';'

### Declaración de funciones 

#**********************************************************
#***   Function
#**********************************************************

Function Proc_Files ()
{   
    Param ( ) 

    $OLD_NAME
    $NAME_OUT
    Pause
 
    #*****************  "Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"  
    $DATATOSAVE = $Y + $DELIMITER_CSV_FILE + $M + $DELIMITER_CSV_FILE + $NAME_OUT + $DELIMITER_CSV_FILE + $FILE_TYPE + $DELIMITER_CSV_FILE + $CHAPTER + $DELIMITER_CSV_FILE + $TITLE + $DELIMITER_CSV_FILE + $OLD_NAME   
    
    Out-File -FilePath ($PATH_REGISTER_FILE + "\" + $PREFIX_NAME_OUT + "DB.csv") -InputObject $DATATOSAVE -Append

    Rename-Item -Path $NAME_IN -NewName $NAME_OUT
    
    #Move-Item -Path *.jpg Destination ’C:\Temp\Mis fotos’
    #Mover archivos
    #Borrar Carpeta miniatura

}


#**********************************************************
#***   Cuerpo principal del script 
#**********************************************************

$CAFECITOS = $False
$CAPSULAS = $False
$PODCASTS = $False      



# ---------------------------------------------------------
# CAFECITO

If ($True -eq $CAFECITOS)       # Habilita la Ejecucion de la Rutina
{

    $PATH_IN = "H:\Nueva carpeta\Ministerio de Honra Dropbox\Un Cafecito y La Palabra"
    $PREFIX_NAME_OUT = "Cafecito-"
    $PREFIX_TMB_NAME_OUT = "Cafecito-"
    $SUFFIX_TMB_NAME_OUT = "-Miniatura"
    $PATH_IN_LOCAL = $NULL
    $PATH_REGISTER_FILE = $PATH_IN 
    $DELIMITER_FILE_NAME = $NULL
    $NAME_IN = $NULL
    $NAME_OUT = $NULL
    $IMAGE_FILES = $NULL
    $PARCIAL = $NULL
    $Test_L = $NULL
    $DATATOSAVE = $NULL
    $TITLE = $NULL
    $CHAPTER = $NULL
    $FILE_TYPE = $NULL
    $OLD_NAME = $NULL

    Out-File -FilePath ($PATH_REGISTER_FILE + "\" + $PREFIX_NAME_OUT + "DB.csv") -InputObject $TITULO_CSV -Append

    ForEach ($Y in $ANO)
    {
        ForEach ($M in $MESES)
        {
            $PATH_IN_LOCAL = $PATH_IN + "\" + $Y + "\" + $M                             # "H:\Nueva carpeta\Ministerio de Honra Dropbox\Capsulas para tu alma\2021\04.Abril\"
            $Test_L = Test-Path $PATH_IN_LOCAL

            $PATH_TMB_IN_LOCAL = $PATH_IN_LOCAL + "\Miniaturas"   
            $PATH_TMB_IN_LOCAL
            $Test_TMB_L = Test-Path $PATH_TMB_IN_LOCAL

            If ($True -eq $Test_TMB_L )     # CLASIFICA ARCHIVOS DE IMAGENES MINIATURA 
            { 
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "Cafecitos_???.jpg" -Name -File
                $DELIMITER_FILE_NAME = "_"
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 1"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files 
                    }    
                }


                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL 'Cafecitos-???.jpg' -Name -File
                $DELIMITER_FILE_NAME = "-"
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 2"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                    
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL 'Miniatura Cafecito_????_???.jpg' -Name -File
                $DELIMITER_FILE_NAME = "_"
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 3"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }
            }

            If ($True -eq $Test_L ) # CLASIFICA ARCHIVOS DE VIDEOS
            { 

                $VIDEO_FILES = Get-ChildItem $PATH_IN "??- Un Cafecito y La Palabra.mp4" -Name
                $DELIMITER_FILE_NAME = "-"
                If ($NULL -ne $VIDEO_FILES)
                {"Video 1"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[0]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                    
                $VIDEO_FILES = Get-ChildItem $PATH_IN '???- Un Cafecito y La Palabra  - *.mp4' -Name 
                $DELIMITER_FILE_NAME = "-"
                If ($NULL -ne $VIDEO_FILES)
                {"Video 2"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $CHAPTER = $PARCIAL[0]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }


                $VIDEO_FILES = Get-ChildItem $PATH_IN 'Cafecito # ??? - * -????-??-??.mp4' -Name 
                $DELIMITER_FILE_NAME = "-"
                If ($NULL -ne $VIDEO_FILES)
                {"Video 3"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = $PARCIAL[1]
                        $PARCIAL2 = $ELEMENT -split " "
                        $CHAPTER = $PARCIAL2[2]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }
            }
        }
    }    
}

#---------------------------------------------------------
# CAPSULAS

If ($True -eq $CAPSULAS)       # Habilita la Ejecucion de la Rutina
{ 
    
    $PATH_IN = "H:\Nueva carpeta\Ministerio de Honra Dropbox\Capsulas para tu alma"
    $PREFIX_NAME_OUT = "Capsula-"
    $PREFIX_TMB_NAME_OUT = "Capsula-"
    $SUFFIX_TMB_NAME_OUT = "-Miniatura"
    $PATH_IN_LOCAL = $NULL
    $PATH_REGISTER_FILE = $PATH_IN 
    $DELIMITER_FILE_NAME = $NULL
    $NAME_IN = $NULL
    $NAME_OUT = $NULL
    $IMAGE_FILES = $NULL
    $PARCIAL = $NULL
    $Test_L = $NULL
    $DATATOSAVE = $NULL
    $TITLE = $NULL
    $CHAPTER = $NULL
    $FILE_TYPE = $NULL
    $OLD_NAME = $NULL
 
    Out-File -FilePath ($PATH_REGISTER_FILE + "\" + $PREFIX_NAME_OUT + "DB.csv") -InputObject $TITULO_CSV -Append

    ForEach ($Y in $ANO)
    {
        ForEach ($M in $MESES)
        {
            $PATH_IN_LOCAL = $PATH_IN + "\" + $Y + "\" + $M                             # "H:\Nueva carpeta\Ministerio de Honra Dropbox\Capsulas para tu alma\2021\04.Abril\"
            $Test_L = Test-Path $PATH_IN_LOCAL

            $PATH_TMB_IN_LOCAL = $PATH_IN_LOCAL + "\" + "Miniaturas"    
            $PATH_TMB_IN_LOCAL
            $Test_TMB_L = Test-Path $PATH_TMB_IN_LOCAL
            
            If ($True -eq $Test_TMB_L )
            { 
                
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "C?psula-???-*.jpg" -Name -File     # Capsula-114-La llave es la Cruz-Miniatura.jpg
                $DELIMITER_FILE_NAME = '-'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 1"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $CHAPTER = $PARCIAL[1]
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                  
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "C?psula_???.jpg" -Name -File       # Cápsula_132.jpg
                $DELIMITER_FILE_NAME = '_'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 2"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                           
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                    
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "C?psulas-???.jpg" -Name -File      # Cápsulas-125.jpg
                $DELIMITER_FILE_NAME = '-'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 3"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                            
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                    
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "C?psula_00??_???.jpg" -Name -File      # Cápsula_0000_164.jpg
                $DELIMITER_FILE_NAME = '_'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 4"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                            
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                    
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "Miniatura C?psulas_00??_???.jpg" -Name -File # Miniatura Capsulas_0000_201.jpg
                $DELIMITER_FILE_NAME = '_'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 5"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                            
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }   
            

################
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL 'Miniatura-Capsula-???.jpg' -Name -File      # Miniatura-Capsula-114.jpg
                $DELIMITER_FILE_NAME = "-"
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 4 temp"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }    
################
            
            }                                                        
            
            If ($True -eq $Test_L )
            { 
                    
                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "???- C?psulas para tu alma.mp4" -Name -File # 1- Cápsulas para tu alma.mp4
                $DELIMITER_FILE_NAME = "-"
                If ($NULL -ne $VIDEO_FILES)
                {"Video 1"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[0]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }        


                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "???- C?psulas para tu alma.mp4.mp4" -Name -File # 72- Cápsulas para tu alma.mp4.mp4
                $DELIMITER_FILE_NAME = "-"
                If ($NULL -ne $VIDEO_FILES)
                {"Video 2"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[0]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }        


                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "???- *.mp4" -Name -File -Exclude "*C?psulas *.mp4" # 114- La Llave es la cruz.mp4
                $DELIMITER_FILE_NAME = "-"
                If ($NULL -ne $VIDEO_FILES)
                {"Video 3"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $CHAPTER = $PARCIAL[0]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }        


                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "C?psula ??? - *.mp4" -Name -File # Cápsula 149 - Fuera la Preocupacion..mp4
                $DELIMITER_FILE_NAME = " "
                If ($NULL -ne $VIDEO_FILES)
                {"Video 4"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $PARCIAL2 = $ELEMENT -split " "
                        $CHAPTER = $PARCIAL2[1]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }        


                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "C?psula ???.mp4" -Name -File # Cápsula 193.mp4
                $DELIMITER_FILE_NAME = " "
                If ($NULL -ne $VIDEO_FILES)
                {"Video 5"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }        


                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "- C?psula ? ??? - * - ????-??-??.mp4" -Name -File # '- Cápsula # 210 - Recuerda - 2022-03-03'
                $DELIMITER_FILE_NAME = " "
                If ($NULL -ne $VIDEO_FILES)
                {"Video 6"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $PARCIAL2 = $ELEMENT -split "-"
                        $TITLE = $PARCIAL2[2]
                        $CHAPTER = $PARCIAL[3]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }
            }
        }
    }
}

# ---------------------------------------------------------
# PODCAST

If ($True -eq $PODCASTS)       # Habilita la Ejecucion de la Rutina
{
    
    $PATH_IN = "H:\Nueva carpeta\Ministerio de Honra Dropbox\PODCAST"
    $PREFIX_NAME_OUT = "Podcast-"
    $PREFIX_TMB_NAME_OUT = "Podcast-"
    $SUFFIX_TMB_NAME_OUT = "-Miniatura"
    $PATH_IN_LOCAL = $NULL
    $PATH_REGISTER_FILE = $PATH_IN 
    $DELIMITER_FILE_NAME = $NULL
    $NAME_IN = $NULL
    $NAME_OUT = $NULL
    $IMAGE_FILES = $NULL
    $PARCIAL = $NULL
    $Test_L = $NULL
    $DATATOSAVE = $NULL
    $TITLE = $NULL
    $CHAPTER = $NULL

    Out-File -FilePath ($PATH_REGISTER_FILE + "\" + $PREFIX_NAME_OUT + "DB.csv") -InputObject $TITULO_CSV -Append

    ForEach ($Y in $ANO)
    {
        ForEach ($M in $MESES)
        {
            $PATH_IN_LOCAL = $PATH_IN + "\" + $Y + "\" + $M                             # "H:\Nueva carpeta\Ministerio de Honra Dropbox\Capsulas para tu alma\2021\04.Abril\"
            $Test_L = Test-Path $PATH_IN_LOCAL

            $PATH_TMB_IN_LOCAL = $PATH_IN_LOCAL + "\Miniaturas"   
            $PATH_TMB_IN_LOCAL
            $Test_TMB_L = Test-Path $PATH_TMB_IN_LOCAL
              
            If ($True -eq $Test_TMB_L )
            { 
            
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "Podcast-??-*.jpg" -Name -File      # Podcast-60-Sobrevivir a lo Insoportable.jpg
                $DELIMITER_FILE_NAME = '-'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 1"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $CHAPTER = $PARCIAL[1]
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }


                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "UCM-??.jpg" -Name -File            # UCM-82.jpg
                $DELIMITER_FILE_NAME = '-'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 2"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                        
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "Podcast-???.jpg" -Name -File        # Podcast-90.jpg
                $DELIMITER_FILE_NAME = '-'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 3"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                    
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "UCM-Enero-???.jpg" -Name -File        # UCM-Enero-100.jpg
                $DELIMITER_FILE_NAME = '-'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 4"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {  
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }

                    
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "UCM-???-especial.jpg" -Name -File        # UCM-106-especial.jpg
                $DELIMITER_FILE_NAME = '-'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 5"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $CHAPTER = $PARCIAL[1]
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }


                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "UCM-Febrero-???.jpg" -Name -File        # UCM-Febrero-104.jpg
                $DELIMITER_FILE_NAME = '-'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 6"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }
                    
                    
                $IMAGE_FILES = Get-ChildItem $PATH_TMB_IN_LOCAL "UCM marzo_00??_???.jpg" -Name -File        # UCM marzo_0001_111.jpg 
                $DELIMITER_FILE_NAME = '_'
                If ($NULL -ne $IMAGE_FILES)
                {"Imagen 7"
                    ForEach ($ELEMENT in $IMAGE_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_TMB_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Imagen .jpg"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $NAME_OUT = $PREFIX_TMB_NAME_OUT + $CHAPTER + $SUFFIX_TMB_NAME_OUT + ".jpg"
                                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }
            }                                                            

            If ($True -eq $Test_L )
            {    
                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "UCM Podcast ???.mp4" -Name -File # UCM Podcast 1.mp4  UCM Podcast 10.mp4  UCM Podcast 100.mp4
                $DELIMITER_FILE_NAME = ' '
                If ($NULL -ne $VIDEO_FILES)
                {"Video 1"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[2].Substring(0,$PARCIAL[2].Length-4)
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }        


                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "PODCAST ???.mp4" -Name -File # PODCAST 17.mp4
                $DELIMITER_FILE_NAME = ' '
                If ($NULL -ne $VIDEO_FILES)
                {"Video 2"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $TITLE = "Sin Titulo"
                        $CHAPTER = $PARCIAL[1].Substring(0,$PARCIAL[1].Length-4)
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }        


                $VIDEO_FILES = Get-ChildItem $PATH_IN_LOCAL "- Podcasts # ??? - * - ????-??-??.mp4" -Name -File # - Podcast # 106 - Siguiendo las instrucciones - 2022-02-22.mp4
                $DELIMITER_FILE_NAME = ' '
                If ($NULL -ne $VIDEO_FILES)
                {"Video 3"
                    ForEach ($ELEMENT in $VIDEO_FILES) 
                    {
                        $OLD_NAME = $ELEMENT
                        $NAME_IN = $PATH_IN_LOCAL + "\" + $OLD_NAME
                        $PARCIAL = $ELEMENT -split $DELIMITER_FILE_NAME
                        $FILE_TYPE = "Video .mp4"
                        $PARCIAL2 = $ELEMENT -split "-"
                        $TITLE = $PARCIAL2[1]
                        $CHAPTER = $PARCIAL[2]
                        $NAME_OUT = $PREFIX_NAME_OUT + $CHAPTER + ".mp4"
                        
                        #"Nombre Archivo ($NAME_OUT) ; Tipo Archivo ($FILE_TYPE) ; Capitulo ($CHAPTER) ; Titulo ($TITLE); Antiguo Nombre ($OLD_NAME)"
                        Proc_Files
                    }
                }        
            }
        }
    }  
}

# ---------------------------------------------------------

