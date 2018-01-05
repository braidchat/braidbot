braidbot
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

For a full example, see [reminderbot](https://github.com/braidchat/reminderbot).

## Creating a Bot

Install [Racket](https://racket-lang.org).

Create a new project `raco pkg new mycoolbot`

Add dependency to `info.rkt` `"https://github.com/braidchat/braidbot.git#v1.0"

Edit `mycoolbot.rkt`.

## Deploying Your Bot

Once you have your bot ready, you can create an executable using `raco exe mycoolbot.rkt`.

Then to create a standalone executable, with the libraries bundled in, use `raco distribute`, like:

`raco distribute deploy mycoolbot`

This will create a directory called `deploy` that you can zip up, upload to your server, and run `bin/mycoolbot`.
