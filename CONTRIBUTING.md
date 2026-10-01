# CONTRIBUTING

## Development

### How to update Python

```console
$ uv python list

cpython-3.14.0a6-linux-x86_64-gnu                 <download available>
cpython-3.14.0a6+freethreaded-linux-x86_64-gnu    <download available>
cpython-3.13.3-linux-x86_64-gnu                   /usr/bin/python3.13
...

$ uv python install 3.13.3

# Edit .python-version & pyproject.toml

$ uv sync
```
