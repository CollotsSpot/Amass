# Music Assistant Mobile - Troubleshooting Guide

## Common Issues and Solutions

### Connection Issues

#### Problem: "Not Connected to Music Assistant"

**Symptoms:**
- App shows disconnected state
- Cannot browse library
- No players available

**Solutions:**

1. **Verify Server URL**
   - Go to Settings
   - Check server URL format: `https://ma.serverscloud.org` or `http://192.168.1.100:8095`
   - Ensure no trailing slash
   - Try both HTTP and HTTPS if unsure

2. **Check Network Connectivity**
   - Ensure device has internet/network access
   - Try opening server URL in mobile browser
   - Check if on same network (for local servers)

3. **Verify Music Assistant Server**
   - Ensure Music Assistant server is running
   - Check server is accessible from your device
   - Verify port 8095 (default) or custom port is open

4. **Check Authentication**
   - If using Authelia, verify credentials
   - Try re-entering username/password
   - Check Authelia is accessible

5. **Clear App Data**
   - Go to Settings → Clear all settings
   - Re-enter server URL and credentials
   - Restart app

#### Problem: "WebSocket Connection Failed"

**Symptoms:**
- Connection drops frequently
- "Connection timeout" errors in logs

**Solutions:**

1. **Check WebSocket Port**
   - Default: 8095 for local, 443 for HTTPS
   - Go to Settings → Custom WebSocket Port
   - Try entering port explicitly

2. **Verify Firewall Rules**
   - Ensure WebSocket traffic is allowed
   - Check reverse proxy configuration (if using)
   - Cloudflare users: Ensure WebSocket support enabled

3. **Test WebSocket Connection**
   - Use browser dev tools to test WebSocket
   - URL format: `wss://ma.serverscloud.org/ws`
   - Look for successful upgrade to WebSocket

---

### Authentication Issues

#### Problem: "Login Failed" or "401 Unauthorized"

**Symptoms:**
- Cannot login with correct credentials
- Session expires immediately
- WebSocket authentication fails

**Solutions:**

1. **Verify Authelia Credentials**
   - Double-check username and password
   - Check Authelia domain is correct
   - Try logging in via web browser first

2. **Check Session Cookie**
   - Cookie name should be `authelia_session`
   - Check cookie is being set by Authelia
   - Verify cookie domain matches

3. **Clear Saved Credentials**
   - Settings → Clear all settings
   - Re-enter credentials
   - Test login

4. **Check Authelia Configuration**
   - Ensure Authelia is properly configured
   - Verify session timeout settings
   - Check Authelia logs for errors

#### Problem: "Auto-login Fails"

**Symptoms:**
- Must re-login every app start
- "Auto-login failed" in logs

**Solutions:**

1. **Check Saved Credentials**
   - Settings → Verify username is saved
   - Password should be saved (not visible)
   - Re-save credentials if needed

2. **Session Timeout**
   - Authelia session may have expired
   - Check Authelia session duration
   - Re-login to refresh session

---

### Playback Issues

#### Problem: "No Players Available"

**Symptoms:**
- Player selector shows empty list
- Cannot select any player
- Music won't play

**Solutions:**

1. **Refresh Player List**
   - Open player selector (top right icon)
   - Tap refresh icon
   - Wait for players to load

2. **Check Music Assistant Server**
   - Verify players are configured in MA server
   - Check players are powered on
   - Ensure players are available

3. **Wait for Initial Load**
   - Players load on connection
   - May take a few seconds
   - Check debug logs for "Loaded X players"

#### Problem: "Now Playing Bar Not Showing"

**Symptoms:**
- Music is playing but no mini-player appears
- Cannot see current track

**Solutions:**

1. **Check Player Selection**
   - Ensure a player is selected (green dot in player selector)
   - Select player explicitly if needed

2. **Verify Queue Has Items**
   - Some players may not support queue state
   - Try playing an album/track
   - Check queue screen for items

3. **Check Debug Logs**
   - Look for "Error getting queue" messages
   - Check for parsing errors
   - Report specific error in GitHub issues

4. **Force Refresh**
   - Stop and restart playback
   - Select different player, then select back
   - Restart app

#### Problem: "Cannot Control Playback"

**Symptoms:**
- Play/pause buttons don't work
- Skip track buttons unresponsive

**Solutions:**

1. **Check Player State**
   - Some players may not support all controls
   - Verify player is powered on
   - Check Music Assistant server logs

2. **Network Latency**
   - Commands may take 1-2 seconds
   - Wait before clicking again
   - Check network connection

3. **Player Availability**
   - Player may have disconnected
   - Refresh player list
   - Re-select player

---

### Library Issues

#### Problem: "No Artists/Albums/Tracks Found"

**Symptoms:**
- Empty library screens
- "No items found" messages

