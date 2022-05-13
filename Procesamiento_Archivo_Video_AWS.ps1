#**********************************************************

# PROCESAMIENTO DE ARCHIVOS DE VIDEO STREAMING
# Autor:
# Version: 1.0 (repo test)

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
#***  DECLARACION DE VARIABLES SCRIPT
#**********************************************************

$FILES_IN = @()  #Array
$FILES_OUT = @()  #Array
$FILES_TO_PROCESS = @()  #Array
$FILES_TO_CLEAR = @()  #Array
$NEW_FILES_TO_PROCESS = @()  #Array
$PATH_DELIMITER = $NULL

#$PATH_IN_L = $NULL
#$FILES_IN_L = $NULL 
#$PATH_OUT_L = $NULL
#$FILES_OUT_L = $NULL
$PATH_FIDF =  "temp/"                   #OJO Crear directorio local y colocar la ruta aca, debe finalizar en "/"
$WORK_FOLDER = "Volumes/honratv/Honratv-scripts/Procesamiento_Archivo_Video_AWS.ps1/"

#----------------------------------------------------------------
#**** Rutas AWS

$AWS_BUCKET = "honratv"

#** IN     

$AWS_PATH_IN = "intest/"                                                      # Ruta Transitoria de Entrada para archivos de Video / Imagenes 
                                                                                                        # de Programas CAFECITO / CAPSULAS / PODCASTS 

$AWS_PATH_IN_VD_01 = $AWS_PATH_IN + "cafecito/"                                       # CAFECITO VIDEOS
$AWS_PATH_IN_VD_02 = $AWS_PATH_IN + "capsulas/"                                       # CAPSULAS VIDEOS
$AWS_PATH_IN_VD_03 = $AWS_PATH_IN + "podcasts/"                                       # PODCASTS VIDEOS

$AWS_PATH_IN_TMB_01 = $AWS_PATH_IN_VD_01 + "thumbnails/"                              # CAFECITO MINIATURAS
$AWS_PATH_IN_TMB_02 = $AWS_PATH_IN_VD_02 + "thumbnails/"                              # CAPSULAS MINIATURAS
$AWS_PATH_IN_TMB_03 = $AWS_PATH_IN_VD_03 + "thumbnails/"                              # PODCASTS MINIATURAS

#** OUT

$AWS_PATH_OUT = "outest/"

$AWS_PATH_OUT_VD_01 = $AWS_PATH_OUT + "cafecito/"                                      # CAFECITO VIDEOS
$AWS_PATH_OUT_VD_02 = $AWS_PATH_OUT + "capsulas/"                                      # CAPSULAS VIDEOS
$AWS_PATH_OUT_VD_03 = $AWS_PATH_OUT + "podcasts/"                                      # PODCASTS VIDEOS

$AWS_PATH_OUT_TMB_01 = $AWS_PATH_OUT_VD_01 + "thumbnails/"                          # CAFECITO MINIATURAS
$AWS_PATH_OUT_TMB_02 = $AWS_PATH_OUT_VD_02 + "thumbnails/"                          # CAPSULAS MINIATURAS
$AWS_PATH_OUT_TMB_03 = $AWS_PATH_OUT_VD_03 + "thumbnails/"                          # PODCASTS MINIATURAS


#**********************************************************
#***  Declaracion de Funciones 
#**********************************************************

# -------------------------------------------------------
# PRUEBA DE RUTA Y/O CREACION

Function Path_Test_Create ()
{   param ( $BUCKET_L, $FOLDER_L )

    $Test_L = $NULL    
    $Test_L = Get-S3Object $BUCKET_L -key $FOLDER_L
    
        If ( $Test_L -eq $NULL ) 
        { 
            Out-File -FilePath ($PATH_FIDF + ".FIDF") -InputObject "Folder ID File"                                             #Creacion de Archivo Vacio
            Write-S3Object -BucketName  $BUCKET_L -Key  ($FOLDER_L + ".FIDF") -File ($PATH_FIDF + ".FIDF") -PublicReadWrite     #Copiando Archivo Vacio para validad Folder
        } 
}

