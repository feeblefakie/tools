# HttpBench

HttpBench is a light-weight and easy-to-use HTTP benchmark tool by golang.

## Usage

1. Create a file with a list of URLs formatted as follows.

For GET:
```
GET http://{url}:{port}/?{URL_encoded_parameters}
GET http://{url}:{port}/?{URL_encoded_parameters}
GET http://{url}:{port}/?{URL_encoded_parameters} 
GET http://{url}:{port}/?{URL_encoded_parameters} 
...
```

For POST:
```
POST http://{url}:{port}/ {URL_encoded_body_parameters}
POST http://{url}:{port}/ {URL_encoded_body_parameters} 
POST http://{url}:{port}/ {URL_encoded_body_parameters} 
POST http://{url}:{port}/ {URL_encoded_body_parameters} 
...
```

2. Run the command as follows.

```
$ go run httpbench.go -file="/path/to/file-created-as-above"
```
```
$ go run httpbench.go -file="/path/to/file-created-as-above" -concurrency=10
```

3. Help

Run `go run httpbench.go` for help.