**Solutions:**

1. **Check Music Assistant Library**
   - Verify library is populated in MA server
   - Scan library in MA web interface
   - Ensure provider is configured

2. **Force Library Reload**
   - Pull down to refresh on library screens
   - Go to home screen and back
   - Restart app

3. **Check API Limits**
   - Default limit is 100 items
   - May not show all items if library > 100
   - Pagination planned for future release

4. **Verify Connection**
   - Ensure WebSocket is connected
   - Check connection status on home screen
   - Look for green dot indicator

#### Problem: "Search Returns No Results"

**Symptoms:**
- Search finds nothing
- Known items don't appear

**Solutions:**

1. **Check Search Query**
   - Try partial matches
   - Search is case-insensitive
   - Wait for debounce (500ms)

2. **Verify Library Content**
   - Ensure items exist in MA library
   - Test search in MA web interface
   - Re-scan library if needed

3. **Check Network**
   - Search requires active connection
   - Verify WebSocket is connected
   - Try again with better connection

---

### Queue Issues

#### Problem: "Queue Screen Shows Empty"

**Symptoms:**
- Queue screen has no items
- Music is playing but queue empty

**Solutions:**

1. **Check Player Type**
   - Some players may not support queue viewing
   - Try different player
   - Check MA server capabilities

2. **Refresh Queue**
   - Tap refresh icon in queue screen
   - Play a new album/track
   - Restart playback

3. **API Issues**
   - Check logs for "Error getting queue"
   - May be API parsing issue
   - Report bug with logs

#### Problem: "Cannot Reorder/Remove Queue Items"

**Symptoms:**
- Drag and drop doesn't work
- Swipe to dismiss fails

**Solutions:**

1. **API Support**
   - Reordering/removing is local only (currently)
   - Server sync not yet implemented
   - Changes won't persist on server

2. **UI Issues**
   - Ensure you're dragging from handle icon
   - Swipe fully to left to dismiss
   - Try on different queue items

---

### Performance Issues

#### Problem: "App is Slow/Laggy"

**Symptoms:**
- UI stutters
- Slow navigation
- Delayed responses

**Solutions:**

1. **Clear App Cache**
   - Settings → Clear all settings
   - Restart app
   - May improve performance

2. **Reduce Polling**
   - Player state polls every 2 seconds
   - Expected behavior for now
   - Future: Event-based updates

3. **Check Device Performance**
   - Close other apps
   - Restart device
   - Check available storage

4. **Network Latency**
   - Test network speed
   - Move closer to WiFi
   - Try different network

#### Problem: "High Battery Drain"

**Symptoms:**
- Battery drains quickly
- App using lots of background power

**Solutions:**

1. **Polling Frequency**
   - Player state polling uses power
   - Will be optimized in future
   - Close app when not in use

2. **Background Activity**
   - App doesn't support background playback yet
   - Ensure app is closed when done
   - Check battery settings

---

### UI Issues

#### Problem: "Images Not Loading"

**Symptoms:**
- Album/artist artwork missing
- Broken image icons

**Solutions:**

1. **Check Network**
   - Images load from server
   - Requires active connection
   - Try refreshing

2. **Verify Image URLs**
   - Check MA server has artwork
   - Test image URL in browser
   - May be missing for some items

3. **Server Configuration**
   - Check image proxy settings
   - Verify image API endpoint
   - Check CORS configuration

#### Problem: "Screen Layout Broken"

**Symptoms:**
- Overlapping elements
- Text cut off
- Weird spacing

**Solutions:**

1. **Restart App**
   - Force close and reopen
   - May fix temporary layout issues

2. **Check Device**
   - Test on different screen size
   - May be device-specific issue
   - Report with device model

---

## Debug Logging

### Enabling Logs

Logs are always enabled and print to console. To view:

**Android Studio / VS Code:**
1. Run app in debug mode
2. Open Debug Console
3. Look for timestamped logs: `[HH:MM:SS.mmm] Message`

**Physical Device:**
1. Connect via USB
2. Run `flutter logs`
3. Filter for app logs

### Important Log Messages

**Connection:**
- `Connected to Music Assistant successfully` - Connection established
- `WebSocket error: ...` - Connection problem
- `Connection timeout` - Server not responding

**Authentication:**
- `🔑 Adding session cookie to WebSocket handshake` - Auth in progress
- `✓ Authenticated` - Auth successful
- `⚠️ Auto-login failed` - Credentials issue

**Players:**
- `Loaded X players` - Player list fetched
- `Selected player: Name (ID)` - Player selected
- `Using cached player list` - Cache hit

**Queue:**
- `🔍 DEBUG: First queue item raw data` - Queue structure
- `Error getting queue: ...` - Queue fetch failed
- `⚠️ Failed to parse queue item` - Parsing error

