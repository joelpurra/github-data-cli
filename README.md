# [github-data-cli](https://joelpurra.com/projects/github-data-cli/): `ghd`

A small set of functionality to retrieve repository data from github, in JSON format.



## Installation

No installation required, as you can execute `ghd` using the full file path from anywhere. For convenience symlink `ghd` to your `PATH`.

```bash
ln -s "$PWD/ghd" "$HOME/bin/ghd"
```



## Usage

Make sure you have loaded relevant github credentials by setting the following environment variables. Get your own credentials by [registering a new github oauth application](https://github.com/settings/applications/new). The values for application name, homepage url, application description, and authorization callback url do not matter for `ghd`; pick your own values.


- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`

Authenticate yourself. If enabled, you will be asked for a 2-factor authentication code.

```bash
ghd authenticate <username>
```

Now execute the main command.

```bash
ghd
```

```text
Usage: ghd <action>
Source folder: .../github-data-cli
Actions available in the source folder:
  authenticate
  contributors
  diff-contributors
  diff-help
  diff-stargazers
  diff
  help
  repositories-help
  repositories-json
  repositories-list
  repositories
  star
  stargazers
  unstar
```



## Notes

- These scripts grew "organically", starting from nothing. The first need was a function for shared credentials, then pagination, then caching, then then then. Don't judge the code style too harshly, unless you have concrete suggestions in the form of a pull request ;)



---



Copyright &copy; 2016, 2017, 2018 [Joel Purra](https://joelpurra.com/). Released under [GNU General Public License version 3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl.html).
