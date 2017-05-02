hs.hotkey.bind({"cmd", "alt"}, "N", function()

  local album
  local artist
  local track
  local ok
  local artwork
  local spotifyState
  local voxState
  local itunesState = hs.itunes.isPlaying()
  local spotifyState = hs.spotify.isPlaying()

  hs.alert.closeSpecific(NowPlayingAlert)

  -- check VOX's state
  local voxExists = hs.appfinder.appFromName("VOX")
  if voxExists == nil then
    voxState = 0
  else
    voxState = hs.vox.getPlayerState()
  end

  -- iTunes {{{
  if itunesState == true and spotifyState ~= true and voxState ~= 1 then
    tweet = true
    album = hs.itunes.getCurrentAlbum()
    artist = hs.itunes.getCurrentArtist()
    track = hs.itunes.getCurrentTrack()

    -- get artwork
    ok = hs.osascript.applescript([[
      tell application "iTunes" to tell artwork 1 of current track
        set srcBytes to raw data
        set ext to ".jpg"
      end tell
      set fileName to (((path to music folder) as text) & "NowPlaying_artwork" & ext)
      set outFile to open for access file fileName with write permission
      set eof outFile to 0
      write srcBytes to outFile
      close access outFile
    ]])

    -- set artwork
    if ok == true then
      artwork = hs.image.imageFromPath("~/Music/NowPlaying_artwork.jpg")
    else
      artwork = nil
    end
  -- }}}

  -- Spotify {{{
  elseif itunesState ~= true and spotifyState == true and voxState ~= 1 then
    tweet = true
    album = hs.spotify.getCurrentAlbum()
    artist = hs.spotify.getCurrentArtist()
    track = hs.spotify.getCurrentTrack()

    -- get artwork
    ok, artwork = hs.osascript.applescript([[
      tell application "Spotify" to artwork url of current track
    ]])
  -- }}}

  -- VOX {{{
  elseif itunesState ~= true and spotifyState ~= true and voxState == 1 then
    tweet = true
    album = hs.vox.getCurrentAlbum()
    artist = hs.vox.getCurrentArtist()

    -- get current track
    ok, track = hs.osascript.applescript([[
      tell application "VOX" to track
    ]])

  -- not playing
  elseif itunesState ~= true and spotifyState ~= true and voxState ~= 1 then
    tweet = false
    NowPlayingAlert = hs.alert.show("Not Playing", {fillColor = {red = 1, alpha = 0.75}}, 0.5)

  -- duplicate
  else
    tweet = false
    NowPlayingAlert = hs.alert.show("Duplicated", {fillColor = {red = 1, alpha = 0.75}}, 0.5)
  end

  -- tweet
  if tweet == true then
    local contents = album.." - "..track.." ("..artist..") ".."#NowPlaying"
    local twitter = hs.sharing.newShare("com.apple.share.Twitter.post")
    twitter:shareItems(contents, artwork)
  end

end)

