[ ] UX Polishing
    [ ] Learn about flutter/dart and good practices for implementing UX, using go_router, etc. Then fix the bad practices we have in the code. And fix exceptions that are raised during runtime.
    [ ] Improve network.dart, such as better error handling and handling edge cases. See TODOs in that file for full list.
    [ ] Consider TODOs in lib/menu/* files
    [ ] Enhance the game menu (settings, about, nicer animations, etc.)
    [ ] Should be easy to join - share the link, i.e. over internet (i.e., copy link on desktop, send to app on android) or in person (i.e., QR code)
    [ ] Make it easy to login (allow seamless login with device id and "account protection" by linking google/facebook/etc or email)
    [ ] Show information about the game from JSON file
    
[ ] Telemetry
    [ ] Detect crashes (+ look into gorouter errorbuilder) and proper error handling in whole app. Consider more useful stack traces with [this package](https://pub.dev/packages/stack_trace)
    [ ] Measure usage
    [ ] Create dashboard
    [ ] Create cloud telemetry endpoint and connect it with the app. Test it works. Do not log to console for release version.
    [ ] Look into libraries we are using that are logging to console and pipe those logs to our logging code if possible

[ ] Nice to have
    [ ] Go through all the code and add restrictings where applicable (i.e. const, final, make variables non-nullable, const constructors)
    [ ] Consider replacing enum value printing with value.name printing
    [ ] Remove public late final's without initializer (so there is no public setter)
    [ ] Optimize game startup and loading of resources (on startup and later)
    [ ] Does nakama support email address verification/validation?

[ ] Let others play the game
    [ ] Test it on actual android device (i.e. ensure device rotation works)
    [ ] Make it work on windows
    [ ] Create cloud server for resources (nakama and game download). Also see [this](https://heroiclabs.com/docs/nakama/getting-started/configuration/)
    [ ] Create cloud server for serving game as webpage
    [ ] Make sure game works with non-local resources
    [ ] Ensure we can reject and update old clients. Create cloud server to inform what is the latest version of the game, whether to enforce update and whether to prevent connecting to server (i.e. muiltiplayer, game download later, etc.). Update clients to notify of new version and/or block running if update is enforced. Prevent connecting to server if told so.
    [ ] Fix any bugs, test for edge cases
    [ ] Ship
        [ ] Play store
        [ ] Create website to download windows binaries
        [ ] Publish linux binaries to snap store
    [ ] Ask people to play it on forums

[ ] Game definition
    [ ] Define JSON schema and validate JSONs (+ serialization) (see [1](https://pub.dev/packages/json_schema) and [2](https://pub.dev/packages/built_value))
    [ ] Better serialization of <events going through nakama>
    [ ] Replace hard-coded (hacky) code with reusable code
    [ ] Come up with and implement strategy for searching for objects with multiple instances (right now we do #<id>#<number>#).
    [ ] Extend schema and implement games:
        [ ] Solitaire (1 player)
        [ ] Tablic (2 player)
        [ ] Yahtzee (1 player)
        [ ] Preferans (3 player)
        [ ] Chess (2 players)
    [ ] With above we will need support for:
        [ ] Showing game rules at start
        [ ] Teaching game during play
        [ ] Explaining what is happening while the game is progressing
            [ ] Announce player changes
        [ ] Setting how verbose/slow/fast game will be (per-game setting)
        [ ] For multiplayer add timeout for player move and game abandonment if player leaves 
    [ ] Add description, author, donation info, license fields. Show that info in-game.

[ ] Downloading games
    [ ] Allow game hosting/downloading (for now upload will be manual and allowed only for administrator)
        [ ] Clean-up code for loading assets, remove hacks, use what is recommended in library documentation
    [ ] Update game menu to support discovering/downloading games
    [ ] Allow playing downloaded games
    [ ] Support game versioning
        [ ] Updating downloaded game notifications
        [ ] Check before starting multiplayer game and fail if not the same version
    [ ] Graciously fail if game definition has a bug/problem + telemetry
    [ ] Ensure game can not be attack vector (i.e. limits on sizes, guard against divide-by-zero, infinite loop detection)
    [ ] If game ends up attacking, graciously detect and fail (i.e. do not crash, but inform user about the issue and bring him back to main menu + send telemetry about the problem)

[ ] Game enhancements
    [ ] Support spritesheets
    [ ] Support animations (in game JSON)
    [ ] Investigate other nakama features we might want to use (i.e. chat, scores, etc.)

[ ] Let others play the game 2
    [ ] Implement authorative multiplayer (i.e. compile relevant .dart files to JS and run them on the nakama server)
    [ ] Ship new version and block old versions
    [ ] Ask people to play it on forums
    [ ] After some time require update of old versions
