
## GitHub action (file upload)

~~~
# .github/workflows/gruploader.yaml
on:
  release:
    types: [created]

permissions:
    contents: write
    packages: write

jobs:
  release-linux-amd64:
    name: release linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: izhiqiang/gruploader-action@main
      with:
        github_token: ${{ secrets.GH_TOKEN }}
        action: files
        extra_files: 
          README.md
          LICENSE
~~~

## GitHub action (golang upload)

~~~
name: build

on:
  release:
    types: [created]

jobs:
  build-go-binary:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        goos: [linux, windows]
        goarch: [arm64]
        exclude:
          - goarch: arm64
            goos: windows
    steps:
      - uses: actions/checkout@v3
      - uses: izhiqiang/gruploader-action@main
        with:
          github_token: ${{ secrets.GH_TOKEN }} 
          action: golang
          goos: ${{ matrix.goos }}
          goarch: ${{ matrix.goarch }}
          bin_name: "test"
          extra_files: LICENSE  README.md 
~~~

## GitHub action (golangs upload)

~~~
# .github/workflows/gruploader.yaml
on:
  release:
    types: [created]

permissions:
    contents: write
    packages: write

jobs:
  release-linux-amd64:
    name: release linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: izhiqiang/gruploader-action@main
      with:
        github_token: ${{ secrets.GH_TOKEN }}
        action: golangs
        bin_name: test
        extra_files: 
          README.md
          LICENSE
~~~

## GitHub action (node upload)

~~~
# .github/workflows/gruploader.yaml
on:
  release:
    types: [created]

permissions:
    contents: write
    packages: write

jobs:
  release-linux-amd64:
    name: release linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: izhiqiang/gruploader-action@main
      with:
        github_token: ${{ secrets.GH_TOKEN }}
        action: node
        bin_name: web
        extra_files: 
          README.md
          LICENSE
~~~

