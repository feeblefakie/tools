# HttpBench

HttpBench is a light-weight and easy-to-use HTTP benchmark tool by golang.

## Usage

1.Create a file with a list of URLs formatted as following.

For GET:
```
GET http://{url}:{port}/ 
GET http://{url}:{port}/ 
GET http://{url}:{port}/ 
GET http://{url}:{port}/ 
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

2.Run the command as follows.

```
$ go run httpbench.go -file="/path/to/file-created-above"
```
```
$ go run httpbench.go -file="/path/to/file-created-above" -concurrency=10
```

3.Options

Run "go run httpbench.go" for help.
