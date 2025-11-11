# Sweetie Bot
A simple Philomena-based booru image fetching bot with a few extra additions for spice.

## Configuring
The provided `settings.example.yml` file is well-commented and should provide enough documentation for you to tweak the bot to your liking.

## Running in Docker

Copy `settings.example.yml` and `database.example.yml` as `settings.yml` and `database.yml`, and fill those out.

Create and import the database schema from `structure.sql`
```
sqlite3 ./bot.db
sqlite> .read ./db/structure.sql
```

Run the bot:

```
docker run --rm -it \
  -v ./settings.yml:/opt/sweetie-bot/config/settings.yml \
  -v ./database.yml:/opt/sweetie-bot/config/database.yml \
  -v ./bot.db:/opt/sweetie-bot/db/bot.db \
  -e DISCORD_BOT_TOKEN=your_discord_bot_token_here \
  -e PHILOMENA_API_KEY=your_booru_api_key_here \
  ghcr.io/derpibooru/sweetie-bot
```

## Running Manually
### Prerequisites
* Linux (anything non-musl will probably work)
* Ruby 3.4.7
* `libsqlite3-dev`

```sh
sudo apt-get install libsqlite3-dev
```

...or your distribution's package manager. You're a grown-up adult, you can figure it out, probably.

### Cloning the Repo and Running
First, clone the repository and navigate to it's folder
```sh
git clone https://github.com/furbooru/furbot
cd furbot
```
Install all the required packages using Bundler
```sh
bundle install
```
Copy the example config file (located in the `config/` folder) and modify it
```sh
cp settings.example.yml settings.yml
```
Import the database schema from `structure.sql`
```
sqlite3 ./db/bot.db
sqlite> .read ./db/structure.sql
```
Once you're done, you can run the bot by running
```sh
./bin/sweetie-bot
```
If you want to load a specific configuration file, you can use `-c` to specify it's location
```sh
./bin/sweetie-bot -c settings.yml
```
