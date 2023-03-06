" This code is in public domain.

if exists("loaded_make_my_code_better")
    finish
endif
if (v:progname == "ex")
   finish
endif
let loaded_make_my_code_better = 1

function! MakeMyCodeBetter() range
  if line("'") != line("''")
    execute "normal! g`\""
  endif

py3 << EOF
import urllib.request
import json
import tiktoken

user_max = None
if vim.eval("exists('g:make_my_code_better_max_tokens')") == "1":
  user_max = int(vim.eval('g:make_my_code_better_max_tokens'))

# ChatGPT accepts 4096 tokens, which includes the instructions and the request.
# So we allow 2000 tokens max in the request, otherwise answer would be
# truncated.
MAX_REQUEST_LEN = user_max or 2000


def fetch(messages, max_tokens_for_answer):
  query = {
    "model": "gpt-3.5-turbo",
    "messages": messages,
    "temperature": 0.5,
    "max_tokens": max_tokens_for_answer,
  }

  headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {vim.eval('g:open_ai_key')}",
  }

  query = json.dumps(query).encode("utf-8")

  try:
    request = urllib.request.Request("https://api.openai.com/v1/chat/completions", headers=headers, data=query)
    raw_response = urllib.request.urlopen(request).read().decode("utf-8")
  except urllib.error.HTTPError as e:
    if e.code == 400:
      raw_response = e.read().decode("utf-8")
    else:
      raise e

  response = json.loads(raw_response)
  if "error" in response:
    return response["error"]["message"]
  else:
    return response["choices"][0]["message"]["content"].lstrip("\n").rstrip("\n")


def code():
  selected_text = vim.eval("getline(\"'<\", \"'>\")")
  if len(selected_text) == 0:
    selected_text = vim.current.buffer[:]
  return "\n".join(selected_text)


def instructions():
  if vim.eval("exists('g:make_my_code_better_instructions')") == "1":
    return vim.eval("g:make_my_code_better_instructions")
  else:
    return """
    I'm going to show you my code, and you're going to make it better, providing
    your version and explaining your changes, or congratulating me if it's already
    perfect. You don't consider coding style preferences, you only suggest changes
    that could make the code more performant, less buggy or easier to maintain.
    """


def show(content):
  vim.command("split 'Make My Code Better'")
  buf = vim.current.buffer
  buf[:] = content.split("\n")
  buf.options["buftype"] = "nofile"
  buf.options["swapfile"] = False
  buf.options["bufhidden"] = "wipe"
  buf.options["filetype"] = "markdown"


messages = [
  {"role": "system", "content": instructions()},
  {"role": "user", "content": code()},
]

token_length = sum(len(tiktoken.get_encoding("gpt2").encode(message["content"])) for message in messages)

if token_length > MAX_REQUEST_LEN:
  content = f"Selected code is too big : {token_length} tokens, while we allow a maximum of {MAX_REQUEST_LEN} tokens. You can use range selection to reduce that amount, by visually selecting a chunk of code and using :'<,'>MakeMyCodeBetter on it."
else:
  max_tokens_for_answer = 2000 - token_length
  content = fetch(messages, max_tokens_for_answer)

show(content)

EOF
endfunction

command -range MakeMyCodeBetter <line1>,<line2>call MakeMyCodeBetter()
