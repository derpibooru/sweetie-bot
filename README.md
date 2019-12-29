# Sweetie Bot
A simple Derpibooru image fetching bot with a few extra additions for spice.

## Running
### Prerequisites
* Linux (Debian Stretch / Ubuntu 16.04 or newer recommended)
* Ruby 2.7.0
* `libsqlite3-dev`

```sh
sudo apt-get install libsqlite3-dev
```

### Cloning the Repo and Running
First, clone the repository and navigate to it's folder
```sh
git clone https://github.com/derpibooru/sweetie-bot
cd sweetie-bot
```
Install all the required packages using Bundler
```sh
bundle install
```
Copy the example config file and modify it
```sh
cp settings.example.yml settings.yml
```
Once you're done, you can run the bot by running
```sh
./bin/sweetie-bot
```
If you want to load a specific configuration file, you can use `-c` to specify it's location
```sh
./bin/sweetie-bot -c settings.yml
```

### Configuration
The provided `settings.example.yml` file is well-commented and should provide enough documentation for you to tweak the bot to your liking.

**If running as self-bot, make sure to change `:bot` to `:user` in `client_type`! Running a self-bot is highly discouraged and is against Discord ToS.**