**Playback:**
- `Playing X tracks via queue on player Y` - Playback started
- `✓ X tracks queued successfully` - Queue successful

### Reporting Bugs

When reporting issues, include:

1. **Steps to Reproduce**
   - Exact actions taken
   - Expected vs actual behavior

2. **Debug Logs**
   - Copy relevant log section
   - Include timestamps
   - Show 10-20 lines before/after error

3. **Environment**
   - Device model and OS version
   - App version
   - Music Assistant server version
   - Network type (WiFi, cellular, etc.)

4. **Screenshots**
   - Error messages
   - UI issues
   - Settings screen

---

## Known Limitations

### Current Constraints

1. **Library Pagination**
   - Loads max 100 items per category
   - Infinite scroll coming soon

2. **Queue Management**
   - Reorder/remove only local
   - Server sync not implemented
   - Changes don't persist

3. **Player State**
   - Polls every 2 seconds
   - Event-based updates coming
   - May have slight delay

4. **Search**
   - Searches entire library only
   - No category-specific search
   - No search history

5. **Offline Mode**
   - No offline playback
   - Requires active connection
   - Planned for future

### Planned Improvements

See ARCHITECTURE.md → Future Enhancements for roadmap.

---

## Advanced Troubleshooting

### WebSocket Debugging

1. **Chrome DevTools Method**
   ```
   1. Open ma.serverscloud.org in Chrome
   2. F12 → Network tab
   3. Filter: WS (WebSocket)
   4. Look for /ws connection
   5. Inspect frames (messages)
   ```

2. **Test WebSocket Manually**
   ```javascript
   const ws = new WebSocket('wss://ma.serverscloud.org/ws');
   ws.onopen = () => console.log('Connected');
   ws.onmessage = (e) => console.log('Message:', e.data);
   ws.onerror = (e) => console.error('Error:', e);
   ```

### API Testing

Use Music Assistant's web interface to test API:
1. Open developer tools
2. Go to Network tab
3. Perform action (search, play, etc.)
4. Inspect WebSocket messages
5. Compare with app behavior

### Flutter Debugging

**DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**Widget Inspector:**
- Shows widget tree
- Inspect layout issues
- Debug rendering

**Performance:**
- Profile mode: `flutter run --profile`
- Check frame rendering times
- Monitor memory usage

---

## Getting Help

### Support Channels

1. **GitHub Issues**
   - Bug reports
   - Feature requests
   - Technical discussions
   - URL: https://github.com/CollotsSpot/music-assistant-mobile/issues

2. **Music Assistant Community**
   - Discord server
   - Forum discussions
   - General questions
   - URL: https://music-assistant.io/

3. **Documentation**
   - ARCHITECTURE.md - Technical details
   - README.md - Getting started
   - Code comments - Implementation details

### Before Asking

1. Check this troubleshooting guide
2. Search existing GitHub issues
3. Check Music Assistant docs
4. Test with Music Assistant web interface
5. Gather debug logs

### Providing Feedback

**Bug Report Template:**
```
**Description**
[Clear description of the issue]

**Steps to Reproduce**
1. Step one
2. Step two
3. ...

**Expected Behavior**
[What should happen]

**Actual Behavior**
[What actually happens]

**Logs**
[Relevant log excerpt]

**Environment**
- Device: [e.g. Samsung Galaxy S21]
- OS: [e.g. Android 13]
- App Version: [e.g. 1.0.0]
- MA Server Version: [e.g. 2.7.0]

**Screenshots**
[If applicable]
```

---

## FAQ

### Q: Does the app support offline playback?
**A:** Not currently. All playback requires connection to Music Assistant server.

### Q: Can I use this with multiple Music Assistant servers?
**A:** Not simultaneously, but you can change servers in Settings.

### Q: Why isn't my local file library showing?
**A:** Check Music Assistant server has scanned your local files and the provider is enabled.

### Q: Does it support Android Auto / CarPlay?
**A:** Not yet, but planned for future releases.

### Q: Can I download music for offline listening?
**A:** Not currently supported.

### Q: How do I update the app?
**A:** Updates will be distributed via app stores once released. Currently, build from source.

### Q: Is my password stored securely?
**A:** Yes, credentials are stored using Flutter's secure storage mechanisms.

### Q: Can I control playback when screen is off?
**A:** Background playback is limited. The app is designed for active use currently.

### Q: Why can't I see all my albums?
**A:** Current limit is 100 items per category. Pagination coming soon.

### Q: Does it work with Spotify/YouTube/etc?
**A:** Yes, if configured as providers in Music Assistant server.

---

**Last Updated:** 2025-01-22
**App Version:** Development Build
**Music Assistant Version:** 2.7.0+