# -------------------------------------------------------
# FILTRO DE OBJETO LISTA DE ARCHIVOS
#
# Ejemplo estructura de elemento a tratar
#            ChecksumAlgorithm : {}
#            ETag              : "46568409d6d82f4a1f2502e053e8a242"
#            BucketName        : honratv
#            Key               : intest/cafecito/thumbnails/ima01.jpg
#            LastModified      : 5/8/2022 7:26:41 PM
#            Owner             : Amazon.S3.Model.Owner
#            Size              : 67044
#            StorageClass      : STANDARD

Function FILTER_OBJECT ()
{   param ( $BUCKET_L, $PATH_L, $FILES_L, $MASK_L )
    
    $LIST_FILES_L = @()

    Foreach ($ELEMENT_L in $FILES_L)                                                                      #Toma cada elemento de la lista de Objetos y los trabaja uno a la vez
    {
        $PATH_FILE_L = $ELEMENT_L.Key.Substring(0, $PATH_L.Length)                                          # $Variable.Substring(primer caracter, Candidad de caracteres a sustraer)  para extraer la subcadena del path comparar con el enviado
        IF ($PATH_FILE_L -eq $PATH_L)                                                                     # si es igual tomar la otra cadena (nombre del archivo) y 
        {
            $FILE_NAME_L = $ELEMENT_L.Key.Substring($PATH_L.Length,($ELEMENT_L.Key.Length-$PATH_L.Length))
            $STRING_ELEMENT_L = $FILE_NAME_L -split "/"

            IF ($STRING_ELEMENT_L.length -eq 1)                                                           # preguntar si extiste "/" para estar seguro que sea el nombre del archivo
            {
                $STATUS_MASK_L = $FILE_NAME_L -like $MASK_L                                                 # hacer comparacion con la mask
                IF ($STATUS_MASK_L -eq $True)
                {
                    $LIST_FILES_L = $LIST_FILES_L + $ELEMENT_L                                                        # Adicione el elemento a nueva lista
                }
            }
        }
    }
    Return $LIST_FILES_L
}

# -------------------------------------------------------
# COMPARACION DE ARCHIVOS DE ENTRADA VS ARCHIVOS DE SALIDA
#
#   Comparar listado de Archivos de Entrada ($FILES_IN) Vs Archivos de Salida ($FILES_OUT)
#   Realizar la siguiente Clasificación:
#       1.- Si existen Archivos de Entrada y Archivos de Salida con un mismo nombre, entonces comparar Ultima Fecha de Modificación
#           1.1.- Si la Fecha de los Archivos de Entrada es Mayor que los Archivos de Salida, entonces, colocarlos en un arreglo (Array) para ser procesados ($FILES_TO_PROCESS).
#       2.- Si Existen nombres de Archivos de Entrada que no esten en Archivo de Salida, colocarlos en un arreglo (Array) para ser procesados ($FILES_TO_PROCESS).
#       3.- Si Existen nombres de Archivos de Salida que no esten en Archivo de Entrada, colocarlos en un arreglo (Array) para ser borrados ($FILES_TO_CLEAR).
        
