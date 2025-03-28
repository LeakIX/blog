# LeakIX blog

## Hugo

The blog is generated with Hugo **extended**. 

## Install Hugo

```sh
$ go install --tags extended github.com/gohugoio/hugo@latest
```

## Develop mode

```sh
$ git submodule init
$ git submodule update
$ hugo server
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
```

## Build static version

Generates a static version in `public`

```sh
$ hugo
Start building sites … 

                   | EN  
-------------------+-----
  Pages            | 68  
  Paginator pages  | 11  
  Non-page files   |  0  
  Static files     | 32  
  Processed images |  0  
  Aliases          | 28  
  Sitemaps         |  1  
  Cleaned          |  0  

Total in 62 ms
```

## Structure

- `content/posts` contains articles
- `static` contains assets to be deployed, mapped to `/`
