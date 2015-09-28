# External Sort

The objective of external sorting is to sort a dataset that does not fit in memory.
To manage this problem effectively in a reasonable period of time,
this restriction will need to be artificial.

## License

MIT.

## Requirements

-   [Julia](http://julialang.org/)

    Tested with version 0.5.0-dev (262d6babf634181c456868182f972a90240a5863).

## Description

-   `es.jl`

    Contains the implementation of the external sort.

-   `es-test.jl`

    Contains the test for external sort.

-   `helper.jl`

    Contains functions to help at the tests, e.g. create files.

-   `main.jl`

    Command line wrapper for external sort.

## Testing

~~~
$ julia es-test.jl
~~~

## Using

Check `main.jl`.