Function FILES_IN_OUT ( )
{   param ( $PATH_IN_L, $FILES_IN_L, $PATH_OUT_L, $FILES_OUT_L ) #se usaron variables globales, asignacion de variables locales dejo de funcionar.

    # Declaracion de Variables Locales adicionales a los parametros de entrada de la Funcion

    $FLAG_IN_L = $False
    $FLAG_OUT_L = $False
    $NEW_FILES_TO_PROCESS_L = @()
    $FILES_TO_PROCESS_L = @()
    $FILES_TO_CLEAR_L = @()

    # Identifica y lista los Archivos de Entrada Nuevos y Antiguos que se deben Procesar
 
    ForEach ($ELEMENT_IN_L in $FILES_IN_L)
    {
        ForEach ($ELEMENT_OUT_L in $FILES_OUT_L)
        {
            $FILES_KEY_IN_L = $ELEMENT_IN_L.Key -Split "/"
            $FILES_KEY_OUT_L = $ELEMENT_OUT_L.Key -Split "/"

            If ($FILES_KEY_IN_L[$FILES_KEY_IN_L.length-1] -eq $FILES_KEY_OUT_L[$FILES_KEY_OUT_L.length-1])     # Se toman los ultimos elementos de los arreglos para comparacion
            { 
                $FLAG_IN_L = $True                                                                             # Marcar Bandera que Existe Archivo IN
                
                If ($ELEMENT_IN_L.LastModified -gt $ELEMENT_OUT_L.LastModified)  
                {
                    $FILES_TO_PROCESS_L = $FILES_TO_PROCESS_L + $ELEMENT_IN_L
                }
            }
        }
        
        If ($False -eq $FLAG_IN_L)
        {   
            $NEW_FILES_TO_PROCESS_L = $NEW_FILES_TO_PROCESS_L + $ELEMENT_IN_L
        }
        $FLAG_IN_L = $False
    }
   
    # Identifica y lista los archivos de salida que se deben borrar

    ForEach ($ELEMENT_OUT_L in $FILES_OUT_L)
    {
        ForEach ($ELEMENT_IN_L in $FILES_IN_L)
        {
            $FILES_KEY_IN_L = $ELEMENT_IN_L.Key -Split "/"
            $FILES_KEY_OUT_L = $ELEMENT_OUT_L.Key -Split "/"

            If ($FILES_KEY_IN_L[$FILES_KEY_IN_L.length-1] -eq $FILES_KEY_OUT_L[$FILES_KEY_OUT_L.length-1])     
            { 
                $FLAG_OUT_L = $True                                         # Marcar Bandera que Existe OUT
            }
        }
    
        If ($False -eq $FLAG_OUT_L)
        { 
            $FILES_TO_CLEAR_L = $FILES_TO_CLEAR_L + $ELEMENT_OUT_L
        }
        $FLAG_OUT_L = $False   
    }
    Return $NEW_FILES_TO_PROCESS_L, $FILES_TO_PROCESS_L, $FILES_TO_CLEAR_L
}

# -------------------------------------------------------
# PROCESAMIENTO DE ARCHIVOS DE IMAGENES MINIATURAS

Function PROCESSING_IMAGE_FILES ()
{   param ( $BUCKET_L, $PATH_IN_L, $FILES_IN_L, $PATH_OUT_L )
    
    ForEach ($ELEMENT_L in $FILES_IN_L)
    {    
        Copy-S3Object -BucketName $BUCKET_L -Key $ELEMENT_L.Key -LocalFile ($WORK_FOLDER + "Work_File.jpg")

# IMAGE RESIZE: 66K
        
        Convert ($WORK_FOLDER + "Work_File.jpg") -resize "800x450" ($WORK_FOLDER + "Work_File.jpg")

# IMAGE OPTIMIZATION:
        
        jpegoptim --strip-all --all-progressive ($WORK_FOLDER + "Work_File.jpg")
        
            # jpegoptim Options used: 
            # --strip-all               strip all (Comment & Exif) markers from output file
            # --all-progressive         force all output files to be progressive
            # -d<path>, --dest=<path>   specify alternative destination directory for optimized files (default is to overwrite originals)

        $FILE_OUT_L = $PATH_OUT_L  + $ELEMENT_L.Key.Substring($PATH_IN_L.Length,($ELEMENT_L.Key.Length-$PATH_IN_L.Length))

        Write-S3Object -BucketName $BUCKET_L -Key $FILE_OUT_L -File ($WORK_FOLDER + "Work_File.jpg") -PublicReadWrite
        Remove-Item ($WORK_FOLDER + "Work_File.jpg")
    }
}

# -------------------------------------------------------
# BORRADO DE ARCHIVOS DE ARCHIVOS

Function DELETE_FILES ( )
{   param ( $BUCKET_L, $FILES_L )

    ForEach ($ELEMENT_L in $FILES_L)
    {
        Remove-S3Object -BucketName $BUCKET_L -Key $ELEMENT_L.Key
    }
}

# ---------------------------------------------------------
# PROCESAMIENTO DE ARCHIVOS DE VIDEO

