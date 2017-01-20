#!/bin/bash
#takes an URL as parameter and starts it on youtube. Requires youtube-dl to be in path
#
#idea and some code from https://github.com/nawar/kodi-cli/blob/master/kodi-cli
#


KODI_HOST='localhost'
KODI_PORT='8080'
KODI_USER=''
KODI_PASS=''
LOCK=false


function xbmc_req {
  output=$(curl -s -i -X POST --header "Content-Type: application/json" -d "$1" http://$KODI_USER:$KODI_PASS@$KODI_HOST:$KODI_PORT/jsonrpc)  

  if [[ $2 = true ]];
  then
	  echo $output
  fi 
}

function parse_json {
 key=$1
 awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$key'\042/){print $(i+1)}}}' | tr -d '"' 
}


ID=$1
if [ "$ID" = "" ]
then
echo -e "provide an url next time\n"
ID='https://vimeo.com/45196609'
fi

URL=$(youtube-dl "-g" "$ID");
if [ $? -ne 0 ]
then
#fail on failure
exit 1
fi

ID=$URL
#sometimes youtube-dl returns multiple urls
URL=($URL[0])

#echo -n "$URL"


  # clear the list
xbmc_req '{"jsonrpc": "2.0", "method": "Playlist.Clear", "params":{"playlistid":1}, "id": 1}';

  # add the video to the list
xbmc_req '{"jsonrpc": "2.0", "method": "Playlist.Add", "params":{"playlistid":1, "item" :{ "file" : "'$ID'"}}, "id" : 1}';

  # open the video
xbmc_req '{"jsonrpc": "2.0", "method": "Player.Open", "params":{"item":{"playlistid":1, "position" : 0}}, "id": 1}';

