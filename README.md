BraidBot
========

A framework for easily writing Braid bots.

The easiest way to get started is to use the `braidbot/insta` language:

```racket
#lang braidbot/insta

;; minimum bot just needs the act-on-message function defined
(define (act-on-message msg)
  (reply-to msg "Hi there!"
    #:bot-id "..."
    #:bot-token "..."))
```

For a simple example, see [rot13bot](https://github.com/braidchat/rot13bot).

For a full example, see [reminderbot](https://github.com/braidchat/reminderbot).

## Creating a Bot

Install [Racket](https://download.racket-lang.org/).

Create a new project: `raco pkg new mycoolbot`

Add BraidBot as a dependency to `info.rkt`: `"https://github.com/braidchat/braidbot.git#v1.1"`

Edit `main.rkt`.
You can use the `braidbot/insta` language or require the library modules & use them directly, if you wish.

For the `insta` language, a good starting point is something like the following:

```racket
#lang braidbot/insta

;; Set the bot-id, bot-token, and braid-url in environment variables.
;; If doing this, you'd run the bot like
;; BOT_ID='...' BOT_TOKEN='...' BRAID_URL='...' racket -t main.rkt
(define bot-id (getenv "BOT_ID"))
(define bot-token (getenv "BOT_TOKEN"))
(define braid-url (getenv "BRAID_URL"))

;; set the port the bot will listen on
(listen-port 8899)

;; set a function to run on startup
(on-init (λ () (println "Bot starting")))

;; required function you must implement
;; `msg` is the decoded message that the bot has recieved
;; note that, if it's a mention, the content will begin with `/botname`
(define (act-on-message msg)
  (println "Got a message:")
  (println (hash-ref msg '#:content))
  ;; reply-to is a function from braidbot/braid (which is automatically required
  ;; by the `insta` language) that sends a message in reply to `msg`, to the same thread.
  ;; If you want to start a new thread, you can use `send-message`.
  (reply-to msg "Hi, I'm a bot!"
    #:bot-id bot-id
    #:bot-token bot-token
    #:braid-url braid-url))
```

## Testing Your Bot

Add a bot to your local Braid install, configure your bot to use the local URL for the `braidbot/braid` communication functions, and the bot-id & bot-token.

The first time you start it, you'll need to install the package for your bot, which will also download the dependencies.
You can do this by running `raco pkg install` in the directory containing the `info.rkt` file.

Once the package is installed, you can run the bot with `racket -t main.rkt`.

## Deploying Your Bot

Once you have your bot ready, you can create an executable using `raco exe main.rkt -o mycoolbot`.

Then to create a standalone executable, with the libraries bundled in, use `raco distribute`, like:

`raco distribute deploy mycoolbot`

This will create a directory called `deploy` that you can zip up, upload to your server, and run `bin/mycoolbot`.

# Module Documentation

## `braidbot/uuid`

This module defines a `uuid` struct that is used to represent version 4 UUIDs.

The following functions are provided:

  - `make-uuid` `(-> uuid?)`: Generate a new, random UUIDv4.
  - `uuid?` `(-> any boolean?)`: Predicate to check if something is a UUID struct.
  - `uuid` `(-> integer? integer? uuid?)`: The struct itself. Used for constructing a UUID from the high and low 64 bits, respectively. Probably don't use this directly.
  - `uuid-hi64` `(-> uuid? integer?)`: Getter to extract the high 64 bits of the UUID. Probably don't use this directly.
  - `uuid-lo64` `(-> uuid? integer?)`: Getter to extract the low 64 bits of the UUID. Probably don't use this directly.

## `braidbot/braid`

This module provides functions for sending messages to braid.

A message is an immutable hash with the following keys and values:

  - `#:id`: `UUID`: The id of the message
  - `#:content`: `String`: The body of the message
  - `#:created-at`: `Date`: The time the message was created at
  - `#:user-id`: `UUID`: The id of the sender
  - `#:thread-id`: `UUID`: The id of the thread the message is in
  - `#:group-id`: `UUID`: The id of the group the thread is in
  - `#:mentioned-user-ids`: `(listof UUID)`: A list of the mentioned users in that message (*not* already tagged in the thread)
  - `#:mentioned-tag-ids`: `(listof UUID)`: A list of the tags in that message (*not* already tagged in the thread)

Note that when sending a message `user-id`, `group-id`, and `created-at` are optional, as the server will fill them in appropriately (and ignore whatever you set).

The following functions are provided (where `message?` is written, treat that as a hash as described above):

  - `send-message` `(-> message? #:bot-id string? #:bot-token string? (#:braid-url string?) any)`: Send the given message to Braid.
  - `reply-to` `(-> message? string? #:bot-id string? #:bot-token string? (#:braid-url string?) any)`: Helper function to reply to the given message. That is, create a new message with the same thread as the given message with the content given by the string argument.
