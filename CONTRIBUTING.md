# Contributing to MapTac

Bug reports, ideas, translations and pull requests are welcome.

## Issues

Use the issue templates. For bugs, the MapTac version, the loaded mods and the RPT log help the most.

## Pull requests

1. Fork the repository and create a branch from `main`.
2. Set up [HEMTT](https://hemtt.dev) and build the mod, see [Development](README.md#development).
3. Keep the pull request focused on one change; describe what it does and how it was tested.

The code follows [ACE3](https://github.com/acemod/ACE3) and [CBA_A3](https://github.com/CBATeam/CBA_A3)
conventions:

- **CBA_A3 is the only dependency.** Anything for another mod goes into a separate `addons/compat_<mod>` addon with
  `skipWhenMissingDependencies = 1`, using the public functions of the core addons.
- `hemtt check --pedantic` must pass without warnings.
- One function per file (`functions/fnc_<name>.sqf`) with an ACE-style header; CBA macros (`GVAR`, `FUNC`,
  `LSTRING`...), `private` local variables, `params` for arguments.
- Network through CBA events, not `remoteExec`.
- Every text shown to players is in `stringtable.xml`.
- Commit messages: `feat: ...`, `fix: ...`, `chore: ...`, `docs: ...`.

## Translations

UI strings are in `addons/<component>/stringtable.xml`. Fix or add the `<Language>` entries of a key, keep the
placeholders (`%1`, `%2`) as in English and run `hemtt ln sort`.

## License

By contributing, you agree that your contributions are licensed under the [APL-SA](LICENSE) license of the project.
