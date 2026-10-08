# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project aims to follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `src/voices.py` to list every available Kokoro voice.
- Double-click launchers for macOS: `generate.command`, `run-all.command`, `render.command`, `render-no-subs.command`.
- New logo (`assets/logo.svg`).
- `docs/NARRATION-PROMPTS.md`: copy-and-paste LLM prompts for drafting narration.
- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, and GitHub issue and pull request templates.

### Changed
- `.command` launchers are now thin wrappers around the scripts in `bin/`.
- README rewritten, with a new "Choosing a voice" section and macOS launcher setup (`chmod +x`, removing the quarantine flag).
