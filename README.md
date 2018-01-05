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
