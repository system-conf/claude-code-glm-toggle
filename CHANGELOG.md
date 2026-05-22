# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-05-22

### Added

- Initial release.
- Activity bar view with clickable mode-switch items.
- Status bar item with current mode and quick-toggle on click.
- Commands: `glmToggle.toggle`, `glmToggle.on`, `glmToggle.off`, `glmToggle.status`, `glmToggle.refresh`.
- Automatic refresh when `~/.claude/settings.json` is changed externally.
- Configurable `.claude` directory path via `glmToggle.claudeDir` setting.
- CLI helper `glm.bat` for terminal-based toggling (Windows).
- PowerShell scripts for PATH setup and VSIX building.
