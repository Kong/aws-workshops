### Hugo Theme Installation
The Hugo Learn Theme is referenced by [git submodule](.gitmodules). To download it, run the following commands:

```

$ git submodule update --init --recursive

$ git submodule update --remote --merge

```

### Hugo Installation

On Mac, use brew to install the Hugo server.

```
$ brew install hugo
```

### Start the Hugo Server for Local Development
Start the Hugo server to view your website. This will render in memory.

```
hugo server
```

### Generate Your Content to Disk
To render your pages to disk (for publishing), you can run your server with the following flag:

```
hugo server --renderToDisk
```

or use the hugo command to perform a one-time generation.

```
hugo
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
