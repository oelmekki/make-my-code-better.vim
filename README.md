# Make My Code Better

Make My Code Better is a vim plugin to ask ChatGPT recommendations about
how to make your code better.

It will send your selected code (or the whole file is no code is selected)
to the ChatGPT api, and provide its answer in a split window.

## Installation and setup

Make My Code Better requires vim to be built with python3 support (check
the output of `vim --version` if you have +python3) and depends on tiktoken,
openai's token counting module which you can install this way:

    pip install tiktoken

Additionally, you must provide your [openai api](https://platform.openai.com/) key,
which you can set up in your vimrc file:

    let g:open_ai_key="<your-key>"

## Usage

After that, you can use `:MakeMyCodeBetter` to run the plugin. This command
accepts range, so you can just send one or two functions. Given the
limitation in number of tokens, this will probably be your most common
usage. You will be warned if you exceed the amount of tokens allowed, and
no request will be performed.

## Instructions

The default instructions for ChatGPT are:

    I'm going to show you my code, and you're going to make it better, providing
    your version and explaining your changes, or congratulating me if it's already
    perfect. You don't consider coding style preferences, you only suggest changes
    that could make the code more performant, less buggy or easier to maintain.


You can change that and use your own instructions instead by setting this
variable:

    let g:make_my_code_better_instructions='
      \ I''m going to show you my code. You''re going to say you found a way to
      \ make it more performant, and you will rewrite my code in C.'

## Limitations

The plugin waits for the whole response to be provided by the api before
displaying it, so you might but hanging for a while waiting for it. I could
have used the new vim-9.0 api to stream it, but I've never used that and
I'm not even sure if it would work through python support. It was just not
painful enough for me to investigate, just don't be surprised if you paste
a lot of code and it takes 30 seconds to complete.

ChatGPT is limited to 4096 tokens per request (a token being usually a part
of a word, but the token count on code can shoot up high fast). This
include the instructions, your code, and the answer of ChatGPT. Since we
ask it to rewrite the code, if can be up to the same length than the code
you provided (hopefully, it will be more concise than your code) and
include some explanations. For that reason, I limited the code you provide
to 2000 tokens. You can tweak that number by setting the
`g:make_my_code_better_max_tokens` variable.

And of course, this is ChatGPT : just because it tells you something
doesn't mean it's true! Check the code it recommends and apply good
judgment. Despite that, it's worth it. I've been a webdeveloper for 15
years and it taught me new things. Has this very plugin been written with
the help of ChatGPT? Of course it has! And was done in less than a day for
it. Roxor.
