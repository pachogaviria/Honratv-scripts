 

$vPSObject = Get-Content "M:\Streaning TV\fuentes\HonraTV_v3.json" -Encoding utf8 | ConvertFrom-Json 

$vPSObject_Movies = $vPSObject.movies
$vPSObject_shortFormVideos = $vPSObject.shortFormVideos
$vPSObject_liveFeeds = $vPSObject.liveFeeds


#138

ForEach ($ELEMENT_IN_L in $vPSObject_Movies)
{
    $ELEMENT_IN_L.id                                #par simple
    $ELEMENT_IN_L.title                             #par simple
    $ELEMENT_IN_L.content.dateAdded                 #objeto {}
    $ELEMENT_IN_L.content.rating.rating             #objeto {}
    $ELEMENT_IN_L.content.rating.ratingSource       #objeto {}
    $ELEMENT_IN_L.content.duration                  #objeto {}
    $ELEMENT_IN_L.content.videos.url                #objeto {}
    $ELEMENT_IN_L.content.videos.quality            #objeto {}
    $ELEMENT_IN_L.content.videos.videoType          #objeto {}
    $ELEMENT_IN_L.genres                            #Lista []
    $ELEMENT_IN_L.thumbnail                         #par simple
    $ELEMENT_IN_L.releasedate                       #par simple
    $ELEMENT_IN_L.shortdescription                  #par simple
    $ELEMENT_IN_L.longdescription                   #par simple
    $ELEMENT_IN_L.tags                              #Lista []
    "    
    "
}


ForEach ($ELEMENT_IN_L in $vPSObject_shortFormVideos)
{
    $ELEMENT_IN_L.id                                #par simple
    $ELEMENT_IN_L.title                             #par simple
    $ELEMENT_IN_L.content.dateAdded                 #objeto {}
    $ELEMENT_IN_L.content.rating.rating             #objeto {}
    $ELEMENT_IN_L.content.rating.ratingSource       #objeto {}
    $ELEMENT_IN_L.content.duration                  #objeto {}
    $ELEMENT_IN_L.content.videos.url                #objeto {}
    $ELEMENT_IN_L.content.videos.quality            #objeto {}
    $ELEMENT_IN_L.content.videos.videoType          #objeto {}
    $ELEMENT_IN_L.genres                            #Lista []
    $ELEMENT_IN_L.thumbnail                         #par simple
    $ELEMENT_IN_L.releasedate                       #par simple
    $ELEMENT_IN_L.shortdescription                  #par simple
    $ELEMENT_IN_L.longdescription                   #par simple
    $ELEMENT_IN_L.tags                              #Lista []
    "    
    "
}


ForEach ($ELEMENT_IN_L in $vPSObject_liveFeeds)
{
    $ELEMENT_IN_L.id                                #par simple
    $ELEMENT_IN_L.title                             #par simple
    $ELEMENT_IN_L.content.dateAdded                 #objeto {}
    $ELEMENT_IN_L.content.rating.rating             #objeto {}
    $ELEMENT_IN_L.content.rating.ratingSource       #objeto {}
    $ELEMENT_IN_L.content.duration                  #objeto {}
    $ELEMENT_IN_L.content.videos.url                #objeto {}
    $ELEMENT_IN_L.content.videos.quality            #objeto {}
    $ELEMENT_IN_L.content.videos.videoType          #objeto {}
    $ELEMENT_IN_L.genres                            #Lista []
    $ELEMENT_IN_L.thumbnail                         #par simple
    $ELEMENT_IN_L.releasedate                       #par simple
    $ELEMENT_IN_L.shortdescription                  #par simple
    $ELEMENT_IN_L.longdescription                   #par simple
    $ELEMENT_IN_L.tags                              #Lista []
    "    
    "
}



#$vPSObject_Movies



