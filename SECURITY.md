# Security Policy

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Use GitHub's private reporting instead: go to the **Security** tab of this repository and choose **Report a vulnerability**. If that isn't available, contact the maintainer through the link on their [GitHub profile](https://github.com/durgeshgowdac).

Include what you found, how to reproduce it, and which macOS and tool versions you used. You can expect an acknowledgement as soon as the maintainer is able to respond; this is a small volunteer project, so please be patient.

## Scope

MLXnarrator runs entirely on your own machine. The things worth reporting include:

- Shell scripts that could execute unintended commands (for example, through unsafe handling of file names)
- Leaking tokens or personal data into the repository or the output files
- Unsafe download instructions

## A note on tokens

If you use a Hugging Face token (see `tests/test_voice.py`), keep it out of git. `.gitignore` blocks common token file names, but the safest option is to use an environment variable. If a token is ever committed, revoke it right away on huggingface.co.
