# Music-Python

When changing the country for my Apple Music subscription from UK to Germany - so that I can use my German credit card to pay for it - Apple helpfully wipe your entire Apple Music library. That's everything I've "added to library" as I browse around during the past few years.

(Note: this doesn't affect anything I bought through iTunes Music Store or things I uploaded into iTunes in the past).

So, having been cautious, I took a backup of my library (`Music > File > Library > Export Library...`). It produces a huge XML file.

Not all of it is relevant for Apple Music, and it's not terribly well formatted.

## Tidying up the XML

Each "Music Item" exists in a `<dict>` element, which contains any number of `<key>` elements, each followed by either an `<integer>`, `<string>` or `<date>` element.

```xml
<dict>
  <key>Track ID</key><integer>6449</integer>
  <key>Name</key><string>Good Love (Jay Haze Edit)</string>
  <key>Artist</key><string>Kevin Saunderson</string>
  <key>Album Artist</key><string>Kevin Saunderson</string>
  <key>Composer</key><string>Kevin Saunderson</string>
  <key>Album</key><string>History Elevate - Remixed</string>
  <key>Genre</key><string>Dance</string>
  <key>Kind</key><string>Apple Music AAC audio file</string>
  <key>Size</key><integer>17098701</integer>
  <key>Total Time</key><integer>504867</integer>
  <key>Disc Number</key><integer>1</integer>
  <key>Disc Count</key><integer>1</integer>
  <key>Track Number</key><integer>13</integer>
  <key>Track Count</key><integer>15</integer>
  <key>Year</key><integer>2009</integer>
  <key>Date Modified</key><date>2020-09-23T14:42:02Z</date>
  <key>Date Added</key><date>2020-09-23T14:42:02Z</date>
  <key>Bit Rate</key><integer>256</integer>
  <key>Sample Rate</key><integer>44100</integer>
  <key>Release Date</key><date>2009-03-30T12:00:00Z</date>
  <key>Artwork Count</key><integer>1</integer>
  <key>Sort Album</key><string>History Elevate - Remixed</string>
  <key>Sort Artist</key><string>Kevin Saunderson</string>
  <key>Sort Name</key><string>Good Love (Jay Haze Edit)</string>
  <key>Persistent ID</key><string>161EC360517D398A</string>
  <key>Track Type</key><string>Remote</string>
  <key>Apple Music</key><true/>
</dict>
```

That's not particularly nice to work with, so I moved the value of each `<key>` into an attribute on the `<key>` element itself, and nested the values inside the `<key>` element. A `regex` makes this easy:

Find:
```
<key>(.*)</key>(.*)
```

Replace (VS Code uses $1, $2 as the placeholder references)
```
<key id="$1">$2</key>
```

Result:

```xml
<dict>
  <key id="Track ID"><integer>6449</integer></key>
  <key id="Name"><string>Good Love (Jay Haze Edit)</string></key>
  <key id="Artist"><string>Kevin Saunderson</string></key>
  <key id="Album Artist"><string>Kevin Saunderson</string></key>
  <key id="Composer"><string>Kevin Saunderson</string></key>
  <key id="Album"><string>History Elevate - Remixed</string></key>
  <key id="Genre"><string>Dance</string></key>
  <key id="Kind"><string>Apple Music AAC audio file</string></key>
  <key id="Size"><integer>17098701</integer></key>
  <key id="Total Time"><integer>504867</integer></key>
  <key id="Disc Number"><integer>1</integer></key>
  <key id="Disc Count"><integer>1</integer></key>
  <key id="Track Number"><integer>13</integer></key>
  <key id="Track Count"><integer>15</integer></key>
  <key id="Year"><integer>2009</integer></key>
  <key id="Date Modified"><date>2020-09-23T14:42:02Z</date></key>
  <key id="Date Added"><date>2020-09-23T14:42:02Z</date></key>
  <key id="Bit Rate"><integer>256</integer></key>
  <key id="Sample Rate"><integer>44100</integer></key>
  <key id="Release Date"><date>2009-03-30T12:00:00Z</date></key>
  <key id="Artwork Count"><integer>1</integer></key>
  <key id="Sort Album"><string>History Elevate - Remixed</string></key>
  <key id="Sort Artist"><string>Kevin Saunderson</string></key>
  <key id="Sort Name"><string>Good Love (Jay Haze Edit)</string></key>
  <key id="Persistent ID"><string>161EC360517D398A</string></key>
  <key id="Track Type"><string>Remote</string></key>
  <key id="Apple Music"><true/></key>
</dict>
```

Technically, I don't care about the type of the objects within each element. Really all I'm interested in is getting the `Artist` and `Album Title` values out.

## Parsing and de-duplication

Turns out, there were several special `id` values to watch out for.

* `Apple Music`: if it's not there, then the track wasn't stored in my Apple Music library, so I don't need to try to add it again.
* `Playlist Only`: I _think_ this flag is set when the track is in the library as the result of adding a Playlist, rather than adding a single or album. I'm not so bothered about keeping these, mostly I would have added them by "mistake" or laziness.
* `Album`: strangely, some items didn't have an Album value. I ignore these.

Also, each track on an album is listed as a separate item, so I want to do some (fairly crude) de-duplication as I process the XML file.

## Processing

* Parse the XML file into an `ElementTree`.
* Find the relevant items through the `XPath` `dict/dict/dict`.
* Check that the item has `Apple Music` and `Album` values, and isn't `Playlist Only`.
* Add the Artist and Album to a `List` – but only if it's not the same album as the previous time round the loop. See, I said crude...

## Getting the Apple Music ID

OK, so now I have a mostly de-duped list of Artist + Album. Now I need to ask the Apple Music API to try and find the relevant ID for the album. 

At first, it looked like I'd need to set up an Apple Developer account again, but actually I can see what's happening when interacting with Apple Music via a browser:

```curl
curl 'https://amp-api.music.apple.com/v1/catalog/de/search?term=madonna%20ray%20of%20light&l=en-gb&platform=web&types=activities%2Calbums%2Capple-curators%2Cartists%2Ccurators%2Ceditorial-items%2Cmusic-movies%2Cmusic-videos%2Cplaylists%2Csongs%2Cstations%2Ctv-episodes%2Cuploaded-videos%2Crecord-labels&limit=25&relate%5Beditorial-items%5D=contents&include[editorial-items]=contents&include[albums]=artists&include[songs]=artists&include[music-videos]=artists&extend=artistUrl&fields[artists]=url%2Cname%2Cartwork%2Chero&fields%5Balbums%5D=artistName%2CartistUrl%2Cartwork%2CcontentRating%2CeditorialArtwork%2Cname%2CplayParams%2CreleaseDate%2Curl&with=serverBubbles%2ClyricHighlights&art%5Burl%5D=c%2Cf&omit%5Bresource%5D=autos' --globoff -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:90.0) Gecko/20100101 Firefox/90.0' -H 'Accept: */*' -H 'Accept-Language: en,de;q=0.8,en-GB;q=0.5,en-US;q=0.3' --compressed -H 'Referer: https://music.apple.com/' -H 'authorization: Bearer YADAYADA' -H 'media-user-token: DABADABA' -H 'Origin: https://music.apple.com' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-site' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers'
```

* `term` = `madonna ray of light`
* `authorization` = `Bearer TOKEN`
* `types` = the various media types that can be searched for. I want to restrict this to just albums.
* `limit` = 25. I want to only return one item.
* `include[blah]` = returns additional meta links for the artist, videos, editorial blurb.
* `fields[blah]` = returns metadata of the item. Not sure I needed any of this.

So I concoct a simpler request URL, where I can tack on the artist and album at the end, and only ask for 1 album:

```curl
https://amp-api.music.apple.com/v1/catalog/de/search?l=de-de&platform=web&types=albums&limit=1&term=madonna%20ray%20of%20light
```

It still returns a lot, but I can work with that. The most important part is the ID: `results > albums > data > 0 > id`.

So for each request, I check that I can find the ID. Then make a second request to add it to my library.

## Authentication

Of course, to add it to my library, I need to be signed in, and from what I can tell, I needed to send the `media-user-token` as well as the `authorization` token when trying to POST to the API. I included the `Origin` in the headers too.

## Adding the album to my library

The URL schema is really simple:

```
https://amp-api.music.apple.com/v1/me/library?ids[albums]=THE_ID_FROM_THE_JSON
```

Loop through the `List` of artists and albums I created, try to extract an ID for each one, then post the update to the API. And log the results ;-)

```txt
*** SUCCESS *** Piroshka Love Drips and Gathers
*** SUCCESS *** ZHU DREAMLAND 2021
*** EXCEPTION *** Mount Obsidian Velvet Desert Music, Vol. 2
*** SUCCESS *** Tune-Yards sketchy.
*** SUCCESS *** Pseudo Echo Autumnal Park
```