Function PROCESSING_VIDEO_FILES ()
{
    param ($BUCKET_L, $PATH_IN_L, $FILES_IN_L, $PATH_OUT_L )

    $VIDEO_BIT_RATE_L = $NULL
    $VIDEO_DURATION_L = $NULL
    
    ForEach ($ELEMENT_L in $FILES_IN_L)
    {   
        Copy-S3Object -BucketName $BUCKET_L -Key $ELEMENT_L.Key -LocalFile ($WORK_FOLDER + "Work_File.mp4")
 
# INFO: bit_rate,

        $VIDEO_BIT_RATE_L = ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 ($WORK_FOLDER + "Work_File.mp4")

# INFO: duration
    
        $VIDEO_DURATION_L = ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 ($WORK_FOLDER + "Work_File.mp4")

# CODEC: FFpmpeg Codec "110% Constrained VBR" Preset Faster (Moving head conent) for VBR two passes.
            
        ffmpeg -y -i ($WORK_FOLDER + "Work_File.mp4") -c:v libx264 -preset Faster -b:v 5000k -an -f mp4 -pass 1 NUL

        ffmpeg -n -i ($WORK_FOLDER + "Work_File.mp4") -c:v libx264 -preset Faster -b:v 5000k -pass 2 -maxrate 5500k -bufsize 5000k #($WORK_FOLDER + "Work_File.mp4") 

# OPCIONES DE APLICACION FFpmpeg:
#       -i url (input)
#           input file url
#
#       -c[:stream_specifier] codec (input/output,per-stream)
#       -codec[:stream_specifier] codec (input/output,per-stream)
#           Select an encoder (when used before an output file) or a decoder (when used before an input file) for one or more streams. codec is the name of a 
#           decoder/encoder or a special value copy (output only) to indicate that the stream is not to be re-encoded. For example:
#           ffmpeg -i INPUT -map 0 -c:v libx264 -c:a copy OUTPUT
#
#       -y (global)
#           Overwrite output files without asking.
#
#       -n (global)
#           Do not overwrite output files, and exit immediately if a specified output file already exists.
#
#       -pass[:stream_specifier] n (output,per-stream)
#           Select the pass number (1 or 2). It is used to do two-pass video encoding. The statistics of the video are recorded in the first pass into a log file, 
#           and in the second pass that log file is used to generate the video at the exact requested bitrate. On pass 1, you may just deactivate audio and set 
#           output to null, examples for Windows and Unix:
#           ffmpeg -i foo.mov -c:v libxvid -pass 1 -an -f rawvideo -y NUL
#
#       -f fmt (input/output)
#           Force input or output file format. The format is normally auto detected for input files and guessed from the file extension for output files, so this option is not needed in most cases.
#       
#       -metadata[:metadata_specifier] key=value (output,per-metadata)
#           Set a metadata key/value pair.
#           An optional metadata_specifier may be given to set metadata on streams, chapters or programs. See -map_metadata documentation for details.
#           This option overrides metadata set with -map_metadata. It is also possible to delete metadata by using an empty value.
#           For example, for setting the title in the output file:
#
#                 ffmpeg -i in.avi -metadata title="my title" out.flv
#
#           To set the language of the first audio stream:
#
#                 ffmpeg -i INPUT -metadata:s:a:0 language=eng OUTPUT
#
#           http://www.videolan.org/developers/x264.html
#
#           Presets(libx264) opciones: Ultrafast Superfast Veryfast Faster Fast Medium Slow Slower Veryslow Placebo

        $FILE_OUT_L = $PATH_OUT_L  + $ELEMENT_L.Key.Substring($PATH_IN_L.Length,($ELEMENT_L.Key.Length-$PATH_IN_L.Length))

        Write-S3Object -BucketName $BUCKET_L -Key $FILE_OUT_L -File ($WORK_FOLDER + "Work_File.mp4") -PublicReadWrite
        Remove-Item ($WORK_FOLDER + "Work_File.mp4")  
    }
}

# ---------------------------------------------------------

#**********************************************************
#***   CUERPO RPINCIPAL DEL SCRIPT
#**********************************************************

$CAFECITOS = $True
$CAPSULAS = $True
$PODCASTS = $True

# ---------------------------------------------------------
# CHEQUEOS DE TODAS LAS RUTAS DE LOS ARCHIVOS (IN / OUT / BP), CREAR DIRECTORIOS QUE NO EXISTEN

$PATH_DELIMITER = "/"

