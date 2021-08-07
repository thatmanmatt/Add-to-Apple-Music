import xml.etree.ElementTree as et
import requests
import json

MusicTree = et.parse('Library.xml')

SearchUrl = 'https://amp-api.music.apple.com/v1/catalog/de/search?l=de-de&platform=web&types=albums&limit=1&term='
AddToLibraryUrl = 'https://amp-api.music.apple.com/v1/me/library?ids[albums]='
CurrentAlbumTitle = 'NIX'
AlbumsToAdd = []

AppleMusicAuthHeader = {'authorization': 'Bearer yaba.daba.dooo',
    'music-user-token': 'here.be.dragons',
    'Origin': 'https://music.apple.com'}

MusicItems = MusicTree.findall('dict/dict/dict')

for MusicItemKeys in MusicItems:
    if MusicItemKeys.find('key[@id="Apple Music"]') is not None \
        and MusicItemKeys.find('key[@id="Album"]') is not None \
        and MusicItemKeys.find('key[@id="Playlist Only"]') is None:

        AlbumTitle = MusicItemKeys.find('key[@id="Album"]').find('string').text
        AlbumArtist = MusicItemKeys.find('key[@id="Artist"]').find('string').text

        if AlbumTitle != CurrentAlbumTitle:
            # print(AlbumTitle, AlbumArtist)
            AlbumsToAdd.append(AlbumArtist + ' ' + AlbumTitle)
            CurrentAlbumTitle = AlbumTitle

for album in AlbumsToAdd:
    AlbumSearchUrl = SearchUrl + album

    AppleMusicResponse = requests.get(AlbumSearchUrl, headers=AppleMusicAuthHeader)

    if AppleMusicResponse.status_code == 200:
        AppleMusicJson = json.loads(AppleMusicResponse.text)
        # print(json.dumps(AppleMusicJson, indent = 1))
        try:
            AlbumId = AppleMusicJson['results']['albums']['data'][0]['id']

            if AlbumId is not None:
                AppleMusicResponse = requests.post(AddToLibraryUrl + AlbumId, headers=AppleMusicAuthHeader)
                if AppleMusicResponse.status_code == 202:
                    print('*** SUCCESS *** ' + album)
                else:
                    print('*** FAILURE *** ' + album)
        except:
            print('*** EXCEPTION *** ' + album)
