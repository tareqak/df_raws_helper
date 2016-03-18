# df_raws_helper
A utility to take a collection of Dwarf Fortress ZIP archives and layer them
into a git repository

## Dependencies
- `zsh`: for simple string-splitting syntax.
- GNU coreutils: for the `cut`, `date`, and `sort` commands.
- GNU `sed`: for find-and-replace.
- `git`: for version control.
- `unzip` / `zipinfo`: for extracting ZIP archives.

## How to run
`zsh df_raws_helper.zsh`

## License note:
Only the df_raws_helper.zsh is licensed under the AGPL v3.0 - the raws that are
extracted by it have been released to the public domain by Toady One.