Path_Test_Create $BUCKET $AWS_PATH_IN
Path_Test_Create $BUCKET $AWS_PATH_IN_VD_01
Path_Test_Create $BUCKET $AWS_PATH_IN_VD_02
Path_Test_Create $BUCKET $AWS_PATH_IN_VD_03
Path_Test_Create $BUCKET $AWS_PATH_IN_TMB_01
Path_Test_Create $BUCKET $AWS_PATH_IN_TMB_02
Path_Test_Create $BUCKET $AWS_PATH_IN_TMB_03

Path_Test_Create $BUCKET $AWS_PATH_OUT
Path_Test_Create $BUCKET $AWS_PATH_OUT_VD_01
Path_Test_Create $BUCKET $AWS_PATH_OUT_VD_02
Path_Test_Create $BUCKET $AWS_PATH_OUT_VD_03
Path_Test_Create $BUCKET $AWS_PATH_OUT_TMB_01
Path_Test_Create $BUCKET $AWS_PATH_OUT_TMB_02
Path_Test_Create $BUCKET $AWS_PATH_OUT_TMB_03

# ---------------------------------------------------------
# INICIACION ARCHIVO DE REGISTROS

    #$TITULO_CSV ="Ano; Mes; Nombre Archivo; Tipo Archivo; Capitulo; Titulo; Antiguo Nombre"
    #$DELIMITER_CSV_FILE = ';'

    #Out-File -FilePath ($PATH_IN + $PATH_DELIMITER +  "Video_Info.csv") -InputObject $DATATOSAVE -Append

# ---------------------------------------------------------
# CAFECITO

If ($True -eq $CAFECITOS)                                                                  # Habilita la Ejecucion de la Rutina
{ 
# Rutina para tratar las imagenes miniatura de Cafecitos

    $FILES_IN = Get-S3Object -BucketName $BUCKET -Prefix $AWS_PATH_IN_TMB_01
    $FILES_IN = FILTER_OBJECT $BUCKET $AWS_PATH_IN_TMB_01 $FILES_IN "*.jpg"                # Parameters Bucket Path Objct Mask; Filtrado de Archivos

    $FILES_OUT = Get-S3Object -BucketName $BUCKET -Prefix $AWS_PATH_OUT_TMB_01
    $FILES_OUT = FILTER_OBJECT $BUCKET $AWS_PATH_OUT_TMB_01 $FILES_OUT "*.jpg"             # Parameters Bucket Path Objct Mask; Filtrado de Archivos
                                                                                           # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L $FILES_OUT_L; Funcion de Clasificacion de archivos 
    $NEW_FILES_TO_PROCESS, $FILES_TO_PROCESS, $FILES_TO_CLEAR = FILES_IN_OUT $AWS_PATH_IN_TMB_01 $FILES_IN $AWS_PATH_OUT_TMB_01 $FILES_OUT  
                                                                                           # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Nuevos de Imagenes
    PROCESSING_IMAGE_FILES $BUCKET $AWS_PATH_IN_TMB_01 $NEW_FILES_TO_PROCESS $AWS_PATH_OUT_TMB_01  
                                                                                           # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Modificados de Imagenes
    PROCESSING_IMAGE_FILES $BUCKET $AWS_PATH_IN_TMB_01 $FILES_TO_PROCESS $AWS_PATH_OUT_TMB_01      
 
    DELETE_FILES $BUCKET $FILES_TO_CLEAR                                                   # Parameters $PATH_L $FILES_L; Borrar Archivos de Imagenes no existentes en Folder de Entrada

# Rutina para tratar los Videos de Cafecitos
    
    $FILES_IN = Get-S3Object -BucketName $BUCKET -Prefix $AWS_PATH_IN_VD_01
    $FILES_IN = FILTER_OBJECT $BUCKET $AWS_PATH_IN_VD_01 $FILES_IN "*.mp4"                 # Parameters Bucket Path Objct Mask; Filtrado de Archivos

    $FILES_OUT = Get-S3Object -BucketName $BUCKET -Prefix $AWS_PATH_OUT_VD_01
    $FILES_OUT = FILTER_OBJECT $BUCKET $AWS_PATH_OUT_VD_01 $FILES_OUT "*.mp4"              # Parameters Bucket Path Objct Mask; Filtrado de Archivos
                                                                                           # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L $FILES_OUT_L; Funcion de Clasificacion de archivos 
    $NEW_FILES_TO_PROCESS, $FILES_TO_PROCESS, $FILES_TO_CLEAR = FILES_IN_OUT $AWS_PATH_IN_VD_01 $FILES_IN $AWS_PATH_OUT_VD_01 $FILES_OUT  
                                    
    PROCESSING_VIDEO_FILES $BUCKET $AWS_PATH_IN_VD_01 $NEW_FILES_TO_PROCESS $AWS_PATH_OUT_VD_01    # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Nuevos de Videos

    PROCESSING_VIDEO_FILES $BUCKET $AWS_PATH_IN_VD_01 $FILES_TO_PROCESS $AWS_PATH_OUT_VD_01        # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Modificados de Videos
 
    DELETE_FILES $FILES_TO_CLEAR                                                           # Parameters $PATH_L $FILES_L; Borrar Archivos de Videos no existentes en Folder de Entrada
   
}

# ---------------------------------------------------------
# CAPSULAS

If ($True -eq $CAPSULAS)                                # Habilita la Ejecucion de la Rutina
{ 
# Rutina para tratar las imagenes miniatura de Capsulas

    $FILES_IN = Get-S3Object -BucketName $BUCKET -Prefix $AWS_PATH_IN_TMB_02
    $FILES_IN = FILTER_OBJECT $BUCKET $AWS_PATH_IN_TMB_02 $FILES_IN "*.jpg"                     # Parameters Bucket Path Objct Mask; Filtrado de Archivos

    $FILES_OUT = Get-S3Object -BucketName $BUCKET -Prefix $AWS_PATH_OUT_TMB_02
    $FILES_OUT = FILTER_OBJECT $BUCKET $AWS_PATH_OUT_TMB_02 $FILES_OUT "*.jpg"                  # Parameters Bucket Path Objct Mask; Filtrado de Archivos
                                                                                            # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L $FILES_OUT_L; Funcion de Clasificacion de archivos 
    $NEW_FILES_TO_PROCESS, $FILES_TO_PROCESS, $FILES_TO_CLEAR = FILES_IN_OUT $PAWS_ATH_IN_TMB_02 $FILES_IN $AWS_PATH_OUT_TMB_02 $FILES_OUT  
 
    PROCESSING_IMAGE_FILES $BUCKET $AWS_PATH_IN_TMB_02 $NEW_FILES_TO_PROCESS $AWS_PATH_OUT_TMB_02           # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Nuevos de Imagenes

    PROCESSING_IMAGE_FILES $BUCKET $AWS_PATH_IN_TMB_02 $FILES_TO_PROCESS $AWS_PATH_OUT_TMB_02               # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Modificados de Imagenes
 
    DELETE_FILES $BUCKET $FILES_TO_CLEAR                                                            # Parameters $PATH_L $FILES_L; Borrar Archivos de Imagenes no existentes en Folder de Entrada

# Rutina para tratar los Videos de Capsulas
    
    $FILES_IN = Get-S3Object -BucketName $BUCKET -Prefix $AWS_PATH_IN_VD_02
    $FILES_IN = FILTER_OBJECT $BUCKET $AWS_PATH_IN_VD_02 $FILES_IN "*.mp4"                     # Parameters Bucket Path Objct Mask; Filtrado de Archivos

    $FILES_OUT = Get-S3Object -BucketName $BUCKET -Prefix $AWS_PATH_OUT_VD_02
    $FILES_OUT = FILTER_OBJECT $BUCKET $AWS_PATH_OUT_VD_02 $FILES_OUT "*.mp4"                  # Parameters Bucket Path Objct Mask; Filtrado de Archivos
                                                                                           # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L $FILES_OUT_L; Funcion de Clasificacion de archivos 
    $NEW_FILES_TO_PROCESS, $FILES_TO_PROCESS, $FILES_TO_CLEAR = FILES_IN_OUT $AWS_PATH_IN_VD_02 $FILES_IN $AWS_PATH_OUT_VD_02 $FILES_OUT  
                                    
    PROCESSING_VIDEO_FILES $BUCKET $AWS_PATH_IN_VD_02 $NEW_FILES_TO_PROCESS $AWS_PATH_OUT_VD_02            # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Nuevos de Videos

    PROCESSING_VIDEO_FILES $BUCKET $AWS_PATH_IN_VD_02 $FILES_TO_PROCESS $AWS_PATH_OUT_VD_02                # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Modificados de Videos
 
    DELETE_FILES $BUCKET $FILES_TO_CLEAR                                                           # Parameters $PATH_L $FILES_L; Borrar Archivos de Videos no existentes en Folder de Entrada
    
}

# ---------------------------------------------------------
# PODCAST

If ($True -eq $PODCASTS)                                # Habilita la Ejecucion de la Rutina
{ 
# Rutina para tratar las imagenes miniatura de PodCasts

    $FILES_IN = Get-S3Object -BucketName $BUCKET -Prefix $PATH_IN_TMB_03
    $FILES_IN = FILTER_OBJECT $BUCKET $PATH_IN_TMB_03 $FILES_IN "*.jpg"                     # Parameters Bucket Path Objct Mask; Filtrado de Archivos

    $FILES_OUT = Get-S3Object -BucketName $BUCKET -Prefix $PATH_OUT_TMB_03
    $FILES_OUT = FILTER_OBJECT $BUCKET $PATH_OUT_TMB_03 $FILES_OUT "*.jpg"                  # Parameters Bucket Path Objct Mask; Filtrado de Archivos
                                                                                            # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L $FILES_OUT_L; Funcion de Clasificacion de archivos 
    $NEW_FILES_TO_PROCESS, $FILES_TO_PROCESS, $FILES_TO_CLEAR = FILES_IN_OUT $PATH_IN_TMB_03 $FILES_IN $PATH_OUT_TMB_03 $FILES_OUT  
 
    PROCESSING_IMAGE_FILES $BUCKET $PATH_IN_TMB_03 $NEW_FILES_TO_PROCESS $PATH_OUT_TMB_03           # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Nuevos de Imagenes

    PROCESSING_IMAGE_FILES $BUCKET $PATH_IN_TMB_03 $FILES_TO_PROCESS $PATH_OUT_TMB_03               # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Modificados de Imagenes
 
    DELETE_FILES $BUCKET $FILES_TO_CLEAR                                                            # Parameters $PATH_L $FILES_L; Borrar Archivos de Imagenes no existentes en Folder de Entrada

# Rutina para tratar los Videos de PodCasts
    
    $FILES_IN = Get-S3Object -BucketName $BUCKET -Prefix $PATH_IN_VD_03
    $FILES_IN = FILTER_OBJECT $BUCKET $PATH_IN_VD_03 $FILES_IN "*.mp4"                     # Parameters Bucket Path Objct Mask; Filtrado de Archivos

    $FILES_OUT = Get-S3Object -BucketName $BUCKET -Prefix $PATH_OUT_VD_03
    $FILES_OUT = FILTER_OBJECT $BUCKET $PATH_OUT_VD_03 $FILES_OUT "*.mp4"                  # Parameters Bucket Path Objct Mask; Filtrado de Archivos
                                                                                           # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L $FILES_OUT_L; Funcion de Clasificacion de archivos 
    $NEW_FILES_TO_PROCESS, $FILES_TO_PROCESS, $FILES_TO_CLEAR = FILES_IN_OUT $PATH_IN_VD_03 $FILES_IN $PATH_OUT_VD_03 $FILES_OUT  
                                    
    PROCESSING_VIDEO_FILES $BUCKET $PATH_IN_VD_03 $NEW_FILES_TO_PROCESS $PATH_OUT_VD_03            # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Nuevos de Videos

    PROCESSING_VIDEO_FILES $BUCKET $PATH_IN_VD_03 $FILES_TO_PROCESS $PATH_OUT_VD_03                # Parameters $PATH_IN_L $FILES_IN_L $PATH_OUT_L; Procesar Archivos Modificados de Videos
 
    DELETE_FILES $BUCKET $FILES_TO_CLEAR                                                           # Parameters $PATH_L $FILES_L; Borrar Archivos de Videos no existentes en Folder de Entrada

}

# ---------------------------------------------------------
# 
